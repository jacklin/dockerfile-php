#使用国内网易镜像可以加快构建速度
FROM php:7.1.33-fpm-alpine

MAINTAINER jacklin@shouyiren.net

#定义环境变量
ENV TIME_ZONE Asiz/Shanghai
ENV RUN_ENV remote

COPY so/zookeeper.so /opt/
COPY tar/zookeeper-client-c.tar.gz /opt/
#国内repo源，让本地构建速度更快。
RUN set -ex \
        && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
#安装tzdata安装包
        && apk add --no-cache tzdata \
#设置时区
        && echo "${TIME_ZONE}" > /etc/timezone \
        && ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime \
#安装GD依赖库
        && apk add --no-cache --virtual .build-deps \
                libssh2-dev \
                freetype-dev \
                libjpeg-turbo-dev \
                libpng-dev \
                libmcrypt-dev \
                libstdc++ \
                librdkafka-dev \
#添加php源码中的扩展，添加gd,mysqli,pdo-mysql,opcache,gettext,mcrypt等扩展
        && docker-php-ext-configure gd \
                --with-freetype-dir=/usr/include/freetype2/freetype \
                --with-jpeg-dir=/usr/include \
                --with-png-dir=/usr/include \
        && docker-php-ext-install sockets gd bcmath zip opcache mcrypt pdo pdo_mysql mysqli pcntl \
#redis属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
        && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS openssl \
        && pecl install redis-4.1.1 \
        && docker-php-ext-enable redis \
#ssh2属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
        && pecl install ssh2-1.1.2 \
        && docker-php-ext-enable ssh2 \
#swoole属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
        && pecl install swoole-4.5.11 \
        && docker-php-ext-enable swoole \
#rdkafka属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
        && pecl install rdkafka \
        && docker-php-ext-enable rdkafka \
#安装zookeeper
        && mv /opt/zookeeper.so /usr/local/lib/php/extensions/no-debug-non-zts-20160303/ \
        && tar zxvf /opt/zookeeper-client-c.tar.gz -C /usr/local/ \
        && ln -s /usr/lib/libssl.so /usr/lib/libssl.so.10 \
        && ln -s /lib/libcrypto.so.1.1 /lib/libcrypto.so.10 \
        && docker-php-ext-enable zookeeper \
        && rm -rf /opt/zookeeper-client-c.tar.gz \
        && apk del .phpize-deps 


CMD ["php-fpm"]