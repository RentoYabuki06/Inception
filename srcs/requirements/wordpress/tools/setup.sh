#!/bin/bash

# WordPressのダウンロードと設定
if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root
    wp config create \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$WORDPRESS_DB_PASSWORD \
        --dbhost=$WORDPRESS_DB_HOST \
        --allow-root
    
    wp core install \
        --url="https://yabukirento.42.fr" \
        --title="Inception WordPress" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
        
    wp user create $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root
fi

# PHP-FPM起動（バージョン番号を8.2に変更）
php-fpm8.2 -F