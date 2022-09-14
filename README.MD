# Wordpress with LEMP Technology Stack in Docker Container
[![Workflow Actions Status](https://github.com/svenikea/Wordpress-LEMP/workflows/Github-Action/badge.svg)](https://github.com/svenikea/Wordpress-LEMP/actions)

The following image have been used:

* PHP 7.4.28
* MySQL 5.7
* Redis 6.2.6
* WordPress 5.9.2
* Nginx 1.21.4

## Quick Start

> Using the startup wizard to install and run the project

```bash
git clone https://github.com/kynguyen98/wordpress-LEMP.git
cd wordpress-LEMP
sudo chmod +x ./startup.sh
sudo ./startup.sh
```


## Manual Install 
### Dependencies
* Docker

 You can get the latest Docker Version from the Docker Official Website 

> For Ubuntu based [here](https://docs.docker.com/engine/install/ubuntu/)
> For Debian based [here](https://docs.docker.com/engine/install/debian/)
> For Red Hat/CentOS [here](https://docs.docker.com/engine/install/centos/)

* Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

### Setup Environment 
* Create a network interface 

```
docker network create -d bridge <network_name>
```

### Generate TLS/SSL Certificate

* OpenSSL
```
openssl req -x509 -nodes -newkey rsa:4096 -days 365 -keyout ./nginx/ssl/web.key -out ./nginx/ssl/web.crt -subj "/C=US/ST=GA/L=Atlanta/O=NHK Inc/OU=DevOps Department/CN=wordpress-test.com"
```

* dhparam
```
openssl dhparam -out dhparam.pem 1024
```

### Running with docker compose file 

```
docker-compose up
```

### Testing 
Testing your container by typing your host IP address with ```HTTPS``` for TLS/SSL connection

### Optional Configuration

#### Change the max file size for upload

> To increase the maximum file size to upload on WordPress, change these settings to enable it

* Nginx Configuration [nginx.conf](./nginx/my-nginx.conf)

```
# Can be increase at any size, using M as standard unit (Megabyte)
client_max_body_size 100M 
```

* PHP-FPM Configuration [php.init](./wordpress/php-fpm/my-php-development.ini)

```
# Can be increase at any size, using M as standard unit (Megabyte)
post_max_size = 200M
upload_max_filesize = 200M 
```

#### Allow unfiltered upload 

> To allow upload unsupported file, change the [compose file](docker-compose.yaml) under these line

```                        
WORDPRESS_CONFIG_EXTRA: |
define('ALLOW_UNFILTERED_UPLOADS', true);
```
* The ```WORDPRESS_CONFIG_EXTRA```  in compose file works but will not visible inside the container

### Securing Docker daemon with TLS and remote access to Docker Engine (Optional)

> To directly control the Docker Engine inside a remote VM or cloud servers without having to resolve with SSH connection. Even tho SSH connection is practically secure with a private key from the client-side and public key on the server-side but the SSH protocol uses port 22 which is a well-known port that many outsiders already knew and may attempt to access and login to the VM. Instead, if the VM is only running docker then the client-side doesn't need to access and control the Docker Engine via SSH connection (the client-side could if they want to).
> For more information, click [here](./REMOTE.MD)

