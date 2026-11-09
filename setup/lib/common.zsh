#!/bin/zsh
# Shared helpers for setup/install, setup/setup and setup/macos. Source this file, don't run it.
#
# Expects (optionally) these globals from the caller:
#   DRY_RUN     1 = print side effects instead of running them
#   ASSUME_YES  1 = answer "yes" to every prompt_confirm

########################################
######## Output
########################################

C_RED=$'\033[0;31m'
C_GREEN=$'\033[0;32m'
C_YELLOW=$'\033[1;33m'
C_BLUE=$'\033[0;34m'
C_BOLD=$'\033[1m'
C_RESET=$'\033[0m'

log_info()    { print -r -- "${C_BLUE}[INFO]${C_RESET} $*"; }
log_success() { print -r -- "${C_GREEN}[OK]${C_RESET} $*"; }
log_warn()    { print -r -- "${C_YELLOW}[WARN]${C_RESET} $*" >&2; }
log_error()   { print -r -- "${C_RED}[ERROR]${C_RESET} $*" >&2; }
log_step()    { print -r -- ""; print -r -- "${C_BOLD}==> $*${C_RESET}"; }

die() {
    log_error "$*"
    exit 1
}

########################################
######## Helpers
########################################

# True if a command is on PATH
have() {
    command -v "$1" &>/dev/null
}

# Run a command, or only describe it when DRY_RUN=1
run() {
    if (( ${DRY_RUN:-0} )); then
        print -r -- "${C_YELLOW}[dry-run]${C_RESET} $*"
        return 0
    fi
    "$@"
}

# Ask a yes/no question on the terminal (works even when stdin is a pipe).
# Returns 0 for yes. ASSUME_YES=1 skips the question; no terminal means "no".
prompt_confirm() {
    local message="$1"
    local reply=""

    (( ${ASSUME_YES:-0} )) && return 0
    if [[ ! -r /dev/tty ]]; then
        log_warn "No terminal to ask '$message' - treating as 'no' (use --yes to auto-confirm)"
        return 1
    fi

    printf "%s [y/N] " "$message" > /dev/tty
    read -r reply < /dev/tty
    [[ "$reply" =~ ^[Yy](es)?$ ]]
}

# Path of the brew binary if Homebrew is installed (Apple Silicon or Intel)
brew_bin() {
    local candidate
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$candidate" ]]; then
            print -r -- "$candidate"
            return 0
        fi
    done
    return 1
}

# Put Homebrew on PATH for this process if it's installed
load_brew_env() {
    local brew
    brew=$(brew_bin) || return 0
    eval "$("$brew" shellenv)"
}
