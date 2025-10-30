NAME			= inception
DOCKER_COMPOSE	= docker compose -f ./srcs/docker-compose.yml

# -----------------------------------------------------------------------------
# Targets
# -----------------------------------------------------------------------------

all: start

start: build
	$(MAKE) up

build:
	$(DOCKER_COMPOSE) build

up:
	$(DOCKER_COMPOSE) up -d

# 起動中のコンテナを停止して削除（ボリュームとネットワークは保持）
down:
	$(DOCKER_COMPOSE) down

# コンテナとボリュームを削除
clean:
	$(DOCKER_COMPOSE) down --volumes

# system prune : Docker 全体の不要なリソース（コンテナ・イメージ・ネットワーク・キャッシュなど）を削除
# -a : all
# -f : force
# --volumes : ボリュームも削除
fclean: clean
	docker system prune -af --volumes

re: fclean all

.PHONY: all build up down clean fclean re start
