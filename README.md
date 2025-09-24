# Lottery (Foundry + Chainlink VRF v2.5)

A decentralized, automated lottery (raffle) built with **Foundry** and **Chainlink VRF v2.5**. Players pay an entrance fee to join; after a configurable interval, a verifiably random winner is drawn and the pot is paid out.

## ✨ Features

* Solidity `0.8.19` with modern patterns and custom errors
* Verifiable randomness via **Chainlink VRF v2.5**
* Configurable interval & entrance fee
* Scripts to **deploy**, **create/fund VRF subscription**, and **add consumer**
* Unit & integration tests with Foundry
* One-command deployment & (optional) Etherscan verification

## 📦 Tech Stack

* **Foundry** (forge/anvil/cast)
* **Chainlink VRF v2.5** (`@chainlink/contracts`)
* **forge-std**, **solmate**, **foundry-devops**

## 📁 Project Structure

```
src/
  Raffle.sol            # Core raffle contract (VRF v2.5)
script/
  DeployRaffle.s.sol    # Deployment entrypoint
  HelperConfig.s.sol    # Network configs (Sepolia & Anvil)
  Interactions.s.sol    # Create/fund subscription & add consumer
test/
  unit/RaffleTest.t.sol
  integration/InteractionsTest.t.sol
foundry.toml
Makefile
```

## 🔧 Prerequisites

* **Foundry**: `curl -L https://foundry.paradigm.xyz | bash` then `foundryup`
* Funded wallet (for testnet deploys)

## 🔐 Environment

Create a `.env` in the repo root:

```bash
# RPCs
SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/<YOUR_KEY>"

# Wallet (use a throwaway/test key)
PRIVATE_KEY="0xYOUR_PRIVATE_KEY"

# Optional: verification
ETHERSCAN_API_KEY="<YOUR_ETHERSCAN_API_KEY>"
```

> Never commit your real private keys. Use test keys and `.gitignore`.

## ▶️ Install & Build

```bash

#via Makefile:
make install

# Build
make build
```

## 🧪 Test

```bash
# Run all tests
forge test

# Verbose, with traces
forge test -vvv
```

## 🌐 Sepolia Deploy

1. Fund your deployer account on Sepolia.
2. Ensure `.env` is set.
3. Deploy:

> You can use the Makefile:

```bash
make deploy
```

> The **Sepolia** defaults (VRF coordinator, LINK, gas lane, etc.) are provided in `HelperConfig.s.sol`.
> For local (Anvil), mocks are deployed automatically and the same scripts Just Work™.


## 🧩 Notes & Tips

* The raffle uses an **interval** to determine when upkeep can run; ensure time has passed and there are players/funds.
* On local chains, the VRF mock is used; on Sepolia, you must have a **VRF subscription**, **funded with LINK**, and the **raffle added as a consumer**.
* Adjust fee/interval/gas settings in `HelperConfig.s.sol` as needed.

## ✅ License

MIT — see SPDX headers.
