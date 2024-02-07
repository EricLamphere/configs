### Script to sync all relevant dotfiles

update_config_files() {
    echo "Synching .on_load/ files"
    rm -rf ~/Personal/configs/dotfiles/zsh/.on_load/
    cp -r ~/.on_load/ ~/Personal/configs/dotfiles/zsh/.on_load/

    echo "Syncing .zshrc file"
    rm -f ~/Personal/configs/dotfiles/zsh/.zshrc
    cp ~/.zshrc ~/Personal/configs/dotfiles/zsh/.zshrc

    echo "Syncing .gitconfig files"
    rm -f ~/Personal/configs/dotfiles/git/.gitconfig
    rm -f ~/Personal/configs/dotfiles/git/.gitconfig-personal
    cp ~/.gitconfig ~/Personal/configs/dotfiles/git/.gitconfig
    cp ~/.gitconfig-personal ~/Personal/configs/dotfiles/git/.gitconfig-personal

    echo "Syncing .gitignore_global file"
    rm -f ~/Personal/configs/dotfiles/git/.gitignore_global
    cp ~/.gitignore_global ~/Personal/configs/dotfiles/git/.gitignore_global

    echo "Syncing .nanorc file"
    rm -f ~/Personal/configs/dotfiles/nano/.nanorc
    cp ~/.nanorc ~/Personal/configs/dotfiles/nano/.nanorc

    echo "Syncing .nano folder"
    rm -rf ~/Personal/configs/dotfiles/nano/.nano
    cp -r ~/.nano/ ~/Personal/configs/dotfiles/nano/.nano

    echo "Syncing .obsidian folder"
    rm -rf ~/Personal/configs/dotfiles/obsidian/.obsidian
    cp -r ~/vaults/notes/.obsidian ~/Personal/configs/dotfiles/obsidian/
}

# Now cd into git repo and sync with git
sync_dotfiles() {
    update_config_files

    cd ~/Personal/configs

    git diff origin/main --name-status
    git add -A
    git commit -m "syncing dotfiles"
    git push

    cd -
}
