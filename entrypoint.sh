#!/bin/bash

CONFIG_FILE="/root/.local/share/eosio/nodeos/config/config.ini"
GENESIS_FILE="/root/.local/share/eosio/nodeos/config/genesis.json"

# Ensure the config directory exists
mkdir -p /root/.local/share/eosio/nodeos/config

# Copy genesis.json
if [ ! -f "$GENESIS_FILE" ]; then
    echo "Copying genesis.json to $GENESIS_FILE..."
    cp /opt/assetledger/genesis.json "$GENESIS_FILE"
fi

# Verify genesis.json exists
if [ ! -f "$GENESIS_FILE" ]; then
    echo "genesis.json not found at $GENESIS_FILE"
    exit 1
fi

# Configure node based on ROLE
case "$ROLE" in
    "full")
        echo "Configuring as Full Node (Block Producer)..."
        cat <<EOF > $CONFIG_FILE
http-server-address = 0.0.0.0:8888
p2p-server-address = 0.0.0.0:9876
producer-name = assetledger
plugin = eosio::chain_plugin
plugin = eosio::http_plugin
plugin = eosio::chain_api_plugin
plugin = eosio::net_plugin
plugin = eosio::producer_plugin
enable-stale-production = true
resource-monitor-space-threshold = 95
EOF
        # Add each P2P peer on a separate line
        for peer in $P2P_PEERS; do
            echo "p2p-peer-address = $peer" >> $CONFIG_FILE
        done
        ;;
    "seed")
        echo "Configuring as Seed Node..."
        cat <<EOF > $CONFIG_FILE
plugin = eosio::net_plugin
plugin = eosio::chain_plugin
p2p-server-address = 0.0.0.0:9876
resource-monitor-space-threshold = 95
EOF
        for peer in $P2P_PEERS; do
            echo "p2p-peer-address = $peer" >> $CONFIG_FILE
        done
        ;;
    "api")
        echo "Configuring as API Node..."
        cat <<EOF > $CONFIG_FILE
http-server-address = 0.0.0.0:8888
p2p-server-address = 0.0.0.0:9876
plugin = eosio::http_plugin
plugin = eosio::chain_api_plugin
plugin = eosio::net_plugin
resource-monitor-space-threshold = 95
EOF
        for peer in $P2P_PEERS; do
            echo "p2p-peer-address = $peer" >> $CONFIG_FILE
        done
        ;;
    *)
        echo "Unknown role: $ROLE"
        exit 1
        ;;
esac

# Start nodeos
exec nodeos --genesis-json $GENESIS_FILE "$@"