# Dotfiles & Configs
Various personal dotfiles and scripts to help manage my workflow

## Setup
The setup and install scripts only work for mac at the moment. Dotfiles for any other operating system (e.g. Windows) are only here for safekeeping.

### Packages
If you're setting up your mac from scratch, install some helpful packages first with the `install` script
```sh
./install
```

### Dotfiles
To setup your dotfiles, simply run the setup script in the root of this repository. Use the `--dry-run` option to see what the setup script does
```sh
./setup --dry-run
```

Once that looks good, run the setup script without the `--dry-run` option
```sh
./setup
```

If you run into errors because certain dotfiles already exist, use the `--force` option
```sh
./setup --force
```

## Notes
* Each subdirectory in the dotfiles directory contains files/folders _exactly_ how they should be named
* Most (if not all) files and directories should be symlinked into the home directory (`~` on mac os)

