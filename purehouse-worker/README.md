# Worker Service

Async event processing service with Express.js

## Technical Overview

Lightweight event processing service for handling asynchronous tasks decoupled from the main API. Demonstrates microservice architecture and non-blocking communication design.

## Architecture Decisions

### Why a Separate Service?

**Decoupling strategy:**
- Main API stays fast and responsive
- Audit logs don't slow user requests
- Independent scaling
- Failure isolation

| Approach | Pros | Cons |
|----------|------|------|
| **Separate Service** ✅ | Independent scaling, isolation | More complexity |
| Inline Processing | Simpler | Blocks API |
| Message Queue | Best for prod | Overkill for demo |

### Framework: Express.js

**Chosen over NestJS because:**
- Lightweight for simple tasks
- Minimal dependencies
- Fast startup
- Demonstrates framework variety

## Technical Implementation

### Service Structure

```
src/
└── index.js    # Main server (~100 lines)
```

Minimal but complete:
- Health check endpoint
- Log ingestion
- Batch processing
- Colorized output

### API Endpoints

```javascript
GET  /health         → { status: "healthy" }
POST /logs           → Single event
POST /logs/batch     → Multiple events
```

### Logging

Colorized console output for visibility:

```javascript
console.log(`${green}[WORKER]${reset} Processing event`);
```

## Integration Pattern

### Communication Flow

```
Backend API
    ↓ (fire-and-forget HTTP POST)
Worker Service
    ↓ (console/database/metrics)
Audit Trail
```

### Service Discovery

Kubernetes DNS:
- Service: `worker-service`
- Namespace: `purehouse`
- Full DNS: `worker-service.purehouse.svc.cluster.local`

## Containerization

Simple Alpine-based Dockerfile (~50MB):

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY src/ ./src/
EXPOSE 3002
CMD ["node", "src/index.js"]
```

## Deployment

**Kubernetes specs:**
- 1 replica (horizontally scalable)
- Resource limits: 200m CPU, 256Mi RAM
- ClusterIP (internal only)

## Skills Demonstrated

- Microservice design
- Express.js minimalist framework
- Event-driven architecture
- REST API design
- Docker lightweight images
- Kubernetes ClusterIP
- Error handling

## Design Patterns

- Fire-and-Forget
- Observer Pattern
- Circuit Breaker
- Health Check Pattern

## Production Enhancements (Not Implemented)

**If scaling to production:**
- Message queue (SQS, RabbitMQ)
- Persistent storage
- Retry logic
- Metrics (Prometheus)
- Dead letter queue

**Why not implemented:** Demo project, demonstrates understanding of trade-offs

## Current Use Cases

- Audit logging (create/update/delete events)
- User action tracking
- Timestamp events

**Future possibilities:**
- Email notifications
- Image processing
- Report generation

---

*Demonstrates microservice architecture, async patterns, and when to decouple functionality.*
