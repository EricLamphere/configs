
# source utils
source <( cat ~/Personal/configs/sync/utils/mac/* )

# run sync scripts from utils
echo ">>> SYNCING NOTES <<<"
sync_notes

echo ">>> SYNCING DOTFILES <<<"
sync_dotfiles