#!/bin/bash

# ==============================================================================
# macOS Development Environment Bootstrap Script
# ==============================================================================
# This script sets up a new macOS machine with development tools and configs.
# It is idempotent - safe to run multiple times.
#
# Usage:
#   ./install.sh           # Run full installation
#   ./install.sh --help    # Show help
#   ./install.sh --dry-run # Show what would be done without making changes
# ==============================================================================

set -e

DOTFILES_DIR="$HOME/.dotfiles"
DRY_RUN=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==============================================================================
# Helper Functions
# ==============================================================================

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

run() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} $*"
    else
        "$@"
    fi
}

# ==============================================================================
# Parse Arguments
# ==============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be done without making changes"
            echo "  --help, -h   Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# ==============================================================================
# Pre-flight Checks
# ==============================================================================

echo ""
echo "========================================"
echo " macOS Development Environment Setup"
echo "========================================"
echo ""

if [ "$DRY_RUN" = true ]; then
    warn "Running in dry-run mode. No changes will be made."
    echo ""
fi

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is designed for macOS only."
fi

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    error "Dotfiles directory not found at $DOTFILES_DIR"
fi

# ==============================================================================
# 1. Xcode Command Line Tools
# ==============================================================================

info "Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools..."
    run xcode-select --install
    echo "Please complete the Xcode installation and re-run this script."
    exit 0
else
    success "Xcode Command Line Tools already installed."
fi

# ==============================================================================
# 2. Homebrew
# ==============================================================================

info "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    success "Homebrew already installed."
fi

# ==============================================================================
# 3. Install Homebrew Packages
# ==============================================================================

info "Installing Homebrew packages from Brewfile..."
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    run brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock
    success "Homebrew packages installed."
else
    warn "Brewfile not found at $DOTFILES_DIR/Brewfile"
fi

# ==============================================================================
# 4. Oh-My-Zsh
# ==============================================================================

info "Checking Oh-My-Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh-My-Zsh..."
    run sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh-My-Zsh installed."
else
    success "Oh-My-Zsh already installed."
fi

# ==============================================================================
# 5. Powerlevel10k Theme
# ==============================================================================

info "Checking Powerlevel10k..."
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    info "Installing Powerlevel10k..."
    run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    success "Powerlevel10k installed."
else
    success "Powerlevel10k already installed."
fi

# ==============================================================================
# 6. Zsh Plugins
# ==============================================================================

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

info "Checking zsh-autosuggestions..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    run git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    success "zsh-autosuggestions installed."
else
    success "zsh-autosuggestions already installed."
fi

info "Checking zsh-syntax-highlighting..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    run git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    success "zsh-syntax-highlighting installed."
else
    success "zsh-syntax-highlighting already installed."
fi

# ==============================================================================
# 7. FZF Integration
# ==============================================================================

info "Setting up FZF integration..."
if [ -f "$(brew --prefix)/opt/fzf/install" ]; then
    run "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
    success "FZF integration setup complete."
else
    warn "FZF not found. Install it with: brew install fzf"
fi

# ==============================================================================
# 8. Symlink Dotfiles
# ==============================================================================

info "Creating symlinks..."

# Backup existing files
backup_and_link() {
    local source=$1
    local target=$2

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        info "Backing up existing $target to $target.backup"
        run mv "$target" "$target.backup"
    fi

    if [ -L "$target" ]; then
        run rm "$target"
    fi

    run ln -sf "$source" "$target"
    success "Linked $source -> $target"
}

backup_and_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
backup_and_link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# ==============================================================================
# 9. GVM (Go Version Manager)
# ==============================================================================

info "Checking GVM..."
if [ ! -d "$HOME/.gvm" ]; then
    info "Installing GVM..."
    run bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
    success "GVM installed. Install Go with: gvm install go1.24 -B && gvm use go1.24 --default"
else
    success "GVM already installed."
fi

# ==============================================================================
# 10. Colima (Docker runtime)
# ==============================================================================

info "Checking Colima..."
if command -v colima &>/dev/null; then
    if ! colima status &>/dev/null; then
        info "Starting Colima..."
        run colima start --cpu 4 --memory 8 --disk 60
        success "Colima started."
    else
        success "Colima already running."
    fi
else
    warn "Colima not installed. Install it with: brew install colima"
fi

# ==============================================================================
# Complete
# ==============================================================================

echo ""
echo "========================================"
echo " Installation Complete!"
echo "========================================"
echo ""
info "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Run 'p10k configure' to customize your prompt"
echo "  3. Set your terminal font to 'MesloLGS NF' or another Nerd Font"
echo "  4. Install Go: gvm install go1.24 -B && gvm use go1.24 --default"
echo ""
success "Enjoy your new development environment!"
