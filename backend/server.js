require("dotenv").config();
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("./db");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// ✅ Root route
app.get("/", (req, res) => {
  res.send("✅ Attendance App Backend is running!");
});

// ------------------- AUTH ROUTES -------------------

// Signup
app.post("/auth/signup", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: "Missing fields" });

  try {
    const [rows] = await db.query("SELECT id FROM users WHERE email = ?", [email]);
    if (rows.length > 0) return res.status(400).json({ error: "Email already registered" });

    const hashed = await bcrypt.hash(password, 10);
    await db.query("INSERT INTO users (email, password) VALUES (?, ?)", [email, hashed]);
    res.json({ message: "User created successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Signup failed", details: err.message });
  }
});

// Login
app.post("/auth/login", async (req, res) => {
  const { email, password } = req.body;
  try {
    const [rows] = await db.query("SELECT * FROM users WHERE email = ?", [email]);
    if (rows.length === 0) return res.status(401).json({ error: "Invalid email or password" });

    const user = rows[0];
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) return res.status(401).json({ error: "Invalid email or password" });

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: "1d" });
    res.json({ token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Login failed" });
  }
});

// ------------------- STUDENTS ROUTES -------------------

// Add student
app.post("/students", async (req, res) => {
  const { name, roll_no } = req.body;
  if (!name || !roll_no) return res.status(400).json({ error: "Missing fields" });

  try {
    await db.query("INSERT INTO students (name, roll_no) VALUES (?, ?)", [name, roll_no]);
    res.json({ message: "Student added successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to add student" });
  }
});

// Get all students
app.get("/students", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM students");
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch students" });
  }
});

// Delete student and related attendance
app.delete("/students/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await db.query("DELETE FROM attendance WHERE student_id = ?", [id]);
    await db.query("DELETE FROM students WHERE id = ?", [id]);
    res.json({ message: "Student and related attendance deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to delete student" });
  }
});

// ------------------- ATTENDANCE ROUTES -------------------

// Get attendance for a specific date
app.get("/attendance", async (req, res) => {
  const { date } = req.query;
  try {
    const [rows] = await db.query(
      `SELECT a.id, a.student_id, s.name, s.roll_no, a.date, a.is_present
       FROM attendance a
       JOIN students s ON a.student_id = s.id
       WHERE a.date = ?`,
      [date]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch attendance" });
  }
});

// Mark attendance (insert or update)
app.post("/attendance/mark", async (req, res) => {
  try {
    const records = Array.isArray(req.body) ? req.body : [req.body];
    for (const r of records) {
      if (!r.student_id || !r.date || typeof r.is_present === "undefined") {
        return res.status(400).json({ error: "student_id, date, and is_present are required" });
      }

      await db.query(
        `INSERT INTO attendance (student_id, date, is_present)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE is_present = VALUES(is_present)`,
        [r.student_id, r.date, r.is_present]
      );
    }
    res.json({ message: "Attendance marked successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to mark attendance" });
  }
});

// Attendance report
app.get("/attendance/report", async (req, res) => {
  const { startDate, endDate } = req.query;
  try {
    let query = `
      SELECT s.name, s.roll_no, a.date, a.is_present
      FROM attendance a
      JOIN students s ON a.student_id = s.id
    `;
    let params = [];

    if (startDate && endDate) {
      query += " WHERE a.date BETWEEN ? AND ?";
      params = [startDate, endDate];
    }

    query += " ORDER BY a.date DESC";

    const [rows] = await db.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch attendance report" });
  }
});

// ------------------- SERVER START -------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
