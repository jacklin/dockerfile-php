#使用国内网易镜像可以加快构建速度
FROM jacklin/php:7.1.33-fpm-alpine

MAINTAINER jacklin@shouyiren.net

ENV PM_MAX_CHILDREN=1000 \
	PM_START_SERVERS=5 \
	PM_MIN_SPARE_SERVERS=2 \
	PM_MAX_SPARE_SERVERS=25 \
	REQUEST_TERMINATE_TIMEOUT=30 \
	RLIMIT_FILES=102400 \
	PHP_FPM_PORT=7133 \
	PHP_FPM_SOCK='/dev/shm/php-cgi.sock' \
	WEB_DOCUMENT_ROOT=/app \
	WEB_SERVER_NAME='127.0.0.1' \
	SSL_CERTIFICATE=/opt/docker/nginx/ssl/common.crt \
	SSL_CERTIFICATE_KEY=/opt/docker/nginx/ssl/common.pem \
	SERVICE_NGINX_OPTS='' \
	SERVER_PORT="80 default" \
	WORKER_PROCESSES=4 \
	WORKER_CPU_AFFINITY='0001 0010 0100 1000' \
	KEEPALIVE_TIMEOUT=0 \
	DENY_SUFFIX_FILES='ini|cfg|dwt|lbi|sh|sql|txt|json|lock' \
	WORKER_RLIMIT_NOFILE=65534 \
	WORKER_CONNECTIONES=65534 \
	SEND_TIMEOUT=30 \
	SERVER_TOKENS=off

COPY conf/ /opt/docker/

#国内repo源，让本地构建速度更快。
RUN set -x \
	&& sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	# 添加用户nginx 用于运行服务
	&& addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    # Install nginx
    && apk add --no-cache \
        nginx 

EXPOSE 80 443

CMD ["/bin/sh","/opt/docker/bin/entrypoint.sh"]
