FROM amd64/alpine:3.17

ENV COMPOSER_ALLOW_SUPERUSER="1" \
    COMPOSER_VERSION="2.4.4" \
    COMPOSER_SHA384="55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae"

RUN apk update && \
    apk add --no-cache openssh-client bash subversion p7zip coreutils make patch tini unzip zip git && \
    apk add --no-cache php81-cli php81-phar php81-openssl php81-json php81-zip php81-curl php81-ctype php81-common php81-mbstring php81-fileinfo && \
    rm -rf /var/cache/apk/*

ARG TIMEZONE="UTC"

RUN apk add --no-cache tzdata && \
    cp -r /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    ln -s /usr/bin/php81 /usr/bin/php && \
    sed -i "s|;*date.timezone\s*=\s*.*|date.timezone = ${TIMEZONE}|i" /etc/php81/php.ini && \
    wget -O /tmp/installer.php https://getcomposer.org/installer && \
    echo ${COMPOSER_SHA384} /tmp/installer.php | sha384sum --strict --check && \
    php81 /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} && \
    rm -f /tmp/installer.php && \
    /usr/bin/composer --ansi --version --no-interaction ; \
    /usr/bin/composer diagnose ; \
    find /tmp -type d -exec chmod -v 1777 {} +

WORKDIR /app

ENTRYPOINT ["/usr/bin/composer"]
