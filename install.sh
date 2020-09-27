#!/bin/bash

#ENV
sleep=1;


#Gathering facts
declare -a a_user
declare -a a_homedir

a_user=($(getent passwd | awk -F: '$3 > 999' | awk -F: '$3 < 60000 {print $1}'))
a_user+=(root)
a_homedir=($(getent passwd | awk -F: '$3 > 999' | awk -F: '$3 < 60000 {print $6}'))
a_homedir+=(/root)

############Install zsh############
if [ -x "$(command -v zsh)" ];
then
        echo "ZSH is already installed"
        sleep $sleep
else
        apt-get install -y -qq git zsh;
        git clone https://github.com/robbyrussell/oh-my-zsh.git /etc/oh-my-zsh && \
        cp /etc/oh-my-zsh/templates/zshrc.zsh-template /etc/skel/.zshrc && \
        sed -ie 's|$HOME/.oh-my-zsh|/etc/oh-my-zsh|g' /etc/skel/.zshrc && \
        echo "export ZSH_CACHE_DIR=~/.oh-my-zsh/cache" >> /etc/skel/.zshrc && \
        mkdir -p /etc/skel/.oh-my-zsh/cache

        ###Change Login Shell###
        for i in "${a_user[@]}"
                do
                         chsh -s /bin/zsh $i
        done
        ########################

        ###Link .zshrc to home dir###
        for i in "${a_homedir[@]}"
                do
                        ln -s /etc/skel/.zshrc $i/.zshrc
        done
        #############################
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /etc/oh-my-zsh/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions /etc/oh-my-zsh/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-completions /etc/oh-my-zsh/plugins/zsh-completions
        autoload -U compinit && compinit
        sed -i 's/ZSH_THEME.*/ZSH_THEME="bureau"/' /etc/skel/.zshrc
        sed -i 's/plugins.*/plugins=(git docker zsh-syntax-highlighting zsh-autosuggestions zsh-completions)/' /etc/skel/.zshrc
fi

############install sudo############
if [ -x "$(command -v sudo)" ];
then
        echo "sudo is already installed"
        sleep $sleep
else
        apt install -y -qq sudo;

	######Add Users to sudo######
	for u in "${a_user[@]}"
        do
		usermod -aG sudo $u
        done
	############################

fi

############install glances############
if [ -x "$(command -v glances)" ];
then
        echo "Glances is already installed"
        sleep $sleep
else
        apt install -y -qq glances;
fi


############install docker############
if [ -x "$(command -v docker)" ];
then
        echo "Docker is already installed"
        sleep $sleep
else
        apt-get install -y -qq apt-transport-https ca-certificates curl gnupg-agent software-properties-common;
        curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -;
        apt-key fingerprint 0EBFCD88;
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable";
        apt-get update;
        apt-get install -y -qq docker-ce docker-ce-cli containerd.io;
        groupadd docker;

        ###Add User to group docker###
        for i in "${a_user[@]}"
	do
        	usermod -aG docker $i
        done
        #############################
fi


############instal docker-compose############
if [ -x "$(command -v docker-compose)" ];
then
        echo "Docker-compose is already installed"
        sleep $sleep
else
        curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
        chmod +x /usr/local/bin/docker-compose;
fi


############install ansible############
if [ -x "$(command -v ansible)" ];
then
        echo "Ansible is already installed"
        sleep $sleep
else
        apt install -y -qq ansible;
fi

############install dnsutils############
if [ -x "$(command -v nslookup)" ];
then
        echo "DNSUtils is already installed"
        sleep $sleep
else
        apt install -y -qq dnsutils;
fi

############install exa############
if [ -x "$(command -v exa)" ];
then
        echo "exa is already installed"
        sleep $sleep
else
        apt install -y -qq exa;
        echo "alias ls='exa -lFhBg'" >> /etc/skel/.zshrc;
fi

############install RClone############
if [ -x "$(command -v rclone)" ];
then
        echo "Rclone is already installed"
        sleep $sleep
else
        apt install -y -qq rclone;
fi


############install BTRFS############
if [ -x "$(command -v btrfs)" ];
then
        echo "BTRFS is already installed"
        sleep $sleep
else
        apt install -y -qq btrfs-progs;
fi


##########Create SSH KeyPair########

for i in "${a_homedir[@]}"
do
	FILE=$i/.ssh/id_rsa.pub
	if test -f "$FILE"; then
		echo "SSH Keypair already exists in $i/.ssh "
		sleep $sleep
	else
		for u in "${a_user[@]}"
		do
			sudo -u $u zsh -c "ssh-keygen -q -f ~/.ssh/id_rsa -N ''"
		done
	fi
done


clear


	for i in "${a_homedir[@]}"
		do
		echo "SSH Public Key from $i"
		cat $i/.ssh/id_rsa.pub
		echo ''
		echo '---------------------'
		echo ''
	done


####################################
