-- 001_schema.sql
-- Schema for SQL Learning Platform (MariaDB/MySQL)
-- Recommended engine/charset for MariaDB
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Drop in safe order (children -> parents)
DROP TABLE IF EXISTS submissions;
DROP TABLE IF EXISTS assignments;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS teachers;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS students;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================
-- CORE TABLES
-- =========================

CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department_id INT NULL,
    CONSTRAINT fk_teachers_department
      FOREIGN KEY (department_id) REFERENCES departments(id)
      ON UPDATE CASCADE
      ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    teacher_id INT NULL,
    CONSTRAINT fk_courses_teacher
      FOREIGN KEY (teacher_id) REFERENCES teachers(id)
      ON UPDATE CASCADE
      ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    CONSTRAINT fk_enrollments_student
      FOREIGN KEY (student_id) REFERENCES students(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
    CONSTRAINT fk_enrollments_course
      FOREIGN KEY (course_id) REFERENCES courses(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
    CONSTRAINT uq_enrollment UNIQUE (student_id, course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE grades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    grade INT NOT NULL,
    CONSTRAINT fk_grades_enrollment
      FOREIGN KEY (enrollment_id) REFERENCES enrollments(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
    CONSTRAINT chk_grade_range CHECK (grade BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- EXTENSIONS (for harder SQL)
-- =========================

CREATE TABLE assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    due_date DATE NOT NULL,
    CONSTRAINT fk_assignments_course
      FOREIGN KEY (course_id) REFERENCES courses(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    student_id INT NOT NULL,
    submitted_at DATETIME NOT NULL,
    score INT NULL,
    CONSTRAINT fk_submissions_assignment
      FOREIGN KEY (assignment_id) REFERENCES assignments(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
    CONSTRAINT fk_submissions_student
      FOREIGN KEY (student_id) REFERENCES students(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
    CONSTRAINT chk_score_range CHECK (score IS NULL OR (score BETWEEN 0 AND 100)),
    CONSTRAINT uq_submission UNIQUE (assignment_id, student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    attended TINYINT(1) NOT NULL,     -- 0/1 (boolean)
    date DATE NOT NULL,
    CONSTRAINT fk_attendance_student
      FOREIGN KEY (student_id) REFERENCES students(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
    CONSTRAINT fk_attendance_course
      FOREIGN KEY (course_id) REFERENCES courses(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
    CONSTRAINT uq_attendance UNIQUE (student_id, course_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
