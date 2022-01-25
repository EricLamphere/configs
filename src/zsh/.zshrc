#######################################################################################
##### ZSH CONFIGURATION #####
#######################################################################################

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export VISUAL=nano
export EDITOR=nano

# less output modification
export LESS="-FXR"

# Path to your oh-my-zsh installation.
export ZSH="/Users/ericlamphere/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Comment out the following line to disable automatic update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? Standard plugins at $ZSH/plugins/ Custom plugins at $ZSH_CUSTOM/plugins/.
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh


## COLORS ##
export Black='\033[0;30m'
export DarkGray='\033[1;30m'
export Red='\033[0;31m'
export LightRed='\033[1;31m'
export Green='\033[0;32m'
export LightGreen='\033[1;32m'
export BrownOrange='\033[0;33m'
export Yellow='\033[1;33m'
export Blue='\033[0;34m'
export LightBlue='\033[1;34m'
export Purple='\033[0;35m'
export LightPurple='\033[1;35m'
export Cyan='\033[0;36m'
export LightCyan='\033[1;36m'
export LightGray='\033[0;37m'
export White='\033[1;37m'




#######################################################################################
######## UTILS ########
#######################################################################################
# Run a docker image locally
# Need to run the following before this function will work
# aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 042160483821.dkr.ecr.us-east-1.amazonaws.com
# docker-compose build <job name>

docker.port() {
    RUN_IMAGE=$1

    echo "Pulling ${LightBlue}$RUN_IMAGE${White}"
    docker pull $RUN_IMAGE

    container_id="$(docker run --rm -d -P --entrypoint=/init \
        #-v $HOME/.aws/:/home/rstudio/.aws/ \
        #-e AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID \
        #-e AWS_DEFAULT_PROFILE=$AWS_DEFAULT_PROFILE \
        #-e AWS_PROFILE=$AWS_PROFILE -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
        #-e AWS_SDK_LOAD_CONFIG=$AWS_SDK_LOAD_CONFIG \
        -e PASSWORD="1234" \
        $RUN_IMAGE)"

    echo $RUN_IMAGE
    docker container port $container_id
}


# ssh into an EC2 R session with RStudio
ssh.ec2.rstudio() {
	EC2_DNS=$1
	STAGE=$2
	ssh -i ~/.ssh/EC2-KEY-$STAGE.pem -N -L 8788:$EC2_DNS:8787 ec2-user@$EC2_DNS
}

# ssh into an EC2 terminal
ssh.ec2.terminal() {
	EC2_DNS=$1
	STAGE=$2
	ssh -i ~/.ssh/EC2-KEY-$STAGE.pem ec2-user@$EC2_DNS
}


find.open.ports() {
	netstat -anvp tcp | awk 'NR<3 || /LISTEN/'
}


close.ports() {
	arr=("$@")
	for i in "${arr[@]}"
		do
			echo "Killing port: ${LightBlue}$i${White}"
				sudo kill -9 $i
		done
}
