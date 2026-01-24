# GitHub CLI Fish Function

This directory contains a fish function wrapper for `gh` that automatically loads your GitHub token from a file.

## How it works

The function checks for a token file in these locations (in order):
1. `/root/.local/config/gh/gh_token` (container)
2. `~/.config/gh/gh_token` (Mac)

If found, it automatically sets `GH_TOKEN` and runs the `gh` command. If not found, it just runs `gh` normally.

## Setup

### In Container (Automatic)

The setup script automatically installs this function when the container is created. No action needed!

### On Mac (Manual)

To use this on your Mac, copy the function to your fish functions directory:

```bash
mkdir -p ~/.config/fish/functions
cp .devcontainer/gh.fish ~/.config/fish/functions/gh.fish
```

Then restart fish or run:
```fish
source ~/.config/fish/functions/gh.fish
```

## Token File

Create a file named `gh_token` in `~/.config/gh/` on your Mac with your GitHub personal access token:

```bash
echo "your_github_token_here" > ~/.config/gh/gh_token
chmod 600 ~/.config/gh/gh_token
```

The token file is automatically mounted into the container, so it works in both places!
