FROM marphy/uc-php7-node-composer:1.0.8
MAINTAINER Marian Abaffy "marphy@abaffy.eu"

COPY repositories /etc/apk/

RUN echo -e ";extension=memcached.so\n" > /etc/php7/conf.d/20_memcached.ini
RUN echo -e ";extension=mongodb.so\n" > /etc/php7/conf.d/mongodb.ini

RUN echo -e "extension=memcache.so\n" > /etc/php7/conf.d/20_memcache.ini

RUN apk update && apk upgrade
RUN apk add --update php7-memcached php7-mongodb

# install and remove building packages
ENV PHPIZE_DEPS autoconf file g++ gcc libc-dev make pkgconf re2c php7-dev php7-pear \
        yaml-dev pcre-dev zlib-dev libmemcached-dev cyrus-sasl-dev

RUN set -xe \
    && apk add --no-cache \
        --virtual .phpize-deps \
        $PHPIZE_DEPS

COPY php.ini /etc/php7/

RUN cd /tmp \
    && wget https://github.com/websupport-sk/pecl-memcache/archive/NON_BLOCKING_IO_php7.zip \
    && unzip NON_BLOCKING_IO_php7.zip \
    && ls /tmp

RUN cd /tmp/pecl-memcache-NON_BLOCKING_IO_php7 \
    && phpize7 \
    && ./configure --with-php-config=/usr/bin/php-config7 \
    && make \
    && make test \
    && make install


