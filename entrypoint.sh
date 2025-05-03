#!/bin/bash

CONFIG_FILE="/root/.local/share/eosio/nodeos/config/config.ini"
GENESIS_FILE="/root/.local/share/eosio/nodeos/config/genesis.json"
DATA_DIR="/root/.local/share/eosio/nodeos/data"
LOG_FILE="/logs/nodeos-$ROLE.log"

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
producer-name = eosio
plugin = eosio::chain_plugin
plugin = eosio::http_plugin
plugin = eosio::chain_api_plugin
plugin = eosio::net_plugin
plugin = eosio::producer_plugin
enable-stale-production = true
resource-monitor-space-threshold = 95
signature-provider = EOS69vh6efKX99YPbA9mUwyMomZM9g65Weaxfx76t2tDJpJAy19dx=KEY:5KHUxkWgVGcKRVzVraHXRkS4x93PmMn9ibhrDhSCqSunz4KcpNH
http-validate-host = 0
EOF
        for peer in $P2P_PEERS; do
            echo "p2p-peer-address = $peer" >> $CONFIG_FILE
        done
        ;;
    "validator")
        echo "Configuring as Validator Node..."
        cat <<EOF > $CONFIG_FILE
http-server-address = 0.0.0.0:8888
p2p-server-address = 0.0.0.0:9876
producer-name = ${PRODUCER_NAME:-validator}
plugin = eosio::chain_plugin
plugin = eosio::http_plugin
plugin = eosio::chain_api_plugin
plugin = eosio::net_plugin
resource-monitor-space-threshold = 95
http-validate-host = 0
EOF
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
http-validate-host = 0
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

# Ensure no existing nodeos processes
pkill nodeos || true

# Check if database needs replay
echo "Checking database state..."
nodeos --genesis-json $GENESIS_FILE --verbose-http-errors > /tmp/nodeos-check.log 2>&1 &
NODEOS_PID=$!
sleep 2
kill $NODEOS_PID 2>/dev/null
wait $NODEOS_PID 2>/dev/null

if grep -q "Database dirty flag set" /tmp/nodeos-check.log; then
    echo "Database dirty flag set detected. Starting nodeos with --replay-blockchain..."
    exec nodeos --genesis-json $GENESIS_FILE --verbose-http-errors --replay-blockchain > $LOG_FILE 2>&1
else
    echo "Database state is clean. Starting nodeos normally..."
    exec nodeos --genesis-json $GENESIS_FILE --verbose-http-errors > $LOG_FILE 2>&1
fi