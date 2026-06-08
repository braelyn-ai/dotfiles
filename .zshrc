# Exit early if not running in zsh
[[ -z "$ZSH_VERSION" ]] && return

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Install Oh My Zsh if it doesn't exist
if [[ ! -d "$ZSH" ]]; then
  echo "Oh My Zsh not found. Installing..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH" 2>/dev/null || {
    echo "Failed to install Oh My Zsh. Please check your internet connection."
  }
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="philips"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git macos brew docker kubectl zsh-autosuggestions zsh-syntax-highlighting)

# Install zsh-autosuggestions if not present
if [[ ! -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions" ]]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions" 2>/dev/null || true
fi

# Install zsh-syntax-highlighting if not present
if [[ ! -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting" ]]; then
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || true
fi

# Source Oh My Zsh if it exists
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Custom prompt (only if Oh My Zsh loaded successfully)
if [[ -n "$ZSH" ]] && type git_prompt_info &>/dev/null; then
  PROMPT='%{$fg[$NCOLOR]%}%B%n%b%{$reset_color%}@${${(%):-%m}/#US*/mbp}:%{$fg[blue]%}%B%c/%b%{$reset_color%} $(git_prompt_info)%(!.🔓.%(?.⛓️.⛓️‍💥))  '
fi

# bun completions
[ -s "/Users/braelyn/.bun/_bun" ] && source "/Users/braelyn/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Source local env if it exists
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# Atuin shell history
if [[ -f "$HOME/.atuin/bin/env" ]]; then
  . "$HOME/.atuin/bin/env"
  command -v atuin &>/dev/null && eval "$(atuin init zsh)"
fi

# opencode
export PATH=/Users/braelyn/.opencode/bin:$PATH
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"


# Load Angular CLI autocompletion.
if [[ -f "$HOME/.local/bin/ng" ]]; then
  source <(ng completion script);
fi

# Welcome message with ASCII art and fortune

# Install figlet if not present
if ! command -v figlet &>/dev/null; then
  if command -v brew &>/dev/null; then
    echo "Installing figlet..."
    brew install figlet 2>/dev/null || true
  elif command -v apt &>/dev/null; then
    echo "Installing figlet..."
    sudo apt install -y figlet 2>/dev/null || true
  fi
fi

# Install fortune if not present
if ! command -v fortune &>/dev/null; then
  if command -v brew &>/dev/null; then
    echo "Installing fortune..."
    brew install fortune 2>/dev/null || true
  elif command -v apt &>/dev/null; then
    echo "Installing fortune..."
    sudo apt install -y fortune-mod 2>/dev/null || true
  fi
fi

# Install epic figlet font if not present
if command -v figlet &>/dev/null; then
  FIGLET_FONTDIR="$(figlet -I2 2>/dev/null)"
  if [[ -n "$FIGLET_FONTDIR" ]] && [[ ! -f "$FIGLET_FONTDIR/epic.flf" ]]; then
    echo "Installing epic figlet font..."
    sudo curl -so "$FIGLET_FONTDIR/epic.flf" \
      https://raw.githubusercontent.com/xero/figlet-fonts/master/Epic.flf 2>/dev/null || true
  fi
fi

# Display ASCII art greeting
if command -v figlet &>/dev/null; then
  figlet -f epic "hello baddie"
else
  echo "==================================="
  echo "      HELLO BADDIE"
  echo "==================================="
fi

# Display fortune
if command -v fortune &>/dev/null; then
  echo ""
  fortune
  echo ""
fi
export PATH="$HOME/.npm-global/bin:$PATH"

# Created by `pipx` on 2026-02-16 06:59:14
export PATH="$PATH:$HOME/.local/bin"

# OpenClaw Completion
[[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"
# Browserbase API
[[ -f "$HOME/.openclaw/secrets/browserbase.env" ]] && source "$HOME/.openclaw/secrets/browserbase.env"

eval "$(atuin ai init zsh)"

cockpit() {
  local session="${PWD##*/}"
  if zellij list-sessions 2>/dev/null | sed $'s/\x1b\[[0-9;]*m//g' | grep -q "^${session} "; then
    zellij attach "$session"
  else
    zellij -l cockpit -s "$session"
  fi
}
