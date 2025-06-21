#!/bin/bash

# nginx.confの動的設定
sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf

# SSL証明書の生成
if [ ! -f /etc/nginx/ssl/server.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/CN=${DOMAIN_NAME}"
fi

# wordpress:9000 が起動するまで最大30秒待つ
echo "Waiting for wordpress:9000 to be ready..."
for i in {1..30}; do
    nc -z wordpress 9000 && echo "wordpress is up!" && break
    echo "Waiting... ($i)"
    sleep 1
done

# NGINX起動
nginx -g "daemon off;"