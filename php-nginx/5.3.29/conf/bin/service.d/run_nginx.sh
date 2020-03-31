#!/usr/bin/env bash

# Init vars
if [[ -z "$SERVICE_NGINX_OPTS" ]]; then
	SERVICE_NGINX_OPTS=""
fi

/usr/local/sbin/php-fpm -D
chown www-data:www-data $PHP_FPM_SOCK
if [[ -f "/etc/nginx/conf.d/default.conf" ]]; then
	mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
fi
exec /usr/sbin/nginx -g 'daemon off;' $SERVICE_NGINX_OPTS
