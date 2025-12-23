ARG BASE_IMAGE="php:8.5.1-alpine"

FROM ${BASE_IMAGE} as builder

# Install build dependencies
RUN apk add --no-cache $PHPIZE_DEPS \
    autoconf git imagemagick-dev icu-dev zlib-dev jpeg-dev libpng-dev libzip-dev postgresql-dev libgomp linux-headers

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-jpeg
RUN docker-php-ext-install bcmath pdo mysqli pdo_mysql pdo_pgsql pgsql intl pcntl gd exif zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP Installer for Extensions
RUN curl -L https://github.com/php/pie/releases/latest/download/pie.phar -o /usr/local/bin/pie && \
    chmod +x /usr/local/bin/pie

# Install imagick extension from specific tag using PIE
RUN pie install imagick/imagick;

# Install xdebug extension from master branch using PIE
RUN pie install xdebug/xdebug; \
    echo "xdebug.mode=coverage" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini;

# Clean up build dependencies
RUN apk del $PHPIZE_DEPS imagemagick-dev icu-dev zlib-dev jpeg-dev libpng-dev libzip-dev postgresql-dev libgomp 

# Final image
FROM ${BASE_IMAGE}

# Copy only the necessary files from the builder stage
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d
COPY --from=builder /usr/local/bin/pie /usr/local/bin/pie
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer

# Install additional tools and required libraries
RUN apk add --no-cache libpng libpq zip jpeg libzip imagemagick \
    git curl sqlite nodejs npm nano ncdu openssh-client