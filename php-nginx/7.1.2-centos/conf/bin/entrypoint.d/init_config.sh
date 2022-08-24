#!/usr/bin/env bash
cat /opt/docker/php/php.ini > /usr/local/etc/php/php.ini
cat /opt/docker/php/php-fpm-env.conf > /usr/local/etc/php-fpm.d/php-fpm-env.conf

if [[ ! -n $PM_MAX_CHILDREN ]]; then
 	PM_MAX_CHILDREN="500"
fi
if [[ ! -n $PM_START_SERVERS ]]; then
 	PM_START_SERVERS="4"
fi
if [[ ! -n $PM_MIN_SPARE_SERVERS ]]; then
 	PM_MIN_SPARE_SERVERS="2"
fi
if [[ ! -n $PM_MAX_SPARE_SERVERS ]]; then
 	PM_MAX_SPARE_SERVERS="8"
fi
if [[ ! -n $REQUEST_TERMINATE_TIMEOUT ]]; then
 	REQUEST_TERMINATE_TIMEOUT="30"
fi
if [[ ! -n $RLIMIT_FILES ]]; then
 	RLIMIT_FILES="12040"
fi
if [[ ! -n $PHP_FPM_PORT ]]; then
 	PHP_FPM_PORT="9000"
fi
if [[ ! -n $PHP_FPM_SOCK ]]; then
 	PHP_FPM_SOCK="/dev/shm/php-cgi.sock"
fi
# 修改PHP监听端口配置
sed -e "s#<PM_MAX_CHILDREN>#$PM_MAX_CHILDREN#" \
-e "s#<PM_START_SERVERS>#$PM_START_SERVERS#" \
-e "s#<PM_MIN_SPARE_SERVERS>#$PM_MIN_SPARE_SERVERS#" \
-e "s#<PM_MAX_SPARE_SERVERS>#$PM_MAX_SPARE_SERVERS#" \
-e "s#<REQUEST_TERMINATE_TIMEOUT>#$REQUEST_TERMINATE_TIMEOUT#" \
-e "s#<RLIMIT_FILES>#$RLIMIT_FILES#" \
-e "s#<PHP_FPM_PORT>#$PHP_FPM_PORT#" \
-e "s#<PHP_FPM_SOCK>#$PHP_FPM_SOCK#" \
/opt/docker/php/zz-docker.conf > /usr/local/etc/php-fpm.d/zz-docker.conf

if [[ ! -n $WORKER_PROCESSES ]]; then
 	WORKER_PROCESSES="1"
fi
if [[ ! -n "${WORKER_CPU_AFFINITY}" ]]; then
 	WORKER_CPU_AFFINITY="0001 0010 0100 1000"
fi
if [[ ! -n $WORKER_RLIMIT_NOFILE ]]; then
 	WORKER_RLIMIT_NOFILE="65534"
fi
if [[ ! -n $WORKER_CONNECTIONES ]]; then
 	WORKER_CONNECTIONES="65534"
fi
if [[ ! -n $GZIP ]]; then
 	GZIP="on"
fi
if [[ ! -n $GZIP_COMP_LEVEL ]]; then
 	GZIP_COMP_LEVEL="4"
fi
if [[ ! -n $GZIP_MIN_LENGTH ]]; then
 	GZIP_MIN_LENGTH="1k"
fi
if [[ ! -n $GZIP_BUFFERS ]]; then
 	GZIP_BUFFERS="4 8k"
fi
if [[ ! -n $GZIP_HTTP_VERSION ]]; then
 	GZIP_HTTP_VERSION="1.0"
fi
if [[ ! -n $GZIP_TYPES ]]; then
 	GZIP_TYPES="text/plain application/x-javascript text/css application/xml text/javasvript application/pdf image/x-ms-bmp"
fi
if [[ ! -n $GZIP_DISABLE ]]; then
 	GZIP_DISABLE='"MSIC [1-6]\.(?!.*SV1)"'
fi
if [[ ! -n $GZIP_VARY ]]; then
 	GZIP_VARY="on"
fi
if [[ ! -n $GZIP_PROXIED ]]; then
 	GZIP_PROXIED="off"
fi

# 修改nginx配置
sed -e "s#<WORKER_PROCESSES>#$WORKER_PROCESSES#" \
-e "s#<WORKER_CPU_AFFINITY>#$WORKER_CPU_AFFINITY#" \
-e "s#<KEEPALIVE_TIMEOUT>#$KEEPALIVE_TIMEOUT#" \
-e "s#<WORKER_RLIMIT_NOFILE>#$WORKER_RLIMIT_NOFILE#" \
-e "s#<WORKER_CONNECTIONES>#$WORKER_CONNECTIONES#" \
-e "s#<GZIP>#$GZIP#" \
-e "s#<GZIP_COMP_LEVEL>#$GZIP_COMP_LEVEL#" \
-e "s#<GZIP_MIN_LENGTH>#$GZIP_MIN_LENGTH#" \
-e "s#<GZIP_BUFFERS>#$GZIP_BUFFERS#" \
-e "s#<GZIP_HTTP_VERSION>#$GZIP_HTTP_VERSION#" \
-e "s#<GZIP_TYPES>#$GZIP_TYPES#" \
-e "s#<GZIP_DISABLE>#$GZIP_DISABLE#" \
-e "s#<GZIP_VARY>#$GZIP_VARY#" \
-e "s#<GZIP_PROXIED>#$GZIP_PROXIED#" \
/opt/docker/nginx/nginx.conf > /etc/nginx/nginx.conf

if [[ ! -n "${WEB_SERVER_PORT}" ]]; then
 	WEB_SERVER_PORT="80 default"
fi
if [[ ! -n $WEB_DOCUMENT_ROOT ]]; then
 	WEB_DOCUMENT_ROOT="/app"
fi

if [[ ! -n "${WEB_SERVER_NAME}" ]];then
	WEB_SERVER_NAME="127.0.0.1"
fi
if [[ ! -n $SSL_CERTIFICATE ]];then
	SSL_CERTIFICATE="common.crt"
fi
if [[ ! -n $SSL_CERTIFICATE_KEY ]];then
	SSL_CERTIFICATE_KEY="common.pem"
fi
if [[ ! -n $DENY_SUFFIX_FILES ]]; then
 	DENY_SUFFIX_FILES="null"
fi
# 修改vhosts配置
sed -e "s#<WEB_SERVER_PORT>#$WEB_SERVER_PORT#" \
-e "s#<WEB_DOCUMENT_ROOT>#$WEB_DOCUMENT_ROOT#" \
-e "s#<WEB_SERVER_NAME>#$WEB_SERVER_NAME#" \
-e "s#<PHP_FPM_PORT>#$PHP_FPM_PORT#" \
-e "s#<PHP_FPM_SOCK>#$PHP_FPM_SOCK#" \
-e "s#<SSL_CERTIFICATE>#$SSL_CERTIFICATE#" \
-e "s#<SSL_CERTIFICATE_KEY>#$SSL_CERTIFICATE_KEY#" \
-e "s#<DENY_SUFFIX_FILES>#$DENY_SUFFIX_FILES#" \
/opt/docker/nginx/vhosts/server.conf > /etc/nginx/conf.d/server.conf
#添加其它vhost配置
if [[ -d "/opt/docker/nginx/vhosts/other/" ]]; then
	alias cp='cp -f'
	cp /opt/docker/nginx/vhosts/other/*.conf /etc/nginx/conf.d/
fi
