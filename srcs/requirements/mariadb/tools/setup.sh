#!/bin/bash

# MariaDBの初期化とセットアップ
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# MariaDB起動
mysqld_safe --datadir=/var/lib/mysql &

# 起動待機
sleep 5

# セキュリティ設定とデータベース作成
mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "FLUSH PRIVILEGES;"

# フォアグラウンドで実行
exec mysqld --user=mysql --bind-address=0.0.0.0