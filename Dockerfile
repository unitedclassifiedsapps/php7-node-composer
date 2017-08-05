FROM marphy/uc-php7-node-composer:1.0.5
MAINTAINER Marian Abaffy "marphy@abaffy.eu"

ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN echo "http://php.codecasts.rocks/7.0" >> /etc/apk/repositories && \
    apk add --update \
    curl \
    bash \
    git \
    unzip \
    wget \
    openssh-client \
    sudo

RUN echo "---> Preparing and Installing PHP" && \
    apk add --update \
    php7 \
    php7-apcu \
    php7-bcmath \
    php7-bz2 \
    php7-curl \
    php7-ctype \
    php7-exif \
    php7-gd \
    php7-imagick \
    php7-imap \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqlnd \
    php7-pdo_mysql \
    php7-mongodb \
    php7-opcache \
    php7-redis \
    php7-soap \
    php7-sqlite3 \
    php7-xdebug \
    php7-xml \
    php7-xmlreader \
    php7-openssl \
    php7-phar \
    php7-zip \
    php7-calendar \
    php7-dba \
    php7-ftp \
    php7-gettext \
    php7-iconv \
    php7-imap \
    php7-ldap \
    php7-odbc \
    php7-pcntl \
    php7-wddx \
    php7-xmlrpc \
    php7-xsl \
    php7-zlib && \
    sudo unlink /usr/bin/php && \
    sudo ln -s /usr/bin/php7 /usr/bin/php
