FROM node:18-alpine

# Set static environment variables
ENV NODE_ENV=production
ENV PORT=3002

WORKDIR /app

# Create a non-root user
RUN addgroup --system app && adduser --system --ingroup app appuser

# Copy package files and install production dependencies
COPY package*.json ./
RUN npm ci --omit=dev || npm install --production --no-audit --no-fund

# Copy source code
COPY src ./src

# Use the non-root user
USER appuser

EXPOSE 3002

# Start the app
CMD [ "node", "src/index.js" ]
