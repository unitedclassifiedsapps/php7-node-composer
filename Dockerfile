FROM alpine:3.7
MAINTAINER Marian Abaffy "marian.abaffy@unitedclassifieds.sk"

ENV NPM_CONFIG_LOGLEVEL info
ENV VERSION=v9.8.0 NPM_VERSION=5 YARN_VERSION=latest
ENV PHANTOMJS_ARCHIVE="phantomjs.tar.gz"

# For base builds
ENV CONFIG_FLAGS="--fully-static" DEL_PKGS="libstdc++" RM_DIRS=/usr/include

RUN apk add --no-cache curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ && \
  for server in pgp.mit.edu keyserver.pgp.com ha.pool.sks-keyservers.net; do \
    gpg --keyserver $server --recv-keys \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      FD3A5288F042B6850C66B31F09FE44734EB7990E \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
      56730D5401028683275BD23C23EFEFE93C4CFFFE \
      77984A986EBC2AA786BC0F66B01FBB92821C587A && break; \
  done && \
  curl -sfSLO https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.xz && \
  curl -sfSL https://nodejs.org/dist/${VERSION}/SHASUMS256.txt.asc | gpg --batch --decrypt | \
    grep " node-${VERSION}.tar.xz\$" | sha256sum -c | grep ': OK$' && \
  tar -xf node-${VERSION}.tar.xz && \
  cd node-${VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(getconf _NPROCESSORS_ONLN) && \
  make install && \
  cd / && \
  if [ -z "$CONFIG_FLAGS" ]; then \
    if [ -n "$NPM_VERSION" ]; then \
      npm install -g npm@${NPM_VERSION}; \
    fi; \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
    if [ -n "$YARN_VERSION" ]; then \
      for server in pgp.mit.edu keyserver.pgp.com ha.pool.sks-keyservers.net; do \
        gpg --keyserver $server --recv-keys \
          6A010C5166006599AA17F08146C2130DFD2497F5 && break; \
      done && \
      curl -sfSL -O https://yarnpkg.com/${YARN_VERSION}.tar.gz -O https://yarnpkg.com/${YARN_VERSION}.tar.gz.asc && \
      gpg --batch --verify ${YARN_VERSION}.tar.gz.asc ${YARN_VERSION}.tar.gz && \
      mkdir /usr/local/share/yarn && \
      tar -xf ${YARN_VERSION}.tar.gz -C /usr/local/share/yarn --strip 1 && \
      ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
      ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
      rm ${YARN_VERSION}.tar.gz*; \
    fi; \
  fi && \
  apk del curl make gcc g++ python linux-headers binutils-gold gnupg ${DEL_PKGS} && \
  rm -rf ${RM_DIRS} /node-${VERSION}* /usr/share/man /tmp/* /var/cache/apk/* \
    /root/.npm /root/.node-gyp /root/.gnupg /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts


ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

RUN apk add --update \
    ca-certificates \
    curl \
    bash \
    git \
    unzip \
    wget \
    openssh-client \
    openssh \
    sudo

RUN apk --update add ca-certificates \
    && echo "@edge-main http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "@edge-community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "@cast https://php.codecasts.rocks/v3.7/php-7.2" >> /etc/apk/repositories \
    && apk add -U \

    php7@cast \
    php7-dev@cast \
    php7-common@cast \
    php7-apcu@cast \
    php7-bcmath@cast \
    php7-ctype@cast \
    php7-curl@cast \
    php7-exif@cast \
    php7-iconv@cast \
    php7-intl@cast \
    php7-json@cast \
    php7-mbstring@cast \
    php7-opcache@cast \
    php7-openssl@cast \
    php7-pcntl@cast \
    php7-pdo@cast \
    php7-mysqlnd@cast \
    php7-pdo_mysql@cast \
    php7-pdo_pgsql@cast \
    php7-phar@cast \
    php7-posix@cast \
    php7-session@cast \
    php7-xml@cast \
    php7-xsl@cast \
    php7-zip@cast \
    php7-zlib@cast \
    php7-dom@cast \
    php7-redis@cast \
    php7-fpm@cast \
    php7-sodium@cast \
    php7-xdebug@cast \

    && ln -s /usr/bin/php7 /usr/bin/php \
    && rm -rf /var/cache/apk/*

COPY php.ini /etc/php/

RUN echo "---> Installing Composer" && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    echo "---> Cleaning up" && \
    rm -rf /tmp/*

RUN /usr/local/bin/composer global require jakub-onderka/php-parallel-lint && \
    /usr/local/bin/composer global require jakub-onderka/php-var-dump-check && \
    /usr/local/bin/composer global require hirak/prestissimo && \
    /usr/local/bin/composer global require phpunit/phpunit && \
    /usr/local/bin/composer global require phpmd/phpmd && \
    /usr/local/bin/composer global require squizlabs/php_codesniffer && \
    /usr/local/bin/composer global require symfony/phpunit-bridge

RUN /usr/local/bin/composer config --global cache-dir /opt/data/cache/composer/cache-dir
RUN /usr/local/bin/composer config --global cache-vcs-dir /opt/data/cache/composer/cache-vcs-dir
RUN /usr/local/bin/composer config --global cache-repo-dir /opt/data/cache/composer/cache-repo-dir

RUN wget https://github.com/phpDocumentor/phpDocumentor2/releases/download/v2.9.0/phpDocumentor.phar

RUN echo -e "#!/bin/bash\n\nphp /phpDocumentor.phar \$@" >> /usr/local/bin/phpdoc && \
    chmod +x /usr/local/bin/phpdoc

RUN ln -sn /root/.composer/vendor/bin/parallel-lint /usr/local/bin/parallel-lint && \
    ln -sn /root/.composer/vendor/bin/var-dump-check /usr/local/bin/var-dump-check && \
    ln -sn /root/.composer/vendor/bin/phpunit /usr/local/bin/phpunit && \
    ln -sn /root/.composer/vendor/bin/phpmd /usr/local/bin/phpmd && \
    ln -sn /root/.composer/vendor/bin/phpcs /usr/local/bin/phpcs && \
    ln -sn /root/.composer/vendor/bin/phpcs /usr/local/bin/phpunit-bridge

RUN npm install --global gulp-cli \
    && npm install --global webpack@2 \
    && npm install --global jsdoc \
	&& npm set registry http://npm.i.etech.sk \
	&& npm set progress=false \
	&& npm config set cache /opt/data/cache/npm/cache --global \
	&& npm config set tmp /opt/data/cache/npm/tmp --global

RUN echo '@edge http://nl.alpinelinux.org/alpine/edge/main'>> /etc/apk/repositories \
	&& apk --update add curl

RUN curl -Lk -o $PHANTOMJS_ARCHIVE https://github.com/fgrehm/docker-phantomjs2/releases/download/v2.0.0-20150722/dockerized-phantomjs.tar.gz \
	&& tar -xf $PHANTOMJS_ARCHIVE -C /tmp/ \
	&& cp -R /tmp/etc/fonts /etc/ \
	&& cp -R /tmp/lib/* /lib/ \
	&& cp -R /tmp/lib64 / \
	&& cp -R /tmp/usr/lib/* /usr/lib/ \
	&& cp -R /tmp/usr/lib/x86_64-linux-gnu /usr/ \
	&& cp -R /tmp/usr/share/* /usr/share/ \
	&& cp /tmp/usr/local/bin/phantomjs /usr/bin/ \
	&& rm -fr $PHANTOMJS_ARCHIVE  /tmp/*
