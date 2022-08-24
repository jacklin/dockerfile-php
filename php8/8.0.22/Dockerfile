FROM php:8.0.22-cli-alpine
# docker build -t jacklin/php:8.1.9-cli-alpine .
RUN set -eux \
	&& sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& apk add --no-cache --virtual .run-deps libssh2-dev librdkafka-dev curl-dev \
	&& apk add --no-cache --virtual .build-deps $PHPIZE_DEPS autoconf libtool automake cppunit-dev git \
	&& docker-php-ext-install mysqli pdo pdo_mysql sockets curl \
	&& printf "\n" | /usr/local/bin/pecl install -f swoole-4.8.11 \
	&& docker-php-ext-enable swoole \
	&& printf "\n" | /usr/local/bin/pecl install -f redis-5.3.7 \
	&& docker-php-ext-enable redis \
	&& printf "\n" | /usr/local/bin/pecl install -f ssh2-1.3.1 \
 	&& docker-php-ext-enable ssh2 \
	&& printf "\n" | /usr/local/bin/pecl install -f rdkafka \
	&& docker-php-ext-enable rdkafka \
    && apk del --no-network .build-deps
