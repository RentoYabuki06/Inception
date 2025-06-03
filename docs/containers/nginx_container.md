# NGINX コンテナ

## 概要
NGINXコンテナは、プロジェクトのフロントエンドとして機能し、HTTPSトラフィックを処理し、WordPressコンテナにリバースプロキシとして動作します。

## 主な機能
- HTTPS（443ポート）でのリクエスト処理
- SSL/TLS終端
- WordPressへのリバースプロキシ
- 静的ファイルの効率的な配信

## Dockerfile解説
```dockerfile
FROM debian:bookworm

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SSL証明書の設定
COPY tools/ssl_setup.sh /ssl_setup.sh
RUN chmod +x /ssl_setup.sh
RUN /ssl_setup.sh

# NGINXの設定
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
```

## 設定ファイル（nginx.conf）の重要ポイント
```nginx
server {
    listen 443 ssl;
    server_name [ドメイン名];

    # SSL設定
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_certificate /etc/ssl/private/nginx.crt;
    ssl_certificate_key /etc/ssl/private/nginx.key;

    # WordPressへのプロキシ設定
    location / {
        proxy_pass http://wordpress:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## セキュリティ設定
- 最新のTLSプロトコル（1.2/1.3）のみ使用
- 安全なSSL暗号スイートの選択
- HTTPSリダイレクトの強制
- セキュリティヘッダーの設定

## ボリュームマウント
- SSL証明書: `/etc/ssl/private/`
- WordPressファイル: `/var/www/html`

## ネットワーク設定
- 外部公開ポート: 443
- 内部ネットワーク: `inception-net`
- WordPressコンテナとの通信

## トラブルシューティング
1. SSL証明書の問題
   - 証明書の有効期限確認
   - 証明書のパーミッション確認

2. 接続エラー
   - NGINXログの確認
   - WordPressコンテナとの接続確認

3. パフォーマンス問題
   - ワーカープロセスの調整
   - バッファサイズの最適化

## メンテナンス
- ログローテーション
- 定期的な証明書更新
- 設定ファイルのバックアップ
- セキュリティアップデートの適用 