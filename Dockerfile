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

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD bun -e "fetch('http://localhost:8080/health').then(r => r.ok ? process.exit(0) : process.exit(1)).catch(() => process.exit(1))"

# Production: run the application
CMD ["bun", "run", "index.ts"]
