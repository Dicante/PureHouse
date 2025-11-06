import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { mongoProvider } from '../mongo.provider';

@Module({
  controllers: [HealthController],
  providers: [mongoProvider],
})
export class HealthModule {}
