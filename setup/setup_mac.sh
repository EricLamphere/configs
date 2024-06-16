
source <( cat ~/Personal/configs/setup/utils/mac/* )

# obsidian
echo "Setting up git configs"
setup_git

echo "Setting up nano configs"
setup_nano

echo "Setting up obsidian configs"
setup_obsidian

echo "Setting up rstudio configs"
setup_rstudio

echo "Setting up zsh configs"
setup_zsh
setup_p10k