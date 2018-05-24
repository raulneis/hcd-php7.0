FROM php:7.0-apache
MAINTAINER @raulneis <raulneis@gmail.com>

ENV PATH="./vendor/bin:${PATH}"
ENV DEBIAN_FRONTEND noninteractive

RUN curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh \
    && bash nodesource_setup.sh


RUN apt-get update \
    && apt-get -y --no-install-recommends install \
               build-essential \
               procps \
               postgresql \
               git \
               supervisor \
               libpq-dev \
               libpng-dev \
               libxml2-dev \
               nano \
               nodejs \
               redis-server \
               libxrender1 \
               libfontconfig1 \
               libxext6 \
    && apt-get -y autoremove
    # && apt-get clean \
    # && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# RUN npm i npm@latest -g
RUN npm install -g nodemon

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN  docker-php-ext-install gd \
                            pgsql \
                            pdo_pgsql \
                            xml \
                            zip \
    && pecl install apcu xdebug-2.7.0alpha1 \
    && docker-php-ext-enable apcu xdebug

COPY config/php/php.ini /usr/local/etc/php/php.ini

COPY config/supervisor/ /etc/supervisor/

RUN mkdir -p /usr/local/etc/apache2
ADD config/apache2/ /usr/local/etc/apache2/
RUN echo "IncludeOptional /usr/local/etc/apache2/*.conf" >> /etc/apache2/apache2.conf

WORKDIR /var/www/html
RUN a2enmod rewrite headers
RUN usermod -u 1000 www-data

RUN chown www-data:www-data /var/www -R

RUN mkdir -p /var/backups/hcd \
    && chown www-data:www-data /var/backups/hcd

EXPOSE 80

ENV APACHE_RUN_USER    www-data
ENV APACHE_RUN_GROUP   www-data
ENV APACHE_PID_FILE    /var/run/apache2.pid
ENV APACHE_RUN_DIR     /var/run/apache2
ENV APACHE_LOCK_DIR    /var/lock/apache2
ENV APACHE_LOG_DIR     /var/log/apache2

COPY config/start.sh /usr/local/bin/start
RUN chmod +x /usr/local/bin/start
CMD ["/usr/local/bin/start"]
