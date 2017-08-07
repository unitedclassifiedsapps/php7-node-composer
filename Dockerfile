FROM marphy/uc-php7-node-composer:1.0.7
MAINTAINER Marian Abaffy "marphy@abaffy.eu"

RUN apk add --update php7-memcached

