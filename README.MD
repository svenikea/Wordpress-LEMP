# Wordpress with LEMP Technology Stack in Docker 
The following image have been used:

* PHP 7.4.19
* MySQL 5.7
* WordPress 5.7.1
* Nginx 1.19.10

## Dependencies
* Docker

> You can get the latest Docker Version from the Docker Official Website 
> For Ubuntu based [here](https://docs.docker.com/engine/install/ubuntu/)
> For Debian based [here](https://docs.docker.com/engine/install/debian/)
> For Red Hat/CentOS [here](https://docs.docker.com/engine/install/centos/)
* Docker Compose

> For Debian based use this commmand

```
sudo apt install docker-compose
```

> For RedHat Based machine use this command

```
sudo yum install docker-compose
```


## Installation
* Create a network interface 

```
docker network create -d bridge <network_name>
```

## Running with docker compose file 

```
docker-compose up
```

## Testing 
Testing your site by typing your host IP address with port 443 for ssl connection

## Optional Configuration

### Change the max file size for upload

> To increase the maximum file size to upload on WordPress, change these setting to enables it

* Nginx Configuration

```
client_max_body_size 100M # Can be increase at any size, using M at standard size
```

* PHP-FPM Configuration

```
post_max_size = 200M
upload_max_filesize = 200M # Can be increase at any size, using M at standard size
```

### Allow unfiltered upload 

> To allow upload unsupported file, change the [wp-config.conf](./wordpress/wp-config/my-wp-config.php)

```
define('ALLOW_UNFILTERED_UPLOADS', true);
```


## Securing Docker daemon with TLS and remote access to Docker Engine (Optional)

> To directly control the Docker Engine inside remote VM or cloud servers without having to resolve with SSH connection. Even tho SSH connection is practically secure with private key from the client side and public key on the server side but the SSH protocol uses port 22 which is a well-known port that many outsiders already knew and may attempt to access it and login to the VM. Instead, if the VM is only running docker then the client side doesn't need to access and control the Docker Engine via SSH connection (the client side could if they want to).
> For more information, click [here](./REMOTE.MD)

