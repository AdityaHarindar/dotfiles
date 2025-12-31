# macOS Development Environment Setup

A comprehensive guide and dotfiles repository for setting up a new macOS machine for software engineering and architecture work.

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Shell Setup](#shell-setup)
- [CLI Tools](#cli-tools)
- [Git Configuration](#git-configuration)
- [Docker Setup](#docker-setup)
- [Kubernetes Tools](#kubernetes-tools)
- [Cloud CLIs](#cloud-clis)
- [Language Environments](#language-environments)
- [Aliases & Functions](#aliases--functions)
- [Symlink Instructions](#symlink-instructions)

---

## Quick Start

```bash
# Clone this repo
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles

# Run the bootstrap script
cd ~/.dotfiles && ./install.sh
```

Or manually follow the sections below.

---

## Prerequisites

### 1. Xcode Command Line Tools

```bash
xcode-select --install
```

### 2. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 3. Install all packages from Brewfile

```bash
cd ~/.dotfiles && brew bundle
```

---

## Shell Setup

### Oh-My-Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Powerlevel10k Theme

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### Essential Plugins (External)

```bash
# zsh-autosuggestions - Fish-like suggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting - Command highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### FZF Integration

```bash
$(brew --prefix)/opt/fzf/install --all
```

### Atuin (Shell History)

```bash
brew install atuin
# Add to .zshrc: eval "$(atuin init zsh)"
```

### Symlink Configs

```bash
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/zsh/.p10k.zsh ~/.p10k.zsh
```

---

## CLI Tools

### Current Setup (Homebrew Packages)

| Category | Tools |
|----------|-------|
| **Core** | git, neovim, htop, tree, watch |
| **Modern Replacements** | bat (cat), ripgrep (grep), lsd (ls), fd (find), git-delta (diff), fzf (fuzzy finder) |
| **Kubernetes** | kubectl, helm, k9s, kubectx, minikube |
| **Docker** | colima, lazydocker |
| **Git** | lazygit, gh (GitHub CLI) |
| **Security** | trivy, sslscan |
| **Dev Tools** | yamllint, swagger-codegen, pack |
| **Shell** | atuin (history) |
| **Misc** | fortune, cowsay |

### Install All at Once

```bash
brew bundle --file=~/.dotfiles/Brewfile
```

### Recommended Additions

```bash
# Better CLI tools
brew install eza           # Modern ls (better than lsd)
brew install fd            # Modern find
brew install jq yq         # JSON/YAML processors
brew install tldr          # Simplified man pages
brew install glow          # Markdown renderer
brew install difftastic    # Structural diff

# Container tools
brew install lazydocker    # TUI for docker
brew install dive          # Analyze docker images
brew install ctop          # Container metrics

# System monitoring
brew install procs         # Better ps
brew install dust          # Better du
brew install duf           # Better df
brew install bottom        # Better top (btm)

# Productivity
brew install httpie        # Better curl
```

---

## Git Configuration

### Current Config

```ini
[user]
    name = AdityaHarindar
    email = aditya.harindar@gmail.com

[alias]
    st = status
    ps = push
    ci = commit
    pl = pull
    ft = fetch
    br = branch
    co = checkout
    d = diff --color=always

[pull]
    rebase = true

[push]
    autoSetupRemote = true

[url "git@github.com:"]
    insteadOf = https://github.com/

[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    side-by-side = false
    line-numbers = true
    syntax-theme = Solarized (dark)
    navigate = true
```

### Symlink

```bash
ln -sf ~/.dotfiles/git/.gitconfig ~/.gitconfig
```

### Recommended Git Aliases to Add

```bash
git config --global alias.lg "log --oneline --graph -20"
git config --global alias.lga "log --oneline --graph --all -20"
git config --global alias.ds "diff --staged"
git config --global alias.aa "add --all"
git config --global alias.cm "commit -m"
git config --global alias.ca "commit --amend"
git config --global alias.cb "checkout -b"
git config --global alias.sw "switch"
git config --global alias.swc "switch -c"
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
```

---

## Docker Setup

### Colima (Docker runtime for macOS)

```bash
brew install colima docker docker-compose

# Start colima (run once, persists across reboots)
colima start --cpu 4 --memory 8 --disk 60

# Verify
docker ps
```

### Docker Configuration

```bash
# Set kubectl to use colima's docker
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
```

---

## Kubernetes Tools

### Essential Tools

```bash
brew install kubernetes-cli    # kubectl
brew install helm              # Package manager
brew install kubectx           # Context/namespace switcher (includes kubens)
brew install k9s               # TUI for kubernetes
brew install minikube          # Local kubernetes
brew install kn                # Knative CLI
```

### kubectl Plugins (via krew)

```bash
# Install krew
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm64/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# Add to PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Useful plugins
kubectl krew install ctx        # Context switcher
kubectl krew install ns         # Namespace switcher
kubectl krew install neat       # Clean up yaml output
kubectl krew install tree       # Show resource hierarchy
kubectl krew install images     # Show images used in cluster
```

### kubectl with Delta

Add to `.zshrc`:
```bash
export KUBECTL_EXTERNAL_DIFF="delta --side-by-side"
```

---

## Cloud CLIs

### AWS CLI

```bash
brew install awscli

# Configure
aws configure
# Or use SSO
aws configure sso
```

### Google Cloud CLI

```bash
brew install --cask google-cloud-sdk

# Initialize
gcloud init
gcloud auth login
gcloud auth application-default login
```

### Azure CLI (if needed)

```bash
brew install azure-cli
az login
```

---

## Language Environments

### Go (via GVM)

```bash
# Install GVM
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

# Add to .zshrc
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# Install Go versions
gvm install go1.24.6 -B
gvm use go1.24.6 --default

# Set GOPATH
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

### Node.js (via nvm or fnm)

```bash
# Option 1: nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Option 2: fnm (faster)
brew install fnm
eval "$(fnm env --use-on-cd)"

# Install Node
nvm install --lts
# or
fnm install --lts
```

### Python (via pyenv or uv)

```bash
# Option 1: pyenv
brew install pyenv
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Option 2: uv (faster, modern)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Python
pyenv install 3.14.2
pyenv global 3.14.2
# or
uv python install 3.14
```

### Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

---

## Aliases & Functions

These are included in the `.zshrc` file. Here's a reference:

### Git Aliases

```bash
alias g="git"
alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline --graph -20"
alias gla="git log --oneline --graph --all -20"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gp="git pull"
alias gpu="git push -u origin HEAD"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias grb="git rebase"
alias grbi="git rebase -i"
alias gst="git stash"
alias gstp="git stash pop"
```

### Kubernetes Aliases

```bash
alias k="kubectl"
alias kx="kubectx"
alias kn="kubens"
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias kgd="kubectl get deployments"
alias kga="kubectl get all"
alias kgn="kubectl get nodes"
alias kd="kubectl describe"
alias kl="kubectl logs"
alias klf="kubectl logs -f"
alias ke="kubectl exec -it"
alias kaf="kubectl apply -f"
alias kdf="kubectl delete -f"
alias kdp="kubectl delete pod"
alias kpf="kubectl port-forward"
```

### Docker Aliases

```bash
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias di="docker images"
alias drm="docker rm"
alias drmi="docker rmi"
alias dprune="docker system prune -af"
alias dlogs="docker logs -f"
alias dexec="docker exec -it"
```

### Modern CLI Defaults

```bash
alias cat="bat"
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first"
alias lt="eza -la --icons --tree --level=2"
alias tree="eza --tree"
alias grep="rg"
alias find="fd"
alias top="btm"
alias du="dust"
alias df="duf"
alias ps="procs"
```

### Navigation

```bash
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"
```

### Development

```bash
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias mk="make"
alias c="code ."
alias v="nvim"
```

### Utility

```bash
alias ip="curl -s ifconfig.me"
alias weather="curl wttr.in"
alias ports="lsof -i -P -n | grep LISTEN"
alias path='echo $PATH | tr ":" "\n"'
alias reload="source ~/.zshrc"
alias cls="clear"
```

### Functions

```bash
# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1" }

# Git clone and cd
gclone() { git clone "$1" && cd "$(basename "$1" .git)" }

# Find and kill process by port
killport() { lsof -ti:$1 | xargs kill -9 2>/dev/null || echo "No process on port $1" }

# Quick HTTP server
serve() { python3 -m http.server ${1:-8000} }

# Docker shell into container
dsh() { docker exec -it "$1" /bin/sh }

# Kubernetes port-forward shortcut
kpf() { kubectl port-forward "$1" "$2" }

# Show listening ports
listening() {
  if [ $# -eq 0 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P
  else
    sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i "$1"
  fi
}

# Extract any archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.tar.xz)  tar xJf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Quick notes
note() { echo "$(date '+%Y-%m-%d %H:%M'): $*" >> ~/.notes }
notes() { cat ~/.notes 2>/dev/null || echo "No notes yet" }

# JSON pretty print from clipboard
jsonclip() { pbpaste | jq . }

# Get public IP with location
myip() { curl -s ipinfo.io | jq -r '"IP: \(.ip)\nCity: \(.city)\nRegion: \(.region)\nCountry: \(.country)"' }
```

---

## FZF Configuration

Add to `.zshrc`:

```bash
# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview "bat --style=numbers --color=always --line-range :500 {}"
'

# Git branch switcher with fzf
fco() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" | fzf --height 40% --reverse) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/origin/##")
}

# Git log browser with fzf
fgl() {
  git log --oneline --graph --color=always |
  fzf --ansi --no-sort --reverse --preview 'git show --color=always {1}' |
  grep -o '[a-f0-9]\{7\}' | head -1 | xargs git show
}

# Kill process with fzf
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}
```

---

## Symlink Instructions

After cloning this repo, create symlinks to use the configs:

```bash
# Backup existing configs (optional)
mkdir -p ~/.config-backup
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.config-backup/
[ -f ~/.p10k.zsh ] && mv ~/.p10k.zsh ~/.config-backup/
[ -f ~/.gitconfig ] && mv ~/.gitconfig ~/.config-backup/

# Create symlinks
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/zsh/.p10k.zsh ~/.p10k.zsh
ln -sf ~/.dotfiles/git/.gitconfig ~/.gitconfig

# Reload shell
source ~/.zshrc
```

---

## Maintenance

### Update Brewfile from current system

```bash
brew bundle dump --file=~/.dotfiles/Brewfile --force
```

### Update all packages

```bash
brew update && brew upgrade
```

### Clean up

```bash
brew cleanup
brew autoremove
```

---

## Troubleshooting

### Powerlevel10k fonts not rendering

Install a Nerd Font:
```bash
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```
Then set your terminal font to "MesloLGS NF".

### Slow shell startup

Profile your zsh startup:
```bash
time zsh -i -c exit
```

Check which plugin is slow:
```bash
zsh -xv 2>&1 | ts -i "%.s" > zsh_startup.log
```

### Colima not starting

```bash
colima delete
colima start --cpu 4 --memory 8 --disk 60
```

---

## License

MIT - Feel free to use and modify.
