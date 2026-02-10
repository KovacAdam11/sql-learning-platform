-- 002_seed.sql
-- Sample data for SQL Learning Platform

SET NAMES utf8mb4;

-- =========================
-- DEPARTMENTS
-- =========================
INSERT INTO departments (name) VALUES
('Katedra informatiky'),
('Katedra geodézie'),
('Katedra matematiky');

-- =========================
-- TEACHERS
-- =========================
INSERT INTO teachers (name, department_id) VALUES
('Dr. SQL', 1),
('Prof. Databáza', 1),
('Ing. Trigger', 1),
('Doc. Mapovanie', 2);

-- =========================
-- STUDENTS
-- =========================
INSERT INTO students (name, email) VALUES
('Katka Nováková', 'katka@test.com'),
('Adam Kováč', 'adam@test.com'),
('Martin Hraško', 'martin@test.com'),
('Lucia Bieliková', 'lucia@test.com'),
('Peter Svoboda', 'peter@test.com'),
('Jana Horváthová', 'jana@test.com');

-- =========================
-- COURSES
-- =========================
INSERT INTO courses (name, teacher_id) VALUES
('Database Systems I', 2),
('SQL Advanced', 1),
('Backend Basics', 3),
('Geoinformatika – základy', 4);

-- =========================
-- ENROLLMENTS
-- =========================
INSERT INTO enrollments (student_id, course_id, enrollment_date) VALUES
(1, 1, '2024-09-01'),
(2, 1, '2024-09-01'),
(3, 1, '2024-09-01'),
(4, 2, '2024-09-05'),
(5, 2, '2024-09-05'),
(6, 3, '2024-09-10'),
(1, 4, '2024-09-12'),
(2, 4, '2024-09-12');

-- =========================
-- GRADES (tied to enrollments)
-- =========================
-- Enrollment IDs depend on insert order above (AUTO_INCREMENT starting at 1)
INSERT INTO grades (enrollment_id, grade) VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 2),
(5, 3),
(6, 1),
(7, 2),
(8, 1);

-- =========================
-- ASSIGNMENTS (per course)
-- =========================
INSERT INTO assignments (course_id, title, due_date) VALUES
(1, 'SELECT + WHERE + ORDER BY', '2024-10-01'),
(1, 'JOIN: students × enrollments × courses', '2024-10-08'),
(2, 'GROUP BY + HAVING: priemery', '2024-10-15'),
(3, 'INSERT/UPDATE/DELETE basics', '2024-10-20'),
(4, 'GIS dataset query (basic)', '2024-10-25');

-- =========================
-- SUBMISSIONS
-- =========================
INSERT INTO submissions (assignment_id, student_id, submitted_at, score) VALUES
(1, 1, '2024-09-30 18:10:00', 95),
(1, 2, '2024-09-30 19:05:00', 88),
(1, 3, '2024-10-01 08:00:00', 70),

(2, 1, '2024-10-07 16:30:00', 92),
(2, 2, '2024-10-07 20:15:00', 85),

(3, 4, '2024-10-14 12:00:00', 78),
(3, 5, '2024-10-15 09:40:00', 81),

(4, 6, '2024-10-19 22:10:00', 90);

-- =========================
-- ATTENDANCE (mix of 0/1)
-- =========================
INSERT INTO attendance (student_id, course_id, attended, date) VALUES
(1, 1, 1, '2024-09-02'),
(1, 1, 1, '2024-09-09'),
(1, 1, 0, '2024-09-16'),

(2, 1, 1, '2024-09-02'),
(2, 1, 0, '2024-09-09'),
(2, 1, 1, '2024-09-16'),

(4, 2, 1, '2024-09-06'),
(4, 2, 1, '2024-09-13'),
(5, 2, 0, '2024-09-06'),
(5, 2, 1, '2024-09-13'),

(1, 4, 1, '2024-09-13'),
(2, 4, 1, '2024-09-13');
