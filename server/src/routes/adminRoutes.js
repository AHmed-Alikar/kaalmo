import { Router } from 'express';
import * as adminController from '../controllers/adminController.js';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/rbac.js';
import { validate } from '../middleware/validate.js';
import { z } from 'zod';
import { reviewCampaignSchema, confirmPaymentSchema, confirmPaymentsBatchSchema } from '../validators/adminValidators.js';
import { reviewReportSchema } from '../validators/reportValidators.js';
import * as reportController from '../controllers/reportController.js';
import * as supportTicketController from '../controllers/supportTicketController.js';
import { replyTicketSchema, updateTicketStatusSchema } from '../validators/supportTicketValidators.js';

const reviewBeneficiarySchema = z.object({ status: z.enum(['verified', 'rejected']) });
const updateUserStatusSchema = z.object({ status: z.enum(['active', 'suspended', 'banned']) });

const router = Router();

router.use(requireAuth, requireRole('admin'));

router.get('/campaigns', adminController.listAllCampaigns);
router.patch('/campaigns/:id/review', validate(reviewCampaignSchema), adminController.reviewCampaign);
router.get('/donations', adminController.listDonations);
router.post('/payments/:paymentId/confirm', validate(confirmPaymentSchema), adminController.confirmManualPayment);
router.post('/payments/confirm-batch', validate(confirmPaymentsBatchSchema), adminController.confirmManualPaymentsBatch);

router.get('/beneficiaries', adminController.listBeneficiaries);
router.patch('/beneficiaries/:id/review', validate(reviewBeneficiarySchema), adminController.reviewBeneficiary);

router.get('/users', adminController.listUsers);
router.patch('/users/:id/status', validate(updateUserStatusSchema), adminController.updateUserStatus);

router.get('/audit-logs', adminController.listAuditLogs);

router.get('/reports', reportController.listReports);
router.patch('/reports/:id/review', validate(reviewReportSchema), reportController.reviewReport);

router.get('/support-tickets', supportTicketController.listSupportTickets);
router.get('/support-tickets/:id', supportTicketController.getSupportTicket);
router.post('/support-tickets/:id/replies', validate(replyTicketSchema), supportTicketController.replyToSupportTicket);
router.patch('/support-tickets/:id', validate(updateTicketStatusSchema), supportTicketController.updateSupportTicketStatus);

router.get('/fraud-signals', adminController.listFraudSignals);

export default router;
