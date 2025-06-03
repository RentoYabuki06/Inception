#!/bin/bash

# 環境変数のデバッグ出力
echo "=== WordPress Setup Debug ==="
echo "WORDPRESS_DB_HOST: '${WORDPRESS_DB_HOST}'"
echo "WORDPRESS_DB_NAME: '${WORDPRESS_DB_NAME}'"
echo "WORDPRESS_DB_USER: '${WORDPRESS_DB_USER}'"
echo "WORDPRESS_DB_PASSWORD: [$(if [ -n "${WORDPRESS_DB_PASSWORD}" ]; then echo "SET"; else echo "EMPTY"; fi)]"
echo "WP_ADMIN_USER: '${WP_ADMIN_USER}'"
echo "WP_ADMIN_PASSWORD: [$(if [ -n "${WP_ADMIN_PASSWORD}" ]; then echo "SET"; else echo "EMPTY"; fi)]"
echo "WP_ADMIN_EMAIL: '${WP_ADMIN_EMAIL}'"
echo "WP_USER: '${WP_USER}'"
echo "WP_USER_PASSWORD: [$(if [ -n "${WP_USER_PASSWORD}" ]; then echo "SET"; else echo "EMPTY"; fi)]"
echo "WP_USER_EMAIL: '${WP_USER_EMAIL}'"
echo "DOMAIN_NAME: '${DOMAIN_NAME}'"
echo "=========================="

# 必須環境変数のチェック
if [ -z "${WORDPRESS_DB_HOST}" ] || [ -z "${WORDPRESS_DB_NAME}" ] || [ -z "${WORDPRESS_DB_USER}" ] || [ -z "${WORDPRESS_DB_PASSWORD}" ]; then
    echo "ERROR: データベース関連の環境変数が設定されていません"
    exit 1
fi

if [ -z "${WP_ADMIN_USER}" ] || [ -z "${WP_ADMIN_PASSWORD}" ] || [ -z "${WP_ADMIN_EMAIL}" ]; then
    echo "ERROR: WordPress管理者関連の環境変数が設定されていません"
    exit 1
fi

if [ -z "${WP_USER}" ] || [ -z "${WP_USER_PASSWORD}" ] || [ -z "${WP_USER_EMAIL}" ] || [ -z "${DOMAIN_NAME}" ]; then
    echo "ERROR: WordPress一般ユーザーまたはドメイン関連の環境変数が設定されていません"
    exit 1
fi

# MariaDBの起動を待機
echo "Waiting for MariaDB to be ready..."
DB_HOST=$(echo $WORDPRESS_DB_HOST | cut -d: -f1)
DB_PORT=$(echo $WORDPRESS_DB_HOST | cut -d: -f2)
DB_PORT=${DB_PORT:-3306}

while ! nc -z $DB_HOST $DB_PORT; do
    echo "Waiting for MariaDB at $DB_HOST:$DB_PORT..."
    sleep 3
done

echo "MariaDB is ready! Proceeding with WordPress setup..."

# WordPressのダウンロードと設定
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress core..."
    wp core download --allow-root
    
    echo "Creating WordPress configuration..."
    wp config create \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$WORDPRESS_DB_PASSWORD \
        --dbhost=$WORDPRESS_DB_HOST \
        --allow-root
    
    echo "Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception WordPress" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
        
    echo "Creating additional WordPress user..."
    wp user create $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root
        
    echo "WordPress setup completed successfully!"
else
    echo "WordPress is already configured. Skipping setup."
fi

echo "Starting PHP-FPM..."
# PHP-FPM起動（バージョン番号を8.2に変更）
php-fpm8.2 -F