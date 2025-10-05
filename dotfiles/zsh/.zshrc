# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#######################################################################################
##### ZSH CONFIGURATION #####
#######################################################################################
ME=$(whoami)


# ----------------- PATH -----------------

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PYTHON_PATH="/opt/homebrew/bin/python3.12"
export PATH="$PATH:$PYTHON_PATH"

#export iodbc_path="/Library/Application Support/iODBC/bin"
#export PATH="$PATH:$iodbc_path"

# dae deploy scripts
export PATH="$PATH:$HOME/.dae-deploy-scripts"

# positron
export POSITRON_PATH="/Applications/Positron.app"
export PATH="$PATH:$POSITRON_PATH"

# ----------------- PATH END -----------------

export VISUAL=nano
export EDITOR=nano

# less output modification
export LESS="-FXR"

# Path to your oh-my-zsh installation.
export ZSH="/Users/$ME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="robbyrussell"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Comment out the following line to disable automatic update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? Standard plugins at $ZSH/plugins/ Custom plugins at $ZSH_CUSTOM/plugins/. 
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git-open)

source $ZSH/oh-my-zsh.sh




#######################################################################################
##### SOURCE UTIL CONFIG FILES #####
#######################################################################################

source ~/.on_load/aliases
source ~/.on_load/env
source ~/.private-env

### p10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# don't show warning due to cat message below
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
# print out todo list
catodo

PATH=$HOME/bin:$PATH
# added by dae-tools installer
PATH=$HOME/.dae-deploy-scripts:$PATH
# added by dae-tools installer
fpath=($HOME/.dae-deploy-scripts/completions $fpath)
# added by dae-tools installer
compinit
# added by dae-tools installer
fpath=($HOME/.dae-deploy-scripts/completions $fpath)
# added by dae-tools installer
compinit


# Add duckdb alias
if [[ -f "$HOME/.duckdb.ini" ]]; then
	alias awsduck='duckdb --init ~/.duckdb.ini'
fi

