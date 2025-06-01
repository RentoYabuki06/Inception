FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 3306

CMD ["/setup.sh"]
