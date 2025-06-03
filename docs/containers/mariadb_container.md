# MariaDB コンテナ

## 概要
MariaDBコンテナは、WordPressのデータを永続的に保存するデータベースサーバーとして機能します。セキュアな設定と効率的なデータ管理を提供します。

## 主な機能
- データベースサーバーの提供
- データの永続化
- ユーザー認証と権限管理
- バックアップとリカバリ

## Dockerfile解説
```dockerfile
FROM debian:bookworm

# MariaDBのインストール
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 設定ファイルのコピー
COPY conf/my.cnf /etc/mysql/my.cnf
COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 3306

CMD ["/setup.sh"]
```

## データベース設定（my.cnf）
```ini
[mysqld]
bind-address = 0.0.0.0
port = 3306
user = mysql
datadir = /var/lib/mysql
log_error = /var/log/mysql/error.log

# パフォーマンス設定
max_connections = 100
connect_timeout = 5
wait_timeout = 600
max_allowed_packet = 64M
thread_cache_size = 128
sort_buffer_size = 4M
bulk_insert_buffer_size = 16M
tmp_table_size = 32M
max_heap_table_size = 32M
```

## 環境変数
```env
MYSQL_ROOT_PASSWORD=rootpass
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=wppass
```

## セットアップスクリプト（setup.sh）の主要機能
1. 環境変数の検証
2. データベースディレクトリの初期化
3. 一時的なMariaDB起動
4. データベースとユーザーの作成
5. 権限の設定
6. セキュリティ設定の適用

## データ永続化
- ボリュームマウント: `/var/lib/mysql`
- バックアップ戦略
- データ整合性の確保

## セキュリティ設定
1. ユーザー権限
   - rootユーザーのリモートアクセス無効化
   - 最小権限の原則適用
   - パスワードポリシーの設定

2. ネットワークセキュリティ
   - バインドアドレスの制限
   - 接続制限の設定
   - SSL/TLS暗号化（オプション）

## パフォーマンスチューニング
- バッファプールサイズの最適化
- クエリキャッシュの設定
- インデックスの最適化
- 接続プールの設定

## トラブルシューティング
1. 起動の問題
   - ログファイルの確認
   - パーミッションの確認
   - データディレクトリの状態確認

2. 接続の問題
   - ネットワーク設定の確認
   - ユーザー権限の確認
   - ファイアウォール設定

3. パフォーマンスの問題
   - スロークエリログの分析
   - リソース使用率の監視
   - キャッシュヒット率の確認

## バックアップと復元
- 定期的なバックアップ
- ポイントインタイムリカバリ
- レプリケーション設定（オプション）

## メンテナンス作業
- ログローテーション
- データベース最適化
- インデックスメンテナンス
- セキュリティアップデート 