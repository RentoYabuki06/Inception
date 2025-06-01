FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY conf.sql /docker-entrypoint-initdb.d/
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 3306

CMD ["/setup.sh"]
