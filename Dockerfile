FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

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
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/assetledger

RUN wget https://github.com/EOSIO/eos/releases/download/v2.1.0/eosio_2.1.0-1-ubuntu-20.04_amd64.deb
RUN dpkg -i eosio_2.1.0-1-ubuntu-20.04_amd64.deb 
RUN rm eosio_2.1.0-1-ubuntu-20.04_amd64.deb 

RUN mkdir -p /root/.local/share/eosio/nodeos/data /root/.local/share/eosio/nodeos/config /opt/assetledger/contracts

# Copy genesis.json and contracts
COPY genesis.json /opt/assetledger/genesis.json
COPY contracts /opt/assetledger/contracts
COPY bp-node-config.ini /bp-node-config.ini
COPY validator-node-config.ini /validator-node-config.ini
COPY api-node-config.ini /api-node-config.ini
COPY entrypoint.sh /entrypoint.sh
COPY deploy_contracts.sh /deploy_contracts.sh

# Convert line endings for entrypoint.sh
RUN dos2unix /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /deploy_contracts.sh

EXPOSE 8888 9876

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--verbose-http-errors"]