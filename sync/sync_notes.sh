sync_notes() {
	curdir=$(pwd)

	cd ~/vaults/notes
	git diff origin/main --name-status
	git add -A
	git commit -m "syncing notes"
	git push
	git push personal

	cd $curdir
}

# git config --file ~/.gitconfig-work
sync_notes
