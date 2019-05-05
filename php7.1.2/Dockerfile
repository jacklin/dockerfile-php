#使用国内网易镜像可以加快构建速度
FROM php:7.1.2-fpm-alpine

MAINTAINER jacklin@shouyiren.net

#定义环境变量
ENV TIME_ZONE Asiz/Shanghai
ENV RUN_ENV remote

#国内repo源，让本地构建速度更快。
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

#安装tzdata安装包
RUN apk add --no-cache tzdata \
#设置时区
&& echo "${TIME_ZONE}" > /etc/timezone \
&& ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

#安装GD依赖库
RUN apk add --no-cache --virtual .build-deps \
                libssh2-dev \
                freetype-dev \
                libjpeg-turbo-dev \
                libpng-dev \
                libmcrypt-dev \
                libstdc++

#添加php源码中的扩展，添加gd,mysqli,pdo-mysql,opcache,gettext,mcrypt等扩展
RUN set -ex \
        && docker-php-ext-configure gd \
                --with-freetype-dir=/usr/include/freetype2/freetype \
                --with-jpeg-dir=/usr/include \
                --with-png-dir=/usr/include \
        && docker-php-ext-install gd bcmath zip opcache iconv mcrypt pdo pdo_mysql mysqli pcntl

# #redis属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
        && pecl install redis-4.1.1 \
        && docker-php-ext-enable redis \
        && apk del .phpize-deps
# #ssh2属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
        && pecl install ssh2-1.1.2 \
        && docker-php-ext-enable ssh2 \
        && apk del .phpize-deps       
# #swoole属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
        && pecl install swoole-4.1.2 \
        && docker-php-ext-enable swoole \
        && apk del .phpize-deps

