# Dotfiles Repository - Agent Instructions

## Overview
This is a personal dotfiles configuration management repository that uses GNU Stow for symlink-based installation. The repository manages shell configurations, editor settings, git configurations, and application preferences across macOS and Windows environments.

## Repository Purpose
- Centralized management of dotfiles and configuration files
- Quick setup of development environments on new machines
- Version control for personal configurations
- Automated installation and symlinking of dotfiles using GNU Stow

## Directory Structure

```
/Users/ericlamphere/Personal/configs/
├── .claude/                    # Claude Code agent configurations (for this repo only)
│   ├── agents/                 # Custom agent definitions
│   └── settings.local.json     # Local Claude settings
├── .git/                       # Git version control
├── .gitignore                  # Git ignore patterns
├── AGENTS.md                   # This file - agent instructions
├── README.md                   # User-facing documentation
├── bootstrap                   # One-command fresh-Mac setup (curl | zsh)
├── install                     # Package/tool installer (macOS only)
├── Brewfile                    # Homebrew packages for install
├── setup                       # GNU Stow-based dotfiles linker
├── macos                       # macOS defaults
├── lib/                        # Shared zsh helpers for the scripts
├── config_exports/             # Exported application configurations
│   └── iTerm2/                 # iTerm2 terminal configurations
└── dotfiles/                   # All managed dotfiles
    ├── mac/                    # macOS-specific configurations
    │   ├── claude/             # Claude Code global configuration (~/.claude/)
    │   ├── duckdb/             # DuckDB database configuration
    │   ├── git/                # Git configuration and aliases
    │   ├── github/             # GitHub CLI configuration
    │   ├── herdr/              # Herdr (coding agent runtime) app configuration
    │   ├── micro/              # Micro text editor (primary editor)
    │   ├── nano/               # Nano text editor with improved syntax
    │   ├── powerlevel10k/      # Powerlevel10k ZSH theme configuration
    │   ├── private/            # Template for machine-specific env vars
    │   ├── rstudio/            # RStudio IDE configuration
    │   ├── stow/               # GNU Stow global ignore rules
    │   ├── vscode/             # Visual Studio Code settings
    │   ├── w3m/                # W3M terminal web browser
    │   └── zsh/                # ZSH shell configuration (primary shell)
    └── windows/                # Windows-specific configurations
        └── powershell/         # PowerShell configuration
```

## Key Files and Scripts

### Root-Level Scripts

All scripts are zsh, macOS-only (except `setup --os windows`), safe to re-run, and support `--help` and `--dry-run`. Shared helpers (logging, `run` for dry-run, `prompt_confirm`, Homebrew detection) live in `lib/common.zsh`.

| File | Purpose |
|---|---|
| `bootstrap` | Fresh-Mac entry point: `curl -fsSL https://raw.githubusercontent.com/EricLamphere/configs/main/bootstrap \| zsh`. Installs Xcode CLT, clones the repo over HTTPS to `~/Personal/configs` (`CONFIGS_DIR`/`CONFIGS_BRANCH` override), then runs `./install`. Standalone (no `lib/` imports). |
| `install` | Runs named steps in order, each skipped if already done: `xcode homebrew packages herdr ohmyzsh zsh_plugins dotfiles github` (+ optional `macos`). Flags: `--only`, `--skip`, `--with-macos`, `--list`, `-y`. Each step runs in a subshell with errexit; on failure it stops and tells you to re-run. |
| `Brewfile` | All Homebrew formulae/casks, installed with `brew bundle --no-upgrade`. Add apps here, not to `install`. |
| `setup` | GNU Stow linker (details below). |
| `macos` | `defaults write` settings as `domain\|key\|type\|value` entries; only writes values that differ, restarts Finder/Dock. |
| `lib/conflicts.zsh` | Finds paths that block stow and moves them to a backup folder for `setup --force`. |
| `lib/doctor.zsh` | `setup --doctor` health checks. |

#### `setup`

```bash
./setup [OPTIONS] [PACKAGE...]   # no packages = all
./setup --dry-run                # -n / -d
./setup git zsh                  # -p/--package/--packages is accepted but optional
./setup --force [--yes]          # move conflicts to ~/.dotfiles-backup/<timestamp>/, then link
./setup --restow | --clean | --list | --doctor
./setup micro --full             # also run the package's .setup.sh
./setup --os windows
```

**Behaviour:**
- Repo location is derived from the script path (not hardcoded); the target is `$HOME` unless `DOTFILES_TARGET` is set (use a scratch dir to test). `DOTFILES_BACKUP_DIR` overrides the backup root.
- `stow` package goes first (`PRIORITY_PACKAGES`); `private` is never stowed. `~/.private-env` is copied from its template if missing.
- `STOW_IGNORE_REGEXES` (`.setup.sh`, `.DS_Store`, `README*`) are passed to stow and used by conflict/doctor checks.
- `REAL_DIRS` (`~/.config`, `~/.claude`, `~/.claude/skills`, `~/.config/micro`, `~/.config/herdr-app{,/layouts,/themes}`, `~/.w3m`, VS Code's `User` dir) are created as real directories before stowing so stow never folds them into links (which would make apps write runtime data into the repo). Add to this list when a package targets a folder an app writes into.
- `--force` never deletes: it checks parent paths first (never follows a symlinked directory), treats correctly-pointing relative links as fine, and moves anything else (files, foreign or absolute links) to the backup folder after asking (or automatically with `--yes`).
- Unknown options and unknown package names are errors. Each package is attempted; failures are summarised and give exit status 1.
- `--doctor` reports unlinked/blocked files, `REAL_DIRS` that are links into the repo, broken or stow-ignored links into the repo, missing commands (`brew stow git micro mdcat gh`), missing Oh My Zsh/powerlevel10k/git-open/`~/.private-env`, and missing Brewfile packages.

### Configuration Documentation

#### `README.md`
User-facing documentation with basic setup instructions and usage notes.

#### `AGENTS.md` (this file)
Comprehensive documentation for AI agents working with this repository, including:
- Detailed repository structure
- Script functionality and behavior
- Package organization
- Code style guidelines
- Common workflows

## Dotfiles Packages (macOS)

### Claude Code

#### `claude/` - Claude Code Global Configuration
**Files:**
- `.claude/settings.json` - Application settings (plugin config, thinking mode)
- `.claude/agents/personal-assistant.md` - Personal productivity agent definition
- `.claude/agents/research-assistant.md` - Research and fact-checking agent definition
- `.claude/rules/common/*.md` - Global coding rules loaded into every project
- `.claude/rules/python/*.md` - Python-specific coding rules (applied when editing .py files)
- `.claude/skills/sync-meeting-notes/` - Skill that syncs OpenWhispr meeting summaries into the Obsidian daily journal (scripts + pytest tests)

**Symlink behavior:** Because `~/.claude` already exists as a real directory (Claude Code writes runtime data there), stow creates individual symlinks for the managed files/subdirectories rather than symlinking the whole `.claude` directory. The symlinks created are:
- `~/.claude/settings.json` → repo
- `~/.claude/agents` → repo (entire directory symlinked)
- `~/.claude/rules` → repo (entire directory symlinked)
- `~/.claude/skills/<name>` → repo (one symlink per skill; `~/.claude/skills` itself is a real directory that also holds Claude-managed `learned/` and `synced/` skills)

**What is NOT tracked (runtime/ephemeral):**
- `~/.claude/settings.local.json` - Session-specific permission allowlists
- `~/.claude/agent-memory/` - Runtime agent memory written during sessions
- `~/.claude/projects/`, `debug/`, `cache/`, `backups/`, `file-history/` - Runtime data
- `~/.claude/plugins/` - Downloaded plugin cache (auto-managed by Claude Code)
- `~/.claude.json` - Root-level auth/session state (contains tokens)

### Shell & Terminal

#### `zsh/` - ZSH Shell Configuration (Primary Shell)
**Files:**
- `.zshrc` - Main ZSH configuration file
- `.on_load/aliases` - 425+ lines of custom aliases and functions
- `.on_load/env` - Environment variable configurations
- `.on_load/git-latest-release.sh` - Git utility script
- `.on_load/git-list-my-branches.sh` - Git utility script
- `.on_load/git-prune-local.sh` - Git utility script

**Key Features:**
- Oh My Zsh integration
- Powerlevel10k theme
- Custom PATH configuration (Python, Positron)
- Editor set to micro (VISUAL and EDITOR env vars)
- Sources private environment file (~/.private-env)
- git-open plugin enabled
- Extensive custom aliases for:
  - Application launching (Chrome, Spotify, RStudio, etc.)
  - Git shortcuts
  - Navigation helpers (goto function)
  - Project-specific utilities
- Completion waiting dots enabled
- Automatic todo list display on shell start (catodo)

#### `powerlevel10k/` - ZSH Theme
**Files:**
- `.p10k.zsh` - Powerlevel10k theme configuration (86KB configuration)

**Purpose:** Visual prompt customization for ZSH shell

### Version Control

#### `git/` - Git Configuration
**Files:**
- `.gitconfig` - Main Git configuration
- `.gitconfig-personal` - Personal project settings
- `.gitconfig-work` - Work project settings
- `.gitignore_global` - Global gitignore patterns

**Key Features:**
- Conditional includes based on directory:
  - `~/Personal/` uses personal config
  - `~/Projects/` and `~/vaults/` use work config
- 30+ custom Git aliases including:
  - Short commands (br, st, sw, ad, cm)
  - Log visualization (lg - graph/decorate/oneline)
  - Branch management (newb, db, pb)
  - Diff helpers (diffo, diflr)
  - Cleanup commands (pruneremote, prunelocal, cleanup)
  - Custom scripts (mybranches, latestrelease)
- Column UI enabled for better output
- Branches sorted by commit date
- Git protocol version 2

#### `github/` - GitHub CLI
**Files:**
- `.config/gh/` - GitHub CLI configuration directory

**Purpose:** GitHub CLI (gh) settings and authentication

#### `herdr/` - Herdr App
**Files:**
- `.config/herdr-app/settings.json` - General app settings
- `.config/herdr-app/keys.json` - Keybindings
- `.config/herdr-app/themes/*.json` - Themes
- `.config/herdr-app/layouts/*` - Layouts

**Symlink behavior:** `~/.config/herdr-app/` is a real directory (the app writes runtime data there), so stow links individual files, including inside `themes/` and `layouts/`.

**What is NOT tracked (runtime/app-managed):** `data/`, `telemetry/`, `mods/`, `icons/`, `layouts/.state/`, `view.json`, `window.json`, `seen.json`, `shared.json`, `installed.json`, `herdr-app.sock`, `*.d.ts`, `AGENTS.md`

**Note:** The running app recreates `settings.json`/`keys.json` if they go missing. If stow reports a conflict on those files, delete the regenerated copies and restow immediately.

### Text Editors

#### `micro/` - Micro Text Editor (Primary Editor)
**Files:**
- `.config/micro/settings.json` - Editor settings
- `.config/micro/bindings.json` - Custom keybindings
- `.config/micro/colorschemes/` - Custom color schemes
- `.config/micro/syntax/` - Custom syntax highlighting
- `.config/micro/plug/` - Installed plugins
- `README.md` - Comprehensive micro setup documentation

**Key Features:**
- Primary text editor (set in EDITOR env var)
- VSCode-like keybindings for cursor movement
- Mouse/trackpad support (click to move cursor)
- Custom GitHub Dark Dimmed color scheme
- Word wrap and soft wrap enabled
- Scrollbar enabled
- Highlight search results

**Installed Plugins:**
- manipulator - Text manipulation utilities
- filemanager - File browser within editor
- bounce - Bracket matching/jumping
- bookmark - Automatic bookmark management (heavily modified)

**Custom Enhancements:**
- Custom syntax highlighting rules
- Enhanced color scheme matching VSCode's GitHub Dark Dimmed
- Automatic bookmarks when cursor moves
- Disabled auto-formatting
- Word wrap enabled

#### `nano/` - Nano Text Editor (Alternative)
**Files:**
- `.nanorc` - Nano configuration
- `.nano/improved_syntax/` - Enhanced syntax highlighting
- `README.md` - Nano setup notes

**Purpose:** Lightweight fallback editor with improved syntax highlighting

#### `vscode/` - Visual Studio Code
**Files:**
- `Library/Application Support/Code/User/` - VSCode settings directory

**Purpose:** VSCode IDE settings and preferences

### Applications & Tools

#### `duckdb/` - DuckDB Database
**Files:**
- `.duckdb.ini` - DuckDB initialization/configuration

**Purpose:** DuckDB SQL database configuration, includes AWS integration (awsduck alias)

#### `rstudio/` - RStudio IDE
**Files:**
- `.config/rstudio/` - RStudio configuration directory

**Purpose:** R IDE settings and preferences

#### `w3m/` - W3M Web Browser
**Files:**
- `.w3m/` - W3M terminal browser configuration

**Purpose:** Terminal-based web browsing configuration (used via 'web' and 'ddg' aliases)

#### `stow/` - GNU Stow
**Files:**
- `.stow-global-ignore` - Patterns for files to ignore when stowing

**Purpose:** Tells Stow which files to skip (e.g., README.md files in packages)

#### `private/` - Private Environment Variables
**Files:**
- `.private-env` - Template for machine-specific environment variables

**Key Features:**
- Template file copied (not symlinked) to ~/.private-env
- Sourced by .zshrc for machine-specific configuration
- Contains variables like:
  - `PROJECT_PATH` - Path to personal projects
  - `FULL_NAME` - User's full name
  - Other machine-specific or sensitive variables
- Excluded from git via .gitignore

**Behavior:** Setup script copies this template to ~/.private-env if it doesn't exist

## Dotfiles Packages (Windows)

#### `powershell/` - PowerShell Configuration
**Purpose:** Windows PowerShell profile and configuration (not actively maintained, for safekeeping)

## Configuration Exports

### `config_exports/`
Contains exported configurations from applications that don't use dotfiles or have complex export processes.

#### `iTerm2/`
Exported iTerm2 terminal emulator preferences and profiles.

**Purpose:** Backup of iTerm2 settings that can be imported on new machines

**Files:**
- `iterm2_default.json` - Exported profile (colors, fonts, key mappings)
- `sync-keys` - Copies the export's `Keyboard Map` into iTerm2's live profiles (`./sync-keys [--dry-run] [profile ...]`, default profile is the export's `Name`). Backs up the prefs plist first; iTerm2 must be quit, so run it from another terminal.

## Git Configuration

### `.gitignore`
Excludes from version control:
- R project files (.Rproj.user, .RData, .Rhistory, .Ruserdata)
- macOS .DS_Store files (recursively)
- Private environment file (~/.private-env)

### Repository Branches
- `main` - Main branch for stable configurations
- `personal` - Current working branch for personal development

## Installation Workflow

### Fresh macOS Machine Setup
1. Run the bootstrap one-liner (see `README.md`). It installs Xcode CLT, clones this repo and runs `./install`, which:
   - Installs Homebrew and everything in the `Brewfile`
   - Installs herdr, Oh My Zsh (unattended, keeps `~/.zshrc`), powerlevel10k and git-open
   - Runs `./setup --force --full` (conflicts are backed up, micro plugins installed)
   - Logs in to GitHub with `gh auth login`

2. Follow the "Manual steps left" the installer prints (iTerm2 profile/font, Ctrl+Arrow shortcuts, `~/.private-env`, app sign-ins), then run `./setup --doctor`.

### Updating Existing Installation
```bash
cd ~/Personal/configs
git pull
./setup --restow  # Clean and reinstall all packages
```

### Installing Specific Packages
```bash
./setup git                 # Install only git dotfiles
./setup micro               # Install only micro editor config
```

### Testing Changes Before Applying
```bash
./setup --dry-run           # See what would change
```

## Code Style Guidelines

### Shell Scripts (Bash/Zsh)
- Shebang: `#!/bin/zsh` or `#!/bin/bash`
- Error handling: `set -e` for strict mode in setup scripts
- Functions: lowercase_with_underscores (e.g., `setup_private_file`)
- Constants/env vars: UPPERCASE (e.g., `BASE_DOTFILES_DIR`)
- Local variables: lowercase_with_underscores (e.g., `package_path`)
- Comments: `#` for single line, `########` for section headers
- Conditionals: Use `[[ ]]` for modern bash/zsh
- Command checks: `if ! command -v tool &> /dev/null`

### Configuration Files
- Follow existing patterns within each config file type
- Add descriptive comments for non-obvious settings
- Maintain consistent formatting within each file type
- Preserve exact indentation when editing

### General Principles
- Use GNU Stow for symlink management (never manual copying)
- No automated linting/testing (manual validation via --dry-run)
- No TypeScript, JavaScript, or Python packages in this repo
- Focus on configuration management and shell scripting

## Package Structure

Each package in `dotfiles/mac/` or `dotfiles/windows/` contains files and directories exactly as they should appear in the home directory (`$HOME`).

**Example:**
```
dotfiles/mac/git/
├── .gitconfig          → symlinked to ~/.gitconfig
├── .gitconfig-personal → symlinked to ~/.gitconfig-personal
├── .gitconfig-work     → symlinked to ~/.gitconfig-work
└── .gitignore_global   → symlinked to ~/.gitignore_global

dotfiles/mac/zsh/
├── .zshrc              → symlinked to ~/.zshrc
└── .on_load/           → symlinked to ~/.on_load/
    ├── aliases
    ├── env
    └── *.sh
```

**Important:** The structure inside each package directory mirrors the target structure in $HOME. Stow creates symlinks maintaining this exact hierarchy.

## Common Workflows

### Adding a New Dotfile
1. Determine which package it belongs to (or create new package)
2. Place file in correct location within package directory
3. Run `./setup --dry-run` to verify symlink location
4. Run `./setup <package_name>` to install
5. Commit changes to git

### Modifying Existing Dotfile
1. Edit the file directly in the dotfiles directory (or via symlink in $HOME)
2. Test changes
3. Commit to git when satisfied

### Creating a New Package
1. Create directory in `dotfiles/mac/` with descriptive name
2. Add files in exact structure they should appear in $HOME
3. Optional: Add README.md to package (will be ignored by stow)
4. Run `./setup <new_package>` to test
5. Commit to git

### Updating from Remote
```bash
cd ~/Personal/configs
git pull
./setup --restow  # Reapply all symlinks
```

### Handling Conflicts
```bash
# Preview conflicts
./setup --dry-run

# Back up conflicting files (asks for each), then link
./setup --force

# Same, without asking (files are moved to ~/.dotfiles-backup, never deleted)
./setup --force --yes
```

## Validation & Testing

### Before Making Changes
```bash
./setup --dry-run  # Preview what would change
```

### After Making Changes
```bash
./setup <modified_package> --dry-run  # Preview specific package
./setup <modified_package>             # Apply specific package
```

### Verifying Symlinks
```bash
ls -la ~/.<config_file>  # Check if symlink points to correct location
```

### Testing New Configurations
1. Modify dotfile in repository
2. Run `./setup --restow <name>`
3. Test the configuration in application
4. If broken, edit and restow again
5. Commit when working correctly

## Important Notes

### Symlink Management
- All dotfiles are symlinked, not copied (except ~/.private-env)
- Editing files in $HOME edits the repository files (they're symlinks)
- Stow creates symlinks for files and unfolds directories as needed
- Broken symlinks are automatically removed during setup

### Private Configuration
- ~/.private-env is COPIED from template, not symlinked
- This allows machine-specific values without committing to git
- File is excluded from git via .gitignore
- Edit ~/.private-env directly on each machine

### Cross-Platform Support
- macOS configurations are actively maintained
- Windows configurations are minimal (for safekeeping only)
- `install` script only works on macOS
- `setup` script works on both platforms with --os flag

### Package Priority
- "stow" package is always processed first
- Contains global ignore rules needed by other packages
- Other packages processed in alphabetical order
- "private" package is skipped during stowing (handled separately)

## Tools & Dependencies

### Required
- GNU Stow - Symlink manager (install via `brew install stow` on macOS)
- Git - Version control
- ZSH - Shell (default on modern macOS)

### Optional (installed by ./install script)
- Homebrew - Package manager for macOS
- Oh My Zsh - ZSH framework
- Powerlevel10k - ZSH theme
- Micro - Text editor
- Git CLI tools - Enhanced git functionality
- Various applications - See install script for full list

## Troubleshooting

### Stow Conflicts
If stow reports conflicts about existing files:
```bash
# Option 1: Preview what's conflicting
./setup --dry-run

# Option 2: Force overwrite with confirmation
./setup --force

# Option 3: Remove specific conflicting file manually
rm ~/.conflicting_file
./setup
```

### Broken Symlinks
```bash
# Setup script automatically removes broken symlinks
./setup --restow

# Or manually find broken symlinks
find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print
```

### Private Environment File Issues
```bash
# If ~/.private-env is broken or missing
rm ~/.private-env  # Remove if exists
./setup           # Will copy template automatically
```

### Git Config Not Working
```bash
# Verify git config is symlinked
ls -la ~/.gitconfig

# Verify conditional includes
git config --list --show-origin | grep include
```

## Build/Lint/Test Commands

### Setup Commands
- `./install` - Install system packages and tools (Homebrew, apps, coding tools)
- `./setup` - Setup dotfiles using GNU Stow (creates symlinks)
- `./setup --dry-run` - Preview what setup will do without making changes
- `./setup --force` - Force setup, overwriting existing files
- `./setup --clean` - Remove existing symlinks
- `./setup --restow` - Clean and restow all packages
- `./setup <name>` - Setup specific package only
- `./setup --list` - List available packages
- `./setup --os mac` - Use macOS dotfiles (default)
- `./setup --os windows` - Use Windows dotfiles

### Validation
- No automated linting/formatting tools configured
- No test framework (this is configuration files, not application code)
- Manual validation: run `./setup --dry-run` to verify changes
- Visual inspection of symlinks: `ls -la ~/.<file>`

## File Locations (Absolute Paths)

### Repository Root
`/Users/ericlamphere/Personal/configs/`

### Key Directories
- Dotfiles source: `/Users/ericlamphere/Personal/configs/dotfiles/mac/`
- Windows dotfiles: `/Users/ericlamphere/Personal/configs/dotfiles/windows/`
- Config exports: `/Users/ericlamphere/Personal/configs/config_exports/`
- Install script: `/Users/ericlamphere/Personal/configs/install`
- Setup script: `/Users/ericlamphere/Personal/configs/setup`

### Symlink Targets
All dotfiles are symlinked to: `/Users/ericlamphere/` (user home directory)

Example: `/Users/ericlamphere/Personal/configs/dotfiles/mac/git/.gitconfig` → `/Users/ericlamphere/.gitconfig`

Note: The `claude` package is a special case — stow creates symlinks for managed files/subdirs *inside* the existing `~/.claude` real directory rather than symlinking `.claude` itself.

## Recent Changes (Git History)

Recent commits focus on micro editor enhancements:
- c813746 - Removing autofmt, applying wordwrap
- 67c9560 - Major enhancements to syntax highlighting
- 333a273 - Adding custom color scheme (GitHub Dark Dimmed)
- 6e331a0 - Adding automatic bookmarks when cursor moves
- 98b83c2 - Adding bookmark plugin to micro

## Agent Responsibilities

When working with this repository, agents should:

1. **Understand Structure**: Know that dotfiles/mac/ contains packages that mirror $HOME structure
2. **Use Setup Script**: Always use `./setup` script, never manually create symlinks
3. **Test First**: Use `--dry-run` before applying changes
4. **Preserve Format**: Maintain exact indentation and formatting in configs
5. **Document Changes**: Update README.md or package-specific README.md files when adding features
6. **Respect Privacy**: Never commit ~/.private-env or sensitive data
7. **Cross-Platform Aware**: Distinguish between macOS and Windows configurations
8. **Package Organization**: Keep related configurations in same package
9. **Follow Patterns**: Match existing code style and organizational patterns
10. **Verify Symlinks**: Confirm symlinks point to correct locations after changes

## Key Insight for Agents

This repository uses GNU Stow's "package" concept. Each subdirectory in dotfiles/mac/ is a package. Files within a package are placed exactly where they should appear relative to $HOME. Stow creates symlinks maintaining this structure. This means:

- `dotfiles/mac/git/.gitconfig` becomes `~/.gitconfig`
- `dotfiles/mac/zsh/.zshrc` becomes `~/.zshrc`
- `dotfiles/mac/zsh/.on_load/aliases` becomes `~/.on_load/aliases`

The directory tree inside each package is preserved in $HOME via symlinks.
