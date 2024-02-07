# Scripts for Setting up a New Machine
Note: Only have a setup script for mac os right now

## Setup
To put all of the relevant files in this repo where they belong on a new machine, follow these steps:
* Clone this repo into your `~/Personal/` directory
  * Make a Personal directory if it doesn't already exist `mkdir ~/Personal && cd ~/Personal` 
  * Clone the repo in the Personal directory `git clone git@github.com:EricLamphere/configs.git`
  * cd back into the home directory `cd ~`
* Run `source ~/Personal/configs/setup/setup_mac.sh`

The full script looks like this:
```sh
mkdir ~/Personal && cd ~/Personal
git clone git@github.com:EricLamphere/configs.git
cd ~
source ~/Personal/configs/setup/setup_mac.sh
```

## TODO
* parameterize paths