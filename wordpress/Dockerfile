FROM alpine:3.13

RUN apk update && \
	apk add wget tar && \
	wget https://wordpress.org/latest.tar.gz && \
	mkdir -p /var/www/html && \
	tar -xvzf latest.tar.gz --directory /var/www/html && \
	apk del wget tar

CMD ["tail", "-f", "/dev/null"]
