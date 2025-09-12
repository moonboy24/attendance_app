require("dotenv").config();
const mysql = require("mysql2/promise");

const DB_HOST = process.env.DB_HOST;
const DB_USER = process.env.DB_USER;
const DB_PASS = process.env.DB_PASS;
const DB_NAME = process.env.DB_NAME;

const db = mysql.createPool({
  host: "sql208.infinityfree.com",
  user: "if0_39925465",
  password: "Benzenten99",
  database: "if0_39925465_attendance_db",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

module.exports = db;
