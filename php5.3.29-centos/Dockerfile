#使用国内网易镜像可以加快构建速度
FROM centos:6.9

MAINTAINER jacklin@shouyiren.net

#定义环境变量
ENV TIME_ZONE Asia/Shanghai
ENV RUN_ENV remote
ENV PHP_VERSION 5.3.29
ENV PHP_INI_DIR /usr/local/etc/php
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
--enable-sockets \
--without-pear  \
--disable-phar


RUN set -eux \
    && groupadd -g 82 www-data\
    && useradd -g 82 -u 82 www-data \
    && mkdir -p "$PHP_INI_DIR/conf.d" \
    && [ ! -d /var/www/html ] \
    && mkdir -p /var/www/html \
    && chown www-data:www-data /var/www/html \
    && chmod 777 /var/www/html \
    && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo \
    && yum install -y libtool autoconf213 bison libxml2-devel openssl-devel bzip2-devel \
    curl-devel libssh2-devel freetype-devel libjpeg-turbo-devel libpng-devel \
    libmcrypt-devel mysql mysql-devel\
    libstdc++  \
    && yum install -y epel-release \
    && yum install -y libmcrypt-devel \
    && export PHP_AUTOCONF=/usr/bin/autoconf-2.13 \
    && cd /opt \
    && curl -SL "https://github.com/php/php-src/archive/php-5.3.29.tar.gz" -o php.tar.gz \
    && mkdir /usr/src/php \
    && tar -xf php.tar.gz -C /usr/src/php --strip-components=1 \
    && rm -rf php.tar.gz \
    && cd /usr/src/php \
    && ./buildconf --force \
    && ./configure \
                --with-config-file-path="$PHP_INI_DIR" \
                --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
                --with-mhash \
                --enable-ftp \
                --enable-mbstring \
                --enable-mysqlnd \
                --with-curl \
                --with-zlib \
                --with-openssl \
                --with-freetype-dir=/usr/include/freetype2/freetype \
                --with-jpeg-dir=/usr/include \
                --with-png-dir=/usr/include \
                --with-mysqli=mysqlnd \
                --with-mysql=mysqlnd \
                --with-gd \
                --with-mcrypt \
                --with-pdo-mysql \
                --with-iconv-dir=/usr/include \
                ${PHP_EXTRA_CONFIGURE_ARGS:-} \
    && make -j "$(nproc)" \
    && find -type f -name '*.a' -delete \
    && make install \
    && cp -v php.ini-* "$PHP_INI_DIR/" \
    && cd /opt \
    && rm -rf /usr/src/php \
    && php --version \
    # && curl -SL "http://pear.php.net/go-pear.phar" -o go-pear.phar\
    # && printf "\n" | php go-pear.phar \
#安装tzdata安装包
    && yum install -y tzdata php-pear\
#设置时区
    && echo "${TIME_ZONE}" > /etc/timezone \
    && alias cp=cp \
    && ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime \
    && printf "\n" | pecl install -f phar \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-phar.ini" \
    && { \
        echo 'extension=phar.so'; \
    } | tee $ini \
    && printf "\n" | pecl install -f redis-4.1.1 \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-redis.ini" \
    && { \
        echo 'extension=redis.so'; \
    } | tee $ini \

#ssh2属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
    && printf "\n" | pecl install -f ssh2-0.13 \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-ssh2.ini" \
    && { \
        echo 'extension=ssh2.so'; \
    } | tee $ini \
    && printf "\n" | pecl install -f zendopcache-7.0.5 \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" \
    && { \
        echo '[zend.opcache]'; \
        echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20090626/opcache.so'; \
        echo 'opcache.enable_cli=1'; \
        echo 'opcache.enable=1'; \
        echo 'opcache.huge_code_pages=1'; \
        echo 'opcache.file_cache=/tmp '; \
    } | tee $ini \
    && curl -SL "http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz" -o /opt/ZendGuardLoader.tar.gz \
    && mkdir /usr/src/zend \
    && tar xf /opt/ZendGuardLoader.tar.gz  -C /usr/src/zend --strip-components=1 \
    && cp /usr/src/zend/php-5.3.x/ZendGuardLoader.so /usr/local/lib/php/extensions/no-debug-non-zts-20090626/ \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-zend_loader.ini" \
    && { \
        echo '[zend.loader]'; \
        echo 'zend_loader.enable=1'; \
        echo 'zend_loader.disable_licensing=0'; \
        echo 'zend_loader.obfuscation_level_support=3'; \
        echo 'zend_loader.license_path='; \
        echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20090626/ZendGuardLoader.so'; \
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
    && yum remove -y libtool autoconf213 bison libxml2-devel openssl-devel bzip2-devel \
    curl-devel libssh2-devel freetype-devel libjpeg-turbo-devel libpng-devel \
     epel-release libmcrypt-devel php-pear gcc\
    && yum clean all \
    && rm -rf /usr/src/zend \
    && rm -rf /opt/ZendGuardLoader.tar.gz

WORKDIR /var/www/html

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE 9000


CMD ["php-fpm"]