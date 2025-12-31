#!/bin/bash

# ==============================================================================
# Dotfiles Backup Script
# ==============================================================================
# Copies current configs to dotfiles repo and commits/pushes changes.
#
# Usage:
#   ./backup.sh                 # Backup and push with auto-generated message
#   ./backup.sh "my message"    # Backup and push with custom message
#   ./backup.sh --dry-run       # Show what would be done
# ==============================================================================

set -e

DOTFILES_DIR="$HOME/.dotfiles"
DRY_RUN=false
COMMIT_MSG=""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; shift ;;
        *) COMMIT_MSG="$1"; shift ;;
    esac
done

cd "$DOTFILES_DIR"

# ==============================================================================
# Backup configs
# ==============================================================================

info "Backing up dotfiles..."

# Zsh configs
[ -f ~/.zshrc ] && cp ~/.zshrc "$DOTFILES_DIR/zsh/.zshrc" && success ".zshrc"
[ -f ~/.p10k.zsh ] && cp ~/.p10k.zsh "$DOTFILES_DIR/zsh/.p10k.zsh" && success ".p10k.zsh"

# Git config
[ -f ~/.gitconfig ] && cp ~/.gitconfig "$DOTFILES_DIR/git/.gitconfig" && success ".gitconfig"

# Update Brewfile from current system
if command -v brew &>/dev/null; then
    info "Updating Brewfile from installed packages..."
    brew bundle dump --file="$DOTFILES_DIR/Brewfile" --force 2>/dev/null && success "Brewfile"
fi

# ==============================================================================
# Git commit and push
# ==============================================================================

# Check for changes
if git diff --quiet && git diff --staged --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    success "No changes to commit."
    exit 0
fi

# Show status
echo ""
info "Changes detected:"
git status --short
echo ""

if [ "$DRY_RUN" = true ]; then
    warn "Dry run - skipping commit and push."
    exit 0
fi

# Generate commit message if not provided
if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="Backup dotfiles $(date '+%Y-%m-%d %H:%M')"
fi

# Commit and push
git add -A
git commit -m "$COMMIT_MSG"

if git remote get-url origin &>/dev/null; then
    git push
    success "Pushed to remote."
else
    warn "No remote configured. Changes committed locally only."
fi

echo ""
success "Backup complete!"
