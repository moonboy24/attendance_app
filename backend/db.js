require("dotenv").config();
const mysql = require("mysql2/promise");

// ✅ Create a connection pool
const db = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  ssl: {
    rejectUnauthorized: true, // Railway requires SSL
  },
});

// ✅ Test connection
(async () => {
  try {
    const connection = await db.getConnection();
    console.log("✅ Connected to Railway MySQL Database");
    connection.release();
  } catch (err) {
    console.error("❌ DB Connection Failed:", err.message);
  }
})();

module.exports = db;
