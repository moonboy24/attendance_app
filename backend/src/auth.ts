import { Router } from 'express';
import { pool } from './db';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { z } from 'zod';


const router = Router();


const creds = z.object({ email: z.string().email(), password: z.string().min(6) });


router.post('/signup', async (req, res) => {
const parse = creds.safeParse(req.body);
if (!parse.success) return res.status(400).json({ message: 'Invalid input' });
const { email, password } = parse.data;
const [rows] = await pool.query('SELECT id FROM users WHERE email=?', [email]);
// @ts-ignore
if (rows.length) return res.status(409).json({ message: 'Email already registered' });
const hash = await bcrypt.hash(password, 10);
await pool.query('INSERT INTO users (email, password_hash) VALUES (?,?)', [email, hash]);
const [rows2]: any = await pool.query('SELECT id FROM users WHERE email=?', [email]);
const token = jwt.sign({ id: rows2[0].id }, process.env.JWT_SECRET as string, { expiresIn: '7d' });
res.json({ token });
});


router.post('/login', async (req, res) => {
const parse = creds.safeParse(req.body);
if (!parse.success) return res.status(400).json({ message: 'Invalid input' });
const { email, password } = parse.data;
const [rows]: any = await pool.query('SELECT id, password_hash FROM users WHERE email=?', [email]);
if (!rows.length) return res.status(401).json({ message: 'Invalid credentials' });
const match = await bcrypt.compare(password, rows[0].password_hash);
if (!match) return res.status(401).json({ message: 'Invalid credentials' });
const token = jwt.sign({ id: rows[0].id }, process.env.JWT_SECRET as string, { expiresIn: '7d' });
res.json({ token });
});


export default router;