#!/bin/bash
set -e

# Paths
CONFIG_DIR="/root/.local/share/eosio/nodeos/config"
DATA_DIR="/root/.local/share/eosio/nodeos/data"
CONFIG_FILE="$CONFIG_DIR/config.ini"

# Validate ROLE
if [ -z "$ROLE" ]; then
    echo "ROLE environment variable must be set to 'seed', 'api', or 'full'"
    exit 1
fi

# Base nodeos command
BASE_CMD="--data-dir $DATA_DIR --config-dir $CONFIG_DIR --genesis-json $CONFIG_DIR/genesis.json"

# Configure based on ROLE
case "$ROLE" in
    "seed")
        echo "Configuring as Seed Node..."
        cat <<EOF > $CONFIG_FILE
data-dir = $DATA_DIR
p2p-listen-endpoint = 0.0.0.0:9876
plugin = eosio::net_plugin
plugin = eosio::chain_plugin
p2p-peer-address = fullnode.onrender.com:9876
EOF
        NODEOS_CMD="$BASE_CMD --p2p-listen-endpoint 0.0.0.0:9876 --plugin eosio::net_plugin --plugin eosio::chain_plugin --p2p-peer-address ${P2P_PEERS}"
        ;;
    "api")
        echo "Configuring as API Node..."
        cat <<EOF > $CONFIG_FILE
data-dir = $DATA_DIR
http-server-address = 0.0.0.0:8888
plugin = eosio::http_plugin
plugin = eosio::chain_api_plugin
p2p-peer-address = fullnode.onrender.com:9876
EOF
        NODEOS_CMD="$BASE_CMD --http-server-address 0.0.0.0:8888 --plugin eosio::http_plugin --plugin eosio::chain_api_plugin --p2p-peer-address ${P2P_PEERS}"
        ;;
    "full")
        echo "Configuring as Full Node (Block Producer)..."
        cat <<EOF > $CONFIG_FILE
data-dir = $DATA_DIR
http-server-address = 0.0.0.0:8888
p2p-listen-endpoint = 0.0.0.0:9876
producer-name = assetledger
signature-provider = EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV=KEY:5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
plugin = eosio::chain_plugin
plugin = eosio::http_plugin
plugin = eosio::chain_api_plugin
plugin = eosio::net_plugin
plugin = eosio::producer_plugin
p2p-peer-address = seednode.onrender.com:9876
EOF
        NODEOS_CMD="$BASE_CMD --http-server-address 0.0.0.0:8888 --p2p-listen-endpoint 0.0.0.0:9876 --producer-name assetledger --signature-provider EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV=KEY:5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 --plugin eosio::chain_plugin --plugin eosio::http_plugin --plugin eosio::chain_api_plugin --plugin eosio::net_plugin --plugin eosio::producer_plugin --p2p-peer-address ${P2P_PEERS}"
        ;;
    *)
        echo "Invalid ROLE: $ROLE. Must be 'seed', 'api', or 'full'"
        exit 1
        ;;
esac

# Execute nodeos with the constructed command and additional arguments
exec /usr/bin/nodeos $NODEOS_CMD "$@"