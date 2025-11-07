# VS-Code Server - Docker Setup & Config

Official VS Code Server in Docker with WebSocket support, full extension compatibility (including GitHub Copilot), based on Debian.

## Quick Start

```bash
# Pull and run
docker pull ghcr.io/nerasse/my-code-server:main
docker run -d -p 8585:8585 -e TOKEN=yourtoken ghcr.io/nerasse/my-code-server:main

# Or with docker-compose
docker compose up -d
```

Access: `http://localhost:8585?tkn=yourtoken`

## Installation

### Prerequisites

- Docker
- Docker Compose (optional)
- Reverse Proxy (optional, for production)

### Option 1: Using Pre-built Image

```bash
docker pull ghcr.io/nerasse/my-code-server:main
```

### Option 2: Build Locally

```bash
# Using buildx (recommended)
docker buildx build -t my-code-server:main .

# Or using legacy builder
docker build -t my-code-server:main .
```

## Usage

### Docker Compose (Recommended)

**Basic usage:**
```bash
docker compose up -d
```

**With custom configuration (.env file):**
```env
HOST_PORT=9090
CONTAINER_PORT=8585
TOKEN=mysecuretoken
PUID=1000
PGID=1000
```

**With volumes (for persistence):**
Uncomment in `docker-compose.yml`:
```yaml
volumes:
  - /path/to/your/data:/home/vscodeuser
```

### Docker Run

**Basic:**
```bash
docker run -d -p 8585:8585 \
  -e PORT=8585 \
  -e TOKEN=sometoken \
  my-code-server:main
```

**With volumes and custom UID/GID:**
```bash
docker run -d -p 8585:8585 \
  -e PORT=8585 \
  -e TOKEN=sometoken \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -v /path/to/your/data:/home/vscodeuser \
  my-code-server:main
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | VS Code Server listening port | `8585` |
| `HOST` | Host interface to listen on | `0.0.0.0` |
| `TOKEN` | Connection token for authentication | None |
| `TOKEN_FILE` | Path to file containing token | - |
| `PUID` | User ID (for volume permissions) | `1000` |
| `PGID` | Group ID (for volume permissions) | `1000` |
| `SERVER_DATA_DIR` | Server data storage directory | - |
| `SERVER_BASE_PATH` | Base path for web UI | - |
| `SOCKET_PATH` | Socket path for server | - |
| `VERBOSE` | Enable verbose output | `false` |
| `LOG_LEVEL` | Log level (trace, debug, info, warn, error, critical, off) | - |
| `CLI_DATA_DIR` | CLI metadata directory | - |

### Docker Compose Variables

Use environment variables or `.env` file:

| Variable | Description | Default |
|----------|-------------|---------|
| `HOST_PORT` | Host port mapping | `8585` |
| `CONTAINER_PORT` | Container port | `8585` |
| `TOKEN` | Authentication token | `sometoken` |
| `PUID` | User ID | `1000` |
| `PGID` | Group ID | `1000` |

### Custom UID/GID

To avoid permission issues with mounted volumes, the container supports dynamic UID/GID:

**With docker-compose:** Set `PUID` and `PGID` environment variables
**With docker run:** Use `-e PUID=$(id -u) -e PGID=$(id -g)`

The container will automatically adjust user permissions at startup.

## Nginx Reverse Proxy Setup

### Network Configuration

- Container name: `my-code-server`
- Network: `vscode-server-network`

### HTTP Configuration

```nginx
server {
    listen 80;
    server_name my-code-server.domain.com;

    location / {
        proxy_pass http://my-code-server.vscode-server-network:8585;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support (required)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### HTTPS/SSL Configuration

```nginx
server {
    listen 443 ssl;
    server_name my-code-server.domain.com;

    ssl_certificate /ssl/.domain.com.cer;
    ssl_certificate_key /ssl/.domain.com.key;

    location / {
        proxy_pass http://my-code-server.vscode-server-network:8585;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support (required)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

Access: `https://my-code-server.domain.com?tkn=yourtoken`

## Architecture Support

- **amd64** (x86_64) - ✅ Fully supported
- **arm64** (aarch64) - ❓ Should work (not tested yet)
- **armv7** - ❌ Not supported

## Security

⚠️ **Important:** Replace default tokens with secure values. Never use published credentials in production.

## Contributing

Contributions are welcome!
