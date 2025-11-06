import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { PostsController } from '../src/posts/posts.controller';
import { PostsService } from '../src/posts/posts.service';

describe('PostsController (e2e)', () => {
  let app: INestApplication;

  const mockService = {
    findAll: jest.fn().mockResolvedValue([]),
    create: jest.fn().mockResolvedValue({ insertedId: 'abc' }),
    findOne: jest.fn().mockResolvedValue({ _id: 'abc', title: 't' }),
    update: jest.fn().mockResolvedValue({ modifiedCount: 1 }),
    remove: jest.fn().mockResolvedValue({ deletedCount: 1 }),
  } as Partial<PostsService>;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [PostsController],
      providers: [{ provide: PostsService, useValue: mockService }],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
    await app.init();
  });

  it('/posts (GET)', () => {
    return request(app.getHttpServer()).get('/posts').expect(200).expect([]);
  });

  it('/posts (POST)', () => {
    return request(app.getHttpServer())
      .post('/posts')
      .send({ title: 't', author: 'a', content: 'c' })
      .expect(201)
      .expect({ insertedId: 'abc' });
  });

  it('/posts/:id (GET)', () => {
    return request(app.getHttpServer())
      .get('/posts/abc')
      .expect(200)
      .expect({ _id: 'abc', title: 't' });
  });

  it('/posts/:id (PUT)', () => {
    return request(app.getHttpServer())
      .put('/posts/abc')
      .send({ title: 'updated' })
      .expect(200)
      .expect({ modifiedCount: 1 });
  });

  it('/posts/:id (DELETE)', () => {
    return request(app.getHttpServer())
      .delete('/posts/abc')
      .expect(200)
      .expect({ deletedCount: 1 });
  });
});
