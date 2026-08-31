import { Router } from 'express';
import * as paymentController from '../controllers/paymentController.js';

const router = Router();

router.get('/config', paymentController.getPaymentConfig);

export default router;
