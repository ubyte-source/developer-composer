FROM amd64/alpine:3.14

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_VERSION 2.2.4
ENV COMPOSER_SHA512 90d6f1b313ac40f98e9dcacc0f5d98ebcd43453d2d93647893e51c7a1c4dde8b17aafc17f5030309d3ce67d99943ea389003c6f8cc6d2f3e731dfe0274dc16d1

RUN apk update && \
    apk add --no-cache openssh-client bash subversion p7zip coreutils make patch tini unzip zip git && \
    apk add --no-cache php7-cli php7-phar php7-mcrypt php7-openssl php7-json php7-zip php7-curl php7-ctype php7-common php7-mbstring php7-fileinfo && \
    rm -rf /var/cache/apk/*

ARG TIMEZONE="UTC"

RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    sed -i "s|;*date.timezone\s*=\s*.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini

RUN wget -O /tmp/installer.php https://getcomposer.org/installer && \
    echo ${COMPOSER_SHA512} /tmp/installer.php | sha512sum --strict --check

RUN php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} && \
    rm -f /tmp/installer.php && \
    /usr/bin/composer --ansi --version --no-interaction ; \
    /usr/bin/composer diagnose ; \
    find /tmp -type d -exec chmod -v 1777 {} +

WORKDIR /app

ENTRYPOINT ["/usr/bin/composer"]