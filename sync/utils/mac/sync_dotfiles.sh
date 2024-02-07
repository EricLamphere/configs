### Script to sync all relevant dotfiles

export PERSONAL_CONFIG_REPO='configs'

update_config_files() {
    echo "Synching .on_load/ files"
    rm -rf ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/zsh/.on_load/
    cp -r ~/.on_load/ ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/zsh/.on_load/

    echo "Syncing .zshrc file"
    rm -f ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/zsh/.zshrc
    cp ~/.zshrc ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/zsh/.zshrc

    echo "Syncing .gitconfig files"
    rm -f ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/git/.gitconfig
    rm -f ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/git/.gitconfig-personal
    cp ~/.gitconfig ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/git/.gitconfig
    cp ~/.gitconfig-personal ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/git/.gitconfig-personal

    echo "Syncing .gitignore_global file"
    rm -f ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/git/.gitignore_global
    cp ~/.gitignore_global ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/git/.gitignore_global

    echo "Syncing .nanorc file"
    rm -f ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/nano/.nanorc
    cp ~/.nanorc ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/nano/.nanorc

    echo "Syncing .nano folder"
    rm -rf ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/nano/.nano
    cp -r ~/.nano/ ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/nano/.nano

    echo "Syncing .obsidian folder"
    rm -rf ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/obsidian/.obsidian
    cp -r ~/vaults/notes/.obsidian ~/Personal/${PERSONAL_CONFIG_REPO}/dotfiles/obsidian/
}

# Now cd into git repo and sync with git
sync_dotfiles() {
    update_config_files

    cd ~/Personal/${PERSONAL_CONFIG_REPO}

    git diff origin/main --name-status
    git add -A
    git commit -m "syncing dotfiles"
    git push

    cd -
}
