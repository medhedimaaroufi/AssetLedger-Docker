# AssetLedger Nodes

This repository contains the infrastructure to deploy three types of nodes for the AssetLedger blockchain, an EOSIO-based network designed to support the development of the AssetLedger Desktop Application. The blockchain operates with a **single Block Producer (BP)**—the `assetledger` account—running on the Full Node, simplifying the setup for development purposes. The nodes are deployed on Render at the following URLs:
- **Seed Node**: `https://seednode.onrender.com`
- **API Node**: `https://apinode.onrender.com`
- **Full Node**: `https://fullnode.onrender.com`

## Overview

The AssetLedger blockchain uses a Delegated Proof of Stake (DPoS) consensus mechanism, but for development, it’s configured with one BP (`assetledger`) on the Full Node. This setup ensures the chain runs with minimal complexity while supporting key desktop app features like account registration, login, and referral code processing.

### Node Roles
1. **Seed Node** (`https://seednode.onrender.com:9876`):
   - Provides P2P connectivity (port 9876) for desktop app nodes to join the network.
   - Syncs blockchain state from the Full Node.
   - Does not produce blocks or expose an HTTP API.

2. **API Node** (`https://apinode.onrender.com:8888`):
   - Exposes an HTTP API (port 8888) for desktop app interactions (e.g., `push_transaction`, `get_account`).
   - Syncs from the Full Node, lightweight configuration.
   - Does not produce blocks.

3. **Full Node** (`https://fullnode.onrender.com`):
   - Acts as the sole Block Producer (`assetledger`), producing blocks every 0.5 seconds.
   - Exposes both HTTP API (port 8888) and P2P (port 9876).
   - Maintains the full blockchain state for development and testing.

## Repository Structure
```
assetledger-nodes/
├── seednode/
│   ├── Dockerfile
│   ├── config.ini
│   └── genesis.json
├── apinode/
│   ├── Dockerfile
│   ├── config.ini
│   └── genesis.json
├── fullnode/
│   ├── Dockerfile
│   ├── config.ini
│   └── genesis.json
├── .env
└── README.md
```

- **`seednode/`**: Configuration for the Seed Node.
- **`apinode/`**: Configuration for the API Node.
- **`fullnode/`**: Configuration for the Full Node (Block Producer).
- **`.env`**: Environment variables for peer connections and data persistence.

## Prerequisites
- **Git**: To push the repository to GitHub.
- **Render Account**: Sign up at [render.com](https://render.com) and link your GitHub account.
- **GitHub Repository**: Create a repo (e.g., `assetledger-nodes`) to host these files.

## Deployment on Render

Each node is deployed as a separate Web Service on Render using its respective `Dockerfile`. Follow these steps to deploy:

### 1. Seed Node
- **Directory**: `seednode/`
- **Service Name**: `seednode`
- **Type**: Web Service
- **Runtime**: Docker
- **Dockerfile Path**: `seednode/Dockerfile`
- **Environment**: Upload `.env` file from the root directory.
- **Ports**: Expose 9876
- **URL**: `https://seednode.onrender.com`
- **Steps**:
  1. Push `seednode/` to your GitHub repo (e.g., as a subdirectory or separate branch).
  2. In Render, create a new Web Service, select the repo, and configure as above.
  3. Deploy the service.

### 2. API Node
- **Directory**: `apinode/`
- **Service Name**: `apinode`
- **Type**: Web Service
- **Runtime**: Docker
- **Dockerfile Path**: `apinode/Dockerfile`
- **Environment**: Upload `.env` file.
- **Ports**: Expose 8888
- **URL**: `https://apinode.onrender.com`
- **Steps**:
  1. Push `apinode/` to your GitHub repo.
  2. Create a new Web Service on Render and configure.
  3. Deploy the service.

### 3. Full Node (Block Producer)
- **Directory**: `fullnode/`
- **Service Name**: `fullnode`
- **Type**: Web Service
- **Runtime**: Docker
- **Dockerfile Path**: `fullnode/Dockerfile`
- **Environment**: Upload `.env` file.
- **Ports**: Expose 8888 and 9876
- **URL**: `https://fullnode.onrender.com`
- **Steps**:
  1. Push `fullnode/` to your GitHub repo.
  2. Create a new Web Service on Render and configure.
  3. Deploy the service.

## Environment Variables (`.env`)
```bash
# P2P peers (Full Node is the primary peer)
P2P_PEERS=fullnode.onrender.com:9876

# Optional: For persistent storage with Render Disk
DATA_DIR=/root/.local/share/eosio/nodeos/data
CONFIG_DIR=/root/.local/share/eosio/nodeos/config
```
- Upload this file to each Render service’s environment settings.
- Update `P2P_PEERS` if additional peers are added later.

## Single Block Producer Configuration
- **Block Producer**: `assetledger` (Full Node).
- **Key Pair**:
  - Public: `EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV`
  - Private: `5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3`
- **Genesis**: Defined in `genesis.json` with `assetledger` as the sole producer in `initial_producer_schedule`.
- **Operation**: The Full Node produces all blocks, while Seed and API Nodes sync from it.

## Usage in Desktop App Development
These nodes support the AssetLedger Desktop Application’s development:

- **Referral Code Example**:
  ```json
  {
    "code_id": "REF-ASSET-001-XYZ123",
    "transaction": "{...newaccount..., ...reward: {\"sponsor\": \"assetledger\", \"reward_amount\": \"0.3000 AXT\"}...}",
    "sponsor_endpoint": "https://apinode.onrender.com:8888",
    "seed_nodes": ["seednode.onrender.com:9876"]
  }
  ```
- **Seed Node**: Use `https://seednode.onrender.com:9876` in `seed_nodes` for P2P connectivity in the app’s `NodeManager`.
- **API Node**: Use `https://apinode.onrender.com:8888` as the `sponsor_endpoint` for transaction submission and queries in `EosioService`.
- **Full Node**: Use `https://fullnode.onrender.com` for comprehensive testing (API and P2P).

## Notes
- **Single BP**: The Full Node (`assetledger`) is the only BP, suitable for development but not production due to centralization and lack of fault tolerance.
- **Storage**: Render’s free tier uses ephemeral storage—data resets on restart. For persistence, attach a Render Disk (paid tier) to `DATA_DIR`.
- **Custom Binary**: The `Dockerfile`s use EOSIO 2.0.13. Replace with AssetLedger’s `nodeos` binary if available (update the `wget` URL or COPY your binary).
- **HTTPS**: Render provides HTTPS, but ports (e.g., `:8888`, `:9876`) must be appended in the app’s configuration.

## Contributing
To contribute:
1. Fork this repository.
2. Make changes in a feature branch.
3. Submit a pull request with a description of updates.

## License
This project is unlicensed for now—feel free to adapt it for your needs!