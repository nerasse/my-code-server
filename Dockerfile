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
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        # Pour AMD64, utiliser le dépôt Microsoft
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg && \
        install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
        echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
        rm /tmp/packages.microsoft.gpg && \
        apt-get update && apt-get install -y code && rm -rf /var/lib/apt/lists/*; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        # Pour ARM64, télécharger le .deb directement
        wget https://aka.ms/linux-arm64-deb -O /tmp/vscode-arm64.deb && \
        apt-get update && apt-get install -y /tmp/vscode-arm64.deb && \
        rm /tmp/vscode-arm64.deb && rm -rf /var/lib/apt/lists/*; \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v7" ]; then \
        # Pour ARMv7, télécharger le .deb directement
        wget https://aka.ms/linux-armhf-deb -O /tmp/vscode-armhf.deb && \
        apt-get update && apt-get install -y /tmp/vscode-armhf.deb && \
        rm /tmp/vscode-armhf.deb && rm -rf /var/lib/apt/lists/*; \
    else \
        echo "VS Code is not available for $TARGETARCH$TARGETVARIANT - skipping installation"; \
    fi

# Additional cleanup
RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Copy start.sh to the container
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Create a non-root user
RUN useradd -m vscodeuser && \
    echo 'vscodeuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscodeuser && \
    chmod 0440 /etc/sudoers.d/vscodeuser && \
    usermod -aG sudo vscodeuser

# Switch to the non-root user
USER vscodeuser

# Set the home directory for the non-root user
ENV HOME=/home/vscodeuser

# Exécutez le script au lancement du conteneur
ENTRYPOINT ["sh", "/app/start.sh"]