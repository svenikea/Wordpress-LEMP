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


