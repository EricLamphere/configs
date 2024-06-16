# Homebrew ----
echo "----- Installing Homebrew -----"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# iterm2 ----
echo "----- Installing iTerm2 -----"
brew install iterm2

# oh-my-zsh ----
echo "----- Installing OhMyZsh -----"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# powerlevel10k ----
echo "----- Installing powerlevel10k -----"
brew install powerlevel10k
echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc

# git-open ----
echo "----- Installing git-open -----"
git clone https://github.com/paulirish/git-open.git $ZSH_CUSTOM/plugins/git-poen

# sublime text ----
echo "----- Installing Sublime Text -----"
brew install sublime-text

# GitHub ----
echo "----- Installing GitHub CLI -----"
brew install gh

echo "----- Authenticating With GitHub -----"
gh auth login

echo "----- Cloning configs Repo & Setting Up Files -----"
mkdir ~/Personal
cd ~/Personal
gh repo clone EricLamphere/configs
source ~/Personal/configs/setup/setup_mac.sh