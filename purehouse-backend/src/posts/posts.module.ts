import { Module } from '@nestjs/common';
import { PostsService } from './posts.service';
import { PostsController } from './posts.controller';
import { mongoProvider } from '../mongo.provider';

@Module({
  controllers: [PostsController],
  providers: [PostsService, mongoProvider],
})
export class PostsModule {}
