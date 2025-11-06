import { Controller, Get, Inject } from '@nestjs/common';
import { MONGO_CLIENT } from '../mongo.provider';
import { MongoClient } from 'mongodb';

@Controller('health')
export class HealthController {
  constructor(@Inject(MONGO_CLIENT) private readonly client: MongoClient) {}

  @Get()
  async getHealth() {
    try {
      // ping the server
      await this.client.db().command({ ping: 1 });
      return { status: 'ok' };
    } catch (error) {
      return {
        status: 'error',
        details: error instanceof Error ? error.message : String(error),
      };
    }
  }
}
