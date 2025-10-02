# Use Debian latest as the base image by default
FROM debian:latest AS base

# Arguments pour la détection de l'architecture
ARG TARGETARCH
ARG TARGETVARIANT

# For ARMv7, downgrade to Bookworm to avoid t64 conflicts
RUN if [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v7" ]; then \
        # Change sources to bookworm
        echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
        echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
        echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
        apt-get update && \
        apt-get install -y --allow-downgrades \
            apt=$(apt-cache policy apt | grep bookworm | head -1 | awk '{print $1}') \
            libc6=$(apt-cache policy libc6 | grep bookworm | head -1 | awk '{print $1}') || true; \
    fi

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
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg && \
        install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
        echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
        rm /tmp/packages.microsoft.gpg && \
        apt-get update && apt-get install -y code && rm -rf /var/lib/apt/lists/*; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        wget https://aka.ms/linux-arm64-deb -O /tmp/vscode-arm64.deb && \
        apt-get update && apt-get install -y /tmp/vscode-arm64.deb && \
        rm /tmp/vscode-arm64.deb && rm -rf /var/lib/apt/lists/*; \
    elif [ "$TARGETARCH" = "arm" ] && [ "$TARGETVARIANT" = "v7" ]; then \
        wget -qO- https://archive.raspberrypi.org/debian/raspberrypi.gpg.key | gpg --dearmor > /tmp/raspberrypi.gpg && \
        install -o root -g root -m 644 /tmp/raspberrypi.gpg /etc/apt/trusted.gpg.d/ && \
        echo "deb http://archive.raspberrypi.org/debian/ bookworm main" > /etc/apt/sources.list.d/raspi.list && \
        rm /tmp/raspberrypi.gpg && \
        apt-get update && apt-get install -y code && rm -rf /var/lib/apt/lists/*; \
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