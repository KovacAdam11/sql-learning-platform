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
