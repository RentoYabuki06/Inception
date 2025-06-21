FROM debian:bookworm

# パッケージリストの更新とNginx、OpenSSLのインストール
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
# 作業ディレクトリ
WORKDIR /var/www/html

# NGINX設定ファイルの配置など (例: conf/default.conf をコピー)
# ここで TLSv1.2 / TLSv1.3 のみ許可する設定を入れた default.conf を使う想定
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# SSL用ディレクトリを作成し、自己署名証明書を生成
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
        -subj "/C=JP/ST=Tokyo/L=Minato/O=42Tokyo/OU=Student/CN=example" \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt

# NGINXログをフォアグラウンドで出力するための設定
# デーモンモードではなくフォアグラウンドモードで実行
CMD ["nginx", "-g", "daemon off;"]
