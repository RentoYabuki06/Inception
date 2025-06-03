# 🚀 Inception プロジェクト学習資料

## 📋 目次

- [🎯 プロジェクト概要](#-プロジェクト概要)
- [🏗️ アーキテクチャ解説](#️-アーキテクチャ解説)
- [🐳 Docker基礎知識](#-docker基礎知識)
- [📦 各サービス詳細解説](#-各サービス詳細解説)
- [🔧 設定ファイル解説](#-設定ファイル解説)
- [🚀 構築手順](#-構築手順)
- [🐛 トラブルシューティング](#-トラブルシューティング)
- [📚 参考資料](#-参考資料)

## 🎯 プロジェクト概要

### 📖 Inceptionとは
42 TokyoのInceptionプロジェクトは、**Dockerを使用して完全なWebインフラストラクチャを構築する**システム管理プロジェクトです。

### 🎓 学習目標
- ✅ Dockerコンテナ技術の習得
- ✅ docker-composeによるサービス管理
- ✅ NGINX リバースプロキシの設定
- ✅ WordPressとPHP-FPMの連携
- ✅ MariaDBデータベース管理
- ✅ SSL/TLS暗号化の実装
- ✅ 永続化ボリュームの管理

### 🚫 制約条件
- ❌ 既製のDockerイメージ使用禁止
- ❌ Docker Hubからのpull禁止
- ❌ --linkオプション使用禁止
- ❌ hostネットワーク使用禁止
- ❌ 無限ループスクリプト禁止

## 🏗️ アーキテクチャ解説

### 🌐 全体構成図
```
📱 クライアント (ブラウザ)
         │ HTTPS (443)
         ▼
🔒 NGINX コンテナ
   ├── SSL証明書による暗号化
   ├── リバースプロキシ
   └── 静的ファイル配信
         │ FastCGI (9000)
         ▼
🐘 WordPress コンテナ
   ├── PHP-FPM処理
   ├── WordPress CMS
   └── 動的コンテンツ生成
         │ MySQL (3306)
         ▼
🗄️ MariaDB コンテナ
   ├── データベースサーバー
   ├── ユーザー・記事データ
   └── 永続化ストレージ
```

### 🔗 データフロー
1. **ユーザーアクセス** → HTTPS リクエスト (443番ポート)
2. **NGINX** → SSL終端、FastCGI転送
3. **WordPress** → PHP処理、データベースアクセス
4. **MariaDB** → データ取得・保存
5. **レスポンス** → HTML生成、暗号化送信

### 📁 ディレクトリ構造
```
srcs/
├── 📄 docker-compose.yml       # オーケストレーション設定
├── 📄 Makefile                 # ビルド自動化
└── 📁 requirements/            # 各サービス定義
    ├── 🔒 nginx/
    │   ├── 📄 Dockerfile
    │   ├── 📁 conf/
    │   │   └── nginx.conf
    │   └── 📁 tools/
    │       └── setup.sh
    ├── 🐘 wordpress/
    │   ├── 📄 Dockerfile
    │   └── 📁 tools/
    │       └── setup.sh
    └── 🗄️ mariadb/
        ├── 📄 Dockerfile
        └── 📁 tools/
            └── setup.sh
```

## 🐳 Docker基礎知識

### 📚 重要概念

#### 🏠 コンテナとイメージ
- **イメージ**: 実行可能なパッケージ（設計図）
- **コンテナ**: イメージから作成された実行インスタンス

#### 🌐 ネットワーク
```yaml
networks:
  inception-net:
    driver: bridge  # デフォルトドライバー
```
- コンテナ間通信を可能にする
- サービス名でのホスト名解決
- 外部からの直接アクセスを制御

#### 💾 ボリューム
```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/rento/data/mariadb
```
- データの永続化
- コンテナ削除後もデータ保持
- ホストとコンテナ間のファイル共有

### 🔧 Docker Compose基本コマンド
```bash
# サービス起動
docker-compose up -d

# ログ確認
docker-compose logs -f [service_name]

# サービス停止
docker-compose down

# イメージ再ビルド
docker-compose build

# 特定サービスの再起動
docker-compose restart [service_name]

# コンテナ内アクセス
docker-compose exec [service_name] bash
```

## 📦 各サービス詳細解説

### 🗄️ MariaDB コンテナ

#### 🎯 役割
- WordPressのデータベースサーバー
- ユーザー情報、記事、設定の保存
- MySQL互換のリレーショナルデータベース

#### 📄 Dockerfile解説
```dockerfile
FROM debian:bookworm                    # 最新安定版ベース
RUN apt-get update && apt-get install -y \
    mariadb-server \                    # データベースサーバー
    mariadb-client \                    # 管理用クライアント
    && apt-get clean                    # イメージサイズ削減
COPY tools/setup.sh /setup.sh          # 初期化スクリプト
EXPOSE 3306                             # MySQLデフォルトポート
CMD ["/setup.sh"]                       # 起動時実行
```

#### 🚀 setup.shスクリプト詳細
```bash
#!/bin/bash

# 1. データディレクトリ初期化チェック
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

# 2. MariaDBをバックグラウンドで起動
mysqld_safe --datadir=/var/lib/mysql &

# 3. 起動完了まで待機
while ! mysqladmin ping --silent; do
    sleep 1
done

# 4. データベースとユーザー作成
mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

# 5. セキュリティ強化
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "FLUSH PRIVILEGES;"

# 6. フォアグラウンドで本起動
exec mysqld --user=mysql --bind-address=0.0.0.0
```

#### 🔒 セキュリティ設定
- 匿名ユーザーの削除
- testデータベースの削除
- rootユーザーのローカル制限
- 専用ユーザーでの実行

### 🐘 WordPress コンテナ

#### 🎯 役割
- コンテンツ管理システム (CMS)
- PHP-FPMによる高速処理
- MariaDBとの連携

#### 📄 Dockerfile解説
```dockerfile
FROM debian:bookworm

# PHP 8.2とWordPress必須拡張のインストール
RUN apt-get update && apt-get install -y \
    php8.2-fpm \           # PHP FastCGI Process Manager
    php8.2-mysql \         # MariaDB接続用
    php8.2-curl \          # HTTP通信用
    php8.2-gd \            # 画像処理用
    php8.2-xml \           # XML処理用
    php8.2-mbstring \      # マルチバイト文字列
    php8.2-zip \           # ファイル圧縮用
    wget curl ca-certificates

# WordPress CLI インストール
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# PHP-FPM設定変更 (Unixソケット → TCPポート)
RUN sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 9000/' /etc/php/8.2/fpm/pool.d/www.conf
```

#### 🚀 setup.shスクリプト詳細
```bash
#!/bin/bash

# WordPress初回セットアップ
if [ ! -f /var/www/html/wp-config.php ]; then
    # WordPressコアダウンロード
    wp core download --allow-root
    
    # データベース設定ファイル作成
    wp config create \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$WORDPRESS_DB_PASSWORD \
        --dbhost=$WORDPRESS_DB_HOST \
        --allow-root
    
    # WordPress初期インストール
    wp core install \
        --url="https://yabukirento.42.fr" \
        --title="Inception WordPress" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
        
    # 一般ユーザー作成
    wp user create $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root
fi

# PHP-FPMをフォアグラウンドで起動
php-fpm8.2 -F
```

#### 🔧 WordPress CLI活用
- `wp core download`: WordPressコアダウンロード
- `wp config create`: データベース設定
- `wp core install`: 初期インストール
- `wp user create`: ユーザー管理
- `wp plugin install`: プラグイン管理

### 🔒 NGINX コンテナ

#### 🎯 役割
- Webサーバー・リバースプロキシ
- SSL/TLS終端処理
- 静的ファイル配信

#### 📄 Dockerfile解説
```dockerfile
FROM debian:bookworm
RUN apt-get update && apt-get install -y \
    nginx \                # Webサーバー
    openssl \              # SSL証明書生成
    ca-certificates        # 証明書検証用

COPY conf/nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /etc/ssl/private && \
    mkdir -p /etc/nginx/ssl    # SSL証明書用ディレクトリ
EXPOSE 443                     # HTTPS専用ポート
```

#### 📝 nginx.conf設定詳細
```nginx
events {
    worker_connections 1024;  # 同時接続数
}

http {
    # MIME タイプ設定
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    server {
        listen 443 ssl;                              # HTTPS専用
        server_name yabukirento.42.fr;               # ドメイン名
        
        # SSL設定
        ssl_protocols TLSv1.2 TLSv1.3;             # セキュアなTLS
        ssl_certificate /etc/nginx/ssl/server.crt;   # 証明書
        ssl_certificate_key /etc/nginx/ssl/server.key; # 秘密鍵
        
        # セキュリティヘッダー
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        
        root /var/www/html;                          # ドキュメントルート
        index index.php index.html;                 # デフォルトファイル
        
        # 静的ファイル処理
        location / {
            try_files $uri $uri/ /index.php?$args;
        }
        
        # PHP処理をWordPressコンテナに転送
        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_pass wordpress:9000;              # コンテナ間通信
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
        }
        
        # 静的ファイルのキャッシュ設定
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

#### 🚀 setup.shスクリプト詳細
```bash
#!/bin/bash

# SSL証明書生成
if [ ! -f /etc/nginx/ssl/server.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/CN=yabukirento.42.fr"
fi

# 設定ファイルのテスト
nginx -t

# NGINXをフォアグラウンドで起動
nginx -g "daemon off;"
```

## 🔧 設定ファイル解説

### 📄 docker-compose.yml完全解説

```yaml
version: '3.8'

services:
  # NGINXサービス設定
  nginx:
    build: ./requirements/nginx          # Dockerfileの場所
    container_name: nginx                # コンテナ名
    restart: always                      # 自動再起動
    volumes:
      - wordpress_data:/var/www/html:ro  # 読み取り専用マウント
      - ./secrets:/etc/ssl/private:ro    # SSL証明書
    ports:
      - "443:443"                        # HTTPSポートマッピング
    networks:
      - inception-net                    # カスタムネットワーク
    depends_on:
      - wordpress                        # WordPress起動後

  # MariaDBサービス設定
  mariadb:
    build: ./requirements/mariadb
    container_name: mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass      # 環境変数で設定
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - mariadb_data:/var/lib/mysql      # データ永続化
    networks:
      - inception-net                    # 内部ネットワークのみ

  # WordPressサービス設定
  wordpress:
    build: ./requirements/wordpress
    container_name: wordpress
    restart: always
    depends_on:
      - mariadb                          # MariaDB起動後
    environment:
      WORDPRESS_DB_HOST: mariadb:3306    # DB接続設定
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WP_ADMIN_USER: admin               # WordPress管理者
      WP_ADMIN_PASSWORD: adminpass
      WP_ADMIN_EMAIL: admin@42.fr
      WP_USER: user                      # 一般ユーザー
      WP_USER_PASSWORD: userpass
      WP_USER_EMAIL: user@42.fr
    volumes:
      - wordpress_data:/var/www/html     # ファイル永続化
    networks:
      - inception-net

# ボリューム設定
volumes:
  mariadb_data:
    driver: local                        # ローカルドライバー
    driver_opts:
      type: none                         # バインドマウント
      o: bind
      device: /home/rento/data/mariadb   # ホストディレクトリ
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/rento/data/wordpress

# ネットワーク設定
networks:
  inception-net:                         # カスタムネットワーク
    driver: bridge                       # ブリッジドライバー
```

### 📄 Makefile自動化

```makefile
# 変数定義
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/rento/data

# デフォルトターゲット
all: up

# データディレクトリ作成
$(DATA_DIR):
    mkdir -p $(DATA_DIR)/mariadb
    mkdir -p $(DATA_DIR)/wordpress

# サービス起動
up: $(DATA_DIR)
    docker-compose -f $(COMPOSE_FILE) up -d

# サービス停止
down:
    docker-compose -f $(COMPOSE_FILE) down

# 完全クリーンアップ
clean: down
    docker-compose -f $(COMPOSE_FILE) down -v
    docker system prune -af
    sudo rm -rf $(DATA_DIR)

# ログ確認
logs:
    docker-compose -f $(COMPOSE_FILE) logs -f

# 再ビルド
rebuild: down
    docker-compose -f $(COMPOSE_FILE) build --no-cache
    docker-compose -f $(COMPOSE_FILE) up -d

.PHONY: all up down clean logs rebuild
```

## 🚀 構築手順

### 📋 事前準備

#### 1. システム要件確認
```bash
# Dockerインストール確認
docker --version
docker-compose --version

# 必要ポートの確認
sudo netstat -tulpn | grep :443
sudo netstat -tulpn | grep :80
```

#### 2. ホスト設定
```bash
# /etc/hostsにドメイン追加
echo "127.0.0.1 yabukirento.42.fr" | sudo tee -a /etc/hosts

# データディレクトリ作成
mkdir -p /home/rento/data/{mariadb,wordpress}
```

### 🛠️ ビルドと起動

#### 1. プロジェクトクローン
```bash
git clone <repository_url>
cd Inception/srcs
```

#### 2. 環境変数設定
```bash
# .envファイル作成（必要に応じて）
cat > .env << EOF
DOMAIN_NAME=yabukirento.42.fr
MYSQL_ROOT_PASSWORD=secure_root_pass
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=secure_wp_pass
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=secure_admin_pass
WP_ADMIN_EMAIL=admin@42.fr
EOF
```

#### 3. ビルドと起動
```bash
# すべてのサービスをビルド
docker-compose build

# サービス起動
docker-compose up -d

# ログ確認
docker-compose logs -f
```

#### 4. 動作確認
```bash
# コンテナ状態確認
docker-compose ps

# ブラウザでアクセス
open https://yabukirento.42.fr
```

### 🔍 各サービス個別確認

#### MariaDB確認
```bash
# コンテナ内アクセス
docker-compose exec mariadb bash

# データベース接続確認
mysql -u wpuser -p wordpress
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

#### WordPress確認
```bash
# コンテナ内アクセス
docker-compose exec wordpress bash

# WordPress CLI確認
wp --info --allow-root
wp user list --allow-root
wp plugin list --allow-root
```

#### NGINX確認
```bash
# 設定ファイルテスト
docker-compose exec nginx nginx -t

# SSL証明書確認
docker-compose exec nginx openssl x509 -in /etc/nginx/ssl/server.crt -text -noout
```

## 🐛 トラブルシューティング

### 🚨 よくある問題と解決方法

#### 1. ポート競合エラー
```bash
# 問題: Port 443 already in use
# 解決方法: 使用中のプロセス確認と停止
sudo lsof -i :443
sudo systemctl stop apache2  # Apacheが動いている場合
sudo systemctl stop nginx    # NGINXが動いている場合
```

#### 2. データベース接続エラー
```bash
# 問題: Database connection error
# 解決方法: 環境変数と起動順序確認
docker-compose logs mariadb
docker-compose logs wordpress

# MariaDBが完全に起動してからWordPressを起動
docker-compose up mariadb
# MariaDBログで "ready for connections" を確認後
docker-compose up wordpress
```

#### 3. SSL証明書エラー
```bash
# 問題: SSL certificate errors
# 解決方法: 証明書再生成
docker-compose exec nginx rm -f /etc/nginx/ssl/server.*
docker-compose restart nginx
```

#### 4. ボリュームマウントエラー
```bash
# 問題: Permission denied on volume mount
# 解決方法: ディレクトリ権限修正
sudo chown -R $USER:$USER /home/rento/data/
chmod -R 755 /home/rento/data/
```

#### 5. ビルドエラー
```bash
# 問題: Build context errors
# 解決方法: ビルドキャッシュクリア
docker-compose build --no-cache
docker system prune -a
```

### 🔧 デバッグコマンド集

#### ログ確認
```bash
# 全サービスログ
docker-compose logs -f

# 特定サービスログ
docker-compose logs -f mariadb
docker-compose logs -f wordpress
docker-compose logs -f nginx

# リアルタイムログ
docker-compose logs -f --tail=100
```

#### ネットワーク確認
```bash
# ネットワーク一覧
docker network ls

# ネットワーク詳細
docker network inspect srcs_inception-net

# コンテナ間通信テスト
docker-compose exec wordpress ping mariadb
docker-compose exec nginx ping wordpress
```

#### リソース確認
```bash
# コンテナリソース使用量
docker stats

# ディスク使用量
docker system df

# イメージ一覧
docker images
```

### 🔄 リセット手順

#### 完全リセット
```bash
# 1. すべてのサービス停止
docker-compose down

# 2. ボリューム削除
docker-compose down -v

# 3. イメージ削除
docker rmi $(docker images -q)

# 4. データディレクトリ削除
sudo rm -rf /home/rento/data/

# 5. 未使用リソース削除
docker system prune -af
```

#### 部分リセット
```bash
# 特定サービスのみ再ビルド
docker-compose build mariadb
docker-compose up -d mariadb

# 特定ボリュームのみ削除
docker volume rm srcs_mariadb_data
```

## 📚 参考資料

### 📖 公式ドキュメント
- [Docker公式ドキュメント](https://docs.docker.com/)
- [Docker Compose リファレンス](https://docs.docker.com/compose/compose-file/)
- [NGINX設定ガイド](https://nginx.org/en/docs/)
- [WordPress開発者向けドキュメント](https://developer.wordpress.org/)
- [MariaDB公式ドキュメント](https://mariadb.org/documentation/)

### 🔒 セキュリティ関連
- [NGINX SSL設定](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [Docker セキュリティベストプラクティス](https://docs.docker.com/engine/security/)
- [WordPress セキュリティガイド](https://wordpress.org/support/article/hardening-wordpress/)

### 🎯 42 School関連
- [42 Inception Subject](https://github.com/42School/42-Subjects/tree/master/inception)
- [42 カリキュラムガイド](https://42.fr/)
- [42 コミュニティフォーラム](https://stackoverflow.com/questions/tagged/42school)

### 🛠️ 追加ツール
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Portainer](https://www.portainer.io/) - Docker管理UI
- [Adminer](https://www.adminer.org/) - データベース管理ツール

### 📝 学習リソース
- [Docker入門ガイド](https://docs.docker.com/get-started/)
- [WordPress CLI ハンドブック](https://make.wordpress.org/cli/handbook/)
- [NGINX Beginner's Guide](http://nginx.org/en/docs/beginners_guide.html)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

---

<div align="center">

### 🎉 42 Tokyo Inception プロジェクト完了おめでとうございます！

[![42](https://img.shields.io/badge/42-Tokyo-000000?style=flat-square&logo=42&logoColor=white)](https://42tokyo.jp/)
[![Docker](https://img.shields.io/badge/Docker-完了-2496ED?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)

**この学習資料が皆さんの理解と成功の助けになれば幸いです** 🚀

</div>