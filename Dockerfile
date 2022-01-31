FROM php:8.1-fpm-alpine as hosting

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
        zip

COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/default.conf /etc/nginx/http.d/default.conf
COPY docker/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY --chmod=111 docker/start.sh /start.sh

EXPOSE 443 80 9001
WORKDIR /code

ENV PATH=$PATH:/code/vendor/bin
ARG HTTP_ROOT=/code/apps/wildalaskancompany.com/public

RUN sed -i "s|{{HTTP_ROOT}}|${HTTP_ROOT}|g" /etc/nginx/http.d/default.conf

ENTRYPOINT ["/bin/bash", "-c", "/start.sh"]

ENV NGINX_START=true \
    PHP_FPM_START=true \
    HORIZON_START=false

FROM hosting as builder

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.12/main/ nodejs=12.22.6-r0 npm

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del -f .build-deps

RUN touch /tmp/xdebug.log \
       && chown www-data:www-data /tmp/xdebug.log

COPY --chmod=111 docker/install-composer.sh /usr/bin/install-composer
RUN install-composer \
    && rm /usr/bin/install-composer

#RUN apk add chromium chromium-chromedriver
