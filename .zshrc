# Exit early if not running in zsh
[[ -z "$ZSH_VERSION" ]] && return

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ls colors (made with https://geoff.greer.fm/lscolors/)
export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS='no=00:fi=00:di=01;34:ln=00;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=41;33;01:ex=00;32:*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32:*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31:*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35:*.dl=01;35:*.gl=01;35:*.wmv=01;35:*.aiff=00;32:*.au=00;32:*.mid=00;32:*.mp3=00;32:*.ogg=00;32:*.voc=00;32:*.wav=00;32:*.patch=00;34:*.o=00;32:*.so=01;35:*.ko=01;31:*.la=00;33'

# Prompt (was the "philips" oh-my-zsh theme)
autoload -U colors && colors
setopt PROMPT_SUBST
if [[ $UID -eq 0 ]]; then NCOLOR="red"; else NCOLOR="green"; fi
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg_no_bold[red]%}%B"
ZSH_THEME_GIT_PROMPT_SUFFIX="%b%{$fg_bold[blue]%})%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="*"

function git_prompt_info() {
  local ref
  ref=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || ref=$(git describe --tags --exact-match HEAD 2>/dev/null) \
    || ref=$(git rev-parse --short HEAD 2>/dev/null) \
    || return 0
  local dirty
  if [[ -n "$(git status --porcelain --ignore-submodules=dirty 2>/dev/null)" ]]; then
    dirty="$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    dirty="$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
  echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${ref//\%/%%}${dirty}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}

RPROMPT='[%*]'
PROMPT='%{$fg[$NCOLOR]%}%B%n%b%{$reset_color%}@${${(%):-%m}/#US*/mbp}:%{$fg[blue]%}%B%c/%b%{$reset_color%} $(git_prompt_info)%(!.🔓.%(?.⛓️.⛓️‍💥))  '

# Completion
autoload -Uz compinit
compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Directory navigation conveniences
setopt auto_cd auto_pushd pushd_ignore_dups pushdminus
alias -g ...='../..'
alias -g ....='../../..'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias md='mkdir -p'
alias rd='rmdir'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias lsa='ls -lah'

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify share_history

# Key bindings (Home/End/Delete/word-nav; adapted from oh-my-zsh's key-bindings.zsh)
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() { echoti smkx }
  function zle-line-finish() { echoti rmkx }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

bindkey -e

[[ -n "${terminfo[kpp]}" ]] && bindkey "${terminfo[kpp]}" up-line-or-history
[[ -n "${terminfo[knp]}" ]] && bindkey "${terminfo[knp]}" down-line-or-history

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-beginning-search

[[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]}" ]] && bindkey "${terminfo[kend]}" end-of-line
[[ -n "${terminfo[kcbt]}" ]] && bindkey "${terminfo[kcbt]}" reverse-menu-complete

bindkey '^?' backward-delete-char
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey "${terminfo[kdch1]}" delete-char
else
  bindkey "^[[3~" delete-char
  bindkey "^[3;5~" delete-char
fi

bindkey '^[[3;5~' kill-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

bindkey '\ew' kill-region
bindkey '^r' history-incremental-search-backward
bindkey ' ' magic-space

autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line
bindkey "^[m" copy-prev-shell-word

# Homebrew, if installed (macOS ARM/Intel, or Linuxbrew)
if ! command -v brew &>/dev/null; then
  for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew \
               /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [[ -x "$_brew" ]]; then
      eval "$("$_brew" shellenv)"
      break
    fi
  done
  unset _brew
fi
# shellenv sets HOMEBREW_PREFIX; fall back for a brew already on PATH
if [[ -z "$HOMEBREW_PREFIX" ]] && command -v brew &>/dev/null; then
  export HOMEBREW_PREFIX="$(brew --prefix)"
fi

# zsh-autosuggestions / zsh-syntax-highlighting (Homebrew or distro packages)
for _plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  for _dir in \
    "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/$_plugin}" \
    "/usr/share/zsh/plugins/$_plugin" \
    "/usr/share/$_plugin" \
    "/usr/local/share/$_plugin"; do
    if [[ -n "$_dir" && -r "$_dir/$_plugin.zsh" ]]; then
      source "$_dir/$_plugin.zsh"
      break
    fi
  done
done
unset _plugin _dir

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

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
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"

# postgresql client from Homebrew, if installed
if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/opt/postgresql@17/bin" ]]; then
  export PATH="$HOMEBREW_PREFIX/opt/postgresql@17/bin:$PATH"
fi


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

command -v atuin &>/dev/null && eval "$(atuin ai init zsh)"

cockpit() {
  local session="${PWD##*/}"
  if zellij list-sessions 2>/dev/null | sed $'s/\x1b\[[0-9;]*m//g' | grep -q "^${session} "; then
    zellij attach "$session"
  else
    zellij -l cockpit -s "$session"
  fi
}
