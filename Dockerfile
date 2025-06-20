FROM debian:latest

# Install base dependencies
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y sudo curl ffmpeg git locales nano python3-pip screen ssh unzip wget

# Set up locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y nodejs

# Configure SSH
RUN mkdir /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo root:choco | chpasswd && \
    ssh-keygen -A

# Create startup script
RUN echo "#!/bin/sh" > /start && \
    echo "# Start Serveo SSH tunnel for port 22" >> /start && \
    echo "while true; do" >> /start && \
    echo "  ssh -o StrictHostKeyChecking=no \\" >> /start && \
    echo "      -o ServerAliveInterval=60 \\" >> /start && \
    echo "      -R 0:localhost:22 serveo.net" >> /start && \
    echo "  sleep 10" >> /start && \
    echo "done &" >> /start && \
    echo "" >> /start && \
    echo "# Start SSH server" >> /start && \
    echo "/usr/sbin/sshd -D" >> /start && \
    chmod 755 /start

# Expose ports (kept the same as original)
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Start command
CMD /start
