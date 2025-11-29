FROM docker.io/caddy:2.9-builder AS builder
RUN xcaddy build v2.9.0 --with github.com/danielballan/replace-response@0f8c8ba
FROM docker.io/caddy:2.9
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
