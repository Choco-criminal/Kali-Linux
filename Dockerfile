FROM ubuntu:22.04

# Basic updates and tools
RUN apt-get -y update && apt-get -y upgrade -y && apt-get install -y \
    sudo curl ffmpeg git locales nano python3-pip screen ssh unzip wget

# Set locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y nodejs

# Download and install ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
    unzip ngrok.zip && \
    mv ngrok /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok

# Add Ngrok authtoken directly
RUN ngrok config add-authtoken 2bmDkAveY0grVVDlgwVXiOP5ia2_3vyBFrEpUdZou7veySL6p

# SSH Configuration
RUN mkdir /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo root:choco | chpasswd

# Create start script
RUN echo '#!/bin/bash' > /start && \
    echo "ngrok tcp --region ap 22 &>/dev/null &" >> /start && \
    echo "/usr/sbin/sshd -D" >> /start && \
    chmod +x /start

# Expose necessary ports
EXPOSE 22 80 443 8888 8080 5130 5131 5132 5133 5134 5135 3306

# Default command
CMD ["/start"]
