#!/bin/sh

# Set correct GID and UID.
if [[ $PHP_UID != 82 ]] || [[ $PHP_GID != 82 ]] ; then
    groupmod -g $PHP_GID www-data
    usermod -u $PHP_UID www-data
fi


# Set timezone.
sed -i -e "s@<TIME_ZONE>@$TIME_ZONE@" /etc/php7/php.ini


# Set index files of website.
sed -i -e "s@<NGINX_INDEX_FILE>@$NGINX_INDEX_FILE@" /etc/nginx/sites.d/default.conf


# Set document root temp page.
sed -i -e "s@<NGINX_DOCUMENT_ROOT>@$NGINX_DOCUMENT_ROOT@" /etc/nginx/sites.d/default.conf


# Temp page.
mkdir -p /var/www/html/$NGINX_DOCUMENT_ROOT
cd /var/www/html/$NGINX_DOCUMENT_ROOT
mv /var/www/index-temp.html index-temp.html
cd /var/www/html


# Start Supervisor and services.
/usr/bin/supervisord --nodaemon -c /etc/supervisord.conf &


# Set 777 permissions to writable directories.
if [[ "$PRODUCTION_MODE" = true ]] ; then

    # Check if Gitlab env is declared.
    if [[ -n "$GITLAB_TOKEN_USER" ]] && [[ -n "$GITLAB_TOKEN" ]] && [[ -n "$GITLAB_REPO_URL" ]]; then
        echo "############################## Fetching git content ##############################"

        git init
        git remote add origin "https://$GITLAB_TOKEN_USER:$GITLAB_TOKEN@$GITLAB_REPO_URL"
        git fetch origin $BRANCH
        git checkout -f $BRANCH

        rm -rf .git
    fi

    # Update composer if exists.
    if [[ -f composer.json ]]; then
        echo ""
        echo "############################## COMPOSER ##############################"

        composer update -o --no-dev

        echo ""
    fi

    # Fix project permissions.
    chmod -R u+rwX,go+rX,go-w /var/www/html
    chown -R $PHP_UID:$PHP_GID /var/www/html

    # Writable directories.
    if [[ -d "temp" ]]; then
        chmod -R 777 temp
    fi
    if [[ -d "log" ]]; then
        chmod -R 777 log
    fi
    if [[ -d "var" ]]; then
        chmod -R 777 var
    fi
fi


# Remove temp HTML file.
cd /var/www/html/$NGINX_DOCUMENT_ROOT && rm index-temp.html && cd /var/www/html


# Restart supervisord.
pkill -f supervisord
/usr/bin/supervisord --nodaemon -c /etc/supervisord.conf
