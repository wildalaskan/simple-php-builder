FROM spiralscout/roadrunner as roadrunner

FROM node:16-alpine as node

FROM php:8.1-fpm-alpine as hosting-deps

COPY --from=roadrunner /usr/bin/rr /usr/bin/rr

RUN apk add --update \
        bash \
        g++ \
        git \
        gnupg \
        icu-dev \
        libmcrypt-dev \
        libpng-dev \
        libxml2-dev \
        libzip-dev \
        make \
        nginx \
        procps \
        sqlite-dev \
        supervisor \
        unzip \
        wget \
        xdg-utils \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
        bcmath \
        gd \
        intl \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_sqlite \
        sockets \
        zip \
    && mkdir /var/run/rr \
    && chmod -R 777 /var/run/rr

WORKDIR /code

ENV PATH=$PATH:/code/vendor/bin \
    NGINX_START=true \
    PHP_FPM_START=true \
    HORIZON_START=false \
    OCTANE_START=false

EXPOSE 443 80 9001
CMD []
ENTRYPOINT ["/entrypoint.sh"]

FROM hosting-deps as builder-deps

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del -f .build-deps

RUN touch /tmp/xdebug.log \
       && chown www-data:www-data /tmp/xdebug.log

COPY --chmod=111 docker/install-composer.sh /usr/bin/install-composer
RUN install-composer \
    && rm /usr/bin/install-composer

RUN npm install -g @stoplight/spectral-cli
RUN composer global require squizlabs/php_codesniffer=\*

FROM hosting-deps as hosting

ARG HTTP_ROOT=/code/public

COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/default.conf /etc/nginx/http.d/default.conf
COPY docker/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY --chmod=111 docker/entrypoint.sh /entrypoint.sh

RUN sed -i "s|{{HTTP_ROOT}}|${HTTP_ROOT}|g" /etc/nginx/http.d/default.conf

FROM builder-deps as builder

COPY --from=hosting /etc/supervisord.conf /etc/supervisord.conf
COPY --from=hosting /etc/nginx/http.d/default.conf /etc/nginx/http.d/default.conf
COPY --from=hosting /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY --from=hosting /entrypoint.sh /entrypoint.sh
