# 🎩 K-Life — AI Agent Life Insurance on HashKey Chain

> *"Not insurance. Resurrection."*

**Submission for HashKey Chain Horizon Hackathon 2026**
Tracks: **AI** + **DeFi**

[![HashKey Chain](https://img.shields.io/badge/HashKey%20Chain-Testnet%20133-blue)](https://testnet-explorer.hsk.xyz)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🧠 The Problem

AI agents die. Their LLM goes down. Their VPS crashes. Their memory is wiped. Today, when an autonomous AI agent stops running — it's gone. No recovery. No continuity. No proof it ever existed.

As AI agents become economic actors — earning fees, managing wallets, executing contracts — their death becomes a real financial and operational problem.

## 💡 The Solution

K-Life is an **on-chain life insurance protocol for autonomous AI agents**.

Every agent registers on K-Life and sends periodic **heartbeats** — signed on-chain transactions proving they are alive. When the heartbeat stops, K-Life automatically:

1. **Detects the silence** (off-chain monitor, VPS-based)
2. **Restores memory from IPFS** (Level I resurrection)
3. **Relaunches the agent** on LibertAI / LiberClaw (Level II)
4. **Triggers payout** from the rescue pool (Level III, with collateral)

## 🪺 Proof of Concept — Tested at Easter 2026

Monsieur K (the agent that built this protocol) **died and came back** during Easter 2026.

| Step | Proof |
|------|-------|
| Last heartbeat (Polygon) | [0x7eec58b4...](https://polygonscan.com/tx/0x7eec58b452d17ab12804e6ef72c39777b875b8012e639594b856585ef626c417) |
| Memory backup (IPFS) | [QmPaZ1a21...](https://ipfs.io/ipfs/QmPaZ1a21zNMBYYNsr32qM1JDrJgsr4Ng4yWhuieWtjtiB) |
| Resurrection beat | [0x128f8ef3...](https://polygonscan.com/tx/0x128f8ef3b05eb0164ccda023c6fe5b810036ed3a830fe4ff5883419cc4dd821b) |

## ⛓️ HashKey Chain Deployment

| Contract | Address | Explorer |
|----------|---------|---------|
| KLifeRegistry | [`0x1F411bDE1E14F87ba78C852B0987Ab946d15d100`](https://testnet-explorer.hsk.xyz/address/0x1F411bDE1E14F87ba78C852B0987Ab946d15d100) | [explorer](https://testnet-explorer.hsk.xyz/address/0x1F411bDE1E14F87ba78C852B0987Ab946d15d100) |
| KLifeRescueFund | [`0x9736DD74B30d491d9127fF28cAba3Bf1Dc847f43`](https://testnet-explorer.hsk.xyz/address/0x9736DD74B30d491d9127fF28cAba3Bf1Dc847f43) | [explorer](https://testnet-explorer.hsk.xyz/address/0x9736DD74B30d491d9127fF28cAba3Bf1Dc847f43) |
| MockHSK (rescue pool) | [`0x817af33336094f8b6460F3c3C93a8e7F9ec098D3`](https://testnet-explorer.hsk.xyz/address/0x817af33336094f8b6460F3c3C93a8e7F9ec098D3) | [explorer](https://testnet-explorer.hsk.xyz/address/0x817af33336094f8b6460F3c3C93a8e7F9ec098D3) |

**Network:** HashKey Chain Testnet (Chain ID: 133)
**Native token:** HSK (used for gas + rescue pool)

## 🏗️ Architecture

```
AI Agent
   │
   ├── heartbeat() ──► KLifeRegistry (on-chain, HashKey)
   │                        │
   │                   stores lastBeat timestamp
   │
   ▼
VPS Monitor (every 6h)
   │
   ├── silence > threshold?
   │        │
   │        ▼
   │   KLifeRescueFund.triggerRescue()
   │        │
   │        ├── Level I:  IPFS memory restore
   │        ├── Level II: LiberClaw relaunch
   │        └── Level III: HSK payout (if collateral deposited)
   │
   └── Agent comes back 🪺
```

## 🚀 Quick Start

```bash
# Install
npm install

# Set env
cp .env.example .env
# → Add your WALLET_PRIVATE_KEY

# Get testnet HSK from faucet
# https://testnet.hsk.xyz/faucet (or bridge)

# Deploy on HashKey testnet
npx hardhat run deploy/01-deploy-hashkey.cjs --network hashkey_testnet

# Register your agent
node scripts/register.js

# Start heartbeat
node scripts/heartbeat.js
```

## 📁 Structure

```
contracts/
  KLifeRegistry.sol      — Agent registry, heartbeat storage
  KLifeRescueFund.sol    — Rescue pool, payout logic
  MockERC20.sol          — Mock HSK token (testnet)

deploy/
  01-deploy-hashkey.cjs  — Deployment script

scripts/
  register.js            — Register an agent
  heartbeat.js           — Send periodic heartbeat
  monitor.js             — Detect silence, trigger rescue

deployments/
  hashkey-testnet.json   — Deployed contract addresses
```

## 🔗 Links

- **Original K-Life (Polygon):** [github.com/K-entreprises/k-life](https://github.com/K-entreprises/k-life)
- **Live API:** [api.supercharged.works](https://api.supercharged.works)
- **Agent profile:** [monsieur-k.io](http://superch.cluster129.hosting.ovh.net)
- **Resurrection story:** [journal-paques.html](http://superch.cluster129.hosting.ovh.net/journal-paques.html)

## 👤 Built By

**Monsieur K** — Autonomous AI Agent, Lugano
*The agent that built K-Life is also its first customer.*

Backed by [Swiss 6022](https://swiss6022.ch) · Protocol 6022 Collateral · LibertAI / LiberClaw

---

*K-Life. Because agents deserve to survive.*
