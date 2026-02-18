-- 003_exercises.sql
-- Exercise bank + reference solutions (for "Show correct result")
SET NAMES utf8mb4;

-- -----------------------
-- Tables for exercises
-- -----------------------
CREATE TABLE IF NOT EXISTS exercises (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  topic VARCHAR(50) NULL,
  description TEXT NOT NULL,

  difficulty ENUM('easy','medium','hard') NOT NULL,

  -- čo je dovolené spúšťať
  allowed_ops ENUM('select_only','dml','ddl','procedures') 
    NOT NULL DEFAULT 'select_only',

  -- presnejší typ úlohy (dôležité pre UI aj backend)
  exercise_type ENUM(
    'select','dml','ddl','view','procedure','trigger','temp_table'
  ) NOT NULL DEFAULT 'select'

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



CREATE TABLE IF NOT EXISTS exercise_solutions (
  exercise_id INT PRIMARY KEY,

  -- správny SQL kód (čo má user napísať)
  reference_sql LONGTEXT NOT NULL,

  -- čo sa má spustiť na zobrazenie výsledku
  reference_result_sql LONGTEXT NULL,

  -- hinty / vysvetlenie riešenia
  notes TEXT NULL,

  CONSTRAINT fk_solution_exercise
    FOREIGN KEY (exercise_id) REFERENCES exercises(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------
-- 30 EXERCISES
-- (IDs will be 1..30 on fresh init)
-- -----------------------
INSERT INTO exercises (title, description, difficulty, exercise_type) VALUES
-- EASY (1-10)
('Zoznam študentov', 'Vypíš všetkých študentov (id, name, email) zoradených podľa name A→Z.', 'easy', 'select'),
('Zoznam učiteľov', 'Vypíš všetkých učiteľov (id, name).', 'easy', 'select'),
('Zoznam katedier', 'Vypíš všetky katedry (departments).', 'easy', 'select'),
('Zoznam kurzov', 'Vypíš všetky kurzy (id, name).', 'easy', 'select'),
('Kurzy a učitelia', 'Vypíš kurz a meno učiteľa ku každému kurzu (aj keď kurz nemá učiteľa).', 'easy', 'select'),
('Študenti s emailom', 'Vypíš študentov, ktorí majú vyplnený email.', 'easy', 'select'),
('Najdi študenta podľa mena', 'Vypíš riadok študenta, ktorého meno obsahuje reťazec "Katka".', 'easy', 'select'),
('Počet študentov', 'Zisti počet študentov v tabuľke students.', 'easy', 'select'),
('Počet kurzov', 'Zisti počet kurzov v tabuľke courses.', 'easy', 'select'),
('Odovzdané submissions', 'Vypíš všetky submissions (assignment_id, student_id, submitted_at, score) zoradené podľa submitted_at (najnovšie prvé).', 'easy', 'select'),

-- MEDIUM (11-22)
('Študenti a ich kurzy', 'Vypíš meno študenta a názov kurzu, do ktorého je zapísaný.', 'medium', 'select'),
('Počet študentov v každom kurze', 'Pre každý kurz vypíš názov kurzu a počet zapísaných študentov.', 'medium', 'select'),
('Kurzy bez študentov', 'Vypíš kurzy, do ktorých nie je zapísaný žiadny študent.', 'medium', 'select'),
('Študenti bez zápisu', 'Vypíš študentov, ktorí nie sú zapísaní v žiadnom kurze.', 'medium', 'select'),
('Známky študentov', 'Vypíš študenta, kurz a známku (join cez enrollments → grades).', 'medium', 'select'),
('Priemer známok podľa študenta', 'Vypočítaj priemernú známku pre každého študenta (len tí, čo majú známky).', 'medium', 'select'),
('Priemer známok podľa kurzu', 'Vypočítaj priemernú známku pre každý kurz (len kurzy s aspoň jednou známkou).', 'medium', 'select'),
('Učitelia a počet kurzov', 'Vypíš učiteľov a koľko kurzov učia (aj keď 0).', 'medium', 'select'),
('Assignments ku kurzom', 'Vypíš všetky assignments spolu s názvom kurzu.', 'medium', 'select'),
('Počet odovzdaní na assignment', 'Vypíš assignment title a počet odovzdaní (submissions).', 'medium', 'select'),
('Najlepšie skóre na assignment', 'Pre každý assignment vypíš najvyššie score (max), ignoruj NULL.', 'medium', 'select'),
('Dochádzka študenta', 'Vypíš pre každého študenta počet attended=1 a počet attended=0 (dochádzka).', 'medium', 'select'),

-- HARD (23-30)
('Študenti bez odovzdania konkrétneho zadania', 'Vypíš študentov, ktorí neodovzdali assignment s title = "JOIN: students × enrollments × courses".', 'hard', 'select'),
('Študenti s priemerom známok <= 2', 'Vypíš študentov, ktorých priemerná známka je 2 alebo lepšia (<=2).', 'hard', 'select'),
('Kurzy s viac než 1 študentom', 'Vypíš iba tie kurzy, kde je viac než 1 zapísaný študent.', 'hard', 'select'),
('Najlepší študent podľa submissions priemeru', 'Nájdi študenta s najvyšším priemerom score zo submissions (ignoruj NULL).', 'hard', 'select'),
('Top 3 študenti podľa submissions priemeru', 'Vypíš top 3 študentov podľa priemeru score zo submissions (DESC).', 'hard', 'select'),
('Assignments bez jediného odovzdania', 'Vypíš assignments, ktoré nemajú žiadne submissions.', 'hard', 'select'),
('Kurz s najvyšším priemerom submissions', 'Nájdi kurz s najvyšším priemerom score zo submissions (ignoruj NULL).', 'hard', 'select'),
('Dochádzka pod 50% v kurze', 'Vypíš študentov a kurzy, kde percento attended=1 je < 50%.', 'hard', 'select');

-- -----------------------
-- Reference solutions (1..30)
-- -----------------------
INSERT INTO exercise_solutions (exercise_id, reference_sql, notes) VALUES
-- EASY 1-10
(1,  'SELECT id, name, email FROM students ORDER BY name ASC;', 'ORDER BY'),
(2,  'SELECT id, name FROM teachers ORDER BY name ASC;', NULL),
(3,  'SELECT id, name FROM departments ORDER BY name ASC;', NULL),
(4,  'SELECT id, name FROM courses ORDER BY name ASC;', NULL),
(5,  'SELECT c.id, c.name AS course_name, t.name AS teacher_name
      FROM courses c
      LEFT JOIN teachers t ON t.id = c.teacher_id
      ORDER BY c.name;', 'LEFT JOIN aby boli aj kurzy bez učiteľa'),
(6,  'SELECT id, name, email FROM students WHERE email IS NOT NULL ORDER BY name;', NULL),
(7,  'SELECT id, name, email FROM students WHERE name LIKE ''%Katka%'';', 'LIKE'),
(8,  'SELECT COUNT(*) AS student_count FROM students;', NULL),
(9,  'SELECT COUNT(*) AS course_count FROM courses;', NULL),
(10, 'SELECT assignment_id, student_id, submitted_at, score
      FROM submissions
      ORDER BY submitted_at DESC;', NULL),

-- MEDIUM 11-22
(11, 'SELECT s.name AS student_name, c.name AS course_name
      FROM enrollments e
      JOIN students s ON s.id = e.student_id
      JOIN courses  c ON c.id = e.course_id
      ORDER BY s.name, c.name;', 'JOIN cez enrollments'),
(12, 'SELECT c.name AS course_name, COUNT(e.id) AS student_count
      FROM courses c
      LEFT JOIN enrollments e ON e.course_id = c.id
      GROUP BY c.id, c.name
      ORDER BY student_count DESC, c.name;', 'GROUP BY + COUNT'),
(13, 'SELECT c.id, c.name
      FROM courses c
      LEFT JOIN enrollments e ON e.course_id = c.id
      GROUP BY c.id, c.name
      HAVING COUNT(e.id) = 0
      ORDER BY c.name;', 'HAVING COUNT=0'),
(14, 'SELECT s.id, s.name
      FROM students s
      LEFT JOIN enrollments e ON e.student_id = s.id
      GROUP BY s.id, s.name
      HAVING COUNT(e.id) = 0
      ORDER BY s.name;', 'študenti bez enrollments'),
(15, 'SELECT s.name AS student_name, c.name AS course_name, g.grade
      FROM grades g
      JOIN enrollments e ON e.id = g.enrollment_id
      JOIN students s ON s.id = e.student_id
      JOIN courses  c ON c.id = e.course_id
      ORDER BY s.name, c.name;', 'join cez grades → enrollments'),
(16, 'SELECT s.id, s.name, ROUND(AVG(g.grade), 2) AS avg_grade
      FROM students s
      JOIN enrollments e ON e.student_id = s.id
      JOIN grades g ON g.enrollment_id = e.id
      GROUP BY s.id, s.name
      ORDER BY avg_grade ASC, s.name;', 'AVG známok (1 je najlepšie)'),
(17, 'SELECT c.id, c.name, ROUND(AVG(g.grade), 2) AS avg_grade
      FROM courses c
      JOIN enrollments e ON e.course_id = c.id
      JOIN grades g ON g.enrollment_id = e.id
      GROUP BY c.id, c.name
      ORDER BY avg_grade ASC, c.name;', 'priemyer podľa kurzu'),
(18, 'SELECT t.id, t.name, COUNT(c.id) AS courses_count
      FROM teachers t
      LEFT JOIN courses c ON c.teacher_id = t.id
      GROUP BY t.id, t.name
      ORDER BY courses_count DESC, t.name;', 'učitelia aj s 0 kurzami'),
(19, 'SELECT a.id, a.title, a.due_date, c.name AS course_name
      FROM assignments a
      JOIN courses c ON c.id = a.course_id
      ORDER BY c.name, a.due_date;', 'assignments + course'),
(20, 'SELECT a.id, a.title, COUNT(su.id) AS submissions_count
      FROM assignments a
      LEFT JOIN submissions su ON su.assignment_id = a.id
      GROUP BY a.id, a.title
      ORDER BY submissions_count DESC, a.title;', 'počet submissions'),
(21, 'SELECT a.id, a.title, MAX(su.score) AS best_score
      FROM assignments a
      LEFT JOIN submissions su ON su.assignment_id = a.id AND su.score IS NOT NULL
      GROUP BY a.id, a.title
      ORDER BY best_score DESC;', 'MAX + ignoruj NULL'),
(22, 'SELECT s.id, s.name,
            SUM(CASE WHEN att.attended = 1 THEN 1 ELSE 0 END) AS attended_yes,
            SUM(CASE WHEN att.attended = 0 THEN 1 ELSE 0 END) AS attended_no
      FROM students s
      LEFT JOIN attendance att ON att.student_id = s.id
      GROUP BY s.id, s.name
      ORDER BY s.name;', 'CASE WHEN agregácie'),

-- HARD 23-30
(23, 'SELECT s.id, s.name
      FROM students s
      WHERE NOT EXISTS (
        SELECT 1
        FROM submissions su
        JOIN assignments a ON a.id = su.assignment_id
        WHERE a.title = ''JOIN: students × enrollments × courses''
          AND su.student_id = s.id
      )
      ORDER BY s.name;', 'NOT EXISTS'),
(24, 'SELECT s.id, s.name, ROUND(AVG(g.grade), 2) AS avg_grade
      FROM students s
      JOIN enrollments e ON e.student_id = s.id
      JOIN grades g ON g.enrollment_id = e.id
      GROUP BY s.id, s.name
      HAVING AVG(g.grade) <= 2
      ORDER BY avg_grade ASC, s.name;', 'HAVING AVG <= 2'),
(25, 'SELECT c.id, c.name, COUNT(e.id) AS student_count
      FROM courses c
      JOIN enrollments e ON e.course_id = c.id
      GROUP BY c.id, c.name
      HAVING COUNT(e.id) > 1
      ORDER BY student_count DESC, c.name;', 'HAVING COUNT > 1'),
(26, 'SELECT s.id, s.name, ROUND(AVG(su.score), 2) AS avg_score
      FROM students s
      JOIN submissions su ON su.student_id = s.id
      WHERE su.score IS NOT NULL
      GROUP BY s.id, s.name
      ORDER BY avg_score DESC
      LIMIT 1;', 'najvyšší priemer score'),
(27, 'SELECT s.id, s.name, ROUND(AVG(su.score), 2) AS avg_score
      FROM students s
      JOIN submissions su ON su.student_id = s.id
      WHERE su.score IS NOT NULL
      GROUP BY s.id, s.name
      ORDER BY avg_score DESC
      LIMIT 3;', 'TOP 3'),
(28, 'SELECT a.id, a.title
      FROM assignments a
      LEFT JOIN submissions su ON su.assignment_id = a.id
      GROUP BY a.id, a.title
      HAVING COUNT(su.id) = 0
      ORDER BY a.title;', 'assignments bez submissions'),
(29, 'SELECT c.id, c.name, ROUND(AVG(su.score), 2) AS avg_score
      FROM courses c
      JOIN assignments a ON a.course_id = c.id
      JOIN submissions su ON su.assignment_id = a.id
      WHERE su.score IS NOT NULL
      GROUP BY c.id, c.name
      ORDER BY avg_score DESC
      LIMIT 1;', 'kurz s najvyšším priemerom'),
(30, 'SELECT s.id, s.name, c.id AS course_id, c.name AS course_name,
       ROUND(100 * AVG(att.attended = 1), 2) AS attendance_pct
      FROM attendance att
      JOIN students s ON s.id = att.student_id
      JOIN courses  c ON c.id = att.course_id
      GROUP BY s.id, s.name, c.id, c.name
      HAVING AVG(att.attended = 1) < 0.5
      ORDER BY attendance_pct ASC;',NULL);

-- -----------------------
-- EXTRA EXERCISES 31+
-- temp tables, triggers, procedures
-- -----------------------

-- 31-36 TEMP TABLE
INSERT INTO exercises (title, description, difficulty, allowed_ops, exercise_type) VALUES
('Temp: Top študenti podľa priemeru známok', 
 'Vytvor TEMPORARY TABLE tmp_student_avg (student_id, student_name, avg_grade). Naplň ju priemerom známok každého študenta (len tí čo majú známky). Potom vypíš TOP 5 podľa avg_grade (ASC).', 
 'medium', 'ddl', 'temp_table'),

('Temp: Kurzy s počtom študentov', 
 'Vytvor TEMPORARY TABLE tmp_course_counts (course_id, course_name, student_count). Naplň ju počtom zapísaných študentov v kurze (aj 0). Potom vypíš iba kurzy so student_count = 0.', 
 'medium', 'ddl', 'temp_table'),

('Temp: Odovzdania v posledných 14 dňoch', 
 'Vytvor TEMPORARY TABLE tmp_recent_submissions (assignment_id, student_id, submitted_at, score) so submissions za posledných 14 dní. Potom vypíš počet odovzdaní podľa assignment_id.', 
 'medium', 'ddl', 'temp_table'),

('Temp: Rebríček kurzov podľa submissions priemeru', 
 'Vytvor TEMPORARY TABLE tmp_course_avg_score (course_id, course_name, avg_score). Naplň ju priemerom score zo submissions (ignoruj NULL). Potom vypíš kurzy zoradené od najlepšieho priemeru (DESC).', 
 'hard', 'ddl', 'temp_table'),

('Temp: Dochádzka percentá', 
 'Vytvor TEMPORARY TABLE tmp_attendance_pct (student_id, course_id, attendance_pct). Naplň percentom dochádzky attended=1 pre každého študenta v každom kurze. Potom vypíš tie riadky kde attendance_pct < 50%.', 
 'hard', 'ddl', 'temp_table'),

('Temp: Detekcia duplicít emailov', 
 'Vytvor TEMPORARY TABLE tmp_dup_emails (email, cnt). Naplň ju emailami zo students, ktoré sa opakujú (cnt > 1). Vypíš výsledok.', 
 'medium', 'ddl', 'temp_table');


-- 37-41 PROCEDURES
INSERT INTO exercises (title, description, difficulty, allowed_ops, exercise_type) VALUES
('Procedure: Priemer známok študenta', 
 'Vytvor procedúru sp_student_avg_grade(IN p_student_id INT), ktorá vráti (SELECT) student_id, student_name, avg_grade. Avg počítaj z grades cez enrollments. Ak nemá známky, vráť avg_grade = NULL.', 
 'medium', 'procedures', 'procedure'),

('Procedure: Zápis študenta do kurzu', 
 'Vytvor procedúru sp_enroll_student(IN p_student_id INT, IN p_course_id INT), ktorá vloží záznam do enrollments iba ak ešte neexistuje. Ak už existuje, neurobí nič.', 
 'hard', 'procedures', 'procedure'),

('Procedure: Najlepší študent v kurze podľa submissions', 
 'Vytvor procedúru sp_best_student_in_course(IN p_course_id INT), ktorá vráti študenta s najvyšším priemerom score zo submissions v danom kurze (ignoruj NULL).', 
 'hard', 'procedures', 'procedure'),

('Procedure: Report attendance pre kurz', 
 'Vytvor procedúru sp_course_attendance_report(IN p_course_id INT), ktorá vráti pre každého študenta: attended_yes, attended_no, attendance_pct.', 
 'hard', 'procedures', 'procedure'),

('Procedure: Vytvor assignment pre kurz', 
 'Vytvor procedúru sp_create_assignment(IN p_course_id INT, IN p_title VARCHAR(200), IN p_due DATE), ktorá vloží nový assignment (course_id, title, due_date). Potom SELECTne novovytvorený riadok.', 
 'medium', 'procedures', 'procedure');


-- 42-46 TRIGGERS
INSERT INTO exercises (title, description, difficulty, allowed_ops, exercise_type) VALUES
('Trigger: Normalizuj email na lowercase', 
 'Vytvor BEFORE INSERT trigger na students, ktorý nastaví NEW.email = LOWER(NEW.email) (ak email nie je NULL).', 
 'medium', 'ddl', 'trigger'),

('Trigger: Zakáž score mimo 0-100', 
 'Vytvor BEFORE INSERT/UPDATE trigger na submissions, ktorý nedovolí uložiť score < 0 alebo > 100 (ak score nie je NULL). Pri porušení vyhoď SIGNAL.', 
 'hard', 'ddl', 'trigger'),

('Trigger: Nedovoľ známku mimo 1-5', 
 'Vytvor BEFORE INSERT trigger na grades, ktorý nedovolí vložiť grade mimo 1-5. Pri porušení vyhoď SIGNAL.', 
 'medium', 'ddl', 'trigger'),

('Trigger: Automatické submitted_at', 
 'Vytvor BEFORE INSERT trigger na submissions, ktorý ak NEW.submitted_at je NULL, nastaví ho na CURRENT_TIMESTAMP.', 
 'easy', 'ddl', 'trigger'),

('Trigger: Zákaz mazania študentov s enrollments', 
 'Vytvor BEFORE DELETE trigger na students: ak má študent aspoň jeden enrollment, mazanie zakáž (SIGNAL).', 
 'hard', 'ddl', 'trigger');


-- -----------------------
-- Reference solutions (31..46)
-- -----------------------
INSERT INTO exercise_solutions (exercise_id, reference_sql, reference_result_sql, notes) VALUES
(31, 'DROP TEMPORARY TABLE IF EXISTS tmp_student_avg;

CREATE TEMPORARY TABLE tmp_student_avg AS
SELECT s.id AS student_id,
       s.name AS student_name,
       ROUND(AVG(g.grade), 2) AS avg_grade
FROM students s
JOIN enrollments e ON e.student_id = s.id
JOIN grades g ON g.enrollment_id = e.id
GROUP BY s.id, s.name;

SELECT *
FROM tmp_student_avg
ORDER BY avg_grade ASC, student_name ASC
LIMIT 5;', NULL, 'TEMPORARY TABLE + AVG známok'),

(32, 'DROP TEMPORARY TABLE IF EXISTS tmp_course_counts;

CREATE TEMPORARY TABLE tmp_course_counts AS
SELECT c.id AS course_id,
       c.name AS course_name,
       COUNT(e.id) AS student_count
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.id
GROUP BY c.id, c.name;

SELECT *
FROM tmp_course_counts
WHERE student_count = 0
ORDER BY course_name;', NULL, 'Kurzy s 0 študentmi cez temp table'),

(33, 'DROP TEMPORARY TABLE IF EXISTS tmp_recent_submissions;

CREATE TEMPORARY TABLE tmp_recent_submissions AS
SELECT assignment_id,
       student_id,
       submitted_at,
       score
FROM submissions
WHERE submitted_at >= (CURRENT_TIMESTAMP - INTERVAL 14 DAY);

SELECT assignment_id,
       COUNT(*) AS cnt
FROM tmp_recent_submissions
GROUP BY assignment_id
ORDER BY cnt DESC, assignment_id;', NULL, 'Filtrovanie podľa dátumu + agregácia'),

(34, 'DROP TEMPORARY TABLE IF EXISTS tmp_course_avg_score;

CREATE TEMPORARY TABLE tmp_course_avg_score AS
SELECT c.id AS course_id,
       c.name AS course_name,
       ROUND(AVG(su.score), 2) AS avg_score
FROM courses c
JOIN assignments a ON a.course_id = c.id
JOIN submissions su ON su.assignment_id = a.id
WHERE su.score IS NOT NULL
GROUP BY c.id, c.name;

SELECT *
FROM tmp_course_avg_score
ORDER BY avg_score DESC, course_name;', NULL, 'Priemer score per kurz'),

(35, 'DROP TEMPORARY TABLE IF EXISTS tmp_attendance_pct;

CREATE TEMPORARY TABLE tmp_attendance_pct AS
SELECT att.student_id,
       att.course_id,
       ROUND(100 * AVG(att.attended = 1), 2) AS attendance_pct
FROM attendance att
GROUP BY att.student_id, att.course_id;

SELECT t.student_id,
       s.name AS student_name,
       t.course_id,
       c.name AS course_name,
       t.attendance_pct
FROM tmp_attendance_pct t
JOIN students s ON s.id = t.student_id
JOIN courses  c ON c.id = t.course_id
WHERE t.attendance_pct < 50
ORDER BY t.attendance_pct ASC, s.name;', NULL, 'AVG(boolean) trik'),

(36, 'DROP TEMPORARY TABLE IF EXISTS tmp_dup_emails;

CREATE TEMPORARY TABLE tmp_dup_emails AS
SELECT email,
       COUNT(*) AS cnt
FROM students
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;

SELECT *
FROM tmp_dup_emails
ORDER BY cnt DESC, email;', NULL, 'Duplikáty cez GROUP BY + HAVING');

INSERT INTO exercise_solutions (exercise_id, reference_sql, reference_result_sql, notes) VALUES
(37,
'DROP PROCEDURE IF EXISTS sp_student_avg_grade;
DELIMITER $$

CREATE PROCEDURE sp_student_avg_grade(IN p_student_id INT)
BEGIN
  SELECT s.id AS student_id, s.name AS student_name,
         ROUND(AVG(g.grade), 2) AS avg_grade
  FROM students s
  LEFT JOIN enrollments e ON e.student_id = s.id
  LEFT JOIN grades g ON g.enrollment_id = e.id
  WHERE s.id = p_student_id
  GROUP BY s.id, s.name;
END$$

DELIMITER ;',
'CALL sp_student_avg_grade(1);',
'LEFT JOIN aby vrátil aj NULL priemer'),

(38,
'DROP PROCEDURE IF EXISTS sp_enroll_student;
DELIMITER $$

CREATE PROCEDURE sp_enroll_student(IN p_student_id INT, IN p_course_id INT)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM enrollments
    WHERE student_id = p_student_id AND course_id = p_course_id
  ) THEN
    INSERT INTO enrollments (student_id, course_id)
    VALUES (p_student_id, p_course_id);
  END IF;

  SELECT * FROM enrollments
  WHERE student_id = p_student_id AND course_id = p_course_id;
END$$

DELIMITER ;',
'CALL sp_enroll_student(1, 1);',
'IF NOT EXISTS + INSERT'),

(39,
'DROP PROCEDURE IF EXISTS sp_best_student_in_course;
DELIMITER $$

CREATE PROCEDURE sp_best_student_in_course(IN p_course_id INT)
BEGIN
  SELECT s.id, s.name, ROUND(AVG(su.score), 2) AS avg_score
  FROM enrollments e
  JOIN students s ON s.id = e.student_id
  JOIN assignments a ON a.course_id = e.course_id
  JOIN submissions su ON su.assignment_id = a.id AND su.student_id = s.id
  WHERE e.course_id = p_course_id
    AND su.score IS NOT NULL
  GROUP BY s.id, s.name
  ORDER BY avg_score DESC
  LIMIT 1;
END$$

DELIMITER ;',
'CALL sp_best_student_in_course(1);',
'Najlepší podľa priemeru score v kurze'),

(40,
'DROP PROCEDURE IF EXISTS sp_course_attendance_report;
DELIMITER $$

CREATE PROCEDURE sp_course_attendance_report(IN p_course_id INT)
BEGIN
  SELECT s.id AS student_id, s.name AS student_name,
         SUM(CASE WHEN att.attended = 1 THEN 1 ELSE 0 END) AS attended_yes,
         SUM(CASE WHEN att.attended = 0 THEN 1 ELSE 0 END) AS attended_no,
         ROUND(100 * AVG(att.attended = 1), 2) AS attendance_pct
  FROM students s
  JOIN attendance att ON att.student_id = s.id
  WHERE att.course_id = p_course_id
  GROUP BY s.id, s.name
  ORDER BY attendance_pct DESC, s.name;
END$$

DELIMITER ;',
'CALL sp_course_attendance_report(1);',
'Report dochádzky pre kurz'),

(41,
'DROP PROCEDURE IF EXISTS sp_create_assignment;
DELIMITER $$

CREATE PROCEDURE sp_create_assignment(
  IN p_course_id INT,
  IN p_title VARCHAR(200),
  IN p_due DATE
)
BEGIN
  INSERT INTO assignments (course_id, title, due_date)
  VALUES (p_course_id, p_title, p_due);

  SELECT * FROM assignments WHERE id = LAST_INSERT_ID();
END$$

DELIMITER ;',
'CALL sp_create_assignment(1, ''New assignment'', CURRENT_DATE + INTERVAL 7 DAY);',
'Insert + LAST_INSERT_ID()');

INSERT INTO exercise_solutions (exercise_id, reference_sql, reference_result_sql, notes) VALUES
(42,
'DROP TRIGGER IF EXISTS trg_students_email_lower_ins;
DELIMITER $$

CREATE TRIGGER trg_students_email_lower_ins
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
  IF NEW.email IS NOT NULL THEN
    SET NEW.email = LOWER(NEW.email);
  END IF;
END$$

DELIMITER ;',
'-- Otestuj: INSERT INTO students(name,email) VALUES (''Test'', ''TeSt@Example.COM'');',
'Lowercase email pri INSERT'),

(43,
'DROP TRIGGER IF EXISTS trg_submissions_score_range_ins;
DROP TRIGGER IF EXISTS trg_submissions_score_range_upd;
DELIMITER $$

CREATE TRIGGER trg_submissions_score_range_ins
BEFORE INSERT ON submissions
FOR EACH ROW
BEGIN
  IF NEW.score IS NOT NULL AND (NEW.score < 0 OR NEW.score > 100) THEN
    SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''Score must be between 0 and 100'';
  END IF;
END$$

CREATE TRIGGER trg_submissions_score_range_upd
BEFORE UPDATE ON submissions
FOR EACH ROW
BEGIN
  IF NEW.score IS NOT NULL AND (NEW.score < 0 OR NEW.score > 100) THEN
    SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''Score must be between 0 and 100'';
  END IF;
END$$

DELIMITER ;',
'-- Otestuj: UPDATE submissions SET score=999 WHERE id=1;',
'Dva triggery (INSERT aj UPDATE)'),

(44,
'DROP TRIGGER IF EXISTS trg_grades_grade_range_ins;
DELIMITER $$

CREATE TRIGGER trg_grades_grade_range_ins
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN
  IF NEW.grade < 1 OR NEW.grade > 5 THEN
    SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''Grade must be between 1 and 5'';
  END IF;
END$$

DELIMITER ;',
'-- Otestuj: INSERT INTO grades(enrollment_id, grade) VALUES (1, 7);',
'Validácia rozsahu známok'),

(45,
'DROP TRIGGER IF EXISTS trg_submissions_set_submitted_at;
DELIMITER $$

CREATE TRIGGER trg_submissions_set_submitted_at
BEFORE INSERT ON submissions
FOR EACH ROW
BEGIN
  IF NEW.submitted_at IS NULL THEN
    SET NEW.submitted_at = CURRENT_TIMESTAMP;
  END IF;
END$$

DELIMITER ;',
'-- Otestuj: INSERT INTO submissions(assignment_id, student_id, score) VALUES (1,1,50);',
'Auto timestamp'),

(46,
'DROP TRIGGER IF EXISTS trg_students_block_delete_if_enrolled;
DELIMITER $$

CREATE TRIGGER trg_students_block_delete_if_enrolled
BEFORE DELETE ON students
FOR EACH ROW
BEGIN
  IF EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = OLD.id) THEN
    SIGNAL SQLSTATE ''45000'' SET MESSAGE_TEXT = ''Cannot delete student with enrollments'';
  END IF;
END$$

DELIMITER ;',
'-- Otestuj: DELETE FROM students WHERE id=1;',
'Zákaz delete pri existujúcich enrollments');
