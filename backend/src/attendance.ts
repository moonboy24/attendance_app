import { Router } from 'express';
import { pool } from './db';
import { auth, AuthRequest } from './middleware';
import { z } from 'zod';


const router = Router();
router.use(auth);


router.get('/', async (req: AuthRequest, res) => {
const date = req.query.date as string | undefined;
if (!date) return res.status(400).json({ message: 'date query param required YYYY-MM-DD' });
const [rows]: any = await pool.query(
`SELECT a.id, a.student_id, s.name, s.roll_no, a.status, a.date
FROM attendance a JOIN students s ON s.id=a.student_id
WHERE a.user_id=? AND a.date=? ORDER BY s.roll_no`, [req.userId, date]
);
res.json(rows);
});


const markSchema = z.object({
date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
records: z.array(z.object({ studentId: z.number(), status: z.enum(['present','absent']) }))
});


router.post('/mark', async (req: AuthRequest, res) => {
const parse = markSchema.safeParse(req.body);
if (!parse.success) return res.status(400).json({ message: 'Invalid payload' });
const { date, records } = parse.data;
const conn = await pool.getConnection();
try {
await conn.beginTransaction();
for (const r of records) {
await conn.query(
`INSERT INTO attendance (user_id, student_id, date, status)
VALUES (?,?,?,?)
ON DUPLICATE KEY UPDATE status=VALUES(status)`,
[req.userId, r.studentId, date, r.status]
);
}
await conn.commit();
res.json({ message: 'Attendance saved' });
} catch (e) {
await conn.rollback();
res.status(500).json({ message: 'Failed to save attendance' });
} finally {
conn.release();
}
});


export default router;