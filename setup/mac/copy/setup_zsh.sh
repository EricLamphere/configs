
setup_zsh() {
    echo "Setting up zsh dotfiles"
    cp -r ~/Personal/configs/dotfiles/zsh/ ~/

    PRIVATE_FILE=~/.private-env
    if [ -f $PRIVATE_FILE ]; then
        echo "$PRIVATE_FILE file already exists"
    else
        echo "Adding template $PRIVATE_FILE file to your home directory"
        cp ~/Personal/configs/dotfiles/private/.private-env ~/
    fi
    
    echo "Adding p10k configs"
    cp ~/Personal/configs/dotfiles/powerlevel10k/.p10k.zsh ~/
    cp -r ~/Personal/configs/dotfiles/powerlevel10k/themes/ ~/.oh-my-zsh/custom/themes/powerlevel10k/
}

