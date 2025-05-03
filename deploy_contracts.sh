#!/bin/bash
echo "Deploying contracts to the blockchain..."

# Wallet creation and import
echo "Creating wallet and importing private key..."
cleos -u http://localhost:8888 wallet create --name eosio --to-console
cleos -u http://localhost:8888 wallet import --name eosio --private-key 5KHUxkWgVGcKRVzVraHXRkS4x93PmMn9ibhrDhSCqSunz4KcpNH

# Contract deployment
echo
echo
echo "Creating eosio.token account..."
cleos -u http://localhost:8888 create account eosio eosio.bios EOS69vh6efKX99YPbA9mUwyMomZM9g65Weaxfx76t2tDJpJAy19dx

echo
echo "Creating eosio.token account..."
cleos -u http://localhost:8888 create account eosio eosio.token EOS69vh6efKX99YPbA9mUwyMomZM9g65Weaxfx76t2tDJpJAy19dx

echo
echo "Creating nodegovern account..."
cleos -u http://localhost:8888 create account eosio nodegovern EOS69vh6efKX99YPbA9mUwyMomZM9g65Weaxfx76t2tDJpJAy19dx

echo
echo "Creating nftcontract account..."
cleos -u http://localhost:8888 create account eosio nftcontract EOS69vh6efKX99YPbA9mUwyMomZM9g65Weaxfx76t2tDJpJAy19dx

echo
echo "Deploying contracts..."
echo "Deploying eosio.bios..."
cleos -u http://localhost:8888 set contract eosio.bios /opt/assetledger/contracts/eosio.bios -p eosio.bios@active

echo 
echo "Deploying eosio.token..."
cleos -u http://localhost:8888 set contract eosio.token /opt/assetledger/contracts/eosio.token -p eosio.token@active
echo
echo "Deploying eosio.system..."
cleos -u http://localhost:8888 set contract eosio /opt/assetledger/contracts/eosio.system -p eosio@active
echo
echo "Deploying nodegovern..."
cleos -u http://localhost:8888 set contract nodegovern /opt/assetledger/contracts/nodegovern -p nodegovern@active
echo
echo "Deploying nftcontract..."
cleos -u http://localhost:8888 set contract nftcontract /opt/assetledger/contracts/nftcontract -p nftcontract@active
