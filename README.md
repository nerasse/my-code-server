# Visual Studio Code Server Docker Setup

## Introduction


This repository hosts a Docker setup for deploying an official installation of Visual Studio Code Server using a container. By leveraging the `serve-web` feature of Visual Studio Code, this setup provides an instance of VS Code accessible through a web browser. The base image used is Ubuntu, ensuring a stable and familiar environment for development. Included in this setup are a Dockerfile and a docker-compose.yml file, simplifying the deployment process.

**Note:** This setup aims to maintain compatibility with all Visual Studio Code extensions, including those like GitHub Copilot Chat, by using the official version of VS Code Server. It is designed with the intention to support the full range of VS Code features and extensions without the limitations often encountered in non-official installations.



## Prerequisites

Before you begin, ensure you have the following installed:
- Docker
- Docker Compose (for using the docker-compose.yml)

## Building the Docker Image

    1. Clone this repository to your local machine.
    2. Navigate to the directory containing the Dockerfile.
    3. Build the Docker image with the following command:

        sudo docker build -t my-code-server .

## Running the Container Using Docker Run

If you prefer to use `docker run` instead of Docker Compose, follow these steps:

   Execute the following command to run the VS Code Server container:

   ```bash
   docker run -d -p 8585:8585 my-code-server
   ```
Explanation of flags:

    -d: Run the container in detached mode (in the background).
    -p 8585:8585: Map port 8585 of the host to port 8585 of the container (adjust if you changed the default port).

Accessing VS Code Server:

Once the container is running, you can access the VS Code Server by navigating to:
```yes
http://localhost:8585
```


Start using the `docker run` command, along with explanations of the command-line options and additional management commands.

## Starting the VS Code Server with docker compose

Use Docker Compose to start the VS Code server:

    1. Navigate to the directory containing the `docker-compose.yml` file.
    2. Run the following command:
    
        docker-compose up -d

markdown
Copy code
3. Once the container is running, the VS Code server will be accessible at `http://localhost:8585`.

## Configuration

- Default port is `8585`.
- To persist data on the host, uncomment the `volumes` section in the `docker-compose.yml` and specify the path.

## Optional Setup: Nginx Reverse Proxy Configuration

To access the VS Code Server securely with a domain name and SSL:

### Optional Setup: Network Configuration

- The container uses the `vscode-server-network` network.

### Configuring Nginx exemple

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
         # Other necessary configurations...
     }
 }
 ```

#### SSL Certificates

Make sure to have valid SSL certificates for 443 ssl usage.

### Accessing VS Code Server

Access via `https://my-code-server.domain.com`.

## Security Note

Replace `<root_password>` and `<token_to_define>` in Dockerfile with secure values.

## Contributing

Contributions are welcome!

## License

This project is open-sourced under the MIT License.