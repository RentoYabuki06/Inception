FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

RUN mkdir -p /etc/ssl/private && \
    mkdir -p /etc/nginx/ssl

CMD ["bash", "/setup.sh"]
