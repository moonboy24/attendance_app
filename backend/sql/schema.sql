-- Create database if missing
CREATE DATABASE IF NOT EXISTS attendance_app;
USE attendance_app;

-- ---------------- USERS TABLE ----------------
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------- STUDENTS TABLE ----------------
CREATE TABLE IF NOT EXISTS students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ✅ Ensure roll_no column exists in students
SET @col_exists := (
  SELECT COUNT(*) 
  FROM information_schema.COLUMNS 
  WHERE TABLE_SCHEMA = 'attendance_app' 
    AND TABLE_NAME = 'students' 
    AND COLUMN_NAME = 'roll_no'
);

SET @stmt := IF(@col_exists = 0,
  'ALTER TABLE students ADD COLUMN roll_no VARCHAR(50) NOT NULL UNIQUE AFTER name;',
  'SELECT "Column roll_no already exists" as msg;'
);

PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------------- ATTENDANCE TABLE ----------------
CREATE TABLE IF NOT EXISTS attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  date DATE NOT NULL,
  is_present BOOLEAN NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- ✅ Prevent duplicate attendance (same student, same date)
  UNIQUE KEY unique_attendance (student_id, date),
  -- ✅ Foreign key link to students table
  CONSTRAINT fk_attendance_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

-- ✅ Query to fetch clean attendance report (no duplicates, one record per student/date)
-- Run this in cmd when you need the report:
-- SELECT s.name, s.roll_no, a.date,
--   CASE WHEN a.is_present = 1 THEN 'Present' ELSE 'Absent' END AS status
-- FROM attendance a
-- JOIN students s ON a.student_id = s.id
-- GROUP BY s.id, a.date
-- ORDER BY a.date DESC, s.roll_no;
