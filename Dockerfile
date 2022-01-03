FROM php:8.1.1-fpm

ARG NODE_VERSION=16

RUN apt-get update && apt-get install -y \
        apt-utils \
        git \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libsqlite3-dev \
        libzip-dev \
        nginx \
        procps \
        supervisor \
        wget \
        zlib1g-dev \
        gconf-service \
        libasound2 \
        libatk1.0-0 \
        libcairo2 \
        libcups2 \
        libfontconfig1 \
        libgdk-pixbuf2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libpango-1.0-0 \
        libxss1 \
        fonts-liberation \
        libnss3 \
        lsb-release \
        xdg-utils \
        zlib1g-dev \
        libicu-dev \
        g++ \
        unzip \
        libxml2-dev \
        gnupg \
    && docker-php-ext-install pdo_mysql pdo_sqlite mysqli gd zip opcache pcntl soap \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

RUN adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx

RUN pecl install xdebug

RUN docker-php-ext-configure intl && \
    docker-php-ext-install intl

RUN apt install -y chromium
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/default.conf /etc/nginx/sites-enabled/default
COPY docker/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY --chmod=111 docker/start.sh /start.sh

EXPOSE 443 80
WORKDIR /code

ENV PATH=$PATH:/code/vendor/bin
ARG HTTP_ROOT=/code/apps/wildalaskancompany.com/public

RUN sed -i "s|{{HTTP_ROOT}}|${HTTP_ROOT}|g" /etc/nginx/sites-enabled/default

ENTRYPOINT ["/bin/bash", "-c", "/start.sh"]
