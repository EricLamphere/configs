update_config_files__obsidian() {
    echo "Synching .on_load/ files with obsidian notes"
    rm -rf ~/vaults/notes/configs/zsh/on_load/
    cp -r ~/.on_load/ ~/vaults/notes/configs/zsh/on_load/

    echo "Syncing .zshrc file with obsidian notes"
    rm -f ~/vaults/notes/configs/zsh/zshrc
    cp ~/.zshrc ~/vaults/notes/configs/zsh/zshrc

    echo "Syncing .nanorc file with obsidian notes"
    rm -f ~/vaults/notes/configs/nano/nanorc
    cp ~/.nanorc ~/vaults/notes/configs/nano/nanorc

    echo "Syncing .nano folder with obsidian notes"
    rm -rf ~/vaults/notes/configs/nano/nano
    cp -r ~/.nano/ ~/vaults/notes/configs/nano/nano

    echo "Syncing .gitconfig with obsidian notes"
    rm -f ~/vaults/notes/configs/git/gitconfig
    cp ~/.gitconfig ~/vaults/notes/configs/git/gitconfig

    echo "Syncing .gitignore_global with obsidian notes"
    rm -f ~/vaults/notes/configs/git/gitignore_global
    cp ~/.gitignore_global ~/vaults/notes/configs/git/gitignore_global
}

sync_notes() {
    update_config_files__obsidian

	cd ~/vaults/notes
	
    git diff origin/main --name-status
	git add -A
	git commit -m "syncing notes"
	git push
	git push personal

	cd -
}

