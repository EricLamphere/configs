### Script to sync all relevant dotfiles
update_config_files__personal() {
    echo "Syncing .on_load/ files"
    rm -rf ~/Personal/configs/dotfiles/zsh/.on_load/
    cp -r ~/.on_load/ ~/Personal/configs/dotfiles/zsh/.on_load/

    echo "Syncing zsh config files"
    rm -f ~/Personal/configs/dotfiles/zsh/.zshrc
    cp ~/.zshrc ~/Personal/configs/dotfiles/zsh/.zshrc

    echo "Syncing .gitconfig files"
    rm -f ~/Personal/configs/dotfiles/git/.gitconfig
    rm -f ~/Personal/configs/dotfiles/git/.gitconfig-personal
    rm -f ~/Personal/configs/dotfiles/git/.gitconfig-work
    cp ~/.gitconfig ~/Personal/configs/dotfiles/git/.gitconfig
    cp ~/.gitconfig-personal ~/Personal/configs/dotfiles/git/.gitconfig-personal
    cp ~/.gitconfig-work ~/Personal/configs/dotfiles/git/.gitconfig-work

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
    rm -f ~/Personal/configs/dotfiles/obsidian/.gitignore
    cp -r ~/vaults/notes/.obsidian ~/Personal/configs/dotfiles/obsidian/
    cp ~/vaults/notes/.gitignore ~/Personal/configs/dotfiles/obsidian/

    echo "Syncing rstudio config folder"
    rm -rf ~/Personal/configs/dotfiles/rstudio/rstudio
    cp -r ~/.config/rstudio ~/Personal/configs/dotfiles/rstudio/rstudio

    echo "Syncing powerlevel10k configs"
    rm -rf ~/Personal/configs/dotfiles/powerlevel10k/.p10k.zsh
    rm -rf ~/Personal/configs/dotfiles/powerlevel10k/internal
    rm -rf ~/Personal/configs/dotfiles/powerlevel10k/config
    rm -rf ~/Personal/configs/dotfiles/powerlevel10k/gitstatus

    mkdir -p ~/Personal/configs/dotfiles/powerlevel10k/themes/internal
    mkdir -p ~/Personal/configs/dotfiles/powerlevel10k/themes/config
    mkdir -p ~/Personal/configs/dotfiles/powerlevel10k/themes/gitstatus

    cp -r ~/.p10k.zsh ~/Personal/configs/dotfiles/powerlevel10k/.p10k.zsh
    cp -r ~/.oh-my-zsh/custom/themes/powerlevel10k/ ~/Personal/configs/dotfiles/powerlevel10k/themes/
    # cp -r ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme ~/Personal/configs/dotfiles/powerlevel10k/themes/
    # cp -r ~/.oh-my-zsh/custom/themes/powerlevel10k/internal ~/Personal/configs/dotfiles/powerlevel10k/themes/internal
    # cp -r ~/.oh-my-zsh/custom/themes/powerlevel10k/config ~/Personal/configs/dotfiles/powerlevel10k/themes/config
    # cp -r ~/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus ~/Personal/configs/dotfiles/powerlevel10k/themes/gitstatus
}

# Now cd into git repo and sync with git
sync_dotfiles() {
    update_config_files__personal

    cd ~/Personal/configs

    git diff origin/main --name-status
    git add -A
    git commit -m "syncing dotfiles"
    git push

    cd -
}
