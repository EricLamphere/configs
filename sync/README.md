## Sync Scripts
These scripts are used for syncing dotfiles to git. These typically have lived in a `~/cron_scripts/` directory

* Personal repos should live in a `~/Personal/` directory
* See `sync_dotfiles.sh` to see where other dotfiles should live (`cp` commands)
* Obsidian notes should live in a `~/vaults/notes/` directory
* Notes should be set up with git on both personal and work machine. Notice how the `utils/mac/sync_notes.sh` file has a `git push` and a `git push personal` -- this pushed to both the work git repo and the personal git repo

## TODO
* Parameterize paths