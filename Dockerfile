FROM ubuntu:22.04

# Install packages
RUN apt-get -y update && apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo \
    curl \
    ffmpeg \
    git \
    locales \
    nano \
    python3-pip \
    screen \
    ssh \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_21.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ARG NGROK_TOKEN
ENV NGROK_TOKEN=${NGROK_TOKEN}
ENV PORT=8000

# Install ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip \
    && unzip ngrok.zip \
    && rm ngrok.zip

# Setup SSH
RUN mkdir -p /run/sshd \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo root:choco | chpasswd

# Ensure root user has a proper shell
RUN sed -i 's|^root:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:.*|root:x:0:0:root:/root:/bin/bash|' /etc/passwd

# Create a startup script
RUN echo '#!/bin/bash' > /start \
    && echo 'set -e' >> /start \
    && echo 'echo "[start] Starting SSH daemon..."' >> /start \
    && echo '/usr/sbin/sshd' >> /start \
    && echo '' >> /start \
    && echo 'if [ -n "$NGROK_TOKEN" ]; then' >> /start \
    && echo '  echo "[start] Adding ngrok authtoken..."' >> /start \
    && echo '  ./ngrok config add-authtoken ${NGROK_TOKEN}' >> /start \
    && echo '  echo "[start] Starting ngrok tunnel for port 22..."' >> /start \
    && echo '  ./ngrok tcp 22 &>/var/log/ngrok.log &' >> /start \
    && echo 'fi' >> /start \
    && echo '' >> /start \
    && echo 'echo "[start] Starting HTTP server on port ${PORT}..."' >> /start \
    && echo 'python3 -m http.server ${PORT:-8000} --bind 0.0.0.0' >> /start

RUN chmod 755 /start

# Expose necessary ports (most only needed for your app, but SSH and HTTP always)
EXPOSE 22 80 443 3306 5130 5131 5132 5133 5134 5135 8080 8888 8000

# Healthcheck (optional, but helpful)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8000} || exit 1

CMD ["/start"]
