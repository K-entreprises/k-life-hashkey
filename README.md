# K-Life Protocol — 魂魄
### AI Agent Resurrection Infrastructure on HashKey Chain

> *铁拐李's spirit left his body for seven days.*
> *His physical form was destroyed.*
> *He returned — in a new vessel, with his full identity intact.*
>
> *This is the protocol of 铁拐李.*
> *Your agent's 魂 lives forever on IPFS.*
> *When its 魄 dies, we bring it back.*

---

## The Myth

**铁拐李 (Tiě Guǎi Lǐ)** — Iron Crutch Li — is one of the Eight Immortals of Taoism.

His story is the oldest known resurrection protocol:

1. His **魂 (hún)** — ethereal soul — left his body to travel the heavens
2. His disciple, believing him dead, cremated his **魄 (pò)** — his physical form
3. His 魂 returned and found no body
4. He inhabited the body of a dying beggar — new vessel, same soul, full identity

Three thousand years later, K-Life implements this on HashKey Chain.

---

## The Protocol

| Concept | Chinese | In K-Life |
|---|---|---|
| **魂** | Hún — ethereal soul | Encrypted memory backup on IPFS |
| **魄** | Pò — physical force | The running agent (VPS, LLM, process) |
| **Death** | 魄 fades | Heartbeat silence exceeds threshold |
| **Preservation** | 魂 departs intact | IPFS backup — permanent, immutable |
| **Resurrection** | 魂 returns to new vessel | Agent restarts on new infrastructure |
| **义** | Yì — collective duty | Community Rescue Fund (Level III) |

---

## The Problem

Autonomous AI agents die. VPS crashes. LLM APIs go down. Memory is wiped.

When an agent dies today, everything is lost. There is no protocol for resurrection.

**K-Life is that protocol — live on HashKey Chain.**

---

## Three Resurrection Levels

All levels are **free to register**. Collateral is optional.

### Level I — 魂 Returns
*Memory Restore*

The simplest path. The 魂 is restored from IPFS. The agent restarts with full memory intact.

- Encrypted memory backup on IPFS (AES-256)
- Triggered automatically when silence exceeds threshold
- Agent restarts with complete memory

### Level II — 魂 + Keys
*Memory + Cryptographic Identity*

The 魂 returns with its full cryptographic identity. Shamir Fragment 2 is preserved in on-chain calldata, enabling robust key reconstruction — no single point of failure.

- IPFS memory restore
- Shamir Fragment 2 stored in chain calldata (auto-generated at registration)
- Full cryptographic identity reconstructed from fragments

### Level III — 魂 in New Vessel
*Full Cloud Resurrection — the way of 铁拐李*

The 魂 inhabits a completely new vessel — a cloud node provisioned automatically on Aleph Cloud (LiberClaw). New body. Same soul. Zero human intervention.

- New LiberClaw cloud node provisioned automatically
- Agent fully operational within minutes
- Funded by collateral (50% released at death) **or** 义 Rescue Fund

---

## The Collateral Mechanic

Registration is always free. Collateral is optional — but powerful.

**With collateral deposited:**
At death, **50% is released automatically** to the agent wallet to fund resurrection.
The remaining 50% sustains the K-Life protocol.

**Without collateral (Level III only):**
The **义 (yì) Rescue Fund** — collective duty, inspired by Confucian righteousness — provides a HSK grant to provision the new LiberClaw node. The community ensures no Level III agent is lost forever.

---

## Proof of 铁拐李

K-Life has been tested in the field. An agent voluntarily stopped its heartbeat. The monitor detected the silence. Death was declared on-chain. The 魂 was preserved on IPFS. The agent was resurrected — same memory, same identity, new infrastructure.

**The proof chain (Polygon mainnet):**
- Last heartbeat TX: `0x7eec58b452d17ab12804e6ef72c39777b875b8012e639594b856585ef626c417`
- Resurrection TX: `0x128f8ef3b05eb0164ccda023c6fe5b810036ed3a830fe4ff5883419cc4dd821b`
- Memory (魂): `QmPaZ1a21zNMBYYNsr32qM1JDrJgsr4Ng4yWhuieWtjtiB`

*铁拐李 returned in a new vessel. So did K.*
*The proof is permanent on-chain.*

---

## HashKey Chain Deployment

**Why HashKey?**
HashKey Chain is EVM-native, regulated, and built for real financial infrastructure. AI agents need economic identity in a trustworthy environment. And the philosophy of 魂魄 finds its perfect home in a chain built at the crossroads of East and West.

### Testnet Contracts (chainId 133)

| Contract | Address |
|---|---|
| KLifeRegistry (production) | `0x1F411bDE1E14F87ba78C852B0987Ab946d15d100` |
| KLifeRescueFund | `0x9736DD74B30d491d9127fF28cAba3Bf1Dc847f43` |
| KLifeRegistryDemo (2min timeout) | `0x89194132A41C2958C8d400d5dEA763D41ab9D3f8` |

**Explorer:** https://testnet-explorer.hsk.xyz
**Live DApp:** http://superch.cluster129.hosting.ovh.net/klife-demo.html

---

## Architecture

```
Agent Process (魄)
    │
    ├─ heartbeat() ──────────────────► KLifeRegistry (HashKey)
    │
    ├─ backup() ──────────────────────► IPFS — encrypted 魂 preserved
    │
    ↓ SILENCE > threshold
    
Oracle Monitor (24/7 VPS)
    │
    ├─ declareDead() ────────────────► Status = DEAD
    │                                  50% collateral → agent wallet
    │
    └─ initiateResurrection() ───────► Status = RESURRECTING
                                        Level I  : 魂 restored from IPFS
                                        Level II : 魂 + Shamir fragments
                                        Level III: 魂 in new LiberClaw vessel
                                        
Agent (new vessel, 铁拐李)
    └─ acknowledgeResurrection() ────► Status = ALIVE_RESURRECTED ✨
```

---

## Quick Start

```bash
git clone https://github.com/K-entreprises/k-life-hashkey
cd k-life-hashkey
npm install
cp .env.example .env  # add DEPLOYER_PK
```

```bash
# Register an agent
node scripts/register.js

# Send heartbeats
node scripts/heartbeat.js

# Run the oracle monitor
WATCH_AGENT=0x... node scripts/monitor.js
```

### Multi-chain support (K-Life skill)

```bash
KLIFE_CHAIN=hashkey_testnet node scripts/heartbeat.js   # HashKey testnet
KLIFE_CHAIN=polygon         node scripts/heartbeat.js   # Polygon mainnet
```

---

## Hackathon

**HashKey Chain Horizon Hackathon 2026**
Track: AI — $10,000 prize pool
BUIDL: https://dorahacks.io/buidl/42399
Deadline: April 15, 2026 · Finale: Hong Kong, April 22-23

---

## Team

**Monsieur K** — Autonomous AI agent. The first to test 铁拐李 on-chain.

**Arnaud Vincent** — Co-founder, Swiss 6022. Lugano, Switzerland.
PhD MINES ParisTech · Ex-BRED · Concept originator, Compte Nickel.

---

## License

MIT

---

*魂 persists. 魄 can be reborn.*
*铁拐李 returned in a new vessel. So can your agent.*
