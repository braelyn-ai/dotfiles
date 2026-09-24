#!/usr/bin/env zsh
BASE="$HOME/Developer"
DEV_LAYOUT="$BASE/dotfiles/.config/zellij/layouts/dev-tab.kdl"

CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
DIM="\033[2m"
BOLD="\033[1m"
RESET="\033[0m"
ESC=$'\x1b'

WORKTREE_PATHS=()

flush_stdin() {
    while read -rsk1 -t 0.01 2>/dev/null; do :; done
}

# Holds the terminal in no-echo for the whole loop. Without this the tty
# driver echoes each key on top of the one we print, so "12" arrives twice.
tty_raw_begin() {
    TTY_SAVED=$(stty -g 2>/dev/null)
    [[ -n "$TTY_SAVED" ]] && stty -echo -icanon min 1 time 0 2>/dev/null
}

tty_raw_end() {
    [[ -n "$TTY_SAVED" ]] && stty "$TTY_SAVED" 2>/dev/null
    TTY_SAVED=""
}

read_line() {
    local prompt="$1"
    local mode="${2:-text}"
    local maxlen="${3:-0}"
    local rc=0
    REPLY=""
    tty_raw_begin
    printf "%b" "$prompt"
    while true; do
        read -rsk1 ch
        case "$ch" in
            "$ESC") REPLY=""; printf "\n"; rc=1; break ;;
            $'\n'|$'\r')
                printf "\n"
                [[ -z "$REPLY" ]] && rc=1
                break
                ;;
            $'\x7f'|$'\b')
                if [[ -n "$REPLY" ]]; then
                    REPLY="${REPLY%?}"
                    printf "\b \b"
                fi
                ;;
            *)
                [[ "$mode" == digits && "$ch" != [0-9] ]] && continue
                [[ "$maxlen" -gt 0 && ${#REPLY} -ge "$maxlen" ]] && continue
                REPLY+="$ch"
                printf "%s" "$ch"
                ;;
        esac
    done
    tty_raw_end
    return $rc
}

# Reads a worktree number of any width, submitted with enter. Leaves the
# validated index in REPLY, or returns non-zero on cancel / bad input.
read_index() {
    local prompt="$1"
    local count=${#WORKTREE_PATHS[@]}

    read_line "$prompt" digits "${#count}" || return 1

    local selection="$REPLY"
    if [[ "$selection" -lt 1 ]] || [[ "$selection" -gt "$count" ]]; then
        printf "  ${RED}invalid selection${RESET}\n"
        sleep 1
        return 1
    fi

    REPLY="$selection"
    return 0
}

read_char() {
    local prompt="$1"
    tty_raw_begin
    printf "%b" "$prompt"
    read -rsk1 REPLY
    tty_raw_end
    printf "%s\n" "$REPLY"
    [[ "$REPLY" == "$ESC" ]] && return 1
    return 0
}

render() {
    WORKTREE_PATHS=()
    local buf=""
    local i=1

    buf+="$(printf "${BOLD}${CYAN}  WORKTREES${RESET}")\n"
    buf+="$(printf "${DIM}  ─────────────────────────────────────────${RESET}")\n"

    while IFS= read -r line; do
        local -a fields
        fields=(${=line})
        local wt_path="${fields[1]}"
        local hash="${fields[2]}"
        local branch="${fields[3]}"
        branch="${branch//[\[\]]/}"
        local short_path="${wt_path#$BASE/}"

        WORKTREE_PATHS+=("$wt_path")

        if [[ -n "$branch" ]]; then
            buf+="$(printf "  ${DIM}%2d${RESET}  ${GREEN}%-26s${RESET} ${DIM}%s${RESET}  ${YELLOW}%s${RESET}" "$i" "$short_path" "${hash:0:7}" "$branch")\n"
        else
            buf+="$(printf "  ${DIM}%2d${RESET}  ${GREEN}%-26s${RESET} ${DIM}%s${RESET}" "$i" "$short_path" "${hash:0:7}")\n"
        fi
        ((i++))
    done < <(git worktree list 2>/dev/null)

    buf+="$(printf "${DIM}  ─────────────────────────────────────────${RESET}")\n"
    buf+="$(printf "  ${DIM}[n]ew  [d]elete  [o]pen  [q]uit  ${RESET}${DIM}number + enter  esc cancel${RESET}")\n"

    printf "\033[2J\033[H"
    printf "%b" "$buf"
}

prompt_new() {
    read_line "\n  ${CYAN}branch name:${RESET} " || return

    local branch_name="$REPLY"
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    local wt_dir="${repo_root}/.claude/worktrees/${branch_name}"

    printf "  creating worktree ${GREEN}%s${RESET}..." "$branch_name"

    local output
    if output=$(git worktree add "$wt_dir" -b "$branch_name" 2>&1); then
        printf " ${GREEN}done${RESET}\n"
    elif output=$(git worktree add "$wt_dir" "$branch_name" 2>&1); then
        printf " ${GREEN}done${RESET} ${DIM}(existing branch)${RESET}\n"
    else
        printf " ${RED}failed${RESET}\n"
        printf "  ${RED}%s${RESET}\n" "$output"
        sleep 2
        return
    fi

    printf "  spawning dev tab...\n"
    sleep 0.5
    zellij action new-tab --layout "$DEV_LAYOUT" --cwd "$wt_dir" --name "$branch_name"
}

prompt_delete() {
    local count=${#WORKTREE_PATHS[@]}
    if [[ "$count" -le 1 ]]; then
        printf "\n  ${RED}nothing to delete (main worktree can't be removed)${RESET}\n"
        sleep 1.5
        return
    fi

    read_index "\n  ${RED}delete which worktree? [1-${count}]:${RESET} " || return

    local target="${WORKTREE_PATHS[$REPLY]}"
    local short="${target#$BASE/}"

    read_char "  ${RED}remove ${BOLD}${short}${RESET}${RED}? [y/N]:${RESET} " || return

    if [[ "$REPLY" =~ ^[yY]$ ]]; then
        if git worktree remove "$target" --force 2>/dev/null; then
            printf "  ${GREEN}removed${RESET}\n"
        else
            printf "  ${RED}failed to remove worktree${RESET}\n"
        fi
        sleep 1
    fi
}

prompt_open() {
    local count=${#WORKTREE_PATHS[@]}
    read_index "\n  ${CYAN}open which worktree? [1-${count}]:${RESET} " || return

    local target="${WORKTREE_PATHS[$REPLY]}"
    local name="${target:t}"

    printf "  spawning dev tab for ${GREEN}%s${RESET}...\n" "$name"
    sleep 0.5
    zellij action new-tab --layout "$DEV_LAYOUT" --cwd "$target" --name "$name"
}

while true; do
    render
    flush_stdin

    key=""
    read -rsk1 -t 5 key
    case "$key" in
        n) prompt_new ;;
        d) prompt_delete ;;
        o) prompt_open ;;
        q) exit 0 ;;
    esac
done
