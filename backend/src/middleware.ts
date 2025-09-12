import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';


export interface AuthRequest extends Request { userId?: number }


export function auth(req: AuthRequest, res: Response, next: NextFunction) {
const header = req.headers.authorization;
if (!header) return res.status(401).json({ message: 'Missing Authorization header' });
const token = header.split(' ')[1];
try {
const payload = jwt.verify(token, process.env.JWT_SECRET as string) as { id: number };
req.userId = payload.id;
next();
} catch (e) {
return res.status(401).json({ message: 'Invalid token' });
}
}