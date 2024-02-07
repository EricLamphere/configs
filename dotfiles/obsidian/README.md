# Obsidian Notes <img src="obsidian/figures/obsidian-app-icon.png" align="right" height="150"/>
This is where I keep my work-related notes

## My Notes Setup
Obsidian stores all of your notes as markdown files in a "vault" (folder that you specify on your machine). I connected git to my vault and set up a cronjob to sync my notes to [GitLab](https://gitlab.com/ixisdigital/scratch/eric/notes) every day at 5:00pm. Here's how it works:


### 1) Obsidian
---
Install Obsidian and write some notes:
1. Install Obsidian with `brew install obsidian`
2. Set up an Obsidian vault (folder) and choose a cool theme (I use Blue Topaz)
3. Save some notes


### 2) Git
---
Connect your Obsidian vault with Git:
1. Create a repo in GitLab to push 
2. Add and set origin
	- `git remote add origin <repo ssh url>`
	- `git remote set-url origin <repo ssh url>`
3. Create a branch and push your folder contents
	-  `git checkout -b first_branch`
	-  `git commit -am "initial commit"`
	-  `git push -u origin first_branch`
		- Note: you can `git remote -v` to list your origin URLs
4. Merge your branch into main in GitLab
5. Pull in your terminal, then checkout main
	- `git pull`
	- `git checkout main`
6. Now you can push directly to main
7. IMPORTANT: create a `.gitignore` file to avoid pushing anything you don't want to


### 3) Cron
---
Use Cron to automatically sync notes every night:
1. Install cron with `brew install cron`
2. Create a shell script to sync your notes (see `sync/utils/mac/sync_notes.sh`)
3. Use `crontab -e` to create a cronjob
```cron
#--------------------------------------------------
# example unix/linux crontab file format:
#--------------------------------------------------
# min,hour,dayOfMonth,month,dayOfWeek command
#
# field allowed values
# ----- --------------
# minute 0-59
# hour 0-23
# day of month 1-31
# month 1-12 (or names, see below)
# day of week 0-7 (0 or 7 is Sun, or use names)
#
#--------------------------------------------------

##############################################################
##### CRON JOBS ####
###############################################################

# sync obsidian notes, dotfiles, and other configs at 5:00pm
0 17 * * * source ~/Personal/configs/sync/sync_mac.sh
```

- **You may need to give crontab access to your shell script**. Do so with `chmod +x <path to your sync_notes script>` 
	- If that doesn't work, try `chmod 4755 /usr/bin/crontab`
- You can consult the [crontab guru](https://crontab.guru/) to sync notes whenever you need. Mine is set up to sync at 5:00pm every day
- **Crontab Notes:** 
	- Local cron jobs don't run while your machine is sleeping or off, so your notes will only sync when your machine is awake during the scheduled cron job
	- When the cronjob runs (successfully or otherwise) you will receive mail to your local machines mail folder. You can access and read this mail with the `mail` command. You can step through your mail using the `return` key and quit out of mail by typing `q` then hitting `return`


### 4) Realize the Greatness
---
#### Benefits
This setup comes with a lot of benefits

**Notes are recoverable**
- All of my notes are automatically synced to [GitLab](https://gitlab.com/ixisdigital/scratch/eric/notes) every night, so if my computer explodes I can still recover my notes by cloning my notes repo and setting the folder as my obsidian vault
	- You can also sync notes manually with the `sync_notes` command pasted above
- Because most Obsidian notes are markdown files, they also look great in git, so you can send other people links to your notes

**Obsidian is great**
- Obsidian stores all of your notes locally in the folder of your choice (you can also have many vaults, not just one), so you can open the markdown files with any editor of your choosing
- There are a _ton_ of adjustable settings. You can change your appearance & theme (can also upload custom CSS), use vim key bindings, and fold headings and indentations
- There are also a ton of core and community plugins you can enable/disable at will. I personally really like the `slash commands` plugin that pulls up a list of commands when you type `/` similar to confluence or slack. My fav plugins shown below
- You can use tags and link to other notes. This also enables a cool graph view that shows how all of your notes connect to each other
- Create custom templates

#### Super Useful Plugins
There are a ton of core and community plugins, so I'll just list my favorite

**Core plugins**
- templates - I have a couple templates that are really useful, so when I create a new note I can really quickly set everything up
- daily notes - I just hit cmd + t and it creates a new daily note in whatever folder structure you want. You can also set your daily notes to initialize with a template so off the bat you can start jotting things down and it's all organized
- slash commands - just super useful in general. very similar to confluence slash commands
- command palette - helpful to search for commands
- quick switcher - makes it really easy to search through all of your notes with keywords
- slides - I don't use it a ton, but you can basically create a janky powerpoint just by separating slides with `---`

**Community plugins**
* Advanced Tables - Make tables look really good in markdown
* Calendar - Calendar widget that works really well in combination with the core daily notes plugin which I use all the time. You can click on a day and it'll switch to the daily note for that day or create a new one
* Editor Syntax Highlight - Let's you view the formatted/syntax highlighted code snippets while you're editing
* Emoji Toolbar - Emojis, of course
* Mind Map - I don't really use this but it's a cool tool. It creates a "mind map" of your current note
