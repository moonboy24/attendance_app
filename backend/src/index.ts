import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './auth';
import studentRoutes from './students';
import attendanceRoutes from './attendance';


dotenv.config();


const app = express();
app.use(cors());
app.use(express.json());


app.get('/', (_req, res) => res.json({ ok: true }));
app.use('/auth', authRoutes);
app.use('/students', studentRoutes);
app.use('/attendance', attendanceRoutes);


const port = Number(process.env.PORT || 3000);
app.listen(port, () => console.log(`API running on http://localhost:${port}`));