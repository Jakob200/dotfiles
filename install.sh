#!/bin/sh
# install.sh - Universally portable dotfiles installer

# Use $0 instead of BASH_SOURCE for POSIX compliance
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Setting up dotfiles from $DOTFILES_DIR..."

# 1. Alpine Rescue: Install required shells and tools if on Alpine
if command -v apk >/dev/null 2>&1; then
    echo "Alpine Linux detected. Installing bash, zsh, git, curl, and git-lfs..."
    sudo apk add --no-cache bash zsh git curl ncurses git-lfs 2>/dev/null || apk add --no-cache bash zsh git curl ncurses git-lfs
fi

# 2. Symlink dotfiles (using a standard loop instead of a Bash array)
for file in .bashrc .zshrc .p10k.zsh .gitconfig; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            mv "$HOME/$file" "$HOME/${file}.bak"
            echo "Backed up existing ~/$file to ~/${file}.bak"
        fi
        
        ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
        echo "Linked ~/$file -> $DOTFILES_DIR/$file"
    else
        echo "Warning: $file not found in dotfiles repository. Skipping."
    fi
done

# 3. Check and install git-lfs for Debian/Ubuntu/Arch
# (Replaced bash specific &> with POSIX >/dev/null 2>&1)
if ! command -v git-lfs >/dev/null 2>&1; then
    echo "git-lfs not found. Attempting to install..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y git-lfs
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm git-lfs
    fi
    git lfs install
fi

echo "Dotfiles setup complete!"