FROM alpine:latest

RUN apk update && \
	apk add wget tar && \
	wget https://wordpress.org/latest.tar.gz && \
	mkdir -p /var/www/html && \
	tar -xvzf latest.tar.gz --directory /var/www/html && \
	apk del wget tar && \
	rm -rf /var/www/html/wp-config.php

CMD ["tail", "-f", "/dev/null"]
