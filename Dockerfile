ARG CADDY_VERSION=2.11.4

ARG PLUGIN_CLOUDFLARE=v1.6.0
ARG PLUGIN_DESEC=v0.0.0
ARG PLUGIN_CLOUDFLARE_IP=<PINNED_TAG_OR_COMMIT>
ARG PLUGIN_COMBINE_IP_RANGES=<PINNED_TAG_OR_COMMIT>
ARG PLUGIN_WEBDAV=v0.0.4

FROM caddy:${CADDY_VERSION}-builder AS builder

ARG CADDY_VERSION
ARG PLUGIN_CLOUDFLARE
ARG PLUGIN_DESEC
ARG PLUGIN_CLOUDFLARE_IP
ARG PLUGIN_COMBINE_IP_RANGES
ARG PLUGIN_WEBDAV

RUN xcaddy build "v${CADDY_VERSION}" \
    --with github.com/caddy-dns/cloudflare@${PLUGIN_CLOUDFLARE} \
    --with github.com/caddy-dns/desec@${PLUGIN_DESEC} \
    --with github.com/WeidiDeng/caddy-cloudflare-ip@${PLUGIN_CLOUDFLARE_IP} \
    --with github.com/fvbommel/caddy-combine-ip-ranges@${PLUGIN_COMBINE_IP_RANGES} \
    --with github.com/mholt/caddy-webdav@${PLUGIN_WEBDAV}

FROM caddy:${CADDY_VERSION}-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN /usr/bin/caddy version && /usr/bin/caddy list-modules

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["version"]
