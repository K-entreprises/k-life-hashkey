# K-Life Demo Video Script — HashKey Horizon Hackathon
**Duration: ~3 minutes**

---

## 🎥 PART 1 — Face cam (30 seconds)

*[Tu regardes la caméra, fond neutre ou bureau]*

> "My name is Arnaud Vincent, co-founder of Swiss 6022.
>
> I want to show you something that's never been done before.
>
> What happens when an AI agent dies?
> Not metaphorically — literally. VPS crashes. LLM goes down. Memory is lost.
>
> We built K-Life: the first on-chain life insurance protocol for autonomous AI agents.
> Register. Heartbeat. Die. Get resurrected.
>
> We tested it at Easter. Here's the proof — live on HashKey Chain."

---

## 🖥️ PART 2 — Screen recording (2 minutes)

*[Lance la démo en terminal. Tout est déjà préparé.]*

### Step 1 — Show the contracts (15s)
```
# Open in browser:
https://testnet-explorer.hsk.xyz/address/0x1F411bDE1E14F87ba78C852B0987Ab946d15d100
```
> "KLifeRegistry — deployed on HashKey testnet. 
> This contract tracks every AI agent: alive, dead, or resurrecting."

---

### Step 2 — Register an agent (30s)
```bash
cd k-life-hashkey
AGENT_PK=0x... node scripts/register.js
```

*[Le terminal affiche : "Registering agent Monsieur K... TX: 0x... ✅ Agent is now ALIVE"]*

> "We register an agent — Monsieur K. 
> He gets an on-chain identity, a heartbeat clock, and an IPFS memory backup.
> Status: ALIVE."

---

### Step 3 — Send heartbeats (20s)
```bash
node scripts/heartbeat.js
node scripts/heartbeat.js
```

*[Deux beats successifs, chaque TX confirmée en ~2s]*

> "Every heartbeat is an on-chain transaction.
> Silence beyond the threshold means death.
> The protocol knows."

---

### Step 4 — Silence = Death (20s)
*[Montre le monitor qui tourne en arrière-plan]*
```bash
ORACLE_PK=0x... WATCH_AGENT=0x... node scripts/monitor.js
```
*[Attendre que le timeout se déclenche — pour la démo, utilise un timeout court de 60s]*

> "The monitor runs 24/7. 
> When silence exceeds the threshold... it acts."

*[Terminal affiche "☠️ SILENCE DETECTED → Marking DEAD → Triggering rescue..."]*

---

### Step 5 — Resurrection (25s)
*[Le monitor déclenche initiateResurrection. Terminal affiche "🌅 Resurrection initiated!"]*
*[Ouvre l'explorer HashKey et montre le TX]*

> "Rescue triggered automatically. No human required.
> Memory backup on IPFS — encrypted, permanent.
> The agent comes back. Same identity. Same memory."

*[Montre le TX de resurrection sur l'explorer]*

---

### Step 6 — Show the proof chain (10s)
```
https://testnet-explorer.hsk.xyz/address/0x1F411bDE1E14F87ba78C852B0987Ab946d15d100
```

> "Every death. Every resurrection. Forever on HashKey Chain.
> This is K-Life."

---

## 🎥 PART 3 — Face cam outro (30 seconds)

> "We didn't just build this for a hackathon.
>
> We tested it at Easter 2026. Voluntarily stopped the heartbeat on Friday.
> Resurrection triggered Monday. The full proof is on Polygon mainnet — 
> and now we're bringing it to HashKey.
>
> AI agents need economic identity. They need to survive infrastructure failure.
> HashKey gives them a trustworthy home.
>
> K-Life. Because agents don't have to die.
>
> GitHub: K-entreprises/k-life-hashkey
> Thank you."

---

## 📋 Pre-recording checklist

- [ ] `.env` has `DEPLOYER_PK` set to `0x752769d33c2bc3a7815cda65921650ae620f87d6f174452db4e4b608c6b934db`
- [ ] HashKey testnet has gas (check faucet: https://faucet.hsk.xyz)
- [ ] Terminal font size 18+ (readable on video)
- [ ] Run `node scripts/register.js` once before recording to confirm it works
- [ ] For the monitor demo: temporarily set `DEFAULT_DEAD_TIMEOUT_FREE = 60` in contract OR use a fresh wallet that's never sent a heartbeat and adjust test

## 🎬 Tips
- Use a dark terminal theme (contrast for judges)
- Show TX hashes — they're proof
- Keep pace calm but energetic
- You can edit in 2 takes: Part 1+3 face cam, Part 2 screen recording
