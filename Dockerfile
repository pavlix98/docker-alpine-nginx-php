FROM alpine:3.8



#  ______           _                                     _                     _       _     _
# |   ___|         (_)                                   | |                   (_)     | |   | |
# | |__ _ ____   ___ _ __ ___  _ __  _ __ ___   ___ _ __ | |_  __   ____ _ _ __ _  __ _| |__ | | ___ ___
# |  __| '_ \ \ / | | '__/ _ \| '_ \| '_ ` _ \ / _ | '_ \| __| \ \ / / _` | '__| |/ _` | '_ \| |/ _ / __|
# | |__| | | \ V /| | | | (_) | | | | | | | | |  __| | | | |_   \ V | (_| | |  | | (_| | |_) | |  __\__ \
# \____|_| |_|\_/ |_|_|  \___/|_| |_|_| |_| |_|\___|_| |_|\__|   \_/ \__,_|_|  |_|\__,_|_.__/|_|\___|___/

    # Server and PHP timezone.
ENV TIME_ZONE=Europe/Prague \
    # Set production mode.
    PRODUCTION_MODE=false \
    # Nginx index file name.
    NGINX_INDEX_FILE=index.php \
    # Set document root of Nginx site (/var/www/html/<NGINX_DOCUMENT_ROOT>).
    NGINX_DOCUMENT_ROOT=www \
    # Set GitLab repo variables.
    GITLAB_TOKEN_USER='' \
    GITLAB_TOKEN='' \
    GITLAB_REPO_URL='' \
    # PHP UID and GID. Default is 82 (recomendend UID for PHP in Alpine linux).
    PHP_GID=82 \
    PHP_UID=82

    # Fix PHP iconv extension. Issue #240 (https://github.com/docker-library/php/issues/240).
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php



#   ___                                       _                     _       _     _
#  / _ \                                     | |                   (_)     | |   | |
# / /_\ \_ __ __ _ _   _ _ __ ___   ___ _ __ | |_  __   ____ _ _ __ _  __ _| |__ | | ___  ___
# |  _  | '__/ _` | | | | '_ ` _ \ / _ \ '_ \| __| \ \ / / _` | '__| |/ _` | '_ \| |/ _ \/ __|
# | | | | | | (_| | |_| | | | | | |  __/ | | | |_   \ V / (_| | |  | | (_| | |_) | |  __/\__ \
# \_| |_/_|  \__, |\__,_|_| |_| |_|\___|_| |_|\__|   \_/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
#             __/ |
#            |___/

    # Packages needed for correctly working flow of this image.
ARG ESSENTIAL_PACKAGES='shadow sed htop nano supervisor nginx git composer'



# ___  ___            _        _       _ _                   _       _
# |  \/  |           (_)      (_)     (_) |                 (_)     | |
# | .  . | __ _  __ _ _  ___   _ _ __  _| |_   ___  ___ _ __ _ _ __ | |_
# | |\/| |/ _` |/ _` | |/ __| | | '_ \| | __| / __|/ __| '__| | '_ \| __|
# | |  | | (_| | (_| | | (__  | | | | | | |_  \__ \ (__| |  | | |_) | |_
# \_|  |_/\__,_|\__, |_|\___| |_|_| |_|_|\__| |___/\___|_|  |_| .__/ \__|
#                __/ |                                        | |
#               |___/                                         |_|

COPY ./manifest/entrypoint.sh /



# ______              _           _        _ _
# | ___ \            (_)         | |      | | |
# | |_/ /   _ _ __    _ _ __  ___| |_ __ _| | | ___ _ __
# |    / | | | '_ \  | | '_ \/ __| __/ _` | | |/ _ \ '__|
# | |\ \ |_| | | | | | | | | \__ \ || (_| | | |  __/ |
# \_| \_\__,_|_| |_| |_|_| |_|___/\__\__,_|_|_|\___|_|

RUN set -x \
    && apk update \
    # Setting the timezone.
    && apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/$TIME_ZONE /etc/localtime \
    # Create user and group.
    && addgroup -g $PHP_GID -S www-data \
    && adduser -u $PHP_UID -D -S -G www-data www-data \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    # Install essential packages.
    && apk add --no-cache $ESSENTIAL_PACKAGES \
    # Install PHP extensions.
    && apk add --no-cache \
        php7-fpm \
        php7-opcache \
        php7-session \
        php7-json \
        php7-fileinfo \
        php7-iconv \
        php7-ctype \
        php7-tokenizer \
        php7-pdo_sqlite \
        php7-pdo_mysql \
        php7-mbstring \
        php7-memcached \
        php7-gd \
        php7-intl \
        php7-simplexml \
        php7-xmlwriter \
        php7-xml \
        php7-dom \
        php7-curl \
        php7-zip \
        php7-ssh2 \
        php7-ftp \
    # Fix PHP iconv extension.
    #&& apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv \
    # Install prestissimo for faster plugin install
    && composer global require hirak/prestissimo \
    # Config supervizor.
    && mkdir -p /etc/supervisord.d \
    # Forward request and error logs to docker log collector.
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && ln -sf /dev/stderr /var/log/php7-fpm.log \
    # Set init script executable.
    && chmod +x /entrypoint.sh \
    # Cleanup.
    && apk del tzdata \
    && rm -rf /var/cache/apk/* /tmp/* /opt/*

    #####################################################################
    ######################## FIX iconv extension #######################$
    #####################################################################
    ENV BUILD_PACKAGES="wget build-base php7-dev autoconf re2c libtool"
    RUN apk --no-cache --progress add $BUILD_PACKAGES \
    # Install GNU libiconv
    && mkdir -p /opt \
    && cd /opt \
    && wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz \
    && tar xzf libiconv-1.15.tar.gz \
    && cd libiconv-1.15 \
    && sed -i 's/_GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");/#if HAVE_RAW_DECL_GETS\n_GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");\n#endif/g' srclib/stdio.in.h \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    # Install PHP iconv from source
    && cd /opt \
    && wget http://php.net/distributions/php-7.1.5.tar.gz \
    && tar xzf php-7.1.5.tar.gz \
    && cd php-7.1.5/ext/iconv \
    && phpize \
    && ./configure --with-iconv=/usr/local \
    && make \
    && make install \
    && mkdir -p /etc/php7/conf.d \
    && echo "extension=iconv.so" >> /etc/php7/conf.d/iconv.ini \
    # Cleanup
    && apk del $BUILD_PACKAGES \
    && rm -rf /opt \
    && rm -rf /var/cache/apk/* \
    && rm -rf /usr/share/*
    #####################################################################
    #####################################################################
    #####################################################################



#  _____                                      __ _          __ _ _
# /  __ \                                    / _(_)        / _(_) |
# | /  \/ ___  _ __  _   _    ___ ___  _ __ | |_ _  __ _  | |_ _| | ___  ___
# | |    / _ \| '_ \| | | |  / __/ _ \| '_ \|  _| |/ _` | |  _| | |/ _ \/ __|
# | \__/\ (_) | |_) | |_| | | (_| (_) | | | | | | | (_| | | | | | |  __/\__ \
#  \____/\___/| .__/ \__, |  \___\___/|_| |_|_| |_|\__, | |_| |_|_|\___||___/
#             | |     __/ |                         __/ |
#             |_|    |___/                         |___/

COPY ./manifest/php/ /etc/php7/
COPY ./manifest/nginx/ /etc/nginx/
COPY ./manifest/supervisor/supervisord.conf /etc/
COPY ./manifest/supervisor/services /etc/supervisord.d/
COPY ./manifest/index-temp.html /var/www/



#  _____      _                                            _          _ _               _
# /  ___|    | |                                          | |        | (_)             | |
# \ `--.  ___| |_    __ _ _ __  _ __   __      _____  _ __| | __   __| |_ _ __ ___  ___| |_ ___  _ __ _   _
#  `--. \/ _ \ __|  / _` | '_ \| '_ \  \ \ /\ / / _ \| '__| |/ /  / _` | | '__/ _ \/ __| __/ _ \| '__| | | |
# /\__/ /  __/ |_  | (_| | |_) | |_) |  \ V  V / (_) | |  |   <  | (_| | | | |  __/ (__| || (_) | |  | |_| |
# \____/ \___|\__|  \__,_| .__/| .__/    \_/\_/ \___/|_|  |_|\_\  \__,_|_|_|  \___|\___|\__\___/|_|   \__, |
#                        | |   | |                                                                     __/ |
#                        |_|   |_|                                                                    |___/

WORKDIR /var/www/html



#  _____                                             _
# |  ___|                                           | |
# | |____  ___ __   ___  ___  ___   _ __   ___  _ __| |_ ___
# |  __\ \/ / '_ \ / _ \/ __|/ _ \ | '_ \ / _ \| '__| __/ __|
# | |___>  <| |_) | (_) \__ \  __/ | |_) | (_) | |  | |_\__ \
# \____/_/\_\ .__/ \___/|___/\___| | .__/ \___/|_|   \__|___/
#           | |                    | |
#           |_|                    |_|

EXPOSE 80



# ______              _       _ _                   _       _
# | ___ \            (_)     (_) |                 (_)     | |
# | |_/ /   _ _ __    _ _ __  _| |_   ___  ___ _ __ _ _ __ | |_
# |    / | | | '_ \  | | '_ \| | __| / __|/ __| '__| | '_ \| __|
# | |\ \ |_| | | | | | | | | | | |_  \__ \ (__| |  | | |_) | |_
# \_| \_\__,_|_| |_| |_|_| |_|_|\__| |___/\___|_|  |_| .__/ \__|
#                                                    | |
#                                                    |_|

ENTRYPOINT ["/entrypoint.sh"]
