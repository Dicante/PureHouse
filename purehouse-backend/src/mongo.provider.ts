import { MongoClient } from 'mongodb';
import { Provider } from '@nestjs/common';

export const MONGO_CLIENT = 'MONGO_CLIENT';

export const mongoProvider: Provider = {
  provide: MONGO_CLIENT,
  useFactory: async (): Promise<MongoClient> => {
    const uri =
      process.env.MONGODB_URI ??
      process.env.MONGO_URI ??
      'mongodb://127.0.0.1:27017';
    const client = new MongoClient(uri);
    await client.connect();
    return client;
  },
};
