# Dockerコマンドの基礎

## イメージ関連のコマンド

### イメージの構築
```bash
# Dockerfileからイメージを構築
docker build -t イメージ名:タグ .

# キャッシュを使用せずにビルド
docker build --no-cache -t イメージ名:タグ .
```

### イメージの管理
```bash
# イメージ一覧の表示
docker images

# イメージの削除
docker rmi イメージ名:タグ

# 未使用イメージの一括削除
docker image prune
```

## コンテナ関連のコマンド

### コンテナの作成と実行
```bash
# コンテナの作成と起動
docker run -d --name コンテナ名 イメージ名:タグ

# ポートフォワーディング
docker run -d -p ホストポート:コンテナポート イメージ名:タグ

# ボリュームマウント
docker run -v ホストパス:コンテナパス イメージ名:タグ

# 環境変数の設定
docker run -e 環境変数名=値 イメージ名:タグ
```

### コンテナの管理
```bash
# 実行中のコンテナ一覧
docker ps

# 全てのコンテナ一覧（停止中含む）
docker ps -a

# コンテナの停止
docker stop コンテナ名

# コンテナの開始
docker start コンテナ名

# コンテナの再起動
docker restart コンテナ名

# コンテナの削除
docker rm コンテナ名

# 実行中のコンテナに接続
docker exec -it コンテナ名 /bin/bash
```

## ネットワーク関連のコマンド

### ネットワークの管理
```bash
# ネットワーク一覧の表示
docker network ls

# ネットワークの作成
docker network create ネットワーク名

# ネットワークの削除
docker network rm ネットワーク名

# コンテナをネットワークに接続
docker network connect ネットワーク名 コンテナ名
```

## ボリューム関連のコマンド

### ボリュームの管理
```bash
# ボリューム一覧の表示
docker volume ls

# ボリュームの作成
docker volume create ボリューム名

# ボリュームの削除
docker volume rm ボリューム名

# 未使用ボリュームの一括削除
docker volume prune
```

## Docker Compose関連のコマンド

### 基本的な操作
```bash
# サービスの起動
docker-compose up -d

# サービスの停止
docker-compose down

# サービスの再構築
docker-compose up -d --build

# サービスのログ表示
docker-compose logs -f
```

## システム情報とクリーンアップ

### システム情報
```bash
# Dockerシステム情報の表示
docker info

# ディスク使用量の確認
docker system df
```

### クリーンアップ
```bash
# 未使用リソースの一括削除
docker system prune

# ボリュームを含めた完全クリーンアップ
docker system prune -a --volumes
```

## よく使用するオプション

- `-d`: デタッチドモード（バックグラウンド実行）
- `-it`: インタラクティブモード（ターミナル接続）
- `--rm`: コンテナ終了時に自動削除
- `--name`: コンテナ名の指定
- `-v`: ボリュームマウント
- `-p`: ポートフォワーディング
- `-e`: 環境変数の設定

## トラブルシューティング

### ログの確認
```bash
# コンテナのログ表示
docker logs コンテナ名

# リアルタイムログ表示
docker logs -f コンテナ名
```

### リソース使用状況
```bash
# コンテナのリソース使用状況
docker stats

# 特定のコンテナの詳細情報
docker inspect コンテナ名
```

## 参考資料
- [Docker公式ドキュメント](https://docs.docker.com/engine/reference/commandline/cli/)
- [Docker Compose公式ドキュメント](https://docs.docker.com/compose/reference/)
