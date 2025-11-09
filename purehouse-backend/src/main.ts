import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // Enable CORS for cross-origin requests from the frontend
  app.enableCors();

  // Add a global prefix so all routes are served under /api
  // The Ingress forwards /api/* to backend:3001/api/*
  // e.g., User requests /api/posts -> Ingress -> backend:3001/api/posts
  app.setGlobalPrefix('api');

  // Enable shutdown hooks so Nest can gracefully handle SIGTERM (useful for K8s)
  app.enableShutdownHooks();

  const port = parseInt(process.env.PORT ?? '3001', 10);
  await app.listen(port);
  console.log(`Nest application listening on http://localhost:${port}/api`);
}
void bootstrap();
