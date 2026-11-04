#!/usr/bin/env bash
# Rebuild this environment on a fresh macOS machine.
# Usage: git clone <repo> ~/.config && ~/.config/bootstrap.sh
set -euo pipefail

CONFIG="$HOME/.config"

if [ "$(uname)" != "Darwin" ]; then
  echo "This script targets macOS." >&2
  exit 1
fi

# 1. Homebrew
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Packages, casks and fonts
brew bundle --file "$CONFIG/Brewfile"

# 3. herdr (official installer; updates itself with `herdr update`)
if ! command -v herdr >/dev/null && [ ! -x "$HOME/.local/bin/herdr" ]; then
  curl -fsSL https://herdr.dev/install.sh | sh
fi

# 4. zellij via cargo
if ! command -v zellij >/dev/null && command -v cargo >/dev/null; then
  cargo install --locked zellij
fi

# 5. oh-my-zsh (the zshrc expects ~/.oh-my-zsh)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 6. Link the tracked zshrc, keeping a backup of any existing one
if [ -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
ln -sf "$CONFIG/zsh/.zshrc" "$HOME/.zshrc"

cat <<'EOF'

Done. Manual steps left (credentials are never stored in this repo):
  - gh auth login
  - Store API keys in the macOS Keychain (the zshrc reads notion-api-key,
    github-personal-access-token, figma-token and gemini-api-key)
  - Open Neovim once so lazy.nvim installs the plugins from lazy-lock.json
  - Log in to Karabiner, AeroSpace and any other app that needs permissions
EOF
