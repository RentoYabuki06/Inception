FROM debian:bullseye

# PHP-FPMとWordPressのセットアップ
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-xml \
    php7.4-mbstring \
    php7.4-zip \
    php7.4-json \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# WordPress CLI のインストール
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# PHP-FPM設定
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/' /etc/php/7.4/fpm/pool.d/www.conf

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

WORKDIR /var/www/html

EXPOSE 9000

CMD ["/setup.sh"]
