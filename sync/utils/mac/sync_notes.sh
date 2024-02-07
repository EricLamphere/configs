sync_notes() {
	cd ~/vaults/notes
	
    git diff origin/main --name-status
	git add -A
	git commit -m "syncing notes"
	git push
	git push personal

	cd -
}

