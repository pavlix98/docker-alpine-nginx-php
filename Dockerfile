# Powerfull and extra small docker image for your PHP apps.
# https://github.com/misaon/docker-alpine-nginx-php

FROM misaon/docker-alpine-supervisord:3.8

MAINTAINER Ondřej Misák <email@ondrejmisak.cz>

# Environment variables
### Setting server timezone.
ENV PHP_TIME_ZONE='Europe/Prague'
### Setting server index file.
ENV NGINX_INDEX_FILE='index.php'
### Set document root of nginx site.
ENV NGINX_DOCUMENT_ROOT='/var/www/html/www'

# Argument variables
## User and group name (if change, you must edit manifest/supervisor/supervisor.conf and manifest/php/php-fpm.conf too)
ARG USER='docker-user'
ARG GROUP='docker-apps'
## Version of PHP which will be installed.
ARG PHP_VER='7.2.8'
## Php core module names without prefix "php7-". Iconv extension is included automatically.
ARG PHP_CORE_PACKAGES='fpm opcache session intl mbstring json fileinfo tokenizer memcached curl gd pdo_sqlite pdo_mysql mysqli'
## Php other module names without prefix "php7-".
ARG PHP_OTHER_PACKAGES='xml simplexml xmlwriter dom bcmath ctype calendar zip ssh2'
## Packages needed for build iconv extension from source.
ARG BUILD_PACKAGES='wget build-base php7-dev'
## Packages needed for correctly working flow of this image.
ARG ESSENTIAL_PACKAGES='nginx'

# Copy init script.
COPY ./manifest/entrypoint.sh /

RUN echo '@testing https://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk update \
    # Create user and group.
    && addgroup -S $GROUP \
    && adduser -H -D -S -G $GROUP $USER \
    # # Create user and group.
    # Install utility, essential packages and PHP modules.
    && apk add --no-cache $ESSENTIAL_PACKAGES php7 $(printf 'php7-%s\n' $PHP_CORE_PACKAGES $PHP_OTHER_PACKAGES) \
    # # Install utility and essential packages.
    # File system actions.
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    # # File system actions.
    # Fix iconv extension.
    && apk add --no-cache --virtual .php-build-dependencies $BUILD_PACKAGES \
    && apk add --no-cache --update gnu-libiconv-dev@testing \
    && (mv /usr/bin/gnu-iconv /usr/bin/iconv; mv /usr/include/gnu-libiconv/*.h /usr/include; rm -rf /usr/include/gnu-libiconv) \
    && mkdir -p /opt \
    && cd /opt \
    && wget -q https://secure.php.net/distributions/php-$PHP_VER.tar.gz \
    && tar xzf php-$PHP_VER.tar.gz \
    && cd php-$PHP_VER/ext/iconv \
    && phpize \
    && ./configure --with-iconv=/usr \
    && make \
    && make install \
    && mkdir -p /etc/php7/conf.d \
    && echo 'extension=iconv.so' >> /etc/php7/conf.d/iconv.ini \
    # # Fix iconv extension.
    # Set init script executable.
    && chmod +x /entrypoint.sh \
    # # Set init script executable.
    # Cleanup.
    && apk del .php-build-dependencies \
    && rm -rf /var/cache/apk/* /tmp/* /opt/*
    # # Cleanup.

# Add config files.
COPY ./manifest/php/ /etc/php7/
COPY ./manifest/nginx/ /etc/nginx/
COPY ./manifest/supervisor/services /etc/supervisord.d/

# Set app work directory.
WORKDIR /var/www/html

# Expose Ports.
EXPOSE 443 80

# Run init script and supervisord.
ENTRYPOINT ["/entrypoint.sh"]
