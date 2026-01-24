# Heavier Ubuntu base for "kitchen sink" dev environments
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# Core CLI + build tooling + networking tools + editors
RUN apt-get update && apt-get install -y --no-install-recommends \
    # essentials
    ca-certificates curl wget gnupg lsb-release software-properties-common \
    git git-lfs openssh-client rsync unzip zip xz-utils jq yq \
    # build tools
    build-essential make cmake pkg-config autoconf automake libtool \
    # common dev libs
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    # python basics
    python3 python3-pip python3-venv python-is-python3 \
    # node helpers (we’ll install Node via nvm below, but keep npm tools handy)
    # (no nodejs apt package here on purpose)
    # network/debug
    iputils-ping dnsutils net-tools traceroute tcpdump nmap \
    # process/system
    htop psmisc lsof strace \
    # shells/editors
    bash zsh fish vim nano \
    # timezones
    tzdata zstd zip unzip \
  && rm -rf /var/lib/apt/lists/*

# Git LFS init (won’t fail if not used)
RUN git lfs install || true

# ---- Bun (fast JS runtime) ----
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Refresh Ubuntu GPG keys to avoid signature errors
RUN apt-get update --allow-releaseinfo-change || true \
  && apt-get install -y --no-install-recommends --reinstall ca-certificates || true \
  && rm -rf /var/lib/apt/lists/*

# ---- Docker CLI (optional but useful if you mount docker socket) ----
# If you don't mount /var/run/docker.sock, this is harmless.
# RUN install -m 0755 -d /etc/apt/keyrings \
#   && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
#   && chmod a+r /etc/apt/keyrings/docker.gpg \
#   && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#      $(. /etc/os-release && echo ${VERSION_CODENAME:-noble}) stable" > /etc/apt/sources.list.d/docker.list \
#   && apt-get update --allow-releaseinfo-change \
#   && apt-get install -y --no-install-recommends docker-ce-cli \
#   && rm -rf /var/lib/apt/lists/*

# Set fish as default shell for root
RUN usermod -s /usr/bin/fish root


# ---- AWS CLI (architecture-aware) ----
  RUN ARCH=$(dpkg --print-architecture) \
  && if [ "$ARCH" = "amd64" ]; then \
       AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"; \
     elif [ "$ARCH" = "arm64" ]; then \
       AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"; \
     else \
       echo "Unsupported architecture: $ARCH" && exit 1; \
     fi \
  && curl "$AWS_CLI_URL" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf awscliv2.zip aws



# Copy package files
COPY package.json bun.lockb* ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy source code
COPY . .

# Keep container alive for Cursor/agents
CMD ["sleep", "infinity"]