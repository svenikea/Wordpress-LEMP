#! /bin/bash 

# Load Distribution Environment variables
source /etc/os-release

apt () {
	sudo apt-get update
	sudo apt-get -y install \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg \
		lsb-release
	# Add Docker GPG Key
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	# Add Docker repository
	echo \
		"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
		$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose
}

yum () {
	sudo yum update -y
	sudo yum install -y yum-utils
	# Add Docker repository
	sudo yum-config-manager \
		--add-repo \
		https://download.docker.com/linux/centos/docker-ce.repo
	sudo yum update -y 
	sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose
}



if [[ $ID == "debian" || $ID == "ubuntu" ]] 
then
	echo "Detected $PRETTY_NAME which is supported"
	apt
elif [[ $ID == "centos" || $ID == "rhel"  ]]
then
	echo "Detected $PRETTY_NAME which is supported"
	yum
else 
	echo "Unsupported Distribution"
fi

clear

# Adding user to docker group
sudo usermod -aG docker $(whoami)

# Asking for network name for docker
read -p "Network Name (Default is net): " network_name
network_name=${network_name:-net}

# Asking for Container name
## Wordpress 
read -p "Wordpress Container Name (Default is wp): " wp_container_name
wp_container_name=${wp_container_name:-wp}
read -p "Wordpress  Hostname (Default is wordpress): " wp_hostname
wp_hostname=${wp_hostname:-wordpress}

## Database
read -p "Database Container Name (Default is db): " db_container_name
db_container_name=${db_container_name:-db}
read -p "Database Hostname (Default is mysql): " db_hostname
db_hostname=${db_hostname:-mysql}
read -p "Database Database Name (Default is content): " db_table
db_table=${db_table:-content}
read -p "Database User Name (Default is user): " db_username
db_username=${db_username:-user}
read -p "Database User Password (Default is password): " db_password
db_password=${db_password:-password}


## Website
read -p "Web Container name (Default is web): " web_container_name
web_container_name=${web_container_name:-web}
read -p "Web hostname (Default is web): " web_hostname
web_hostname=${web_hostname:-web}

# Export all variable to the environment file
sed "s/net/$network_name/g" -i .env
sed "s/wp/$wp_container_name/g" -i .env
sed "s/wordpress/$wp_hostname/g" -i .env
sed "s/db/$db_hostname/g" -i .env
sed "s/mysql/$db_table/g" -i .env
sed "s/user/$db_username/g" -i .env
sed "s/password/$db_password/g" -i .env
sed "s/content/$db_table/g" -i .env
sed "s/web/$web_container_name/g" -i .env
sed "s/web/$web_hostname/g" -i .env

# Start Docker Systemd
sudo systemctl start docker
sudo systemctl enable

# Run the Docker Compose
sudo docker network create -d bridge ${network_name}
sudo docker-compose up -d
