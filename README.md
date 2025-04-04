# VS-Code Server - Docker Setup & config

## Introduction

This repository hosts a Docker setup for deploying an official installation of Visual Studio Code Server using a container. By leveraging the `serve-web` feature of Visual Studio Code, this setup provides an instance of VS Code accessible through a web browser. The base image used is **Debian**, ensuring a light, stable and familiar environment for development. Included in this setup are a Dockerfile and a docker-compose.yml file, simplifying the deployment process.

**Note:** This setup aims to maintain compatibility with all Visual Studio Code extensions, including those like GitHub Copilot Chat, by using the official version of VS Code Server. It is designed with the intention to support the full range of VS Code features and extensions without the limitations often encountered in non-official installations.

## Prerequisites

Before you begin, ensure you have the following installed:

- Docker
- Docker Compose (for using the docker-compose.yml)
- Reverse Proxy (for websocket)

## Getting Image

### Pull image from Docker Package Registry

To pull the pre-built image from Docker Package Registry, execute the following command:

```bash
docker pull ghcr.io/nerasse/my-code-server:main
```

### Building the Docker Image

    1. Clone this repository to your local machine.
    2. Navigate to the directory containing the Dockerfile.
    3. Build the Docker image with the following command:

    sudo docker build -t my-code-server:main .

## Running the Container Using Docker Run

If you prefer to use `docker run` instead of Docker Compose, follow these steps:

   Execute the following command to run the VS Code Server container:

```bash
   docker run -d -p 8585:8585 -e PORT=8585 -e TOKEN=sometoken my-code-server:main
```

Explanation of flags:

    -d: Run the container in detached mode (in the background).
    -p 8585:8585: Map port 8585 of the host to port 8585 of the container (adjust if you changed the default port).
    -e PORT=8585: Set the environment variable `PORT` to 8585 (adjust if you changed the default port).
    -e TOKEN=sometoken: Set a token for authentication (optional).

Accessing VS Code Server:

Once the container is running, you can access the VS Code Server by navigating to:

```link
http://host:8585?tkn=sometoken
```

host should be replaced with your actual host IP address or domain name.


Start using the `docker run` command, along with explanations of the command-line options and additional management commands.

## Starting the VS Code Server with docker compose

Use Docker Compose to start the VS Code server:

    1. Navigate to the directory containing the`docker-compose.yml` file.
    2. Run the following command:

    docker compose up -d

    3. Once the container is running, the VS Code server will be accessible at`http://localhost:8585`.

## Configuration

- Default port is `8585`.
- Authentication is optional. If not provided, no token will be required.
- To persist data on the host, uncomment the `volumes` section in the `docker-compose.yml` and specify the path.

## Environment Variables

The following environment variables can be configured:

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | The port on which VS Code Server will listen | `8585` |
| `HOST` | The host interface to listen on | `0.0.0.0` |
| `TOKEN` | A connection token for authentication | No token if not provided |
| `TOKEN_FILE` | Path to a file containing a connection token | - |
| `SERVER_DATA_DIR` | Directory where server data is stored | - |
| `SERVER_BASE_PATH` | Path under which the web UI and code server is provided | - |
| `SOCKET_PATH` | Socket path for the server to use | - |
| `VERBOSE` | Enable verbose output | `false` |
| `LOG_LEVEL` | Log level (trace, debug, info, warn, error, critical, off) | - |
| `CLI_DATA_DIR` | Directory where CLI metadata should be stored | - |

## Setup: Nginx Reverse Proxy Configuration

To access the VS Code Server (also securely with a domain name and SSL):

### Optional Setup: Network Configuration

- The container uses the `vscode-server-network` network.
- The container name is `my-code-server`.

### Configuring Nginx HTTP exemple

```nginx
# my code server
server {
    listen 80;
    server_name my-code-server.domain.com;

    location / {
        set $codeservervar my-code-server.vscode-server-network:8585;
        proxy_pass http://$codeservervar;  
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### Configuring Nginx HTTPS/SSL exemple

```nginx
# my code server
server {
    listen 443 ssl;
    server_name my-code-server.domain.com;

    ssl_certificate /ssl/.domain.com.cer;
    ssl_certificate_key /ssl/.domain.com.key;

    location / {
        set $codeservervar my-code-server.vscode-server-network:8585;
        proxy_pass http://$codeservervar;    
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

#### SSL Certificates

Make sure to have valid SSL certificates for 443 ssl usage.

### Accessing VS Code Server

Access via `https://my-code-server.domain.com` plus `?tkn=sometoken` in the URL if you have set `sometoken` as your token.

## Security Note

**Replace all passwords and tokens with secure values. Please be aware of the security implications of using default or published credentials on repositories.**

## Contributing

Contributions are welcome!
