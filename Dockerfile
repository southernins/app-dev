#FROM node:14 AS node
FROM composer:2 AS composer
FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user=southerndev
ARG uid=1000

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

#COPY ./custom.ini /usr/local/etc/php/conf.d/custom.ini

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Install Node/Npm
RUN apt-get install -y --no-install-recommends gnupg && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

## Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user
#USER 1000