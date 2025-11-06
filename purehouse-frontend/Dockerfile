# ----------------------------------
# STAGE 1: BUILD
# ----------------------------------
FROM node:18-alpine AS builder

# Set Next.js build environment (if needed, default to production)
# ENV NODE_ENV production

WORKDIR /app

# Allow build-time injection of the client runtime URL
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

# Copy dependencies manifest files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy all source code
COPY . .

# Build the Next.js application for production
RUN npm run build

# ----------------------------------
# STAGE 2: RUN (Final Production Image)
# ----------------------------------
FROM node:18-alpine

WORKDIR /app

# Create a non-root user for security best practice
RUN addgroup --system app && adduser --system --ingroup app appuser
## Copy package metadata from build stage and install only production deps
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json ./package-lock.json
RUN npm ci --omit=dev

## Copy build output and public assets from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

## Ensure files are accessible by the non-root user
RUN chown -R appuser:app /app

## Use the non-root user
USER appuser

## Default port for Next.js
EXPOSE 3000

## Start command (uses `next start`, which reads the built .next)
CMD ["npm", "start"]