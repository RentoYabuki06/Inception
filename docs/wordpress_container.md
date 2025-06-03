# WordPress コンテナ

## 概要
WordPressコンテナは、PHP-FPMとWordPressを組み合わせて、動的なWebアプリケーションを提供します。NGINXからのリクエストを処理し、MariaDBと連携してコンテンツを管理します。

## 主な機能
- WordPress Core の実行
- PHP-FPM によるPHP処理
- MariaDBとの連携
- ファイルシステムの管理

## Dockerfile解説
```dockerfile
FROM debian:bookworm

# PHP-FPMとWordPressの依存関係インストール
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
    && apt-get clean

# WordPress CLI のインストール
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# PHP-FPM設定
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

WORKDIR /var/www/html

USER www-data

EXPOSE 9000

CMD ["/setup.sh"]
```

## 環境変数
```env
WORDPRESS_DB_HOST=mariadb:3306
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=wppass
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=adminpass
WP_ADMIN_EMAIL=admin@example.com
```

## セットアップスクリプト（setup.sh）の主要機能
1. 環境変数の検証
2. MariaDB接続の待機
3. WordPressのダウンロードと設定
4. データベース接続の設定
5. 初期ユーザーの作成

## PHP-FPM設定（www.conf）のポイント
```ini
[www]
user = www-data
group = www-data
listen = 9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

## ボリュームとパーミッション
- WordPress ファイル: `/var/www/html`
- 所有者: `www-data`
- 権限: ディレクトリ 755, ファイル 644

## データベース連携
- MariaDBコンテナとの通信
- wp-config.php の自動生成
- データベース接続テスト

## トラブルシューティング
1. データベース接続エラー
   - 環境変数の確認
   - MariaDBの起動確認
   - ネットワーク接続確認

2. PHP-FPMの問題
   - プロセス数の調整
   - メモリ制限の確認
   - ログの確認

3. WordPressの問題
   - パーミッション確認
   - プラグインの互換性
   - テーマの問題

## パフォーマンスチューニング
- PHP-FPMプロセス数の最適化
- OPcacheの設定
- メモリ制限の調整
- アップロード制限の設定

## セキュリティ対策
- 適切なファイルパーミッション
- PHP設定の最適化
- WordPressの自動更新
- プラグインとテーマの管理 