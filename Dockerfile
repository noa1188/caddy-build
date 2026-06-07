# ------------------------------------------------------------------------------
# Custom Caddy build with pinned plugin references
#
# Maintenance rules:
# 1. CADDY_VERSION:
#    - This is the upstream Caddy core version.
#    - It is suitable for automated bumping by GitHub Actions.
#    - Example: 2.11.4
#
# 2. Core DNS plugins:
#    - Prefer stable Git tags.
#    - Example tag format: v1.2.3
#
# 3. Smaller third-party plugins without clear release practice:
#    - Prefer exact commit SHA.
#    - Example commit format: f53b62a
#
# 4. Utility plugins:
#    - Use a verified tag if available.
#    - Otherwise pin an exact commit SHA.
#
# 5. Do not leave plugin refs unpinned in production.
#    - Bad: --with github.com/owner/plugin
#    - Good: --with github.com/owner/plugin@v1.2.3
#    - Good: --with github.com/owner/plugin@abcdef1
# ------------------------------------------------------------------------------

# Upstream Caddy core version.
# Example:
#   ARG CADDY_VERSION=2.11.4
ARG CADDY_VERSION=2.11.4

# ------------------------------------------------------------------------------
# Tier 1: Core DNS plugins
# These are critical for ACME DNS challenge and certificate automation.
# Prefer Git tags first, because they have clearer upgrade semantics.
#
# Example values:
#   ARG PLUGIN_CLOUDFLARE=v1.0.0
#   ARG PLUGIN_DESEC=v0.2.0
# ------------------------------------------------------------------------------
ARG PLUGIN_CLOUDFLARE=v0.2.4
ARG PLUGIN_DESEC=v1.1.0

# ------------------------------------------------------------------------------
# Tier 2: Smaller third-party plugin
# Prefer exact commit SHA when release/tag practice is weak or unclear.
#
# Example values:
#   ARG PLUGIN_CLOUDFLARE_IP=f53b62a
#   ARG PLUGIN_CLOUDFLARE_IP=1a2b3c4d5e6f
# ------------------------------------------------------------------------------
ARG PLUGIN_CLOUDFLARE_IP=f53b62aa13cb7ad79c8b47aacc3f2f03989b67e5

# ------------------------------------------------------------------------------
# Tier 3: Utility plugins
# Use a verified Git tag if the project maintains tags you trust.
# Otherwise use an exact commit SHA.
#
# Example tag values:
#   ARG PLUGIN_COMBINE_IP_RANGES=v0.1.0
#   ARG PLUGIN_WEBDAV=v0.3.0
#
# Example commit values:
#   ARG PLUGIN_COMBINE_IP_RANGES=abc1234
#   ARG PLUGIN_WEBDAV=def5678
# ------------------------------------------------------------------------------
ARG PLUGIN_COMBINE_IP_RANGES=5624d08f5f9e788816bdd877b7c81280c69b434e
ARG PLUGIN_WEBDAV=fa2f366b0d75e54c2e381c0aefc3a8df8bf5794b

# ------------------------------------------------------------------------------
# Build stage
# We build a custom caddy binary with xcaddy and pinned plugin references.
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Runtime stage
# Keep the final image small by copying only the built caddy binary.
# ------------------------------------------------------------------------------
FROM caddy:${CADDY_VERSION}-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Basic validation during image build:
# - caddy version: confirms the binary exists and runs
# - caddy list-modules: confirms plugins were built into the binary
RUN /usr/bin/caddy version \
 && /usr/bin/caddy list-modules

# Default container behavior:
# - ENTRYPOINT keeps caddy as the main executable
# - CMD can be overridden by docker run / compose / kubernetes
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["version"]
