# syntax=docker/dockerfile:1

# ============================================
# Stage 1: Base - Shared dependencies
# ============================================
FROM oven/bun:latest AS base

WORKDIR /workspace

# Copy dependency files first for optimal caching
COPY package.json bun.lockb* ./

# Install production dependencies (cached unless package.json/lock changes)
RUN bun install --frozen-lockfile

# ============================================
# Stage 2: Development - Full tooling
# ============================================
FROM base AS dev

# Layer 1: System packages (rarely change) - 53MB cached layer
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg \
    git git-lfs openssh-client rsync unzip zip xz-utils jq \
    build-essential make cmake \
    libssl-dev libbz2-dev libreadline-dev libsqlite3-dev zlib1g-dev \
    python3 python3-pip \
    bash zsh fish vim nano \
    htop strace \
    tzdata sudo less docker.io \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: Git LFS initialization (rarely change)
RUN git lfs install || true

# Layer 3: AWS CLI (stable, architecture-aware)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"; \
    elif [ "$ARCH" = "arm64" ]; then \
        AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"; \
    fi && \
    if [ -n "${AWS_CLI_URL:-}" ]; then \
        curl "$AWS_CLI_URL" -o "awscliv2.zip" && \
        unzip -q awscliv2.zip && \
        ./aws/install && \
        rm -rf awscliv2.zip aws; \
    fi

# Layer 4: GitHub CLI (stable, architecture-aware)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        GH_ARCH="amd64"; \
    elif [ "$ARCH" = "arm64" ]; then \
        GH_ARCH="arm64"; \
    fi && \
    if [ -n "$GH_ARCH" ]; then \
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
        chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
        echo "deb [arch=$GH_ARCH signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
        apt-get update -qq && \
        apt-get install -y --no-install-recommends gh && \
        rm -rf /var/lib/apt/lists/*; \
    fi

# Layer 5: Node.js LTS (for npx/npm)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Layer 6: Cursor IDE (may update occasionally)
RUN curl https://cursor.com/install -fsS | bash

# Layer 7: Claude Code CLI (may update occasionally)
RUN curl -fsSL https://claude.ai/install.sh | bash

# Layer 8: Fish shell configuration
RUN if command -v fish &> /dev/null; then \
        FISH_PATH=$(command -v fish) && \
        usermod -s "$FISH_PATH" root || true && \
        mkdir -p /root/.local/config/fish && \
        echo "export XDG_CONFIG_HOME=/root/.local/config" >> /root/.bashrc && \
        echo "export XDG_CONFIG_HOME=/root/.local/config" >> /root/.profile && \
        echo "export SHELL=$FISH_PATH" >> /root/.bashrc && \
        echo "export SHELL=$FISH_PATH" >> /root/.profile; \
    fi

# Layer 9: Python packages (for deploy script)
RUN pip3 install --no-cache-dir pyyaml boto3 --break-system-packages

# Layer 10: Dev dependencies (changes when package.json changes)
RUN bun install

# Layer 11: Application code (changes most frequently)
COPY . .

# Development environment variables
ENV NODE_ENV=development
ENV PORT=8080

# Keep container running for development
CMD ["sleep", "infinity"]

# ============================================
# Stage 3: Production - Minimal runtime
# ============================================
FROM base AS prod

# Copy only application code (no dev scripts)
COPY . .

# Production environment
ENV NODE_ENV=production
ENV PORT=8080

# Expose application port
EXPOSE 8080

# Health check for production
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Run application
CMD ["bun", "run", "index.ts"]
