git branch -r | xargs -L1 git --no-pager show -s --oneline --author="$(git config user.name)" --author="Eric Lamphere"
