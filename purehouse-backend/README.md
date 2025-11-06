# Backend Service# Backend Service# Backend Service# PureHouse Backend



NestJS REST API with MongoDB integration and async worker communication



## Technical Overview> NestJS REST API with MongoDB integration and async worker communication



RESTful API service implementing structured backend architecture using NestJS framework with TypeScript. Demonstrates enterprise-level API design patterns, database integration, and microservice communication.



## Architecture Decisions## 🎯 Technical Overview> NestJS REST API with MongoDB integration and async worker communicationRESTful API backend for the PureHouse blog platform built with NestJS, TypeScript, and MongoDB.



### Framework: NestJS



**Chosen over Express because:**RESTful API service implementing a **structured backend architecture** using NestJS framework with TypeScript. Demonstrates enterprise-level API design patterns, database integration, and microservice communication.

- Opinionated structure for scalability

- Built-in dependency injection

- Decorator-based routing

- TypeScript-first approach## 🏗️ Architecture Decisions## 🎯 Technical Overview## 🚀 Features



### Database: Custom MongoDB Provider



- Direct MongoDB driver for full control### Framework Choice: NestJS

- Connection pooling for performance

- Health check integration



### Async Worker Pattern**Why NestJS over Express:**RESTful API service implementing a **structured backend architecture** using NestJS framework with TypeScript. Demonstrates enterprise-level API design patterns, database integration, and microservice communication.- **Modern Architecture**: Built with NestJS framework for scalable and maintainable code



HTTP-based service-to-service communication for non-blocking audit logging.- Opinionated structure reduces architectural decisions



```typescript- Built-in dependency injection for testability- **MongoDB Integration**: Native MongoDB driver with custom provider

// Fire-and-forget pattern

this.http.post('http://worker:3002/logs', data)- Decorator-based routing (similar to Spring Boot)

  .catch(err => console.error('Worker unavailable'));

```- TypeScript-first with excellent type safety## 🏗️ Architecture Decisions- **Health Checks**: Kubernetes-ready health endpoints



## Technical Implementation



### API Structure### Database Integration- **Worker Integration**: Async logging to worker service for audit trails



```

src/

├── app.module.ts          # Root module**Custom MongoDB Provider**:### Framework Choice: NestJS- **CRUD Operations**: Complete posts management system

├── mongo.provider.ts      # MongoDB connection

├── health/                # Health checks- Direct MongoDB driver (not Mongoose) for full control

└── posts/                 # Posts API

    ├── posts.controller.ts- Connection pooling for performance- **Type Safety**: Full TypeScript implementation with DTOs

    ├── posts.service.ts

    └── dto/              # Validation schemas- Health check integration for Kubernetes probes

```

**Why NestJS over Express:**- **Testing**: Unit and E2E tests included

### Key Features

```typescript

- **Health Checks**: `/api/health` endpoint for K8s probes

- **Input Validation**: DTOs with class-validator// Custom provider pattern for flexibility- Opinionated structure reduces architectural decisions- **Docker Ready**: Multi-stage Dockerfile for optimized production builds

- **Error Handling**: Global exception filter

- **Modular Design**: Feature-based modules@Injectable()



## Integration Pointsexport class MongoProvider {- Built-in dependency injection for testability



| Service | Connection | Purpose |  private client: MongoClient;

|---------|-----------|---------|

| MongoDB Atlas | Connection string | Data persistence |  private db: Db;- Decorator-based routing (similar to Spring Boot)## 📋 API Endpoints

| Worker Service | HTTP POST | Async event logging |

| Frontend | REST API | Client requests |  



## Containerization  // Singleton connection with proper cleanup- TypeScript-first with excellent type safety



Multi-stage Docker build optimizes image size to ~150MB:}

1. Builder stage: Install deps, compile TypeScript

2. Runtime stage: Copy only production artifacts```### Health



## Deployment



**Kubernetes specs:**### Async Worker Pattern### Database Integration- `GET /api/health` - Database health check (MongoDB ping)

- 2 replicas for HA

- Resource limits: 500m CPU, 512Mi RAM

- ClusterIP service on port 3001

**HTTP-based service-to-service communication**:

**CI/CD:**

1. Run tests- Backend → Worker (fire-and-forget logging)

2. Build Docker image

3. Push to ECR- Non-blocking I/O for audit trail**Custom MongoDB Provider**:### Posts

4. Deploy to EKS

- Graceful failure handling (doesn't break main flow)

## Skills Demonstrated

- Direct MongoDB driver (not Mongoose) for full control- `GET /api/posts` - List all posts

- NestJS modular architecture

- TypeScript strict typing```typescript

- MongoDB native driver integration

- REST API design// Async notification without blocking response- Connection pooling for performance- `GET /api/posts/:id` - Get post by ID

- Microservice communication

- Multi-stage Docker buildsthis.http.post('http://worker:3002/logs', data)

- Kubernetes health checks

  .catch(err => console.error('Worker unavailable'));- Health check integration for Kubernetes probes- `POST /api/posts` - Create new post

## Design Patterns

```

- Dependency Injection

- Repository Pattern- `PUT /api/posts/:id` - Update post

- DTO Pattern

- Module Pattern## 📊 Technical Implementation

- Observer Pattern

```typescript- `DELETE /api/posts/:id` - Delete post

---

### API Structure

*Production-grade backend with proper separation of concerns and cloud-native readiness.*

// Custom provider pattern for flexibility

```

src/@Injectable()## 🏗️ Architecture

├── app.module.ts           # Root module with service wiring

├── mongo.provider.ts       # Custom MongoDB connectionexport class MongoProvider {

├── health/

│   ├── health.controller.ts  # K8s health probe endpoint  private client: MongoClient;```

│   └── health.module.ts

└── posts/  private db: Db;Client → Backend API → MongoDB Atlas

    ├── posts.controller.ts    # REST endpoints

    ├── posts.service.ts       # Business logic                ↓ (async)

    ├── posts.interface.ts     # TypeScript types

    └── dto/  // Singleton connection with proper cleanup         Worker Service (logging)

        ├── create-post.dto.ts  # Validation schemas

        └── update-post.dto.ts}```

```

```

### Key Features Implemented

## 🛠️ Tech Stack

**1. Health Checks**

- `/api/health` endpoint for Kubernetes liveness/readiness### Async Worker Pattern

- MongoDB ping for database connectivity validation

- Returns 200 OK only if DB is reachable- **Framework**: NestJS 10



**2. Input Validation****HTTP-based service-to-service communication**:- **Language**: TypeScript 5

- DTOs with `class-validator` decorators

- Automatic validation pipe in main.ts- Backend → Worker (fire-and-forget logging)- **Database**: MongoDB (native driver)

- Type-safe request/response contracts

- Non-blocking I/O for audit trail- **Validation**: class-validator, class-transformer

**3. Error Handling**

- Global exception filter- Graceful failure handling (doesn't break main flow)- **Testing**: Jest

- Proper HTTP status codes

- Consistent error response format- **Runtime**: Node.js 18+



**4. Modular Design**```typescript

- Feature-based modules (health, posts)

- Dependency injection for loose coupling// Async notification without blocking response## 📦 Installation

- Easy to add new feature modules

this.http.post('http://worker:3002/logs', data)

## 🔗 Integration Points

  .catch(err => console.error('Worker unavailable'));```bash

### External Services

```npm install

| Service | Connection | Purpose |

|---------|-----------|---------|```

| MongoDB Atlas | Connection string | Data persistence |

| Worker Service | HTTP POST | Async event logging |## 📊 Technical Implementation

| Frontend | REST API | Client requests |

## 🔧 Configuration

### Environment Variables

### API Structure

```typescript

MONGODB_URI: Connection string (from Kubernetes secret)Create a `.env` file in the root directory:

PORT: 3001 (default)

WORKER_URL: http://worker-service:3002 (K8s internal DNS)```

```

src/```bash

## 🐳 Containerization

├── app.module.ts           # Root module with service wiring# MongoDB Connection

**Multi-stage Docker build**:

├── mongo.provider.ts       # Custom MongoDB connectionMONGODB_URI=mongodb://localhost:27017

```dockerfile

Stage 1: Builder├── health/# or for MongoDB Atlas:

- Install dependencies

- Build TypeScript → JavaScript│   ├── health.controller.ts  # K8s health probe endpoint# MONGODB_URI=mongodb+srv://<user>:<password>@cluster.mongodb.net

- Generate production artifacts

│   └── health.module.ts

Stage 2: Runtime

- Copy only dist/ and node_modules└── posts/# Database Name

- Run as non-root user

- Expose port 3001    ├── posts.controller.ts    # REST endpointsMONGODB_DB=purehouse

```

    ├── posts.service.ts       # Business logic

**Image size optimization**: ~150MB (vs ~800MB without multi-stage)

    ├── posts.interface.ts     # TypeScript types# Application Port

## 🧪 Testing Strategy

    └── dto/PORT=3001

### Unit Tests

```bash        ├── create-post.dto.ts  # Validation schemas

npm test                    # All tests

npm test posts.service      # Specific service        └── update-post.dto.ts# Worker Service URL (optional, for async logging)

```

```WORKER_URL=http://localhost:3002

### E2E Tests

```bash```

npm run test:e2e            # Integration tests

```### Key Features Implemented



**Test coverage**:See `.env.example` for reference.

- Controller endpoint validation

- Service business logic**1. Health Checks**

- MongoDB integration

- Worker communication- `/api/health` endpoint for Kubernetes liveness/readiness## 🏃 Running the Application



## 🚀 Deployment- MongoDB ping for database connectivity validation



### Kubernetes Configuration- Returns 200 OK only if DB is reachable```bash



**Deployment specs**:# Development mode with hot reload

- 2 replicas for high availability

- Resource limits: 500m CPU, 512Mi memory**2. Input Validation**npm run start:dev

- Health probes: `/api/health` endpoint

- Rolling update strategy- DTOs with `class-validator` decorators



**Service**:- Automatic validation pipe in main.ts# Production mode

- ClusterIP (internal only)

- Port 3001- Type-safe request/response contractsnpm run start:prod

- Accessible via Ingress routing



### CI/CD Integration

**3. Error Handling**# Debug mode

**Automated pipeline**:

1. Run unit tests- Global exception filternpm run start:debug

2. Run e2e tests

3. Build Docker image- Proper HTTP status codes```

4. Push to ECR

5. Deploy to EKS- Consistent error response format



## 💡 Technical HighlightsThe API will be available at `http://localhost:3001/api`



### Skills Demonstrated**4. Modular Design**



- ✅ **NestJS Framework**: Modular architecture, dependency injection- Feature-based modules (health, posts)## 🧪 Testing

- ✅ **TypeScript**: Strict typing, interfaces, DTOs

- ✅ **MongoDB**: Native driver integration, connection management- Dependency injection for loose coupling

- ✅ **REST API Design**: Proper HTTP methods, status codes, error handling

- ✅ **Microservice Communication**: HTTP-based async patterns- Easy to add new feature modules```bash

- ✅ **Containerization**: Multi-stage builds, optimization

- ✅ **Testing**: Unit and integration test coverage# Unit tests

- ✅ **Cloud Native**: Health checks, environment-based config

## 🔗 Integration Pointsnpm run test

### Design Patterns Used



- **Dependency Injection**: Services injected via NestJS IoC

- **Repository Pattern**: Abstracted data access layer### External Services# E2E tests

- **DTO Pattern**: Data transfer objects with validation

- **Module Pattern**: Feature-based code organizationnpm run test:e2e

- **Observer Pattern**: HTTP notifications to worker

| Service | Connection | Purpose |

---

|---------|-----------|---------|# Test coverage

*This service showcases production-grade backend development with proper separation of concerns, testability, and cloud-native deployment readiness.*

| MongoDB Atlas | Connection string | Data persistence |npm run test:cov

| Worker Service | HTTP POST | Async event logging |

| Frontend | REST API | Client requests |# Watch mode

npm run test:watch

### Environment Variables```



```typescript## 🐳 Docker

MONGODB_URI: Connection string (from Kubernetes secret)

PORT: 3001 (default)Build and run with Docker:

WORKER_URL: http://worker-service:3002 (K8s internal DNS)

``````bash

# Build image

## 🐳 Containerizationdocker build -t purehouse-backend .



**Multi-stage Docker build**:# Run container

docker run -p 3001:3001 \

```dockerfile  -e MONGODB_URI=mongodb://host.docker.internal:27017 \

Stage 1: Builder  -e MONGODB_DB=purehouse \

- Install dependencies  purehouse-backend

- Build TypeScript → JavaScript```

- Generate production artifacts

## 📁 Project Structure

Stage 2: Runtime

- Copy only dist/ and node_modules```

- Run as non-root usersrc/

- Expose port 3001├── app.module.ts           # Root module

```├── main.ts                 # Application entry point

├── mongo.provider.ts       # MongoDB connection provider

**Image size optimization**: ~150MB (vs ~800MB without multi-stage)├── health/                 # Health check module

│   ├── health.controller.ts

## 🧪 Testing Strategy│   └── health.module.ts

└── posts/                  # Posts CRUD module

### Unit Tests    ├── posts.controller.ts

```bash    ├── posts.service.ts

npm test                    # All tests    ├── posts.module.ts

npm test posts.service      # Specific service    ├── posts.interface.ts

```    └── dto/

        ├── create-post.dto.ts

### E2E Tests        └── update-post.dto.ts

```bash```

npm run test:e2e            # Integration tests

```## 🚀 Deployment



**Test coverage**:This backend is designed to run in Kubernetes with:

- Controller endpoint validation- MongoDB Atlas for database

- Service business logic- Worker service for logging

- MongoDB integration- Health checks for liveness/readiness probes

- Worker communication

See the root README for full deployment instructions.

## 🚀 Deployment

## 📝 API Documentation

### Kubernetes Configuration

### Create Post

**Deployment specs**:

- 2 replicas for high availability```bash

- Resource limits: 500m CPU, 512Mi memoryPOST /api/posts

- Health probes: `/api/health` endpointContent-Type: application/json

- Rolling update strategy

{

**Service**:  "title": "My Post Title",

- ClusterIP (internal only)  "author": "Author Name",

- Port 3001  "content": "Post content here...",

- Accessible via Ingress routing  "excerpt": "Brief excerpt",

  "coverImage": { "url": "https://example.com/image.jpg" }

### CI/CD Integration}

```

**Automated pipeline**:

1. Run unit tests### Response

2. Run e2e tests

3. Build Docker image```json

4. Push to ECR{

5. Deploy to EKS  "insertedId": "507f1f77bcf86cd799439011"

}

## 💡 Technical Highlights```



### Skills Demonstrated## 🔗 Related Services



- ✅ **NestJS Framework**: Modular architecture, dependency injection- **Frontend**: `../purehouse-frontend` - Next.js application

- ✅ **TypeScript**: Strict typing, interfaces, DTOs- **Worker**: `../purehouse-worker` - Logging service

- ✅ **MongoDB**: Native driver integration, connection management

- ✅ **REST API Design**: Proper HTTP methods, status codes, error handling## 📄 License

- ✅ **Microservice Communication**: HTTP-based async patterns

- ✅ **Containerization**: Multi-stage builds, optimizationMIT

- ✅ **Testing**: Unit and integration test coverage- To stay in the loop and get updates, follow us on [X](https://x.com/nestframework) and [LinkedIn](https://linkedin.com/company/nestjs).

- ✅ **Cloud Native**: Health checks, environment-based config- Looking for a job, or have a job to offer? Check out our official [Jobs board](https://jobs.nestjs.com).



### Design Patterns Used## Support



- **Dependency Injection**: Services injected via NestJS IoCNest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

- **Repository Pattern**: Abstracted data access layer

- **DTO Pattern**: Data transfer objects with validation## Stay in touch

- **Module Pattern**: Feature-based code organization

- **Observer Pattern**: HTTP notifications to worker- Author - [Kamil Myśliwiec](https://twitter.com/kammysliwiec)

- Website - [https://nestjs.com](https://nestjs.com/)

---- Twitter - [@nestframework](https://twitter.com/nestframework)



*This service showcases production-grade backend development with proper separation of concerns, testability, and cloud-native deployment readiness.*## License


Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).
