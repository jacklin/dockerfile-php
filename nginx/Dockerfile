#使用国内网易镜像可以加快构建速度
FROM nginx:stable-alpine

MAINTAINER jacklin@shouyiren.net

ENV RLIMIT_FILES=102400 \
	WEB_DOCUMENT_ROOT=/app \
	WEB_SERVER_PORT='80 default' \
	WEB_SERVER_NAME='127.0.0.1' \
	SSL_CERTIFICATE=/opt/docker/nginx/ssl/common.crt \
	SSL_CERTIFICATE_KEY=/opt/docker/nginx/ssl/common.pem \
	SERVICE_NGINX_OPTS='' \
	WORKER_PROCESSES=4 \
	WORKER_CPU_AFFINITY='0001 0010 0100 1000' \
	KEEPALIVE_TIMEOUT=0 \
	DENY_SUFFIX_FILES='ini|cfg|dwt|lbi|sh|sql|txt|json|lock' \
	WORKER_RLIMIT_NOFILE=65534\
	WORKER_CONNECTIONES=65534 \
	SSL_SESSION_CACHE='shared:sslcache:20m' \
	SSL_SESSION_TIMEOUT='10m'

EXPOSE 80 443

COPY conf/ /opt/docker/

CMD ["/bin/sh","/opt/docker/bin/entrypoint.sh"]