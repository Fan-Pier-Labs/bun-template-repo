# Production Dockerfile - minimal setup
FROM oven/bun:latest

WORKDIR /workspace

# Copy package files
COPY package.json bun.lockb* ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy source code
COPY . .

# Production: run the application
CMD ["bun", "run", "index.ts"]
