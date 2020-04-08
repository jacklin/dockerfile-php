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
# 修改nginx配置
sed -e "s#<WORKER_PROCESSES>#$WORKER_PROCESSES#" \
-e "s#<WORKER_CPU_AFFINITY>#$WORKER_CPU_AFFINITY#" \
-e "s#<KEEPALIVE_TIMEOUT>#$KEEPALIVE_TIMEOUT#" \
-e "s#<WORKER_RLIMIT_NOFILE>#$WORKER_RLIMIT_NOFILE#" \
-e "s#<WORKER_CONNECTIONES>#$WORKER_CONNECTIONES#" \
/opt/docker/nginx/nginx.conf > /etc/nginx/nginx.conf

if [[ ! -n $SERVER_PORT ]]; then
 	SERVER_PORT="80 default"
fi
if [[ ! -n $WEB_DOCUMENT_ROOT ]]; then
 	WEB_DOCUMENT_ROOT="/app"
fi

if [[ ! -n $WEB_SERVER_NAME ]];then
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
sed -e "s#<SERVER_PORT>#$SERVER_PORT#" \
-e "s#<WEB_DOCUMENT_ROOT>#$WEB_DOCUMENT_ROOT#" \
-e "s#<WEB_SERVER_NAME>#$WEB_SERVER_NAME#" \
-e "s#<PHP_FPM_PORT>#$PHP_FPM_PORT#" \
-e "s#<PHP_FPM_SOCK>#$PHP_FPM_SOCK#" \
-e "s#<SSL_CERTIFICATE>#$SSL_CERTIFICATE#" \
-e "s#<SSL_CERTIFICATE_KEY>#$SSL_CERTIFICATE_KEY#" \
-e "s#<DENY_SUFFIX_FILES>#$DENY_SUFFIX_FILES#" \
/opt/docker/nginx/vhosts/server.conf > /etc/nginx/conf.d/server.conf
