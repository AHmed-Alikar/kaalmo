import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';

import authRoutes from './routes/authRoutes.js';
import userRoutes from './routes/userRoutes.js';
import campaignRoutes from './routes/campaignRoutes.js';
import withdrawalRoutes from './routes/withdrawalRoutes.js';
import adminRoutes from './routes/adminRoutes.js';
import donationRoutes from './routes/donationRoutes.js';
import payoutAccountRoutes from './routes/payoutAccountRoutes.js';
import beneficiaryRoutes from './routes/beneficiaryRoutes.js';
import uploadRoutes from './routes/uploadRoutes.js';
import reportRoutes from './routes/reportRoutes.js';
import notificationRoutes from './routes/notificationRoutes.js';
import campaignInviteRoutes from './routes/campaignInviteRoutes.js';
import supportTicketRoutes from './routes/supportTicketRoutes.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';
import { UPLOAD_DIR } from './middleware/upload.js';

const app = express();

// Cross-origin resource policy relaxed so the client (a different port in
// dev, a different origin in prod) can load uploaded campaign images.
app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(
  cors({
    origin: process.env.CLIENT_ORIGIN?.split(',') || 'http://localhost:5173',
    credentials: true,
  })
);
app.use(express.json({ limit: '2mb' }));
app.use(cookieParser());
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

app.use('/uploads', express.static(UPLOAD_DIR));

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/campaigns', campaignRoutes);
app.use('/api/v1/withdrawals', withdrawalRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/donations', donationRoutes);
app.use('/api/v1/payout-accounts', payoutAccountRoutes);
app.use('/api/v1/beneficiaries', beneficiaryRoutes);
app.use('/api/v1/uploads', uploadRoutes);
app.use('/api/v1/reports', reportRoutes);
app.use('/api/v1/notifications', notificationRoutes);
app.use('/api/v1/campaign-invites', campaignInviteRoutes);
app.use('/api/v1/support-tickets', supportTicketRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

export default app;
