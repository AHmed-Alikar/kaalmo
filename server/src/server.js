import 'dotenv/config';
import app from './app.js';
import { connectDB } from './config/db.js';
import { isFcmConfigured } from './services/fcmService.js';

const PORT = process.env.PORT || 5000;

async function start() {
  try {
    await connectDB();
    app.listen(PORT, () => {
      console.log(`Kaalmo API listening on port ${PORT}`);
      // Loud on startup: without Firebase Admin credentials NO push is ever
      // sent (in-app notifications still work). This is the #1 reason
      // background / terminated notifications never appear on a real device.
      console.log(
        isFcmConfigured()
          ? `[fcmService] FCM push ENABLED (project ${process.env.FIREBASE_PROJECT_ID})`
          : '[fcmService] FCM push DISABLED — FIREBASE_PROJECT_ID / FIREBASE_CLIENT_EMAIL / FIREBASE_PRIVATE_KEY not set. Background/terminated notifications will not be delivered.'
      );
    });
  } catch (err) {
    console.error('Failed to start server:', err.message);
    process.exit(1);
  }
}

start();
