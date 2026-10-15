#!/bin/sh
# install.sh - Universally portable dotfiles installer

# Use $0 instead of BASH_SOURCE for POSIX compliance
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse command line flags
MODE="symlink"
RESTORE=0

while [ $# -gt 0 ]; do
    case "$1" in
        --symlink)
            MODE="symlink"
            shift
            ;;
        --move)
            MODE="move"
            shift
            ;;
        --uninstall)
            MODE="uninstall"
            shift
            ;;
        --restore)
            RESTORE=1
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--symlink | --move | --uninstall [--restore]]"
            echo "  --symlink            Symlink dotfiles to home directory (default, best for containers)"
            echo "  --move               Copy dotfiles to home directory for manual installation"
            echo "  --uninstall          Remove dotfiles/symlinks"
            echo "  --uninstall --restore Remove dotfiles/symlinks and restore backups (*.bak)"
            echo "  -h, --help           Display this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use '$0 --help' for usage information."
            exit 1
            ;;
    esac
done

if [ "$MODE" = "uninstall" ]; then
    echo "Uninstalling dotfiles from $HOME..."
    
    for file in .bashrc .zshrc .p10k.zsh .gitconfig; do
        if [ -e "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
            rm -f "$HOME/$file"
            echo "Removed ~/$file"
        fi
        
        if [ "$RESTORE" -eq 1 ] && [ -e "$HOME/${file}.bak" ]; then
            mv "$HOME/${file}.bak" "$HOME/$file"
            echo "Restored ~/${file}.bak to ~/$file"
        fi
    done
    
    echo "Dotfiles uninstallation complete!"
    exit 0
fi

if [ "$MODE" = "move" ]; then
    echo "Setting up dotfiles (move/copy mode) from $DOTFILES_DIR/dotfiles..."
else
    echo "Setting up dotfiles (symlink mode) from $DOTFILES_DIR/dotfiles..."
fi

# 1. Alpine Rescue: Install required shells and tools if on Alpine
if command -v apk >/dev/null 2>&1; then
    echo "Alpine Linux detected. Installing bash, zsh, git, curl, and git-lfs..."
    sudo apk add --no-cache bash zsh git curl ncurses git-lfs 2>/dev/null || apk add --no-cache bash zsh git curl ncurses git-lfs
fi

# 2. Setup dotfiles (Symlink or Move)
for file in .bashrc .zshrc .p10k.zsh .gitconfig; do
    if [ -f "$DOTFILES_DIR/dotfiles/$file" ]; then
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ] && [ ! -e "$HOME/${file}.bak" ]; then
            mv "$HOME/$file" "$HOME/${file}.bak"
            echo "Backed up existing ~/$file to ~/${file}.bak"
        fi
        
        rm -f "$HOME/$file"
        
        if [ "$MODE" = "move" ]; then
            cp -f "$DOTFILES_DIR/dotfiles/$file" "$HOME/$file"
            echo "Copied $DOTFILES_DIR/dotfiles/$file -> ~/$file"
        else
            ln -sf "$DOTFILES_DIR/dotfiles/$file" "$HOME/$file"
            echo "Linked ~/$file -> $DOTFILES_DIR/dotfiles/$file"
        fi
    else
        echo "Warning: $file not found in dotfiles repository. Skipping."
    fi
done

# 3. Check and install git-lfs for Debian/Ubuntu/Arch
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