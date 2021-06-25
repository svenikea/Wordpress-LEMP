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
	sudo pacman -Sy
	sudo pacman -S docker docker-compose git base-devel --needed
}

if [[ $ID == "debian" || $ID == "ubuntu" ]] 
then
	echo "Detected $PRETTY_NAME which is supported"
	apt
elif [[ $ID == "centos" || $ID == "rhel"  ]]
then
	echo "Detected $PRETTY_NAME which is supported"
	yum
elif [[ $PID == "arch" || $PID == "manjaro" ]]
then
	echo "Detected $PRETTY_NAME which is supported"
	pacman
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
#echo "SSL Connection keys and Cert"
#read -p "The key name (Default is server): " keyname
#keyname=${keyname:-server}
#keyname+='.key'
#read -p "The Cert name (Default is server): " certname
#certname=${certname:-server}
#certname+='.crt'
#read -p "How many days does this key will expires (Default is 365): " days
#days=${days:-365}


# Creating key for SSL connection
#sudo openssl req -x509 -newkey rsa:4096 -days ${days} -keyout ./nginx/ssl/${keyname} -out ./nginx/ssl/${certname}

# Export all variable to the environment file
sed "s/net/$network_name/g" -i .env
sed "s/wp/$wp_container_name/g" -i .env
sed "s/wordpress/$wp_hostname/g" -i .env
sed "s/mysql/$db_hostname/g" -i .env
sed "s/db/$db_container_name/g" -i .env
sed "s/user/$db_username/g" -i .env
sed "s/password/$db_password/g" -i .env
sed "s/content/$db_table/g" -i .env
sed "s/web/$web_container_name/g" -i .env
sed "s/web/$web_hostname/g" -i .env
#sed "s/server.key/$keyname/g" -i .env
#sed "s/server.crt/$certname/g" -i .env
#sed "s/server.key/$keyname/g" -i ./nginx/my-default.conf
#sed "s/server.crt/$certname/g" -i ./nginx/my-default.conf
sed "s/mysql/$db_table/g" -i ./wordpress/wp-config/my-wp-config.php


# Start Docker Systemd
sudo systemctl start docker
sudo systemctl enable

# Run the Docker Compose
sudo docker network create -d bridge ${network_name}
sudo docker-compose up -d
web_ip=$(sudo docker inspect $web_container_name | grep '"IPAddress": "1' | tr -d  '", ' | cut -d ':' -f2)
database_ip=$(sudo docker inspect $db_container_name | grep '"IPAddress": "1' | tr -d  '", ' | cut -d ':' -f2)
wordpress_ip=$(sudo docker inspect $wp_container_name | grep '"IPAddress": "1' | tr -d  '", ' | cut -d ':' -f2)
echo "============================================="
echo "|     Container      |      IP Address      |"
echo "---------------------------------------------"
echo "|		$wp_container_name	   |     $wordpress_ip    		  |"
echo "---------------------------------------------"
echo "|  $db_container_name		   |    $database_ip           	  |"
echo "---------------------------------------------"
echo "|	$web_container_name		   |	$web_ip 		  |"
echo "============================================="
echo "Go to this IP $web_ip or address on your browser and check it out"
