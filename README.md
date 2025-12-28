# MTProxy Docker Image (Multi-Arch)

A lightweight, multi-architecture (AMD64 & ARM64) Docker image for running a Telegram MTProto Proxy.

## Quick Start

Run the proxy with a single command. It will automatically generate a secret for you.

```bash
docker run -d \
  --name mtproxy \
  --restart always \
  -p 8443:8888 \
  arm64builds/mtproxy:latest
```

View the logs to get your connection links and the generated secret:

```bash
docker logs mtproxy
```

## Docker Compose

Create a `docker-compose.yml` file:

```yaml
services:
  mtproxy:
    image: arm64builds/mtproxy:latest
    container_name: mtproxy
    restart: always
    ports:
      - "8443:8888"
    volumes:
      - ./.env:/data/.env
    environment:
      - HOST_PORT=8443
      # - SECRET=ee... # Optional: Provide your own secret
      # - DOMAIN=google.com # Optional: FakeTLS domain
```

Run it:
```bash
docker compose up -d
```

## Configuration

You can configure the proxy using environment variables.

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRET` | A 32-character hex secret. If not provided, one is generated automatically. | *(Randomly Generated)* |
| `DOMAIN` | The domain used for FakeTLS. | `cdnjs.cloudflare.com` |
| `HOST_PORT`| The port exposed on the host. Used for link generation. | `8443` |
| `PUBLIC_IP`| Your server's public IP. Used for link generation. | *(Auto-detected via ifconfig.me)* |

## Persistence

The image is designed to persist the generated secret so it doesn't change if you recreate the container.

To enable this, mount a file to `/data/.env`. The container will write the generated `SECRET` to this file if it doesn't allow exist.

1. Create an empty file:
   ```bash
   touch .env
   ```
2. Mount it in your run command:
   ```bash
   docker run -d \
     -p 8443:8888 \
     -v $(pwd)/.env:/data/.env \
     arm64builds/mtproxy:latest
   ```

## Troubleshooting

- **Logs**: Check `docker logs mtproxy` to see the startup status and generated links.
- **Ports**: Ensure the `HOST_PORT` matches the port you mapped in Docker (e.g., `-p 8443:8888` means `HOST_PORT` should be 8443).
