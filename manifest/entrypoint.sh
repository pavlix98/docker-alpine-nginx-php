#!/bin/sh

# Set timezone
sed -i -e "s@<PHP_TIME_ZONE>@$PHP_TIME_ZONE@" /etc/php7/php.ini

# Set document root of website
sed -i -e "s@<NGINX_DOCUMENT_ROOT>@$NGINX_DOCUMENT_ROOT@" /etc/nginx/sites.d/default.conf

# Set index files of website
sed -i -e "s@<NGINX_INDEX_FILE>@$NGINX_INDEX_FILE@" /etc/nginx/sites.d/default.conf

# Welcome message.
echo -e 'Thank you for using \033[1mdocker-alpine-nginx-php\033[0m (PHP 7.2.x) image for your project. Cheers!'
echo 'Server is starting...'
echo ''

# Start Supervisor and services.
exec /usr/bin/supervisord --nodaemon -c /etc/supervisord.conf
