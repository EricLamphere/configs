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
├── .claude/                    # Claude Code agent configurations
│   ├── agents/                 # Custom agent definitions
│   └── settings.local.json     # Local Claude settings
├── .git/                       # Git version control
├── .gitignore                  # Git ignore patterns
├── AGENTS.md                   # This file - agent instructions
├── README.md                   # User-facing documentation
├── install                     # Initial system setup script (macOS only)
├── setup                       # GNU Stow-based dotfiles installer
├── config_exports/             # Exported application configurations
│   └── iTerm2/                 # iTerm2 terminal configurations
└── dotfiles/                   # All managed dotfiles
    ├── mac/                    # macOS-specific configurations
    │   ├── duckdb/             # DuckDB database configuration
    │   ├── git/                # Git configuration and aliases
    │   ├── github/             # GitHub CLI configuration
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

#### `install` (macOS only)
Initial system setup script that installs packages and tools on a fresh macOS machine.

**What it does:**
1. Installs Homebrew package manager
2. Installs GUI applications: iTerm2, Sublime Text, Google Chrome, Spotify
3. Installs coding tools: VS Code, R, RStudio, GitHub CLI, Docker, Python, DuckDB
4. Installs utilities: mdcat, micro, tree, ddgr, w3m
5. Installs Oh My Zsh framework
6. Installs Powerlevel10k theme for ZSH
7. Installs git-open plugin
8. Authenticates with GitHub via gh CLI
9. Clones this configs repository to ~/Personal/configs
10. Runs the setup script

**Usage:** `./install`

#### `setup` (Cross-platform)
GNU Stow-based dotfiles management script that creates symlinks from the dotfiles directory to the home directory.

**Key Features:**
- Uses GNU Stow for symlink management
- OS-specific dotfiles support (--os mac|windows)
- Dry-run mode to preview changes
- Force mode to overwrite existing files
- Package-specific installation
- Priority package handling (stow package first)
- Colored output for status messages
- Interactive prompts when removing conflicting files

**Usage Examples:**
```bash
./setup                         # Install all macOS dotfiles
./setup --dry-run               # Preview what would be installed
./setup --os mac                # Explicitly use macOS dotfiles
./setup --os windows            # Use Windows dotfiles
./setup --package git           # Install only git package
./setup --force                 # Overwrite existing files (prompts)
./setup --force --yes           # Overwrite existing files (no prompts)
./setup --clean                 # Remove all symlinks
./setup --restow                # Clean and reinstall all packages
./setup --list                  # List available packages
```

**How it works:**
1. Checks for GNU Stow installation
2. Validates dotfiles directory exists
3. Handles private environment file setup (copies template if missing)
4. For each package in dotfiles/mac/ or dotfiles/windows/:
   - Skips "private" package (handled separately)
   - Uses stow to create symlinks from package contents to $HOME
   - In force mode: removes conflicting files/directories before stowing
5. Processes "stow" package first (priority package)
6. Creates symlinks maintaining the exact directory structure

**Important Behaviors:**
- Symlinks are created in $HOME (~)
- Files/directories in each package are named exactly as they should appear in $HOME
- Private environment file is copied (not symlinked) from template
- Broken symlinks are automatically removed before creating new ones

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
1. Run `./install` to install all packages and tools
   - Installs Homebrew, apps, coding tools, utilities
   - Sets up Oh My Zsh and Powerlevel10k
   - Authenticates with GitHub
   - Clones this repository
   - Automatically runs ./setup

2. Manual steps after installation:
   - Configure iTerm2 keybindings (disable Option+arrows, Ctrl+arrows system shortcuts)
   - Import iTerm2 configuration from config_exports/
   - Run `p10k configure` to customize Powerlevel10k prompt
   - Edit ~/.private-env with machine-specific values
   - Review and customize any application-specific settings

### Updating Existing Installation
```bash
cd ~/Personal/configs
git pull
./setup --restow  # Clean and reinstall all packages
```

### Installing Specific Packages
```bash
./setup --package git       # Install only git dotfiles
./setup --package micro     # Install only micro editor config
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
4. Run `./setup --package <package_name>` to install
5. Commit changes to git

### Modifying Existing Dotfile
1. Edit the file directly in the dotfiles directory (or via symlink in $HOME)
2. Test changes
3. Commit to git when satisfied

### Creating a New Package
1. Create directory in `dotfiles/mac/` with descriptive name
2. Add files in exact structure they should appear in $HOME
3. Optional: Add README.md to package (will be ignored by stow)
4. Run `./setup --package <new_package>` to test
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

# Force overwrite with prompts
./setup --force

# Force overwrite without prompts (dangerous)
./setup --force --yes
```

## Validation & Testing

### Before Making Changes
```bash
./setup --dry-run  # Preview what would change
```

### After Making Changes
```bash
./setup --package <modified_package> --dry-run  # Preview specific package
./setup --package <modified_package>             # Apply specific package
```

### Verifying Symlinks
```bash
ls -la ~/.<config_file>  # Check if symlink points to correct location
```

### Testing New Configurations
1. Modify dotfile in repository
2. Run `./setup --package <name> --restow`
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
- `./setup --package <name>` - Setup specific package only
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
