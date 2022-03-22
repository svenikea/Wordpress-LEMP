#! /bin/bash

# Load Distribution Environment variables
if [ -f /etc/os-release ]; then
	. /etc/os-release
fi
if [ -f /lib/os-release ]; then
	. /lib/os-release
fi
apt_update() {
	sudo apt-get update
	sudo apt-get -y install \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg \
		lsb-release
	# Add Docker GPG Key
	# Add Docker repository
}
let tmp=${VERSION_ID::2}
apt () {
	if [[ $ID == "debian" ]]
	then
		if [[ $tmp == 9 ]]
		then
			echo "Installing Docker"
			apt_update
			curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
			echo \
				"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
				$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
			sudo apt-get update 
			sudo apt-get -y install docker-ce docker-ce-cli containerd.io
		elif [[ $tmp -lt 9 ]]
		then 
			echo "Detected $PRETTY_NAME which is not supported"
			exit 0
		fi
	elif [[ $ID == "ubuntu" ]]
	then
		if [[ $tmp == 16 ]]
		then
			echo "Installing Docker"
			apt_update
			sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv 9BDB3D89CE49EC21
			sudo gpg --export --armor 9BDB3D89CE49EC21 | sudo apt-key add -
			sudo add-apt-repository "deb [arch=amd64] \
    		https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
			sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
			sudo apt-get update 
			sudo apt-get -y install docker-ce docker-ce-cli containerd.io
		elif [[ $tmp -lt 16 ]]
		then 
			echo "Detected $PRETTY_NAME which is not supported"
			exit 0
		elif [[ $tmp == 18 ]]
		then
			echo "Installing Docker"
			apt update
			apt-get -y install ca-certificates curl gnupg lsb-release
			curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
			echo \
			"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
			$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
			sudo apt-get update
			sudo apt-get -y install docker-ce docker-ce-cli containerd.io
		fi
	fi
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}


yum () {
	sudo yum install -y yum-utils
	# Add Docker repository
	sudo yum-config-manager \
		--add-repo \
		https://download.docker.com/linux/centos/docker-ce.repo
	sudo yum install -y docker-ce docker-ce-cli containerd.io 
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

}

pacman () {
	sudo pacman -Sy docker docker-compose git base-devel --needed --noconfirm
}

if [[ $ID == "debian" || $ID == "ubuntu" ]] 
then
	apt
elif [[ $ID == "centos" || $ID == "rhel"  ]]
then
	echo "Detected $PRETTY_NAME which is supported"
	yum
elif [[ $ID == "arch" || $ID == "manjaro" ]]
then
	echo "Detected $PRETTY_NAME which is supported"
	pacman
else 
	echo "Unsupported Distribution"
fi

clear

# Creating key for SSL connection
sudo mkdir -p nginx/ssl
sudo openssl req -x509 -nodes -newkey rsa:4096 -days 365 -keyout ./nginx/ssl/web.key -out ./nginx/ssl/web.crt -subj "/C=US/ST=GA/L=Atlanta/O=NHK Inc/OU=DevOps Department/CN=wordpress-test.com"

# Start Docker Systemd
sudo systemctl start docker
# Run the Docker Compose
sudo docker network create -d bridge net
sudo docker-compose up -d
web_ip=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(sudo docker-compose ps -q web))
database_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(sudo docker-compose ps -q db))
wordpress_ip=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(sudo docker-compose ps -q wordpress))
redis_ip=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(sudo docker-compose ps -q cache))
redis_ping=$(sudo docker exec -it $(sudo docker-compose ps -q wordpress) /bin/sh -c "apk add;redis-cli -h ${redis_ip}  -p 6379 ping")
status_code=$(curl -s -o /dev/null -w "%{http_code}" localhost)
if [[ -z "$wordpress_ip" || -z "$database_ip" || -z "$web_ip" || -z "$redis_ip" ]];then
	exit 1
else
	if [[ "$redis_ping" != "PONG" ]]; then
		exit 1
	elif [[ "${status_code}" != 200 ]]; then
		exit 1
	fi
	echo "All check are OK"
fi
