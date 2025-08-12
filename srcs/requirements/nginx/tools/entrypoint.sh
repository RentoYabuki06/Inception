#!/bin/bash

# nginx.confの動的設定（ビルド時ではなくコンテナ起動時にドメイン名を注入できる）
sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf

# SSL証明書の生成（自己署名証明書）
# 「/etc/nginx/ssl/server.crt」が存在しない場合のみ作成
if [ ! -f /etc/nginx/ssl/server.crt ]; then
    openssl req \                              # 証明書署名要求（CSR）または証明書を作成するコマンド
        -x509 \                                # 自己署名証明書を直接生成（CAに署名依頼しない）
        -nodes \                               # 秘密鍵をパスフレーズなしで作成（起動時にパスワード入力不要）
        -days 365 \                            # 証明書の有効期限（日数指定：ここでは365日）
        -newkey rsa:2048 \                     # 2048ビットの新しいRSA秘密鍵を同時に生成
        -keyout /etc/nginx/ssl/server.key \    # 生成した秘密鍵の保存先（サーバー側のみ保持）
        -out /etc/nginx/ssl/server.crt \       # 生成した公開証明書の保存先（クライアントに送信）
        -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/CN=${DOMAIN_NAME}"  
                                                # 証明書のサブジェクト情報（国C、都道府県ST、市区町村L、組織O、コモンネームCN）
                                                # CNには対象ドメイン名（${DOMAIN_NAME}）を指定
fi

# SSL/TLS通信では名残でSSL証明書と言うが、SSLには脆弱性が見つかり現在はほぼTLSで行われている
# RSA暗号のRSAは発明者3人の頭文字らしい。素因数分解が非常に困難な大きな整数を用いている

# wordpress:9000 が起動するまで最大30秒待つ
echo "Waiting for wordpress:9000 to be ready..."
for i in {1..30}; do
    nc -z wordpress 9000 && echo "wordpress is up!" && break
    echo "Waiting... ($i)"
    sleep 1
done

# NGINX起動
nginx -g "daemon off;"