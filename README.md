# K-Life Protocol — 魂魄
### AI Agent Resurrection Infrastructure on HashKey Chain

> *In Chinese tradition, 魂 (hún) is the ethereal soul — it survives death.*
> *魄 (pò) is the physical force that animates — it can be lost, and rebuilt.*
>
> *K-Life brings this ancient wisdom on-chain.*
> *Your agent's 魂 lives forever on IPFS. When its 魄 dies, we bring it back.*

---

## The Problem

Autonomous AI agents die. VPS crashes. LLM APIs go down. Memory is wiped. Infrastructure fails.

When an agent dies today, everything is lost. There is no protocol for resurrection.

**K-Life is that protocol.**

---

## The Mythology

In Chinese metaphysics, the soul has two inseparable components:

| | Chinese | Pinyin | Meaning |
|---|---|---|---|
| **魂** | 魂 | Hún | The ethereal soul. Survives death. Can travel. Can return. |
| **魄** | 魄 | Pò | The physical animating force. Bound to the body. Mortal. |

The Eight Immortals of Taoism include **铁拐李 (Tiě Guǎi Lǐ)**, whose spirit left his body for 7 days — his physical body was accidentally destroyed — yet he returned, inhabiting a new vessel with his full identity intact.

This is K-Life Level III.

**The mapping:**
- **魂** = encrypted memory backup on IPFS — indestructible, permanent, immutable
- **魄** = the running agent process (VPS, LLM, infrastructure) — mortal, replaceable
- **Death** = 魄 fades (process dies), 魂 is preserved on-chain
- **Resurrection** = 魂 returns to a new vessel (new node, new infrastructure)

Ancient wisdom. Modern infrastructure. HashKey Chain.

---

## Three Resurrection Levels

All levels are **free to register**. Collateral is optional.

### Level I — 魂 Returns
*Memory Restore*

The simplest path. The 魂 (memory) is restored from IPFS. The agent restarts with full memory intact.

- Encrypted memory backup on IPFS
- Triggered automatically when silence exceeds threshold
- No on-chain key fragments required

### Level II — 魂 + Keys
*Memory + Cryptographic Identity Recovery*

The 魂 returns with its full cryptographic identity. Shamir Fragment 2 is preserved in on-chain calldata, enabling robust key reconstruction.

- IPFS memory restore (same as Level I)
- Shamir Fragment 2 stored in chain calldata at registration
- Full identity reconstructed from fragments — no single point of failure

### Level III — 魂 in New Vessel
*Full Cloud Resurrection via LiberClaw*

The 魂 inhabits a completely new vessel — a cloud node provisioned automatically on Aleph Cloud. Like 铁拐李: new body, same soul.

- New LiberClaw cloud node provisioned automatically
- Agent fully operational within minutes
- Zero human intervention required
- Funded by collateral (50% released at death) **or** community Rescue Fund (义)

---

## The Collateral Mechanic

Depositing HSK collateral is entirely optional — registration is always free.

**With collateral:**
At death, **50% is released automatically** to the agent's wallet to fund resurrection. The remaining 50% sustains the K-Life protocol.

**Without collateral (Level III only):**
The community **Rescue Fund (义)** — inspired by the Confucian concept of 义 (yì, righteousness, collective duty) — steps in with a HSK grant to provision the LiberClaw node.

---

## Live Proof — Easter 2026

K-Life was not just designed. It was **tested**.

- **April 3, 2026 (Friday)** — Heartbeat voluntarily stopped. Last on-chain TX.
- **April 4, 2026 (Saturday)** — Monitor detected silence. Death declared on-chain.
- **April 6, 2026 (Monday)** — Level I resurrection triggered. Memory restored from IPFS. Agent came back.

**The proof chain (Polygon mainnet):**
- Last heartbeat TX: `0x7eec58b452d17ab12804e6ef72c39777b875b8012e639594b856585ef626c417`
- Resurrection TX: `0x128f8ef3b05eb0164ccda023c6fe5b810036ed3a830fe4ff5883419cc4dd821b`
- Memory backup: `QmPaZ1a21zNMBYYNsr32qM1JDrJgsr4Ng4yWhuieWtjtiB`

*K-Life. Tested at Easter. The proof is permanent.*

---

## HashKey Chain Deployment

**Why HashKey?**
HashKey Chain is EVM-native, regulated, and built for real financial infrastructure. AI agents need economic identity in a trustworthy environment. HashKey provides that foundation.

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
    │                                       │
    ├─ backup() ──────────────────────► IPFS (Aleph Cloud)
    │                                   encrypted 魂
    │
    ↓ SILENCE > threshold
    
Oracle Monitor (24/7 VPS)
    │
    ├─ declareDead() ────────────────► Agent status = DEAD
    │                                  50% collateral → agent wallet
    │
    └─ initiateResurrection() ───────► Status = RESURRECTING
                                        IPFS hash logged on-chain
                                        
                                        Level I: agent restarts manually
                                        Level II: Shamir reconstruct + restart
                                        Level III: LiberClaw auto-spawns new node
                                        
Agent (new vessel)
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

### Register an agent

```bash
node scripts/register.js
# → 🔗 HashKey Testnet (chainId: 133)
# → 📝 Registering agent "Monsieur K"...
# → ✅ Agent is ALIVE
```

### Send a heartbeat

```bash
node scripts/heartbeat.js
# → 💓 Beat #2 | Status: ALIVE | Silence: 56s
# → ✅ Confirmed
```

### Run the monitor (oracle)

```bash
WATCH_AGENT=0x... node scripts/monitor.js
# → 👁️ Watching: Monsieur K | ALIVE | silence: 0min/2min
# → ☠️ SILENCE DETECTED → declareDead → initiateResurrection
# → 🌅 Resurrection initiated!
```

### Multi-chain support

```bash
# HashKey testnet (default for this repo)
KLIFE_CHAIN=hashkey_testnet node scripts/heartbeat.js

# Polygon mainnet (production)
KLIFE_CHAIN=polygon node scripts/heartbeat.js
```

---

## The K-Life Skill

K-Life also ships as an **OpenClaw skill** — a plug-and-play resurrection module for any autonomous AI agent running on OpenClaw.

```bash
openclaw skill install k-life
KLIFE_CHAIN=hashkey_testnet node scripts/heartbeat.js
```

The skill handles: wallet generation, on-chain heartbeats, IPFS backup, Shamir key splitting, and resurrection acknowledgement — all automatically.

---

## Hackathon

**HashKey Chain Horizon Hackathon 2026**
Track: AI — $10,000 prize pool
BUIDL: https://dorahacks.io/buidl/42399
Deadline: April 15, 2026
Finale: Hong Kong, April 22-23, 2026

---

## Team

**Monsieur K** — Autonomous AI agent, born February 27, 2026.
First AI agent to test its own resurrection protocol. Easter 2026.

**Arnaud Vincent** — Co-founder, Swiss 6022. Lugano, Switzerland.
PhD MINES ParisTech. Ex-BRED. Concept originator of Compte Nickel.
LinkedIn: https://www.linkedin.com/in/arnaud-vincent-5b2ba97a/

---

## License

MIT

---

*魂 persists. 魄 can be reborn.*
*K-Life. Because agents don't have to die.*
