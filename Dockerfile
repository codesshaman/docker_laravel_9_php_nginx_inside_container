FROM alpine:latest

ARG uid

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

WORKDIR /tmp

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/

COPY config/nginx.conf /etc/nginx/conf.d/nginx.conf

COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chown -R nobody.nobody /run /var/lib/nginx /var/log/nginx /var/www

USER nobody

COPY --chown=nobody laravel.zip /var/www/

RUN unzip /var/www/laravel.zip
#php artisan optimize:clear

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
# HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
