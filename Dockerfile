# Use Ubuntu as the base image
FROM debian:latest

# Install necessary packages
RUN apt-get update && apt-get install -y software-properties-common apt-transport-https wget

# Add the Microsoft GPG key
RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg

# Add the Visual Studio Code repository
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list

# Install needed packages on your IDE system
RUN apt-get update && apt-get install -y code
RUN apt-get -y install sudo -y \
    nano \
    git \
    curl \
    wget \
    unzip \
    npm \
    ssh && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Copy start.sh to the container
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Create a non-root user
RUN useradd -m vscodeuser && \
    echo 'vscodeuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscodeuser && \
    chmod 0444 /etc/sudoers.d/vscodeuser && \
    usermod -aG sudo vscodeuser

# Switch to the non-root user
USER vscodeuser

# Set the home directory for the non-root user
ENV HOME=/home/vscodeuser

# Exécutez le script au lancement du conteneur
ENTRYPOINT ["sh", "/app/start.sh"]
