#使用国内网易镜像可以加快构建速度
FROM centos:8

MAINTAINER jacklin@shouyiren.net

#定义环境变量
ENV TIME_ZONE Asia/Shanghai
ENV RUN_ENV remote
ENV PHP_VERSION 7.1.33
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_EXTRA_CONFIGURE_ARGS \
--with-fpm-user=www-data \
--with-fpm-group=www-data \
--with-xmlrpc \
--with-bz2 \
--enable-fpm \
--disable-cgi \
--disable-rpath \
--enable-ipv6 \
--enable-fpm \
--enable-zip \
--enable-opcahce \
--enable-soap \
--enable-mbregex \
--enable-sysvsem \
--enable-shmop \
--enable-bcmath \
--enable-xml \
--enable-gd-native-ttf \
--enable-ftp \
--enable-mbstring \
--enable-exif \
--enable-pcntl \
--enable-sockets \
--without-pear  \
--disable-phar

COPY tar/* /opt/
RUN set -eux \
    && groupadd -g 82 www-data\
    && useradd -g 82 -u 82 www-data \
    && mkdir -p "$PHP_INI_DIR/conf.d" \
    && [ ! -d /var/www/html ] \
    && mkdir -p /var/www/html \
    && chown www-data:www-data /var/www/html \
    && chmod 777 /var/www/html \
    && rename '.repo' '.repo.bak' /etc/yum.repos.d/*.repo \
    && curl https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo -o /etc/yum.repos.d/Centos-vault-8.5.2111.repo \
    && curl https://mirrors.aliyun.com/repo/epel-archive-8.repo -o /etc/yum.repos.d/epel-archive-8.repo \
    && sed -i 's/mirrors.cloud.aliyuncs.com/mirrors.aliyun.com/g' /etc/yum.repos.d/Centos-vault-8.5.2111.repo \
    && sed -i 's/mirrors.cloud.aliyuncs.com/mirrors.aliyun.com/g' /etc/yum.repos.d/epel-archive-8.repo \
    && yum clean all \
    && yum makecache \
    && yum update -y \
    && rename '.repo' '.repo.bak' /etc/yum.repos.d/CentOS-Linux-AppStream.repo \
    && rename '.repo' '.repo.bak' /etc/yum.repos.d/CentOS-Linux-BaseOS.repo \
    && yum install -y libtool autoconf bison libxml2-devel openssl-devel bzip2-devel git \
    curl-devel freetype-devel libjpeg-turbo-devel libpng-devel \
    mysql mysql-devel\
    gcc-c++ \
    && yum -y install gcc automake make\
    && yum install -y epel-release \
    && yum install -y libmcrypt-devel \
    && export PHP_AUTOCONF=/usr/bin/autoconf \
    && cd /opt \
    && yum install -y cyrus-sasl cyrus-sasl-devel cyrus-sasl-lib \
    && git clone https://github.com/edenhill/librdkafka.git \
    && cd librdkafka \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf librdkafka \
    && cd /opt \
    && curl -SL "https://github.com/php/php-src/archive/php-${PHP_VERSION}.tar.gz" -o php.tar.gz \
    && mkdir /usr/src/php \
    && tar -xf php.tar.gz -C /usr/src/php --strip-components=1 \
    && rm -rf php.tar.gz \
    && cd /usr/src/php \
    && ./buildconf --force \
    && ./configure \
                --prefix=/usr/local \
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
    && curl -SL "http://pear.php.net/go-pear.phar" -o go-pear.phar\
    && printf "\n" | php go-pear.phar \
# install zookeeper-client-c
    && cd /opt \
    && tar -zxvf zookeeper-client-c.tar.gz \
    && cd zookeeper-client-c \
    && ./configure --without-cppunit --prefix=/usr/local/zookeeper-client-c --disable-dependency-tracking \
    && make \
    && make install \
    && cd .. \
    && rm -rf zookeeper-client-c zookeeper-client-c.tar.gz \
# install php-zookeeper
    && cd /opt \
    && tar zxvf php-zookeeper-1.0.0.tar.gz \
    && cd php-zookeeper-1.0.0 \
    && phpize \
    && ./configure --with-libzookeeper-dir=/usr/local/zookeeper-client-c --with-php-config=/usr/local/bin/php-config \
    && make \
    && make install \
    && cd .. \
    && rm -rf php-zookeeper-1.0.0 php-zookeeper-1.0.0.tar.gz \
#安装tzdata安装包
    && yum install -y tzdata libssh2-devel \
#设置时区
    && echo "${TIME_ZONE}" > /etc/timezone \
    && alias cp=cp \
    && ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime \
    && printf "\n" | /usr/local/bin/pecl install -f redis-4.1.1 \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-redis.ini" \
    && { \
        echo 'extension=redis.so'; \
    } | tee $ini \
# #升级gcc至4.8
#     && { \
#         echo  '[testing-devtools-2-centos-$releasever]' ;\
#         echo 'name=testing 2 devtools for CentOS $releasever ' ;\
#         echo 'baseurl=http://people.centos.org/tru/devtools-2/$releasever/$basearch/RPMS' ; \
#         echo 'gpgcheck=0'; \
#      } | tee /etc/yum.repos.d/devtools-2.repo \
#     && yum install -y devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-c++\
#     && mv /usr/bin/gcc /usr/bin/gcc-4.4.7 \
#     && mv /usr/bin/g++ /usr/bin/g++-4.4.7 \
#     && mv /usr/bin/c++ /usr/bin/c++-4.4.7 \
#     && ln -s /opt/rh/devtoolset-2/root/usr/bin/gcc /usr/bin/gcc \
#     && ln -s /opt/rh/devtoolset-2/root/usr/bin/c++ /usr/bin/c++ \
#     && ln -s /opt/rh/devtoolset-2/root/usr/bin/g++ /usr/bin/g++ \
#     && gcc --version \
#rdkafka属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
    && printf "\n" | /usr/local/bin/pecl install -f rdkafka \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-rdkafka.ini" \
    && { \
        echo 'extension=rdkafka.so'; \
    } | tee $ini \
#swoole属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
    && printf "\n" | /usr/local/bin/pecl install -f swoole-4.2.8 \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-swoole.ini" \
    && { \
        echo 'extension=swoole.so'; \
    } | tee $ini \
#ssh2属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
    && printf "\n" | /usr/local/bin/pecl install -f ssh2-1.2 \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-ssh2.ini" \
    && { \
        echo 'extension=ssh2.so'; \
    } | tee $ini \
    # && printf "\n" | /usr/local/bin/pecl install -f zendopcache-7.0.5 \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" \
    && { \
        echo '[zend.opcache]'; \
        echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20160303/opcache.so'; \
        echo 'opcache.enable_cli=1'; \
        echo 'opcache.enable=1'; \
        echo 'opcache.huge_code_pages=1'; \
        echo 'opcache.file_cache=/tmp '; \
    } | tee $ini \
    && ini="$PHP_INI_DIR/conf.d/docker-php-ext-zookeeper.ini" \
    && { \
        echo 'extension=zookeeper.so'; \
    } | tee $ini \

    && cd /usr/local/etc \
    && cp php-fpm.conf.default php-fpm.conf \
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
    && yum remove -y gcc automake make epel-release libtool autoconf bison mysql \
    && yum clean all \
    && rm -rf /usr/src/zend 

WORKDIR /var/www/html

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE 9000


CMD ["php-fpm"]