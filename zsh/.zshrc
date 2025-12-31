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
  kubectl
  helm
  golang
  aws
  gcloud

  zsh-autosuggestions      # Fish-like suggestions (install separately)
  zsh-syntax-highlighting  # Command highlighting (install separately)
  fzf                      # Fuzzy finder integration
  z                        # Smart directory jumping
  aliases                  # List aliases with `als`
  jsontools                # pp_json, is_json, urlencode/decode
  httpie                   # HTTP client completions
  terraform                # tf completions & aliases
  gh                       # GitHub CLI completions
  rust                     # Cargo/rustc completions
  npm                      # Node completions
  extract                  # `x` to extract any archive
)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# User configuration

# PATH additions
export PATH="$HOME/.local/bin:$PATH"          # uv, uvx, claude-monitor
export PATH="$HOME/.claude/local:$PATH"       # Claude CLI
export PATH="$HOME/go/bin:$PATH"              # Go binaries (GOPATH/bin)

# GVM (Go Version Manager)
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# Kubectl diff with delta
export KUBECTL_EXTERNAL_DIFF="delta --side-by-side"

# Atuin shell history
eval "$(atuin init zsh)"

# Load Powerlevel10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Fun startup (optional)
# fortune | cowsay
export PATH="$HOME/bin:$PATH"

alias dotbackup="~/.dotfiles/backup.sh"