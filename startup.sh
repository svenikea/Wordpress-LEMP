#! /bin/bash

# Load Distribution Environment variables
if [ -f /etc/os-release ]; then
	. /etc/os-release
fi
if [ -f /lib/os-release ]; then
	. /lib/os-release
fi
apt_update() {
	apt-get update
	apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release
}
let tmp=${VERSION_ID::2}

apt () {
	if [[ $ID == "debian" ]]; then
		if [[ $tmp == 9 ]]; then
			echo "Installing Docker"
			apt_update
			curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
			echo \
			"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
			$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
			apt-get update 
			apt-get -y install -y docker-ce docker-ce-cli containerd.io
		elif [[ $tmp -lt 9 ]]; then
			echo "Detected $PRETTY_NAME which is not supported"
			exit 0
		fi
	elif [[ $ID == "ubuntu" ]]; then
		if [[ $tmp == 16 ]]; then
			echo "Installing Docker"
			apt_update
			gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv 9BDB3D89CE49EC21
			gpg --export --armor 9BDB3D89CE49EC21 | apt-key add -
			add-apt-repository "deb [arch=amd64] \
    		https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
			curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
			apt-get update 
			apt-get -y install docker-ce docker-ce-cli containerd.io
		elif [[ $tmp -lt 16 ]]; then
			echo "Detected $PRETTY_NAME which is not supported"
			exit 0
		elif [[ $tmp -ge 18 ]]; then
			echo "Installing Docker"
			apt_update
			curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
			echo \
			"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
			$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
			apt-get update
			apt-get -y install docker-ce docker-ce-cli containerd.io
		fi
	fi
	curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}
yum () {
	yum install -y yum-utils
	# Add Docker repository
	yum-config-manager \
		--add-repo \
		https://download.docker.com/linux/centos/docker-ce.repo
	yum install -y docker-ce docker-ce-cli containerd.io 
	curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

}

pacman () {
	pacman -Sy docker docker-compose git base-devel --needed --noconfirm
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
mkdir -p nginx/ssl
openssl req -x509 -nodes -newkey rsa:4096 -days 365 -keyout ./nginx/ssl/web.key -out ./nginx/ssl/web.crt -subj "/C=US/ST=GA/L=Atlanta/O=NHK Inc/OU=DevOps Department/CN=wordpress-test.com"

# Start Docker Systemd
systemctl start docker
# Run the Docker Compose
docker network create -d bridge net
docker-compose up -d
web_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker-compose ps -q web))
database_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker-compose ps -q db))
wordpress_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker-compose ps -q wordpress))
redis_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker-compose ps -q cache))
redis_ping=$(docker exec -it $(docker-compose ps -q wordpress) /bin/sh -c "apk add;redis-cli -h ${redis_ip}  -p 6379 ping")
status_code=$(curl -s -o /dev/null -w "%{http_code}" localhost)
if [[ -z "$wordpress_ip" || -z "$database_ip" || -z "$web_ip" || -z "$redis_ip" ]];then
	exit 1
else
	if [[ "$redis_ping" != "PONG" ]]; then
		exit 1
	elif [[ "${status_code}" != 200 ]]; then
		exit 1
	else 
		echo "All Check Finished!"
	fi
fi
