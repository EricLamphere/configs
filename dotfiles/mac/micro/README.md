# Micro
Micro is a simple, light weight editor that has everything I want. I didn't want to spend months memorizing keybindings (vim, emacs, etc.) 
and I personally use the trackpad on my mac all the time, but I also felt limited with what I could do with nano.  I wanted an editor that
felt like I was using vscode and had all of the features I wanted:

* Click to move cursor
* Similar cursor movement keybindings to vscode
	* alt+left/right to move back/forward a word
	* ctrl+left/right to move to the beginning/end of a line
	* alt+up/down to move lines up/down
* Syntax highlighting with customizable themes

Turns out Micro is that editor! There was some setup involved to get everything working, but all in all it's been exactly what I wanted.

## Setup
Things I had to do manually with my config setup:
1. Make sure there wasn't any custom keybinding mapped to option+down or option+up
2. Disable all ctrl+left/right/up/down keybindings in System Settings > Keyboard > Keyboard Shortcuts > Mission Control
3. Update EDITOR environment variable in ~/.zshrc to micro


## Plugins
You can run this command to install plugins
```sh
micro --plugin install <plugin>
```

The plugins I have installed should always be added to the `.setup.sh` file.


## Helpful Links
* [Micro GitHub](https://github.com/zyedidia/micro)
	* [All built-in colorschemes](https://github.com/zyedidia/micro/tree/master/runtime/colorschemes)
* [Plugins](https://micro-editor.github.io/plugins.html)
* Guarda Linux: [Mastering the Micro Text Editor](https://forum.garudalinux.org/t/mastering-the-micro-text-editor/32889)
* [MicroOmni plugin](https://github.com/Neko-Box-Coder/MicroOmni)

