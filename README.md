# Dotfiles & Configs
Various personal dotfiles and scripts to help manage my workflow

## New Mac
One command installs everything and links the dotfiles:
```sh
curl -fsSL https://raw.githubusercontent.com/EricLamphere/configs/main/bootstrap | zsh
```
It installs the Xcode Command Line Tools, clones this repo to `~/Personal/configs` over HTTPS and runs `./install`. To also apply macOS settings: `... | zsh -s -- --with-macos`.

Afterwards, follow the "Manual steps left" list it prints, then check everything with `./setup --doctor`.

## Scripts
Everything is safe to re-run, and all of it supports `--dry-run` and `--help`. These scripts only work on macOS; the Windows dotfiles are kept for safekeeping.

| Script | What it does |
|---|---|
| `bootstrap` | Fresh Mac: Command Line Tools, clone, then `./install` |
| `install` | Homebrew + the `Brewfile`, herdr, Oh My Zsh + plugins, `./setup`, GitHub login |
| `setup` | Links the dotfiles into `~` with GNU Stow |
| `macos` | Applies macOS settings (`defaults write`) |
| `Brewfile` | Every Homebrew package and app |

### install
```sh
./install                     # everything (skips what's already done)
./install --dry-run           # preview
./install --only packages     # just `brew bundle`
./install --skip herdr,github
./install --with-macos        # also run ./macos
```
If a step fails, fix it and re-run; finished steps are skipped.

To add an app, add it to the `Brewfile` and run `./install --only packages`.

### setup
```sh
./setup --dry-run      # preview
./setup                # link every package
./setup git zsh        # link some packages
./setup --force        # move files that are in the way to ~/.dotfiles-backup/<time>/, then link
./setup --restow       # re-link (after renaming/deleting files in a package)
./setup --clean        # remove the links
./setup micro --full   # link, then run the package's .setup.sh (e.g. micro plugins)
./setup --doctor       # check links + required tools, change nothing
```
`--force` never deletes anything. It asks before moving each file unless you add `--yes`.

To try changes without touching your real home folder:
`DOTFILES_TARGET=/tmp/fakehome ./setup`

## Notes
* Each subdirectory in the dotfiles directory contains files/folders _exactly_ how they should be named
* Most (if not all) files and directories should be symlinked into the home directory (`~` on mac os)
* Folders apps write their own data into (`~/.config`, `~/.claude`, VS Code's `User` folder, etc.) are listed in `REAL_DIRS` in `setup`. They're kept as real folders, so only the tracked files inside them become links.
* Docker comes from the `docker-desktop` cask, which also provides the `docker` CLI, so don't add the `docker` formula alongside it.
