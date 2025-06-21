#!/bin/bash

# 環境変数のデバッグ出力
echo "=== MariaDB Setup Debug ==="
echo "MYSQL_DATABASE: '${MYSQL_DATABASE}'"
echo "MYSQL_USER: '${MYSQL_USER}'"
echo "MYSQL_PASSWORD: [$(if [ -n "${MYSQL_PASSWORD}" ]; then echo "SET"; else echo "EMPTY"; fi)]"
echo "MYSQL_ROOT_PASSWORD: [$(if [ -n "${MYSQL_ROOT_PASSWORD}" ]; then echo "SET"; else echo "EMPTY"; fi)]"
echo "=========================="

# 必須環境変数のチェック
if [ -z "${MYSQL_DATABASE}" ] || [ -z "${MYSQL_USER}" ] || [ -z "${MYSQL_PASSWORD}" ] || [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
    echo "ERROR: 必須の環境変数が設定されていません"
    echo "以下の環境変数を.envファイルで設定してください:"
    echo "- MYSQL_DATABASE"
    echo "- MYSQL_USER"
    echo "- MYSQL_PASSWORD"
    echo "- MYSQL_ROOT_PASSWORD"
    exit 1
fi

# MariaDBデータディレクトリの初期化
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql > /dev/null
fi

# MariaDBをバックグラウンドで起動（初期状態：パスワードなし）
echo "Starting MariaDB..."
mysqld_safe --datadir=/var/lib/mysql --skip-grant-tables &

# MariaDBが起動するまで待機
echo "Waiting for MariaDB to start..."
sleep 5
while ! mysql -u root -e "SELECT 1;" >/dev/null 2>&1; do
    echo "Waiting for MariaDB connection..."
    sleep 2
done

echo "MariaDB started successfully. Configuring database..."

# データベースとユーザーの作成
mysql -u root << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "Database configuration completed."

# バックグラウンドプロセスを停止
echo "Stopping background MariaDB process..."
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# フォアグラウンドでMariaDBを起動
echo "Starting MariaDB in foreground mode..."
exec mysqld --user=mysql --bind-address=0.0.0.0