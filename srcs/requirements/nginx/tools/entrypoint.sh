#!/bin/bash

set -e

# デフォルトサイト（ポート80）を無効化 - 42プロジェクト要件でHTTPSのみ許可
if [ -L /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
    echo "Removed default site configuration (port 80)"
elif [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
    echo "Removed default site configuration file (port 80)"
fi

# sites-enabledディレクトリ内の他の設定ファイルもチェック（念のため）
if [ -d /etc/nginx/sites-enabled ]; then
    for site in /etc/nginx/sites-enabled/*; do
        if [ -f "$site" ] && grep -q "listen.*80" "$site" 2>/dev/null; then
            echo "Warning: Found site configuration with port 80: $site"
        fi
    done
fi

# default.conf の server_name を DOMAIN_NAME に差し替え
if [ -n "${DOMAIN_NAME}" ]; then
    sed -i "s/server_name\s\+[^;]\+;/server_name ${DOMAIN_NAME};/" /etc/nginx/conf.d/default.conf || true
fi

# SSL証明書の生成（自己署名証明書）
# 「/etc/nginx/ssl/server.crt」が存在しない場合のみ作成
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    CN=${DOMAIN_NAME:-localhost}
    openssl req \
        -x509 \
        -nodes \
        -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/CN=${CN}" \
        -addext "subjectAltName=DNS:${CN}"
fi

# SSL/TLS通信では名残でSSL証明書と言うが、SSLには脆弱性が見つかり現在はほぼTLSで行われている
# RSA暗号のRSAは発明者3人の頭文字らしい。素因数分解が非常に困難な大きな整数を用いている

echo "Waiting for wordpress:9000 to be ready..."
for i in $(seq 1 60); do
    if nc -z wordpress 9000; then echo "wordpress is up!"; break; fi
    echo "Waiting... ($i)"; sleep 1
done

exec nginx -g "daemon off;"