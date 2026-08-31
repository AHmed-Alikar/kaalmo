import { Router } from 'express';
import * as deviceTokenController from '../controllers/deviceTokenController.js';
import { requireAuth } from '../middleware/auth.js';
import { validate } from '../middleware/validate.js';
import { registerDeviceSchema, removeDeviceSchema } from '../validators/deviceValidators.js';

const router = Router();

router.get('/', requireAuth, deviceTokenController.listMyDevices);
router.post('/', requireAuth, validate(registerDeviceSchema), deviceTokenController.registerDevice);
router.delete('/', requireAuth, validate(removeDeviceSchema), deviceTokenController.removeDevice);

export default router;
