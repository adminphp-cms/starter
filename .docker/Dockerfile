# syntax=docker/dockerfile:1

# The image of the starter: its Composer dependencies (AdminPHP from Packagist),
# its Vite assets and FrankenPHP. compose.yaml runs it with MariaDB and Redis:
#
#   docker compose up

ARG PHP_VERSION=8.4
ARG NODE_VERSION=22

# --- Composer dependencies --------------------------------------------------
FROM composer:2 AS vendor

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install --no-dev --no-interaction --no-progress --prefer-dist \
        --no-scripts --no-autoloader --ignore-platform-reqs

COPY . .

RUN composer dump-autoload --no-dev --optimize --classmap-authoritative --no-scripts

# --- Vite assets ------------------------------------------------------------
FROM node:${NODE_VERSION}-alpine AS assets

WORKDIR /app

COPY package.json package-lock.json .npmrc ./
RUN npm ci --ignore-scripts

COPY vite.config.js ./
COPY resources ./resources
COPY public ./public
# app.css pulls in Blade views from vendor/ (e.g. Laravel's pagination).
COPY --from=vendor /app/vendor ./vendor
COPY app ./app

RUN npm run build

# --- Runtime ----------------------------------------------------------------
FROM dunglas/frankenphp:1-php${PHP_VERSION}-alpine

LABEL org.opencontainers.image.title="AdminPHP Starter" \
      org.opencontainers.image.description="A Laravel site ready to edit with AdminPHP." \
      org.opencontainers.image.source="https://github.com/adminphp-cms/starter" \
      org.opencontainers.image.licenses="MIT"

ENV SERVER_NAME=:80 \
    PHP_MEMORY_LIMIT=256M \
    PHP_UPLOAD_MAX_FILESIZE=32M \
    PHP_POST_MAX_SIZE=32M

# curl is the binary used by the healthcheck below, not the PHP extension.
RUN apk add --no-cache curl

# gd and exif drive the media library (image sizes and WebP copies), redis the
# cache, sessions and queue of compose.yaml.
RUN install-php-extensions \
        exif \
        gd \
        intl \
        opcache \
        pcntl \
        pdo_mysql \
        redis

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" "$PHP_INI_DIR/php.ini" \
    && sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}|i" "$PHP_INI_DIR/php.ini" \
    && sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_POST_MAX_SIZE}|i" "$PHP_INI_DIR/php.ini"

COPY .docker/opcache.ini $PHP_INI_DIR/conf.d/opcache.ini
COPY .docker/Caddyfile /etc/caddy/Caddyfile
COPY .docker/cmd.sh /usr/local/bin/cmd.sh
RUN chmod +x /usr/local/bin/cmd.sh

WORKDIR /app

COPY --chown=www-data:www-data . /app
COPY --chown=www-data:www-data --from=vendor /app/vendor /app/vendor
COPY --chown=www-data:www-data --from=assets /app/public/build /app/public/build

# Composer ran without its scripts: discover the packages and publish the admin
# assets of AdminPHP here.
RUN rm -Rf /app/.docker \
    && php artisan package:discover --ansi \
    && php artisan vendor:publish --tag=adminphp-assets --force --ansi \
    && chown -R www-data:www-data /app/storage /app/bootstrap/cache /app/public/vendor

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl -sf http://localhost/up || exit 1

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/cmd.sh"]
