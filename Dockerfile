FROM php:8.1-fpm

ARG NODE_VERSION=12

RUN apt-get update && apt-get install -y \
        apt-utils \
        fonts-liberation \
        g++ \
        gconf-service \
        git \
        gnupg \
        libasound2 \
        libatk1.0-0 \
        libcairo2 \
        libcups2 \
        libfontconfig1 \
        libfreetype6-dev \
        libgdk-pixbuf2.0-0 \
        libgtk-3-0 \
        libicu-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libnspr4 \
        libnss3 \
        libpango-1.0-0 \
        libpng-dev \
        libsqlite3-dev \
        libxml2-dev \
        libxss1 \
        libzip-dev \
        lsb-release \
        nginx \
        procps \
        supervisor \
        unzip \
        wget \
        xdg-utils \
        zlib1g-dev \
        zlib1g-dev \
    && docker-php-ext-install \
        gd \
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

RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

RUN adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx

RUN pecl install xdebug

RUN docker-php-ext-configure intl && \
    docker-php-ext-install intl && \
    docker-php-ext-enable xdebug

RUN docker-php-ext-install bcmath

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
