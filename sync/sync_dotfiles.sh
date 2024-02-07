### Script to sync all relevant dotfiles

echo "Synching .on_load/ files"
rm -rf ~/Personal/configurations/dotfiles/zsh/.on_load/
cp -r ~/.on_load/ ~/Personal/configurations/dotfiles/zsh/.on_load/

echo "Syncing .zshrc file"
rm -f ~/Personal/configurations/dotfiles/zsh/.zshrc
cp ~/.zshrc ~/Personal/configurations/dotfiles/zsh/.zshrc

echo "Syncing .gitconfig files"
rm -f ~/Personal/configurations/dotfiles/git/.gitconfig
rm -f ~/Personal/configurations/dotfiles/git/.gitconfig-personal
cp ~/.gitconfig ~/Personal/configurations/dotfiles/git/.gitconfig
cp ~/.gitconfig-personal ~/Personal/configurations/dotfiles/git/.gitconfig-personal

echo "Syncing .gitignore_global file"
rm -f ~/Personal/configurations/dotfiles/git/.gitignore_global
cp ~/.gitignore_global ~/Personal/configurations/dotfiles/git/.gitignore_global

echo "Syncing .nanorc file"
rm -f ~/Personal/configurations/dotfiles/nano/.nanorc
cp ~/.nanorc ~/Personal/configurations/dotfiles/nano/.nanorc

echo "Syncing .nano folder"
rm -rf ~/Personal/configurations/dotfiles/nano/.nano
cp -r ~/.nano/ ~/Personal/configurations/dotfiles/nano/.nano

echo "Syncing .obsidian folder"
rm -rf ~/Personal/configurations/dotfiles/obsidian/.obsidian
cp -r ~/vaults/notes/.obsidian ~/Personal/configurations/dotfiles/obsidian/

# Now cd into git repo and sync with git
sync_dotfiles() {
    cd ~/Personal/configurations

    git diff origin/main --name-status
    git add -A
    git commit -m "syncing dotfiles"
    git push

    cd -
}

sync_dotfiles
