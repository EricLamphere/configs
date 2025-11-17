# Agent Instructions for Configs Repository

## Build/Lint/Test Commands

### Setup Commands
- `./install` - Install system packages and tools (Homebrew, apps, coding tools)
- `./setup` - Setup dotfiles using GNU Stow (creates symlinks)
- `./setup --dry-run` - Preview what setup will do without making changes
- `./setup --force` - Force setup, overwriting existing files
- `./setup --clean` - Remove existing symlinks
- `./setup --restow` - Clean and restow all packages
- `./setup --package <name>` - Setup specific package only

### Validation
- No automated linting/formatting tools configured
- No test framework (this is configuration files, not application code)
- Manual validation: run `./setup --dry-run` to verify changes

## Code Style Guidelines

### Shell Scripts (Bash/Zsh)
- Use `#!/bin/bash` or `#!/bin/zsh` shebangs
- Use `set -e` for strict error handling in setup scripts
- Functions: lowercase with underscores (snake_case) - `setup_private_file()`
- Variables: UPPERCASE for constants/environment variables - `BASE_DOTFILES_DIR`
- Local variables: lowercase with underscores - `package_path`
- Comments: `#` for single line, `########` for section headers
- Error handling: Check command success with `if ! command -v ...` or `if (( $? != 0 ))`
- String comparisons: Use `[[ ]]` for zsh/bash, avoid `[` for new code

### Configuration Files
- Follow existing patterns in each config file type
- Use descriptive comments explaining non-obvious settings
- Maintain consistent formatting within each file type

### General
- No TypeScript/JavaScript in this repository
- No Python packages or build tools
- Focus on configuration management and shell scripting
- Prefer GNU Stow for symlink management over manual copying

## Repository Structure
- `dotfiles/mac/` - macOS specific configurations
- `dotfiles/windows/` - Windows specific configurations
- `config_exports/` - Exported application configurations
- Scripts in root: `install`, `setup` for setup automation</content>
<parameter name="filePath">/Users/ericlamphere/Personal/configs/AGENTS.md
