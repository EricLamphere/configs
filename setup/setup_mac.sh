
export PERSONAL_CONFIGS_REPO_PATH="~/Personal/configs"
export PERSONAL_DOTFILES_PATH="${PERSONAL_CONFIGS_REPO_PATH}/dotfiles"

source <( cat ~/Personal/configs/setup/utils/mac/* )

# obsidian
echo "Setting up git configs"
setup_git