FROM marphy/uc-php7-node-composer:1.0.6
MAINTAINER Marian Abaffy "marphy@abaffy.eu"

RUN echo -e '\napc.enable_cli = 1\napc.enabled = 1' >> /etc/php7/php.ini

