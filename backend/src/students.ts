import { Router } from 'express';
import { pool } from './db';
import { auth, AuthRequest } from './middleware';
import { z } from 'zod';


const router = Router();


router.use(auth);


router.get('/', async (req: AuthRequest, res) => {
const [rows] = await pool.query('SELECT id, name, roll_no FROM students WHERE user_id=? ORDER BY created_at DESC', [req.userId]);
// @ts-ignore
res.json(rows);
});


const studentSchema = z.object({ name: z.string().min(1), rollNo: z.string().min(1) });


router.post('/', async (req: AuthRequest, res) => {
const parse = studentSchema.safeParse(req.body);
if (!parse.success) return res.status(400).json({ message: 'Invalid input' });
const { name, rollNo } = parse.data;
await pool.query('INSERT INTO students (user_id, name, roll_no) VALUES (?,?,?)', [req.userId, name, rollNo]);
res.status(201).json({ message: 'Student added' });
});


router.delete('/:id', async (req: AuthRequest, res) => {
await pool.query('DELETE FROM students WHERE id=? AND user_id=?', [req.params.id, req.userId]);
res.json({ message: 'Student deleted' });
});


export default router;