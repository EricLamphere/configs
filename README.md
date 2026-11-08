# Dotfiles & Configs
Various personal dotfiles and scripts to help manage my workflow

## New Mac
One command installs everything and links the dotfiles:
```sh
curl -fsSL https://raw.githubusercontent.com/EricLamphere/configs/main/setup/bootstrap | zsh
```
It installs the Xcode Command Line Tools, clones this repo to `~/Personal/configs` over HTTPS and runs `setup/install`. To also apply macOS settings: `... | zsh -s -- --with-macos`.

Afterwards, follow the "Manual steps left" list it prints, then check everything with `setup/setup --doctor`.

## Scripts
Everything is safe to re-run, and all of it supports `--dry-run` and `--help`. These scripts only work on macOS; the Windows dotfiles are kept for safekeeping.

| Script | What it does |
|---|---|
| `setup/bootstrap` | Fresh Mac: Command Line Tools, clone, then `setup/install` |
| `setup/install` | Homebrew + the `Brewfile`, herdr, Oh My Zsh + plugins, `setup/setup`, GitHub login |
| `setup/setup` | Links the dotfiles into `~` with GNU Stow |
| `setup/macos` | Applies macOS settings (`defaults write`) |
| `setup/Brewfile` | Every Homebrew package and app |

### install
```sh
setup/install                     # everything (skips what's already done)
setup/install --dry-run           # preview
setup/install --only packages     # just `brew bundle`
setup/install --skip herdr,github
setup/install --with-macos        # also run setup/macos
```
If a step fails, fix it and re-run; finished steps are skipped.

To add an app, add it to the `Brewfile` and run `setup/install --only packages`.

### setup
```sh
setup/setup --dry-run      # preview
setup/setup                # link every package
setup/setup git zsh        # link some packages
setup/setup --force        # move files that are in the way to ~/.dotfiles-backup/<time>/, then link
setup/setup --restow       # re-link (after renaming/deleting files in a package)
setup/setup --clean        # remove the links
setup/setup micro --full   # link, then run the package's .setup.sh (e.g. micro plugins)
setup/setup --doctor       # check links + required tools, change nothing
```
`--force` never deletes anything. It asks before moving each file unless you add `--yes`.

To try changes without touching your real home folder:
`DOTFILES_TARGET=/tmp/fakehome setup/setup`

## Notes
* Each subdirectory in the dotfiles directory contains files/folders _exactly_ how they should be named
* Most (if not all) files and directories should be symlinked into the home directory (`~` on mac os)
* Folders apps write their own data into (`~/.config`, `~/.claude`, VS Code's `User` folder, etc.) are listed in `REAL_DIRS` in `setup/setup`. They're kept as real folders, so only the tracked files inside them become links.
* Docker comes from the `docker-desktop` cask, which also provides the `docker` CLI, so don't add the `docker` formula alongside it.
