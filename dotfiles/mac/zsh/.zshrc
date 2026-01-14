# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


ME=$(whoami)


# ----------------- PATH -----------------
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PYTHON_PATH="/opt/homebrew/bin/python3.12"
export PATH="$PATH:$PYTHON_PATH"

# positron
export POSITRON_PATH="/Applications/Positron.app"
export PATH="$PATH:$POSITRON_PATH"

# misc
PATH=$HOME/bin:$PATH
# ----------------- PATH END -----------------


# ----------------- BASE -----------------
export VISUAL=micro
export EDITOR=micro

# less output modification
export LESS="-FXR"

# ----------------- BASE END -----------------



# ----------------- ZSH -----------------

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
plugins=(git-open git aliases docker command-not-found aws web-search)

source $ZSH/oh-my-zsh.sh

# ----------------- ZSH END -----------------






# ----------------- UTIL CONFIG FILES -----------------

source ~/.on_load/aliases
source ~/.on_load/env
source ~/.private-env

# ----------------- UTIL CONFIG FILES END -----------------




# ----------------- P10k -----------------

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# don't show warning due to cat message below
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# ----------------- P10k -----------------

# print out todo list
catodo



