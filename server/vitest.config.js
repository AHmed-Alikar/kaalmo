import { defineConfig } from 'vitest/config';

// Password-reset / payment / push tests run against one shared in-memory
// MongoDB (see test/globalSetup.js). Serial execution keeps the shared
// rate-limiter state deterministic.
export default defineConfig({
  test: {
    environment: 'node',
    globals: false,
    globalSetup: ['./test/globalSetup.js'],
    setupFiles: ['./test/setup.js'],
    fileParallelism: false,
    hookTimeout: 60000,
    testTimeout: 30000,
  },
});
