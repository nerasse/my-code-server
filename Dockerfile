# Use Debian latest as the base image
FROM debian:latest

# Arguments pour la détection de l'architecture
ARG TARGETARCH
ARG TARGETVARIANT

# Install necessary packages
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    wget \
    curl \
    gnupg2 \
    sudo \
    nano \
    git \
    unzip \
    npm \
    ssh \
    && rm -rf /var/lib/apt/lists/*

# Install VS Code based on architecture
RUN ARCH=$(dpkg --print-architecture) && \
    echo "Detected architecture: $ARCH (TARGETARCH=$TARGETARCH)" && \
    if [ "$TARGETARCH" = "amd64" ] || [ "$ARCH" = "amd64" ]; then \
        echo "Installing VS Code for amd64..." && \
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg && \
        install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
        echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
        rm /tmp/packages.microsoft.gpg && \
        apt-get update && apt-get install -y code && rm -rf /var/lib/apt/lists/* && \
        echo "VS Code installed successfully" && \
        which code || (echo "ERROR: code command not found after installation!" && exit 1); \
    elif [ "$TARGETARCH" = "arm64" ] || [ "$ARCH" = "arm64" ]; then \
        echo "Installing VS Code for arm64..." && \
        wget https://aka.ms/linux-arm64-deb -O /tmp/vscode-arm64.deb && \
        apt-get update && apt-get install -y /tmp/vscode-arm64.deb && \
        rm /tmp/vscode-arm64.deb && rm -rf /var/lib/apt/lists/* && \
        echo "VS Code installed successfully" && \
        which code || (echo "ERROR: code command not found after installation!" && exit 1); \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v7" ]; then \
        echo "WARNING: VS Code is not officially available for armv7 - container will be built without VS Code"; \
    else \
        echo "WARNING: VS Code is not available for architecture: $TARGETARCH$TARGETVARIANT ($ARCH) - container will be built without VS Code"; \
    fi

# Additional cleanup
RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Copy start.sh to the container
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Create a non-root user with default UID/GID (will be adjustable at runtime via env vars)
RUN groupadd -g 1000 vscodeuser && \
    useradd -m -u 1000 -g 1000 -s /bin/bash vscodeuser && \
    echo 'vscodeuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscodeuser && \
    chmod 0440 /etc/sudoers.d/vscodeuser && \
    usermod -aG sudo vscodeuser

# Don't switch to vscodeuser yet - start.sh will handle it

# Set the home directory for the non-root user
ENV HOME=/home/vscodeuser

# Exécutez le script au lancement du conteneur (as root to allow UID/GID changes)
ENTRYPOINT ["/app/start.sh"]