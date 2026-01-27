# Production Dockerfile - minimal setup
FROM oven/bun:latest

WORKDIR /workspace

# Copy package files
COPY package.json bun.lockb* ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy source code
COPY . .

# Expose port and start
EXPOSE 8080
ENV PORT=8080

# Production: run the application
CMD ["bun", "run", "index.ts"]
