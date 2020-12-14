#!/usr/bin/env bash

# Init vars
if [[ -z "$SERVICE_NGINX_OPTS" ]]; then
	SERVICE_NGINX_OPTS=""
fi

exec /usr/sbin/nginx -g 'daemon off;' $SERVICE_NGINX_OPTS
