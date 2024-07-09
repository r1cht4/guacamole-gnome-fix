# Use an official Ubuntu as a parent image
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libcairo2-dev \
    libjpeg-turbo8-dev \
    libpng-dev \
    uuid-dev \
    libtool-bin \
    libpango1.0-dev \
    libssh2-1-dev \
    libtelnet-dev \
    libvncserver-dev \
    libpulse-dev \
    libwebsockets-dev \
    libssl-dev \
    libvorbis-dev \
    libwebp-dev \
    freerdp2-dev \
    ffmpeg \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    git \
    autoconf \
    automake \
    pkg-config \
    systemd \
    && rm -rf /var/lib/apt/lists/*

# Clone the Guacamole server source code
RUN git clone https://github.com/apache/guacamole-server.git /guacamole-server

# Set working directory
WORKDIR /guacamole-server

# Build Guacamole server
RUN autoreconf -fi \
    && ./configure --with-systemd-dir=/etc/systemd/system \
    && make \
    && make install \
    && ldconfig

    
RUN echo '#!/bin/bash\n\
/usr/local/sbin/guacd -b 0.0.0.0 &\n\
# Keep the container running\n\
tail -f /dev/null' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

# Expose the guacd port
EXPOSE 4822

# Use this when using sleep or tail in entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
