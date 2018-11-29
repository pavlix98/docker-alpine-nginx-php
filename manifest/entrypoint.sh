#!/bin/sh

# Set correct GID and UID.
groupmod -g $PHP_GID www-data
usermod -u $PHP_UID www-data


# Set PHP mode.
if [[ "$PRODUCTION_MODE" = true ]] ; then
    mv /etc/php7/php.ini-production /etc/php7/php.ini
else
    mv /etc/php7/php.ini-development /etc/php7/php.ini
fi


# Set timezone.
sed -i -e "s@<TIME_ZONE>@$TIME_ZONE@" /etc/php7/php.ini


# Set document root of website.
sed -i -e "s@<NGINX_DOCUMENT_ROOT>@$NGINX_DOCUMENT_ROOT@" /etc/nginx/sites.d/default.conf


# Set index files of website.
sed -i -e "s@<NGINX_INDEX_FILE>@$NGINX_INDEX_FILE@" /etc/nginx/sites.d/default.conf


# Check if Gitlab env is declared.
if [[ -n "$GITLAB_TOKEN_USER" ]] && [[ -n "$GITLAB_TOKEN" ]] && [[ -n "$GITLAB_REPO_URL" ]]; then
    echo "############################## Fetching git content ##############################"

    git init
    git remote add origin "https://$GITLAB_TOKEN_USER:$GITLAB_TOKEN@$GITLAB_REPO_URL"
    git fetch origin production
    git checkout -f production

    rm -rf .git
fi


# Fix project permissions.
chmod -R u+rwX,go+rX,go-w /var/www/html
chown -R $PHP_UID:$PHP_GID /var/www/html


# Set 777 permissions to writable directories
if [[ -d "temp" ]]; then
    chmod -R 777 temp
fi
if [[ -d "log" ]]; then
    chmod -R 777 log
fi


# Update composer if exists.
if [[ -f composer.json ]]; then
    echo ""
    echo "############################## COMPOSER ##############################"

    if [[ "$PRODUCTION_MODE" = true ]] ; then
        composer update -o --no-dev --classmap-authoritative
    else
        composer update -o
    fi

    echo ""
fi


# Start Supervisor and services.
exec /usr/bin/supervisord --nodaemon -c /etc/supervisord.conf
