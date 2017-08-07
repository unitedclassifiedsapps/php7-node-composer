FROM marphy/uc-php7-node-composer:1.0.7
MAINTAINER Marian Abaffy "marphy@abaffy.eu"

COPY repositories /etc/apk/

RUN apk update && apk upgrade

RUN apk add --no-cache --repository "http://dl-cdn.alpinelinux.org/alpine/edge/community"

ENV PHPIZE_DEPS autoconf file g++ gcc libc-dev make pkgconf re2c php7-dev php7-pear \
        yaml-dev pcre-dev zlib-dev libmemcached-dev cyrus-sasl-dev

RUN set -xe \
    && apk add --no-cache --repository "http://dl-cdn.alpinelinux.org/alpine/edge/community" \
        --virtual .phpize_deps \
        $PHPIZE_DEPS

#basic tools
RUN apk add --update wget vim bash git tar curl grep zlib make libxml2 readline \
    freetype openssl libjpeg-turbo libpng libmcrypt libwebp

RUN buildDeps=" build-base re2c file readline-dev autoconf binutils bison \
        libxml2-dev curl-dev freetype-dev openssl-dev \
        libjpeg-turbo-dev libpng-dev libmcrypt-dev \
        gmp-dev libmemcached-dev linux-headers" \
    && apk --update add $buildDeps

RUN apk add --update \
	libmemcached-dev

RUN cd /tmp \
    && wget https://github.com/websupport-sk/pecl-memcache/archive/NON_BLOCKING_IO_php7.zip \
    && unzip NON_BLOCKING_IO_php7.zip \
    && ls /tmp

RUN cd /tmp/pecl-memcache-NON_BLOCKING_IO_php7 \
    && phpize \
    && ./configure \
    && make \
    && make test \
    && make install

COPY php.ini /etc/php7/php.ini


