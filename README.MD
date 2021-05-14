# Wordpress with LEMP Technology Stack in Docker 
The following image have been used:

* PHP 7.4.19
* MySQL 5.7
* WordPress 5.7.1
* Nginx 1.19.10

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


