# caddy-cloudflare-desec-webdav

```
https://github.com/mholt/caddy-l4

https://caddyserver.com/download

https://github.com/caddy-dns/cloudflare

https://github.com/caddy-dns/desec

https://github.com/mholt/caddy-webdav
```
First, create the docker network:
```
docker network create caddy-cf
```

Example: docker-compose.yml

```
services:
  caddy:
    image: dzluck/caddy-cloudflare-desec:v2.11.2
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    networks:
      - caddy-cf
    environment:
      - CLOUDFLARE_API_TOKEN=CF_TOKEN
      - DESEC_TOKEN=deSEC_Token
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./html:/srv
      - ./caddy_data:/data
      - ./caddy_config:/config
      - ./caddy_log:/logs
 
volumes:
  caddy_data:
  caddy_config:
  caddy_log:
 
networks:
  caddy-cf:
    external: true
```
Caddyfile example:
```
{
    email your-email@example.com
}

a.cf-domain.com {
    reverse_proxy 127.0.0.1:8080
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
}

*.cf-domain.com {
    reverse_proxy 127.0.0.1:9090
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
}

api.desec-domain.net {
    reverse_proxy 127.0.0.1:3000
    tls {
        dns desec {env.DESEC_TOKEN}
    }
}
```
