import { MongoMemoryServer } from 'mongodb-memory-server';

// One in-memory MongoDB for the whole run — starting a separate mongod per
// test file is slow and flaky on constrained machines.
export default async function ({ provide }) {
  const mongod = await MongoMemoryServer.create();
  provide('MONGO_URI', mongod.getUri());
  return async () => {
    await mongod.stop();
  };
}
