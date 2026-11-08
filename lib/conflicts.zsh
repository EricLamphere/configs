#!/bin/zsh
# Find and back up files that would block `stow` from linking a package.
# Source this file, don't run it.
#
# Expects these globals from ./setup:
#   DOTFILES_DIR, TARGET_DIR, BACKUP_DIR, STOW_IGNORE_REGEXES, DRY_RUN

# True if a path inside a package is ignored by stow (any part matches)
is_ignored_path() {
    local rel="$1"
    local part regex
    for part in "${(@s:/:)rel}"; do
        for regex in "${STOW_IGNORE_REGEXES[@]}"; do
            [[ "$part" =~ $regex ]] && return 0
        done
    done
    return 1
}

# Every file stow would link for a package, relative to the package root
package_files() {
    local pkg_dir="$DOTFILES_DIR/$1"
    local file rel
    for file in "$pkg_dir"/**/*(.DN) "$pkg_dir"/**/*(@DN); do
        rel=${file#$pkg_dir/}
        is_ignored_path "$rel" || print -r -- "$rel"
    done
}

# True if $TARGET_DIR/<rel> already resolves to the package's copy of <rel>,
# either directly or through a linked parent directory
is_linked() {
    local pkg="$1" rel="$2"
    local target="$TARGET_DIR/$rel"
    local source="$DOTFILES_DIR/$pkg/$rel"
    [[ -e "$target" && "${target:A}" == "${source:A}" ]]
}

# True if <path> is a link stow would treat as its own: relative, and pointing
# at <expected> (stow refuses absolute links even when they point correctly)
is_stow_link() {
    local candidate="$1" expected="$2"
    [[ -L "$candidate" && "$(readlink "$candidate")" != /* && "${candidate:A}" == "${expected:A}" ]]
}

# Print the target path (relative to $TARGET_DIR) that blocks linking <rel>,
# or nothing if there's no conflict. Parents are checked first so we never
# reach "through" a symlinked directory and touch whatever it points at.
find_blocker() {
    local pkg="$1" rel="$2"
    local pkg_dir="${DOTFILES_DIR:A}/$pkg"
    local -a parts=("${(@s:/:)rel}")
    local prefix="" i

    for (( i = 1; i < ${#parts}; i++ )); do
        prefix="${prefix:+$prefix/}${parts[i]}"
        local candidate="$TARGET_DIR/$prefix"
        if [[ -L "$candidate" ]]; then
            # A stow-folded directory link into this package is fine
            is_stow_link "$candidate" "$pkg_dir/$prefix" && return 0
            print -r -- "$prefix"
            return 0
        fi
        if [[ -e "$candidate" && ! -d "$candidate" ]]; then
            print -r -- "$prefix"
            return 0
        fi
        [[ -e "$candidate" ]] || return 0   # parent missing: stow creates it
    done

    local target="$TARGET_DIR/$rel"
    if [[ -L "$target" ]]; then
        is_stow_link "$target" "$pkg_dir/$rel" || print -r -- "$rel"
    elif [[ -e "$target" ]]; then
        print -r -- "$rel"
    fi
}

# Unique list of blocking paths for a package
find_conflicts() {
    local pkg="$1"
    local -aU blockers
    local rel blocker
    for rel in "${(@f)$(package_files "$pkg")}"; do
        [[ -n "$rel" ]] || continue
        blocker=$(find_blocker "$pkg" "$rel")
        [[ -n "$blocker" ]] && blockers+=("$blocker")
    done
    (( ${#blockers} )) && print -rl -- "${blockers[@]}"
    return 0
}

# Move each conflicting path into $BACKUP_DIR (keeping its relative path).
# Nothing is ever deleted. Returns 1 if the user declined any move.
backup_conflicts() {
    local pkg="$1"
    local -a conflicts=("${(@f)$(find_conflicts "$pkg")}")
    conflicts=(${conflicts:#})   # drop empty entries
    local declined=0 rel dest

    (( ${#conflicts} )) || return 0

    for rel in "${conflicts[@]}"; do
        dest="$BACKUP_DIR/$rel"
        if (( DRY_RUN )); then
            log_info "[dry-run] would back up ~/${rel} -> $dest"
            continue
        fi
        if ! prompt_confirm "~/$rel is in the way of '$pkg'. Move it to $BACKUP_DIR?"; then
            log_warn "Left ~/$rel in place; '$pkg' will not stow cleanly"
            declined=1
            continue
        fi
        if ! { mkdir -p "${dest:h}" && mv "$TARGET_DIR/$rel" "$dest"; }; then
            log_error "Couldn't move ~/$rel to $dest"
            declined=1
            continue
        fi
        log_info "Backed up ~/$rel -> $dest"
    done
    return $declined
}
