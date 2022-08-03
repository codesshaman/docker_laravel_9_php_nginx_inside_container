FROM alpine:3.16

WORKDIR /var/www/public

ARG UID

RUN apk add --no-cache \
  postgresql-dev \
  nano \
  curl \
  nginx \
  php81 \
  php81-ctype \
  php81-curl \
  php81-dom \
  php81-fpm \
  php81-gd \
  php81-intl \
  php81-mbstring \
  php81-mysqli \
  php81-opcache \
  php81-openssl \
  php81-phar \
  php81-session \
  php81-xml \
  php81-xmlreader \
  php81-tokenizer \
  php81-xmlwriter \
  php81-simplexml \
  php81-fileinfo \
  php81-zlib \
  php81-pdo \
  php81-pgsql \
  php81-pdo_pgsql \
  supervisor

RUN ln -s /usr/bin/php81 /usr/bin/php

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY config/nginx.conf /etc/nginx/nginx.conf

COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN addgroup --gid $UID user && \
    adduser -D -u $UID -G www-data -G root -G user user && \
    mkdir -p /home/user/.composer && \
    chown -R user:user /home/user

RUN chown -R user.user /var/www/public /run /var/lib/nginx /var/log/nginx

USER user

COPY --chown=user index.php /var/www/public/

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
