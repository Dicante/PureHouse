# ----------------------------------
# STAGE 1: BUILD
# ----------------------------------
FROM node:18-alpine AS build

WORKDIR /app

# Copy dependencies manifest files
COPY package*.json ./

# Install dependencies and compile
RUN npm ci
COPY . .
# Assuming 'build' script compiles your TypeScript/NestJS code (e.g., to /dist)
RUN npm run build 

# ----------------------------------
# STAGE 2: RUN (Final Production Image)
# ----------------------------------
FROM node:18-alpine

# Set static environment variables
ENV NODE_ENV=production
# Default internal port for the API (This is overridden by the orchestrator if needed)
ENV PORT=3001

WORKDIR /app

# Create a non-root user
RUN addgroup --system app && adduser --system --ingroup app appuser

# Copy package metadata and install only production dependencies (smaller final image)
COPY --from=build /app/package.json ./package.json
# Try a clean ci (preferred when package-lock.json exists in build stage),
# otherwise fall back to installing production deps so build doesn't fail.
RUN npm ci --omit=dev || npm install --production --no-audit --no-fund

# Assuming compiled code is in /dist
COPY --from=build /app/dist ./dist

# Use the non-root user
USER appuser

EXPOSE 3001

# Start the compiled app directly so PID 1 is the Node process (better signal handling)
CMD [ "node", "dist/main.js" ]