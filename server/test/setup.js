import { beforeAll, afterAll, afterEach, beforeEach, inject } from 'vitest';
import mongoose from 'mongoose';

import { authRateLimiter, passwordResetRateLimiter, donationRateLimiter } from '../src/middleware/rateLimit.js';

// jwt.js reads these at call time — provide deterministic test secrets.
process.env.JWT_ACCESS_SECRET = process.env.JWT_ACCESS_SECRET || 'test_access_secret';
process.env.JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'test_refresh_secret';
process.env.JWT_ACCESS_EXPIRES = process.env.JWT_ACCESS_EXPIRES || '15m';
process.env.JWT_REFRESH_EXPIRES = process.env.JWT_REFRESH_EXPIRES || '30d';
// Keep emailService on its dev (console) path; individual tests still mock it.
delete process.env.RESEND_API_KEY;

beforeAll(async () => {
  // One shared mongod from globalSetup; each file gets its own logical DB.
  const uri = inject('MONGO_URI');
  await mongoose.connect(uri, { dbName: `test_${Math.random().toString(36).slice(2, 10)}` });
});

// supertest requests originate from ::ffff:127.0.0.1 — clear the per-IP counters
// so rate-limit state from one test never bleeds into the next.
beforeEach(async () => {
  const keys = ['::ffff:127.0.0.1', '::1', '127.0.0.1'];
  for (const limiter of [authRateLimiter, passwordResetRateLimiter, donationRateLimiter]) {
    for (const key of keys) {
      await limiter.resetKey(key);
    }
  }
});

afterEach(async () => {
  const { collections } = mongoose.connection;
  for (const name of Object.keys(collections)) {
    await collections[name].deleteMany({});
  }
});

afterAll(async () => {
  await mongoose.disconnect();
});
