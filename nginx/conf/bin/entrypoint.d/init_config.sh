#!/usr/bin/env bash

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
if [[ ! -n $SSL_SESSION_CACHE ]]; then
 	SSL_SESSION_CACHE="shared:sslcache:20m"
fi
if [[ ! -n $SSL_SESSION_TIMEOUT ]]; then
 	SSL_SESSION_TIMEOUT="10m"
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
-e "s#<SSL_SESSION_CACHE>#$SSL_SESSION_CACHE#" \
-e "s#<SSL_SESSION_TIMEOUT>#$SSL_SESSION_TIMEOUT#" \
/opt/docker/nginx/vhosts/server.conf > /etc/nginx/conf.d/server.conf
#添加其它vhost配置
if [[ -d "/opt/docker/nginx/vhosts/other/" ]]; then
	alias cp='cp -f'
	cp /opt/docker/nginx/vhosts/other/*.conf /etc/nginx/conf.d/
fi

