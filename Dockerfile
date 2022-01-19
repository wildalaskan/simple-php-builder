FROM php:8.1-fpm-alpine

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
        soap \
        zip \
    && EXPECTED_COMPOSER_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '${EXPECTED_COMPOSER_SIGNATURE}') { echo 'Composer.phar Installer verified'; } else { echo 'Composer.phar Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del -f .build-deps

RUN touch /tmp/xdebug.log \
       && chown www-data:www-data /tmp/xdebug.log

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.12/main/ nodejs=12.22.6-r0 npm

RUN apk add chromium chromium-chromedriver

COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/default.conf /etc/nginx/sites-enabled/default
COPY docker/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY --chmod=111 docker/start.sh /start.sh

EXPOSE 443 80 9001
WORKDIR /code

ENV PATH=$PATH:/code/vendor/bin
ARG HTTP_ROOT=/code/apps/wildalaskancompany.com/public

RUN sed -i "s|{{HTTP_ROOT}}|${HTTP_ROOT}|g" /etc/nginx/sites-enabled/default

ENTRYPOINT ["/bin/bash", "-c", "/start.sh"]
