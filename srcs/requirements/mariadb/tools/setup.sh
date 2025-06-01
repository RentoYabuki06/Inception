#!/bin/bash

# MariaDBデータディレクトリの初期化
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

# MariaDBをバックグラウンドで起動
mysqld_safe --datadir=/var/lib/mysql &

# MariaDBが起動するまで待機
while ! mysqladmin ping --silent; do
    sleep 1
done

# データベースとユーザーの作成
mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

# セキュリティ設定
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "FLUSH PRIVILEGES;"

# バックグラウンドプロセスを停止
mysqladmin shutdown

# フォアグラウンドでMariaDBを起動
exec mysqld --user=mysql --bind-address=0.0.0.0