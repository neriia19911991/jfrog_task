# ---------- Stage 1: Build and test ----------
FROM node:14-alpine AS build

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy full source (including tests)
COPY src/ ./src/

# Optional test
RUN if [ "$RUN_TESTS" = "true" ]; then npm test; fi

# Remove test folder after tests
RUN rm -rf ./src/test

# ---------- Stage 2: Final image ----------
FROM node:14-alpine

WORKDIR /app

# Copy node_modules + src from build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY package*.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001 \
    && chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

CMD ["npm", "start"]
