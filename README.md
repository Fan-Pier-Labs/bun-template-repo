# Bun Template Repository

A production-ready template for building applications with [Bun](https://bun.sh) - the fast all-in-one JavaScript runtime. This template includes everything you need for both development and production deployment.

## ✨ Features

- **🚀 Bun Runtime** - Fast JavaScript runtime with built-in TypeScript support
- **🐳 Docker Support** - Production-ready Dockerfile using `oven/bun` base image
- **💻 DevContainer** - Complete development environment with VS Code/Cursor support
- **🔧 Development Tools** - Pre-configured with essential dev tools (git, curl, build tools, etc.)
- **🐚 Fish Shell** - Fish shell configured as default with proper environment setup
- **🔐 GitHub CLI Integration** - Automatic token loading via fish function wrapper
- **☁️ AWS CLI** - Architecture-aware AWS CLI installation
- **📦 Single Dockerfile** - Works for both development and production

## 🚀 Quick Start

### Using as a Template

1. Click "Use this template" on GitHub to create a new repository
2. Clone your new repository
3. Open in VS Code/Cursor with DevContainers extension
4. The container will automatically set up your development environment

### Local Development (without DevContainer)

```bash
# Install dependencies
bun install

# Run the application
bun run index.ts
```

## 🛠️ Development Setup

### DevContainer (Recommended)

This repository includes a fully configured DevContainer that sets up:

- **Base Image**: `oven/bun:latest` - Official Bun runtime
- **Development Tools**: Git, curl, wget, build tools, Python, fish shell, vim, nano, and more
- **GitHub CLI**: With automatic token loading (see below)
- **AWS CLI**: Architecture-aware installation (amd64/arm64)
- **Fish Shell**: Configured as default shell with proper environment variables

#### First Time Setup

1. Open the repository in VS Code/Cursor
2. When prompted, click "Reopen in Container"
3. The setup script will automatically:
   - Install all development tools
   - Configure fish shell
   - Set up GitHub CLI (if token file exists)
   - Install development dependencies

#### GitHub CLI Authentication

To use GitHub CLI in the container:

1. **On your Mac**, get your GitHub token:
   ```bash
   gh auth token
   ```

2. **Create the token file**:
   ```bash
   echo "your_token_here" > ~/.config/gh/gh_token
   chmod 600 ~/.config/gh/gh_token
   ```

3. The token file is automatically mounted into the container, and the fish function wrapper will use it automatically.

4. **For Mac users with fish shell**, copy the wrapper function:
   ```bash
   mkdir -p ~/.config/fish/functions
   cp .devcontainer/gh.fish ~/.config/fish/functions/gh.fish
   ```

Now `gh` commands will automatically use your token in both Mac and container environments!

## 🐳 Production Deployment

### Docker Build

The included `Dockerfile` is optimized for production:

```bash
# Build the image
docker build -t bun-app .

# Run the container
docker run -p 3000:3000 bun-app
```

**Features:**
- Uses `oven/bun:latest` base image (minimal size)
- Installs only production dependencies
- Runs your application with `bun run index.ts`

### Dockerfile Architecture

The Dockerfile is designed to work for both:
- **Development**: Used by DevContainer (with `overrideCommand: true`)
- **Production**: Runs your application directly

## 📁 Project Structure

```
.
├── .devcontainer/          # DevContainer configuration
│   ├── devcontainer.json   # Container settings and mounts
│   ├── setup-dev.sh        # Development environment setup script
│   └── gh.fish             # GitHub CLI fish function wrapper
├── Dockerfile              # Production Docker image
├── index.ts                # Application entry point
├── package.json            # Dependencies and scripts
├── tsconfig.json           # TypeScript configuration
└── README.md              # This file
```

## 🔧 Development Tools Included

The setup script automatically installs:

- **Core Tools**: git, curl, wget, gnupg, openssh-client
- **Build Tools**: build-essential, make, cmake, pkg-config
- **Development Libraries**: libssl-dev, zlib1g-dev, libbz2-dev, etc.
- **Languages**: Python 3, TypeScript (via Bun)
- **Shells**: bash, zsh, fish
- **Editors**: vim, nano
- **Utilities**: htop, strace, jq, rsync, unzip, zip

## 🎯 Usage Examples

### Running Tests

```bash
bun test
```

### Building for Production

```bash
bun build index.ts --outdir ./dist
```

### Type Checking

```bash
bunx tsc --noEmit
```

## 🔐 Environment Variables

The DevContainer automatically sets:
- `XDG_CONFIG_HOME=/root/.local/config` - For fish shell configuration
- `GH_TOKEN` - Automatically loaded from `~/.config/gh/gh_token` (if present)

## 📝 Notes

- **Fish Shell**: The default shell is fish. Universal variables are stored in `/root/.local/config/fish/` to work with the read-only mounted config directory.
- **GitHub CLI**: The fish function wrapper automatically loads tokens from the mounted file, making authentication seamless.
- **Single Dockerfile**: The same Dockerfile works for both dev and production - DevContainer overrides the CMD to keep the container alive for development.

## 🤝 Contributing

This is a template repository. Feel free to:
1. Use it as a starting point for your projects
2. Customize the setup scripts for your needs
3. Add your own development tools and configurations

## 📄 License

This template is provided as-is for use in your projects.

---

Built with [Bun](https://bun.sh) - the fast all-in-one JavaScript runtime.
