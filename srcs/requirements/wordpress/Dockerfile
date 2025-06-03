FROM debian:bookworm

# PHP-FPMとWordPressのセットアップ
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-xml \
    php8.2-mbstring \
    php8.2-zip \
    wget \
    curl \
    ca-certificates \
    netcat-openbsd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# WordPress CLI のインストール（複数の方法を試行）
RUN (curl -f -L https://github.com/wp-cli/wp-cli/releases/download/v2.10.0/wp-cli-2.10.0.phar -o wp-cli.phar \
    || curl -f -L https://raw.githubusercontent.com/wp-cli/wp-cli/v2.10.0/wp-cli.phar -o wp-cli.phar \
    || wget -O wp-cli.phar https://github.com/wp-cli/wp-cli/releases/download/v2.10.0/wp-cli-2.10.0.phar) \
    && echo "WP-CLI downloaded successfully" \
    && php wp-cli.phar --info \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info

# PHP-FPM設定
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# 必要なディレクトリの作成と権限設定
RUN mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /var/www/html /run/php && \
    chmod -R 755 /var/www/html /run/php

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh && \
    chown www-data:www-data /setup.sh

WORKDIR /var/www/html

# www-dataユーザーとして実行
USER www-data

EXPOSE 9000

CMD ["/setup.sh"]
