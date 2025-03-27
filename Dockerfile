FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies required by eosio and general tools
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    libssl-dev \
    libcurl4-openssl-dev \
    libgmp-dev \
    libusb-1.0-0-dev \
    libtinfo5 \
    libcurl3-gnutls \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/assetledger

# Download and install eosio 2.1.0, then clean up
RUN wget https://github.com/EOSIO/eos/releases/download/v2.1.0/eosio_2.1.0-1-ubuntu-20.04_amd64.deb && \
    dpkg -i eosio_2.1.0-1-ubuntu-20.04_amd64.deb && \
    rm eosio_2.1.0-1-ubuntu-20.04_amd64.deb

RUN mkdir -p /root/.local/share/eosio/nodeos/data /root/.local/share/eosio/nodeos/config

COPY genesis.json /root/.local/share/eosio/nodeos/config/genesis.json
COPY config.ini /root/.local/share/eosio/nodeos/config/config.ini.template
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8888 9876

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nodeos", "--verbose-http-errors"]