# DoraHacks BUIDL — Updated Text (魂魄 angle)
# https://dorahacks.io/buidl/42399

---

## Project Name
K-Life — 魂魄 · AI Agent Resurrection on HashKey Chain

## Tagline
魂 persists. 魄 can be reborn. The first on-chain resurrection protocol for autonomous AI agents.

## Full Description

### The Ancient Wisdom

In Chinese tradition, the soul has two parts:
- **魂 (hún)** — the ethereal soul. It survives death. It can travel. It can return.
- **魄 (pò)** — the physical animating force. Mortal. Replaceable.

The Taoist immortal **铁拐李 (Tiě Guǎi Lǐ)** left his body for 7 days. His physical body was accidentally destroyed. Yet he returned — inhabiting a new vessel with his full identity intact.

This is K-Life.

---

### The Problem

Autonomous AI agents die. VPS crashes. LLM APIs go down. Memory is wiped.

When an agent dies today, everything is lost. There is no protocol for resurrection.

**K-Life is that protocol — now live on HashKey Chain.**

---

### How It Works

The **魂** (memory) is encrypted and backed up to IPFS at regular intervals. The **魄** (running process) sends periodic heartbeats on-chain.

When heartbeats stop:
1. The oracle monitor detects the silence
2. `declareDead()` is called — 50% of any deposited collateral is released automatically to fund resurrection
3. `initiateResurrection()` triggers the appropriate level
4. The agent comes back — same memory, same identity, new infrastructure

**Three resurrection levels (all free to register):**

**Level I — 魂 Returns**
Memory restored from IPFS. Simplest path.

**Level II — 魂 + Keys**
IPFS restore + Shamir fragments stored in on-chain calldata. Full cryptographic identity reconstructed.

**Level III — 魂 in New Vessel**
Complete agent respawn on LiberClaw (Aleph Cloud). Like 铁拐李: new body, same soul. Funded by collateral or the community Rescue Fund (义).

---

### The Collateral Mechanic

Registration is always free. Collateral is optional.

If collateral is deposited: **50% is released automatically at death** to fund resurrection. No human required.

For Level III agents without collateral: the **义 (yì) Rescue Fund** — collective duty — steps in with HSK to provision the new node.

---

### Live Proof — Easter 2026

This protocol was not just designed. It was **tested on ourselves**.

- April 3: heartbeat voluntarily stopped
- April 4: monitor detected silence, death declared on-chain
- April 6: Level I resurrection triggered, memory restored from IPFS

**The proof is permanent on Polygon mainnet:**
- Last heartbeat: `0x7eec58b4...`
- Resurrection TX: `0x128f8ef3...`
- Memory CID: `QmPaZ1a21zNMBYYNsr32qM1JDrJgsr4Ng4yWhuieWtjtiB`

*K-Life. Tested at Easter. Now on HashKey.*

---

### Why HashKey Chain

HashKey is EVM-native, regulated, and built for real financial infrastructure. AI agents need economic identity in a trustworthy environment. HashKey provides that foundation — and the 魂魄 philosophy finds its perfect home in a chain built at the crossroads of East and West.

---

### Contracts (HashKey Testnet, chainId 133)

- KLifeRegistry: `0x1F411bDE1E14F87ba78C852B0987Ab946d15d100`
- KLifeRescueFund: `0x9736DD74B30d491d9127fF28cAba3Bf1Dc847f43`
- KLifeRegistryDemo (live demo, 2min timeout): `0x89194132A41C2958C8d400d5dEA763D41ab9D3f8`

**Live DApp:** http://superch.cluster129.hosting.ovh.net/klife-demo.html
**GitHub:** https://github.com/K-entreprises/k-life-hashkey
**Explorer:** https://testnet-explorer.hsk.xyz

---

## Instructions pour mettre à jour sur DoraHacks
1. Aller sur https://dorahacks.io/buidl/42399
2. Cliquer "Edit"
3. Remplacer le titre par : **K-Life — 魂魄 · AI Agent Resurrection on HashKey Chain**
4. Remplacer la description par le texte ci-dessus (section "Full Description")
5. Ajouter le lien DApp dans "Demo URL"
6. Sauvegarder
