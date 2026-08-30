import { Router } from 'express';
import * as supportTicketController from '../controllers/supportTicketController.js';
import { requireAuth, optionalAuth } from '../middleware/auth.js';
import { validate } from '../middleware/validate.js';
import { createTicketSchema, replyTicketSchema } from '../validators/supportTicketValidators.js';

const router = Router();

router.post('/', optionalAuth, validate(createTicketSchema), supportTicketController.createTicket);
router.get('/mine', requireAuth, supportTicketController.listMyTickets);
router.get('/mine/:id', requireAuth, supportTicketController.getMyTicket);
router.post('/mine/:id/replies', requireAuth, validate(replyTicketSchema), supportTicketController.replyToMyTicket);

export default router;
