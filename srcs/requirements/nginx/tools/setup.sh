#!/bin/bash

# SSL証明書が存在しない場合は作成
if [ ! -f /etc/nginx/ssl/server.crt ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42/CN=localhost"
fi

# 証明書のパスを設定
ssl_certificate /etc/nginx/ssl/server.crt;
ssl_certificate_key /etc/nginx/ssl/server.key;

# 起動
nginx -g "daemon off;"
