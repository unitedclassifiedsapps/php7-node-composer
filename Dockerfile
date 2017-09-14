FROM marphy/uc-php7-node-composer:1.0.9
MAINTAINER Marian Abaffy "marphy@abaffy.eu"

RUN composer config --global cache-dir /opt/data/cache/composer/cache-dir \
	&& composer config --global cache-repo-dir  /opt/data/cache/composer/cache-repo-dir \
	&& composer config --global cache-vcs-dir /opt/data/cache/composer/cache-vcs-dir \
	&& composer config --global cache-repo-dir /opt/data/cache/composer/cache-repo-dir \
	&& npm set registry http://npm.i.etech.sk \
	&& npm set progress=false \
	&& npm config set cache /opt/data/cache/npm/cache --global \
	&& npm config set tmp /opt/data/cache/npm/tmp --global


