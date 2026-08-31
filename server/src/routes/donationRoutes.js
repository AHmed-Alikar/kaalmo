import { Router } from 'express';
import * as donationController from '../controllers/donationController.js';
import { requireAuth } from '../middleware/auth.js';

const router = Router();

router.get('/mine', requireAuth, donationController.listMyDonations);

export default router;
