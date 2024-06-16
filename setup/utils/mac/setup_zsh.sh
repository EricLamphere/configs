
setup_zsh() {
    cp -r ~/Personal/configs/dotfiles/zsh/ ~/
}

setup_p10k() {
    cp ~/Personal/configs/dotfiles/powerlevel10k/.p10k.zsh ~/
    cp -r ~/Personal/configs/dotfiles/powerlevel10k/themes ~/.oh-my-zsh/custom/themes/powerlevel10k/
}