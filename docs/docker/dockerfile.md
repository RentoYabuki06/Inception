# Dockerfileの基礎

## Dockerfileとは
Dockerfileは、Dockerイメージを作成するための設計図のようなものです。テキストファイル形式で、イメージの構築に必要な手順を記述します。

## 基本的な命令

### FROM
```dockerfile
FROM ubuntu:20.04
```
- ベースイメージを指定する命令
- Dockerfileの最初に必ず記述する必要がある
- タグを指定することで、特定のバージョンを使用可能

### RUN
```dockerfile
RUN apt-get update && apt-get install -y nginx
```
- イメージ構築時に実行するコマンドを指定
- パッケージのインストールやファイルの作成などに使用
- `&&`で複数のコマンドを連結することで、レイヤー数を削減可能

### COPY / ADD
```dockerfile
COPY ./app /app
ADD https://example.com/file.tar.gz /app/
```
- ホストからコンテナにファイルやディレクトリをコピー
- ADDはURLからのダウンロードや圧縮ファイルの展開も可能

### WORKDIR
```dockerfile
WORKDIR /app
```
- 作業ディレクトリを設定
- 以降の命令はこのディレクトリを基準に実行される

### ENV
```dockerfile
ENV NODE_VERSION=16.14.0
```
- 環境変数を設定
- イメージ構築時と実行時の両方で使用可能

### EXPOSE
```dockerfile
EXPOSE 80
```
- コンテナが使用するポートを指定
- ドキュメント的な役割（実際のポート公開には-pオプションが必要）

### CMD / ENTRYPOINT
```dockerfile
CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["python", "app.py"]
```
- コンテナ起動時に実行されるコマンドを指定
- CMDは上書き可能、ENTRYPOINTは固定のコマンド

## ベストプラクティス

1. マルチステージビルド
```dockerfile
# ビルドステージ
FROM node:16 AS builder
WORKDIR /app
COPY . .
RUN npm install && npm run build

# 実行ステージ
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

2. レイヤーの最適化
- RUNコマンドの連結
- 不要なファイルの削除
- .dockerignoreの使用

3. キャッシュの活用
- 変更が少ない命令を先に配置
- 依存関係のインストールを先に実行

## セキュリティ考慮事項

1. 最小限のベースイメージ使用
```dockerfile
FROM alpine:3.14  # フルOSの代わりに軽量イメージを使用
```

2. 非rootユーザーの使用
```dockerfile
RUN adduser -D myuser
USER myuser
```

3. 機密情報の取り扱い
- ビルド引数（ARG）の使用
- 機密情報を直接Dockerfileに記述しない

## デバッグとトラブルシューティング

1. ビルドコンテキスト
- 必要なファイルのみを含める
- .dockerignoreファイルの活用

2. ビルドキャッシュ
- `docker build --no-cache`でキャッシュを無視
- `docker history`でレイヤー構造を確認

## 実践的な例

### Webアプリケーション
```dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 3000
CMD ["npm", "start"]
```

### データベース
```dockerfile
FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=secret
ENV MYSQL_DATABASE=myapp

COPY ./init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306
```

## 参考資料
- [Docker公式ドキュメント](https://docs.docker.com/engine/reference/builder/)
- [Dockerfile ベストプラクティス](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)