# Inception プロジェクト概要

## プロジェクトの目的
このプロジェクトは、Dockerを使用して複数のサービス（NGINX、WordPress、MariaDB）を連携させ、セキュアなWordPressサイトを構築することを目的としています。

## アーキテクチャ
```
                    ┌─────────────┐
                    │    NGINX    │
                    │  (443/SSL)  │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │  WordPress  │
                    │   (PHP-FPM) │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │   MariaDB   │
                    └─────────────┘
```

## 主な特徴
- すべてのサービスが独立したコンテナで動作
- データの永続化（Docker Volumes使用）
- TLS 1.2/1.3によるセキュアな通信
- カスタムネットワークによる分離
- 環境変数による設定管理

## ディレクトリ構造
```
srcs/
├── docker-compose.yml
├── .env
└── requirements/
    ├── nginx/
    ├── wordpress/
    └── mariadb/
```

## セットアップ手順
1. 必要な環境変数を`.env`ファイルに設定
2. SSL証明書の生成
3. `docker-compose up --build`でサービスを起動
4. ブラウザで`https://[ドメイン名]`にアクセス

## 技術スタック
- Docker & Docker Compose
- NGINX (Webサーバー)
- WordPress + PHP-FPM
- MariaDB (データベース)
- OpenSSL (SSL証明書)

## セキュリティ対策
- SSLによる暗号化通信
- カスタムネットワークによるコンテナ間通信の制限
- 環境変数による機密情報の管理
- 最小限の公開ポート（443のみ）

## 運用管理
- データの永続化（WordPress、MariaDB）
- コンテナの自動再起動設定
- ヘルスチェックによる監視
- ログ管理 