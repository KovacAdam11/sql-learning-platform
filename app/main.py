import os
import re
import uuid
from typing import Any

from fastapi import FastAPI, Request, Form, Query, Response
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from typing import Any

import mysql.connector

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

DB_HOST = os.getenv("DB_HOST", "mariadb")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_USER = os.getenv("DB_USER", "student")
DB_PASSWORD = os.getenv("DB_PASSWORD", "student")

TEMPLATE_DB = os.getenv("TEMPLATE_DB", "sql_training")  # dataset/template DB

# ----------------------------
# DB helpers
# ----------------------------
def conn_server():
    """Connect without specifying database (for CREATE DATABASE, etc.)."""
    return mysql.connector.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        autocommit=True,
        use_pure=True
    )

def conn_db(dbname: str):
    return mysql.connector.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=dbname,
        autocommit=True,
        use_pure=True
    )

def ensure_session_id(request: Request) -> str:
    sid = request.cookies.get("sid")
    if not sid:
        sid = uuid.uuid4().hex
    return sid

def sandbox_db_name(sid: str) -> str:
    safe = re.sub(r"[^a-zA-Z0-9_]", "", sid)
    return f"sql_sandbox_{safe}"

def clone_template_to_sandbox(sandbox_db: str):
    """
    Create sandbox DB and copy schema+data from TEMPLATE_DB.
    Simple and reliable approach:
      - CREATE DATABASE
      - For each table in TEMPLATE_DB: CREATE TABLE LIKE + INSERT SELECT
    """
    sconn = conn_server()
    cur = sconn.cursor()

    # Drop and recreate sandbox
    cur.execute(f"DROP DATABASE IF EXISTS `{sandbox_db}`;")
    cur.execute(f"CREATE DATABASE `{sandbox_db}` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;")

    # list tables in template
    tconn = conn_db(TEMPLATE_DB)
    tcur = tconn.cursor()

    tcur.execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE';")
    tables = [row[0] for row in tcur.fetchall()]

    for tbl in tables:
        # create table structure
        cur.execute(f"CREATE TABLE `{sandbox_db}`.`{tbl}` LIKE `{TEMPLATE_DB}`.`{tbl}`;")
        # copy data
        cur.execute(f"INSERT INTO `{sandbox_db}`.`{tbl}` SELECT * FROM `{TEMPLATE_DB}`.`{tbl}`;")

    # also copy views (optional). simplest: recreate via SHOW CREATE VIEW
    tcur.execute("SHOW FULL TABLES WHERE Table_type = 'VIEW';")
    views = [row[0] for row in tcur.fetchall()]
    for vw in views:
        tcur.execute(f"SHOW CREATE VIEW `{TEMPLATE_DB}`.`{vw}`;")
        _, create_sql = tcur.fetchone()
        # SHOW CREATE VIEW contains `TEMPLATE_DB` names; replace with sandbox_db
        create_sql = create_sql.replace(f"`{TEMPLATE_DB}`.", f"`{sandbox_db}`.")
        cur.execute(create_sql)

    tconn.close()
    sconn.close()

def get_exercise(exercise_id: int) -> dict[str, Any] | None:
    conn = conn_db(TEMPLATE_DB)
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM exercises WHERE id=%s", (exercise_id,))
    ex = cur.fetchone()
    conn.close()
    return ex

def get_solution(exercise_id: int) -> dict[str, Any] | None:
    conn = conn_db(TEMPLATE_DB)
    cur = conn.cursor(dictionary=True)
    cur.execute(
        "SELECT reference_sql, reference_result_sql, notes FROM exercise_solutions WHERE exercise_id=%s",
        (exercise_id,),
    )
    sol = cur.fetchone()
    conn.close()
    return sol

def is_allowed_sql(sql: str, allowed_ops: str) -> tuple[bool, str]:
    """
    Basic safety gate. Since we run in per-session sandbox, we can allow more.
    Still block dangerous server-wide commands.
    """
    s = sql.strip().lower()
    if not s:
        return False, "Empty SQL."

    # block server-level destructive stuff even in sandbox
    forbidden = ["shutdown", "create user", "drop user", "grant ", "revoke ", "set global", "flush ", "load data", "outfile", "infile"]
    if any(f in s for f in forbidden):
        return False, "This operation is not allowed."

    if allowed_ops == "select_only":
        # allow SELECT + SHOW/DESCRIBE/EXPLAIN
        ok = s.startswith("select") or s.startswith("show") or s.startswith("describe") or s.startswith("explain")
        return (ok, "Only SELECT/SHOW/DESCRIBE/EXPLAIN are allowed for this exercise.")
    if allowed_ops in ("dml", "ddl", "procedures"):
        # allow almost anything in sandbox
        return True, ""
    return False, "Unknown allowed_ops."

def _split_sql_with_delimiters(sql: str) -> list[str]:
    """
    Split SQL into statements respecting:
      - DELIMITER directives (client-side)
      - quotes (' " `)
      - line comments (--, #)
      - block comments (/* */)

    Default delimiter is ';'.
    Example supported input:

      DELIMITER $$
      CREATE PROCEDURE p()
      BEGIN
        SELECT 1;
      END$$
      DELIMITER ;
      CALL p();
    """
    sql = sql.replace("\r\n", "\n").replace("\r", "\n")

    statements: list[str] = []
    delimiter = ";"

    buff: list[str] = []

    in_single = False
    in_double = False
    in_backtick = False
    in_line_comment = False
    in_block_comment = False

    i = 0
    while i < len(sql):
        ch = sql[i]
        nxt = sql[i + 1] if i + 1 < len(sql) else ""

        # Detect DELIMITER directive ONLY when we're at start of a line (ignoring whitespace)
        # and not inside quotes/comments.
        if not (in_single or in_double or in_backtick or in_line_comment or in_block_comment):
            # Look back to find start of line
            line_start = sql.rfind("\n", 0, i) + 1
            prefix = sql[line_start:i]
            if prefix.strip() == "":
                # Try match DELIMITER <token>
                m = re.match(r"(?i)DELIMITER\s+(\S+)", sql[i:])  # case-insensitive
                if m:
                    # flush any pending buffer as a statement (rare but safe)
                    pending = "".join(buff).strip()
                    if pending:
                        statements.append(pending)
                    buff = []

                    delimiter = m.group(1)
                    # advance to end of this line
                    endline = sql.find("\n", i)
                    if endline == -1:
                        # end of file
                        return statements
                    i = endline + 1
                    continue

        # Handle comments
        if not (in_single or in_double or in_backtick or in_block_comment) and not in_line_comment:
            if ch == "-" and nxt == "-":
                # MySQL treats -- as comment if followed by space or control; we'll accept anyway
                in_line_comment = True
            elif ch == "#":
                in_line_comment = True
            elif ch == "/" and nxt == "*":
                in_block_comment = True

        if in_line_comment:
            buff.append(ch)
            if ch == "\n":
                in_line_comment = False
            i += 1
            continue

        if in_block_comment:
            buff.append(ch)
            if ch == "*" and nxt == "/":
                buff.append(nxt)
                i += 2
                in_block_comment = False
                continue
            i += 1
            continue

        # Handle quotes (ignore escaped quotes)
        if ch == "'" and not (in_double or in_backtick):
            if i > 0 and sql[i - 1] == "\\":
                buff.append(ch)
            else:
                in_single = not in_single
                buff.append(ch)
            i += 1
            continue

        if ch == '"' and not (in_single or in_backtick):
            if i > 0 and sql[i - 1] == "\\":
                buff.append(ch)
            else:
                in_double = not in_double
                buff.append(ch)
            i += 1
            continue

        if ch == "`" and not (in_single or in_double):
            in_backtick = not in_backtick
            buff.append(ch)
            i += 1
            continue

        # Split when we hit the current delimiter (and not inside quotes/comments)
        if not (in_single or in_double or in_backtick):
            if delimiter and sql.startswith(delimiter, i):
                stmt = "".join(buff).strip()
                if stmt:
                    statements.append(stmt)
                buff = []
                i += len(delimiter)
                continue

        buff.append(ch)
        i += 1

    last = "".join(buff).strip()
    if last:
        statements.append(last)

    return [s for s in statements if s.strip()]


def run_sql_in_sandbox(sandbox_db: str, sql: str) -> tuple[list[dict[str, Any]] | None, str | None]:
    """
    Executes SQL that can include:
      - SELECT
      - DML/DDL
      - TEMP TABLES
      - VIEWS
      - PROCEDURES
      - TRIGGERS
    Supports DELIMITER directives.

    Returns rows from the LAST statement that produced rows (SELECT / CALL that returns rows).
    """
    conn = conn_db(sandbox_db)
    cur = conn.cursor(dictionary=True)

    rows = None
    try:
        statements = _split_sql_with_delimiters(sql)
        if not statements:
            conn.close()
            return None, "Empty SQL."

        for stmt in statements:
            if not stmt.strip():
                continue

            cur.execute(stmt)

            # capture last result set if present
            if getattr(cur, "with_rows", False):
                rows = cur.fetchall()

        conn.close()
        return rows, None

    except Exception as e:
        conn.close()
        return None, str(e)

# ----------------------------
# Routes
# ----------------------------

@app.get("/", response_class=HTMLResponse)
def home(
    request: Request,
    difficulty: str | None = Query(default=None),
    ex_type: str | None = Query(default=None),
    topic: str | None = Query(default=None),
):
    conn = conn_db(TEMPLATE_DB)
    cursor = conn.cursor(dictionary=True)

    where = []
    params = []

    if difficulty:
        where.append("difficulty = %s")
        params.append(difficulty)

    if ex_type:
        where.append("exercise_type = %s")
        params.append(ex_type)

    if topic:
        where.append("topic = %s")
        params.append(topic)

    sql = "SELECT * FROM exercises"
    if where:
        sql += " WHERE " + " AND ".join(where)
    sql += " ORDER BY FIELD(difficulty, 'easy','medium','hard'), id"

    cursor.execute(sql, params)
    exercises = cursor.fetchall()

    cursor.execute("SELECT DISTINCT difficulty FROM exercises ORDER BY FIELD(difficulty,'easy','medium','hard')")
    difficulties = [r["difficulty"] for r in cursor.fetchall()]

    cursor.execute("SELECT DISTINCT exercise_type FROM exercises ORDER BY exercise_type")
    types = [r["exercise_type"] for r in cursor.fetchall()]

    topics = []
    try:
        cursor.execute("SELECT DISTINCT topic FROM exercises WHERE topic IS NOT NULL ORDER BY topic")
        topics = [r["topic"] for r in cursor.fetchall()]
    except Exception:
        topics = []

    conn.close()

    resp = templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "exercises": exercises,
            "difficulties": difficulties,
            "types": types,
            "topics": topics,
            "selected": {"difficulty": difficulty, "ex_type": ex_type, "topic": topic},
        },
    )

    # ensure sid cookie exists
    sid = ensure_session_id(request)
    resp.set_cookie("sid", sid, httponly=True, samesite="lax")
    return resp


@app.get("/exercise/{exercise_id}", response_class=HTMLResponse)
def exercise_page(request: Request, exercise_id: int):
    sid = ensure_session_id(request)
    sdb = sandbox_db_name(sid)

    # create sandbox if missing
    sconn = conn_server()
    scur = sconn.cursor()
    scur.execute("SHOW DATABASES LIKE %s", (sdb,))
    exists = scur.fetchone() is not None
    sconn.close()

    if not exists:
        clone_template_to_sandbox(sdb)

    ex = get_exercise(exercise_id)
    sol = get_solution(exercise_id)

    resp = templates.TemplateResponse(
        "exercise.html",
        {
            "request": request,
            "exercise": ex,
            "solution": sol,
            "result_rows": None,
            "error": None,
            "shown_code": None,
        },
    )
    resp.set_cookie("sid", sid, httponly=True, samesite="lax")
    return resp


@app.post("/run", response_class=HTMLResponse)
def run_sql(
    request: Request,
    exercise_id: int = Form(...),
    query: str = Form(...),
):
    sid = ensure_session_id(request)
    sdb = sandbox_db_name(sid)

    ex = get_exercise(exercise_id)
    sol = get_solution(exercise_id)

    # safety + allowed ops per exercise
    allowed_ops = (ex or {}).get("allowed_ops", "select_only")
    ok, msg = is_allowed_sql(query, allowed_ops)
    if not ok:
        resp = templates.TemplateResponse(
            "exercise.html",
            {
                "request": request,
                "exercise": ex,
                "solution": sol,
                "result_rows": None,
                "error": msg,
                "shown_code": None,
            },
        )
        resp.set_cookie("sid", sid, httponly=True, samesite="lax")
        return resp

    rows, err = run_sql_in_sandbox(sdb, query)

    resp = templates.TemplateResponse(
        "exercise.html",
        {
            "request": request,
            "exercise": ex,
            "solution": sol,
            "result_rows": rows,
            "error": err,
            "shown_code": None,
        },
    )
    resp.set_cookie("sid", sid, httponly=True, samesite="lax")
    return resp


@app.get("/code/{exercise_id}", response_class=HTMLResponse)
def show_correct_code(request: Request, exercise_id: int):
    sid = ensure_session_id(request)
    sdb = sandbox_db_name(sid)

    ex = get_exercise(exercise_id)
    sol = get_solution(exercise_id)

    resp = templates.TemplateResponse(
        "exercise.html",
        {
            "request": request,
            "exercise": ex,
            "solution": sol,
            "result_rows": None,
            "error": None,
            "shown_code": (sol or {}).get("reference_sql"),
        },
    )
    resp.set_cookie("sid", sid, httponly=True, samesite="lax")
    return resp


@app.get("/solution/{exercise_id}", response_class=HTMLResponse)
def show_correct_result(request: Request, exercise_id: int):
    sid = ensure_session_id(request)
    sdb = sandbox_db_name(sid)

    ex = get_exercise(exercise_id)
    sol = get_solution(exercise_id)

    if not sol:
        rows, err = None, "No solution found for this exercise."
    else:
        # run reference_sql first (so procedures/temp tables/views can be created)
        rows, err = run_sql_in_sandbox(sdb, sol["reference_sql"])

        # if a separate result sql exists, run it to show output
        if not err and sol.get("reference_result_sql"):
            rows, err = run_sql_in_sandbox(sdb, sol["reference_result_sql"])

    resp = templates.TemplateResponse(
        "exercise.html",
        {
            "request": request,
            "exercise": ex,
            "solution": sol,
            "result_rows": rows,
            "error": err,
            "shown_code": None,
        },
    )
    resp.set_cookie("sid", sid, httponly=True, samesite="lax")
    return resp


@app.post("/reset", response_class=HTMLResponse)
def reset_sandbox(request: Request, exercise_id: int = Form(...)):
    sid = ensure_session_id(request)
    sdb = sandbox_db_name(sid)
    clone_template_to_sandbox(sdb)
    return RedirectResponse(url=f"/exercise/{exercise_id}", status_code=303)
