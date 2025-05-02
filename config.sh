#!/bin/bash

# Configuration
NODEOS_ENDPOINT="http://localhost:8888"  # BP node endpoint
WALLET_HOST="localhost"
WALLET_PORT="8900"
CLEOS="cleos --url $NODEOS_ENDPOINT --wallet-url http://$WALLET_HOST:$WALLET_PORT"
CONTRACTS_DIR="/opt/assetledger/contracts"
BP_ACCOUNT="assetledger"
VALIDATOR_ACCOUNT="validator"
TOKEN_ACCOUNT="eosio.token"
SYSTEM_ACCOUNT="eosio"
GOVERNANCE_ACCOUNT="governance"
NFT_ACCOUNT="nftcontract"

# Start wallet
echo "Starting keosd..."
keosd --http-server-address $WALLET_HOST:$WALLET_PORT &
sleep 2

# Create wallet
echo "Creating wallet..."
$CLEOS wallet create --to-console | grep password | awk '{print $2}' > wallet_password.txt
WALLET_PASSWORD=$(cat wallet_password.txt)

# Import keys
echo "Importing keys..."
$CLEOS wallet import --private-key PRIVATE_KEY_HERE

# Deploy eosio.bios
echo "Deploying eosio.bios..."
$CLEOS set contract eosio $CONTRACTS_DIR/eosio.bios -p eosio

# Create accounts
echo "Creating accounts..."
$CLEOS system newaccount eosio $BP_ACCOUNT EOS8cEr7LxFxpAdptPHo1DTPUFs5bv7Ptb5t1FN8VW4VzmgoYhoCD --stake-net "1000.0000 SYS" --stake-cpu "1000.0000 SYS" --buy-ram-kbytes 8000 -p eosio
$CLEOS system newaccount eosio $VALIDATOR_ACCOUNT EOS8cEr7LxFxpAdptPHo1DTPUFs5bv7Ptb5t1FN8VW4VzmgoYhoCD --stake-net "1000.0000 SYS" --stake-cpu "1000.0000 SYS" --buy-ram-kbytes 8000 -p eosio
$CLEOS system newaccount eosio $TOKEN_ACCOUNT EOS8cEr7LxFxpAdptPHo1DTPUFs5bv7Ptb5t1FN8VW4VzmgoYhoCD --stake-net "1000.0000 SYS" --stake-cpu "1000.0000 SYS" --buy-ram-kbytes 8000 -p eosio
$CLEOS system newaccount eosio $GOVERNANCE_ACCOUNT EOS8cEr7LxFxpAdptPHo1DTPUFs5bv7Ptb5t1FN8VW4VzmgoYhoCD --stake-net "1000.0000 SYS" --stake-cpu "1000.0000 SYS" --buy-ram-kbytes 8000 -p eosio
$CLEOS system newaccount eosio $NFT_ACCOUNT EOS8cEr7LxFxpAdptPHo1DTPUFs5bv7Ptb5t1FN8VW4VzmgoYhoCD --stake-net "1000.0000 SYS" --stake-cpu "1000.0000 SYS" --buy-ram-kbytes 8000 -p eosio

# Deploy contracts
echo "Deploying eosio.token..."
$CLEOS set contract $TOKEN_ACCOUNT $CONTRACTS_DIR/eosio.token -p $TOKEN_ACCOUNT
$CLEOS push action $TOKEN_ACCOUNT create '[ "eosio", "1000000000.0000 AXT" ]' -p $TOKEN_ACCOUNT

echo "Deploying eosio.system..."
$CLEOS set contract $SYSTEM_ACCOUNT $CONTRACTS_DIR/eosio.system -p $SYSTEM_ACCOUNT

echo "Deploying nodegovern..."
$CLEOS set contract $GOVERNANCE_ACCOUNT $CONTRACTS_DIR/governance -p $GOVERNANCE_ACCOUNT

echo "Deploying nftcontract..."
$CLEOS set contract $NFT_ACCOUNT $CONTRACTS_DIR/nft_contract -p $NFT_ACCOUNT

# Initialize system
echo "Initializing system..."
$CLEOS push action eosio init '[]' -p eosio
$CLEOS system regproducer $BP_ACCOUNT EOS8cEr7LxFxpAdptPHo1DTPUFs5bv7Ptb5t1FN8VW4VzmgoYhoCD -p $BP_ACCOUNT
$CLEOS system voteproducer prods $BP_ACCOUNT [$BP_ACCOUNT] -p $BP_ACCOUNT

# Register validator node
echo "Registering validator node..."
$CLEOS push action $GOVERNANCE_ACCOUNT regnode '["validator", "validator", "full"]' -p $VALIDATOR_ACCOUNT

# Create AXT for testing
echo "Issuing AXT..."
$CLEOS push action $TOKEN_ACCOUNT issue '[ "eosio", "1000000.0000 AXT", "initial issuance" ]' -p $TOKEN_ACCOUNT
$CLEOS push action $TOKEN_ACCOUNT transfer '[ "eosio", "assetledger", "500000.0000 AXT", "fund BP" ]' -p $TOKEN_ACCOUNT
$CLEOS push action $TOKEN_ACCOUNT transfer '[ "eosio", "validator", "500000.0000 AXT", "fund validator" ]' -p $TOKEN_ACCOUNT

# Test NFT creation
echo "Creating NFT collection..."
$CLEOS push action $NFT_ACCOUNT createcol '[ "nftcontract", "gaming_collection", "Gaming", "{\"type\": \"weapon\"}" ]' -p $NFT_ACCOUNT
$CLEOS push action $NFT_ACCOUNT create '[ "nftcontract", "gaming_collection", 1, "{\"name\": \"Sword\"}" ]' -p $NFT_ACCOUNT
$CLEOS push action $NFT_ACCOUNT issue '[ "nftcontract", "gaming_collection", 1, "assetledger", "initial issuance" ]' -p $NFT_ACCOUNT

echo "Testnet configuration complete!"