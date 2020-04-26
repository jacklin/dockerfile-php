#使用国内网易镜像可以加快构建速度
FROM centos:6.9

MAINTAINER jacklin@shouyiren.net

#定义环境变量
ENV TIME_ZONE Asiz/Shanghai
ENV RUN_ENV remote
ENV PHPIZE_DEPS \
                autoconf \
                dpkg-dev dpkg \
                file \
                g++ \
                gcc \
                libc-dev \
                make \
                pkgconf \
                re2c \
                automake \
                libtool

ENV PHP_INI_DIR /usr/local/etc/php

RUN set -eux \
        && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
        && apk add --no-cache \
                ca-certificates \
                curl \
                tar \
                xz \
        && addgroup -g 82 -S www-data \
        && adduser -u 82 -D -S -G www-data www-data \
        && mkdir -p "$PHP_INI_DIR/conf.d" \
        && [ ! -d /var/www/html ] \
        && mkdir -p /var/www/html \
        && chown www-data:www-data /var/www/html \
        && chmod 777 /var/www/html

ENV PHP_EXTRA_CONFIGURE_ARGS \
--with-fpm-user=www-data \
--with-fpm-group=www-data \
--with-xmlrpc \
--with-bz2 \
--enable-fpm \
--disable-cgi \
--disable-rpath \
--disable-ipv6 \
--enable-fpm \
--enable-zip \
--enable-soap \
--enable-mbregex \
--enable-sysvsem \
--enable-shmop \
--enable-bcmath \
--enable-magic-quotes \
--enable-xml \
--enable-gd-native-ttf \
--enable-ftp \
--enable-mbstring \
--enable-exif \
--enable-pcntl \
--enable-sockets


ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

ENV GPG_KEYS 7267B52D FC9C83D7

ENV PHP_VERSION 5.3.29
ENV PHP_URL="https://www.php.net/get/php-5.3.29.tar.xz/from/this/mirror" PHP_ASC_URL="https://www.php.net/get/php-5.3.29.tar.xz.asc/from/this/mirror"
ENV PHP_SHA256="8438c2f14ab8f3d6cd2495aa37de7b559e33b610f9ab264f0c61b531bf0c262d" PHP_MD5=""



RUN set -eux; \
        \
        apk add --no-cache --virtual .fetch-deps gnupg; \
        \
        mkdir -p /usr/src; \
        cd /usr/src; \
        \
        curl -fsSL -o php.tar.xz "$PHP_URL"; \
        \
        #!/bin/sh \
        if [ -n "$PHP_SHA256" ]; then \
                echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
        fi; \
        if [ -n "$PHP_MD5" ]; then \
                echo "$PHP_MD5 *php.tar.xz" | md5sum -c -; \
        fi; \
        # \
        # if [ -n "$PHP_ASC_URL" ]; then \
        #         curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
        #         export GNUPGHOME="$(mktemp -d)"; \
        #         for key in $GPG_KEYS; do \
        #                 gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
        #         done; \
        #         gpg --batch --verify php.tar.xz.asc php.tar.xz; \
        #         gpgconf --kill all; \
        #         rm -rf "$GNUPGHOME"; \
        # fi; \
        \
        apk del --no-network .fetch-deps


COPY docker-php-source /usr/local/bin/


RUN set -eux \
        && chmod +x /usr/local/bin/docker-php-source \
        && apk add --no-cache --virtual .build-deps \
                $PHPIZE_DEPS \
                bzip2 \
                bzip2-dev \
                coreutils \
                libedit-dev \
                libxml2-dev \
                linux-headers \
                oniguruma-dev \
                sqlite-dev \
                curl-dev \
        && export CFLAGS="$PHP_CFLAGS" \
                CPPFLAGS="$PHP_CPPFLAGS" \
                LDFLAGS="$PHP_LDFLAGS" \
		&& OPENSSL_VERSION="1.0.1u" \
		&& cd /tmp \
		&& mkdir openssl \
		&& curl -sL "https://www.openssl.org/source/old/1.0.1/openssl-$OPENSSL_VERSION.tar.gz" -o openssl.tar.gz \
		&& tar -xf openssl.tar.gz -C openssl --strip-components=1 \
		&& cd /tmp/openssl \
		&& ./config \
		&& make -j "$(nproc)" \
		&& make install \
        && cd /tmp \
		&& rm -rf /tmp/* \
        && docker-php-source extract \
        && cd /usr/src/php \
        && ./configure \
                --with-config-file-path="$PHP_INI_DIR" \
                --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
                --with-mhash \
                --enable-ftp \
                --enable-mbstring \
                --enable-mysqlnd \
                --with-curl \
                --with-zlib \
                --with-openssl-dir=/usr/local/ssl \
                --with-openssl=/usr/local/ssl \
                ${PHP_EXTRA_CONFIGURE_ARGS:-} \
        && make -j "$(nproc)" \
        && find -type f -name '*.a' -delete \
        && make install \
        && find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true \
        && make clean \
        && cp -v php.ini-* "$PHP_INI_DIR/" \
        && cd / \
        && docker-php-source delete \
        && runDeps="$( \
                scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
                        | tr ',' '\n' \
                        | sort -u \
                        | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
        )" \
        && apk add --no-cache $runDeps \
        && apk del --no-network .build-deps \
        && rm -rf /tmp/pear ~/.pearrc \
        && php --version

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/


ENTRYPOINT ["docker-php-entrypoint"]

WORKDIR /var/www/html



# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE 9000

COPY so/* /usr/local/lib/php/extensions/no-debug-non-zts-20090626/
#国内repo源，让本地构建速度更快。
RUN set -eux \
        && chmod +x /usr/local/bin/docker-php* \
#安装tzdata安装包
        && apk add --no-cache tzdata \
#设置时区
        && echo "${TIME_ZONE}" > /etc/timezone \
        && ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime \
#安装GD依赖库
        && apk add --no-cache \
                libssh2-dev \
                freetype-dev \
                libjpeg-turbo-dev \
                libpng-dev \
                libmcrypt-dev \
                libstdc++ \
        && apk add --no-cache --virtual .build-op \
                mysql-dev \
                mysql \
#添加php源码中的扩展，添加gd,mysqli,pdo-mysql,opcache,gettext,mcrypt等扩展
        && docker-php-ext-configure gd \
                --with-freetype-dir=/usr/include/freetype2/freetype \
                --with-jpeg-dir=/usr/include \
                --with-png-dir=/usr/include \
        && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
        && docker-php-ext-configure mysql --with-mysql=mysqlnd \
        && docker-php-ext-install gd bcmath zip iconv mcrypt pdo pdo_mysql mysql mysqli \
#redis属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
        && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
        && pecl install redis-4.1.1 \
        && docker-php-ext-enable redis \
#ssh2属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
        && pecl install ssh2-0.13 \
        && docker-php-ext-enable ssh2 \
        && pecl install zendopcache-7.0.5 \
        && docker-php-ext-enable opcache \
        && docker-php-source delete \
        && ini="$PHP_INI_DIR/conf.d/docker-php-ext-zend_loader.ini" \
        && { \
        	echo '[zend.loader]'; \
            echo 'zend_loader.enable=1'; \
            echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20090626/ZendGuardLoader.so'; \
        } | tee $ini \
        && ini="$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" \
        && { \
        	echo '[zend.opcache]'; \
            echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20090626/opcache.so'; \
            echo 'opcache.enable_cli=1'; \
            echo 'opcache.enable=1'; \
            echo 'opcache.huge_code_pages=1'; \
            echo 'opcache.file_cache=/tmp '; \
        } | tee $ini \
        && cd /usr/local/etc \
        && mkdir php-fpm.d \
        && cp php-fpm.conf.default php-fpm.d/www.conf \
        && { \
                echo '[global]'; \
                echo 'include=etc/php-fpm.d/*.conf'; \
        } | tee php-fpm.conf \
        && { \
                echo '[global]'; \
                echo 'error_log = /proc/self/fd/2'; \
                echo '; https://github.com/docker-library/php/pull/725#issuecomment-443540114'; \
                echo; \
                echo '[www]'; \
                echo '; if we send this to /proc/self/fd/1, it never appears'; \
                echo 'access.log = /proc/self/fd/2'; \
                echo; \
                echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
                echo 'catch_workers_output = yes'; \
        } | tee php-fpm.d/docker.conf \
        && { \
                echo '[global]'; \
                echo 'daemonize = no'; \
                echo; \
                echo '[www]'; \
                echo 'listen = 9000'; \
        } | tee php-fpm.d/zz-docker.conf \
        && apk del --no-network .phpize-deps

CMD ["php-fpm"]