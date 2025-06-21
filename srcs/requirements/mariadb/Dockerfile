FROM debian:bookworm

# パッケージリストの更新とMariaDBのインストール
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# データベース用ディレクトリ
RUN mkdir -p /var/lib/mysql

# 起動スクリプトコピー
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ポート開放(コンテナ内部)
EXPOSE 3306

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "mysqld", "--bind-address=0.0.0.0" ]
