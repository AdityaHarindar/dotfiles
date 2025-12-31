# Enable Powerlevel10k instant prompt (should stay at top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh-My-Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme: Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh-My-Zsh plugins
plugins=(
  git
  brew
  docker
  docker-compose
  kubectl
  helm
  golang
  aws
  gcloud
  terraform
  gh
  npm
  z
  extract
  jsontools
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# ==============================================================================
# PATH Configuration
# ==============================================================================

export PATH="$HOME/.local/bin:$PATH"          # uv, uvx, local binaries
export PATH="$HOME/.claude/local:$PATH"       # Claude CLI
export PATH="$HOME/go/bin:$PATH"              # Go binaries (GOPATH/bin)
export PATH="$HOME/bin:$PATH"                 # Personal scripts
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"  # kubectl plugins

# ==============================================================================
# Environment Variables
# ==============================================================================

# Go
export GOPATH=$HOME/go

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# kubectl diff with delta
export KUBECTL_EXTERNAL_DIFF="delta --side-by-side"

# Docker (Colima)
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"

# ==============================================================================
# Tool Initializations
# ==============================================================================

# GVM (Go Version Manager)
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# Atuin shell history
eval "$(atuin init zsh)"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ==============================================================================
# FZF Configuration
# ==============================================================================

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview "bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || echo {}"
'

# ==============================================================================
# Aliases - Git
# ==============================================================================

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
alias gaa="git add --all"

# ==============================================================================
# Aliases - Kubernetes
# ==============================================================================

alias k="kubectl"
alias kx="kubectx"
alias kns="kubens"
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

# ==============================================================================
# Aliases - Docker
# ==============================================================================

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

# ==============================================================================
# Aliases - Modern CLI Replacements
# ==============================================================================

alias cat="bat"
alias ls="eza --icons --group-directories-first 2>/dev/null || lsd"
alias ll="eza -la --icons --group-directories-first 2>/dev/null || lsd -la"
alias lt="eza -la --icons --tree --level=2 2>/dev/null || lsd --tree --depth 2"
alias tree="eza --tree 2>/dev/null || tree"
# alias grep="rg"   # Uncomment if you want rg as default
# alias find="fd"   # Uncomment if you want fd as default

# ==============================================================================
# Aliases - Navigation
# ==============================================================================

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# ==============================================================================
# Aliases - Development
# ==============================================================================

alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias mk="make"
alias c="code ."
alias v="nvim"

# ==============================================================================
# Aliases - Utility
# ==============================================================================

alias ip="curl -s ifconfig.me"
alias weather="curl wttr.in"
alias ports="lsof -i -P -n | grep LISTEN"
alias path='echo $PATH | tr ":" "\n"'
alias reload="source ~/.zshrc"
alias cls="clear"
alias h="history"
alias j="jobs -l"

# ==============================================================================
# Functions
# ==============================================================================

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1" }

# Git clone and cd
gclone() { git clone "$1" && cd "$(basename "$1" .git)" }

# Find and kill process by port
killport() {
  lsof -ti:$1 | xargs kill -9 2>/dev/null || echo "No process on port $1"
}

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
myip() {
  curl -s ipinfo.io | jq -r '"IP: \(.ip)\nCity: \(.city)\nRegion: \(.region)\nCountry: \(.country)"'
}

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

# ==============================================================================
# Load Powerlevel10k config
# ==============================================================================

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
