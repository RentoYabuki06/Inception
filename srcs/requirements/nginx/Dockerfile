FROM debian:bookworm

# パッケージリストの更新とNginx、OpenSSLのインストール
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    ca-certificates \
    netcat-openbsd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
# 作業ディレクトリ
WORKDIR /var/www/html

# NGINX設定ファイルの配置など (例: conf/default.conf をコピー)
# ここで TLSv1.2 / TLSv1.3 のみ許可する設定を入れた default.conf を使う想定
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# デフォルトサイト（ポート80）を無効化 - 42プロジェクト要件でHTTPSのみ許可
RUN rm -f /etc/nginx/sites-enabled/default

# ランタイムで証明書を生成するためのSSLディレクトリを作成
RUN mkdir -p /etc/nginx/ssl

# エントリーポイントスクリプトを配置
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# コンテナ起動時にエントリーポイントを実行
ENTRYPOINT ["entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
