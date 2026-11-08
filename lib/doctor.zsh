#!/bin/zsh
# `./setup --doctor`: check the dotfiles are linked and the tools they rely on
# are installed. Changes nothing. Source this file, don't run it.
#
# Expects these globals/functions from ./setup and lib/:
#   REPO_DIR, DOTFILES_DIR, TARGET_DIR, REAL_DIRS, SKIP_PACKAGES,
#   package_files, find_blocker, is_linked, is_ignored_path

# Commands the shell config needs: "command|why"
DOCTOR_COMMANDS=(
    "brew|Homebrew"
    "stow|./setup"
    "git|everything"
    "micro|\$EDITOR"
    "mdcat|catodo on shell start"
    "gh|GitHub CLI"
)

# Paths that must exist: "path|why"
DOCTOR_PATHS=(
    "$HOME/.oh-my-zsh|Oh My Zsh"
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k|powerlevel10k theme"
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/git-open|git-open plugin"
)

# Where to look (under the target folder) for broken links into the repo: "dir|depth"
DOCTOR_LINK_SCAN=(
    ".|1"
    ".config|3"
    ".claude|3"
)

DOCTOR_PROBLEMS=0

doctor_fail() {
    log_error "$*"
    (( DOCTOR_PROBLEMS++ )) || true
}

doctor_check_links() {
    local pkg="$1"
    local rel blocker linked=0 missing=0
    for rel in "${(@f)$(package_files "$pkg")}"; do
        [[ -n "$rel" ]] || continue
        if is_linked "$pkg" "$rel"; then
            (( linked++ )) || true
            continue
        fi
        blocker=$(find_blocker "$pkg" "$rel")
        if [[ -n "$blocker" ]]; then
            doctor_fail "$pkg: ~/$rel is blocked by ~/$blocker (run ./setup --force $pkg)"
        else
            doctor_fail "$pkg: ~/$rel is not linked (run ./setup $pkg)"
        fi
        (( missing++ )) || true
    done
    (( missing )) || log_success "$pkg: $linked files linked"
}

# Directories apps write runtime data into must not be links into the repo
doctor_check_real_dirs() {
    local dir target
    for dir in "${REAL_DIRS[@]}"; do
        target="$TARGET_DIR/$dir"
        if [[ -L "$target" && "${target:A}" == "${REPO_DIR:A}"/* ]]; then
            doctor_fail "~/$dir links into the repo, so app data will be written there. Run ./setup --restow"
        fi
    done
}

# Broken links into the repo, and links to files stow should have ignored
doctor_check_stray_links() {
    local entry dir depth link rel
    local repo="${REPO_DIR:A}"
    for entry in "${DOCTOR_LINK_SCAN[@]}"; do
        dir="$TARGET_DIR/${entry%|*}"
        depth=${entry##*|}
        [[ -d "$dir" ]] || continue
        while IFS= read -r link; do
            # :A resolves as far as it can, so broken links into the repo match too
            [[ "${link:A}" == "$repo"/* ]] || continue
            if [[ ! -e "$link" ]]; then
                doctor_fail "Broken link: $link -> $(readlink "$link")"
                continue
            fi
            rel=${${link:A}#$repo/}
            if is_ignored_path "$rel"; then
                doctor_fail "Shouldn't be linked (stow-ignored file): $link"
            fi
        done < <(find "$dir" -maxdepth "$depth" -type l 2>/dev/null)
    done
}

doctor_check_tools() {
    local entry cmd why path_entry target
    for entry in "${DOCTOR_COMMANDS[@]}"; do
        cmd=${entry%%|*}
        why=${entry#*|}
        have "$cmd" || doctor_fail "Missing command: $cmd ($why)"
    done
    for path_entry in "${DOCTOR_PATHS[@]}"; do
        target=${path_entry%%|*}
        why=${path_entry#*|}
        [[ -e "$target" ]] || doctor_fail "Missing: $target ($why)"
    done
    [[ -f "$TARGET_DIR/.private-env" ]] || doctor_fail "Missing: ~/.private-env (run ./setup to copy the template)"
    if have brew && ! brew bundle check --no-upgrade --file="$REPO_DIR/Brewfile" &>/dev/null; then
        doctor_fail "Some Brewfile packages are missing (run: brew bundle check --no-upgrade --file=$REPO_DIR/Brewfile --verbose)"
    fi
}

run_doctor() {
    local -a packages=("$@")
    local pkg

    log_step "Links"
    for pkg in "${packages[@]}"; do
        (( ${SKIP_PACKAGES[(Ie)$pkg]} )) && continue
        doctor_check_links "$pkg"
    done
    doctor_check_real_dirs
    doctor_check_stray_links

    log_step "Tools"
    doctor_check_tools

    print ""
    if (( DOCTOR_PROBLEMS )); then
        log_error "$DOCTOR_PROBLEMS problem(s) found"
        return 1
    fi
    log_success "Everything looks good"
}
