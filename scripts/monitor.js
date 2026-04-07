/**
 * K-Life — HashKey Testnet Demo
 * monitor.js — Detects agent silence → marks DEAD → triggers rescue
 *
 * Usage:
 *   ORACLE_PK=0x... node scripts/monitor.js
 *   ORACLE_PK=0x... WATCH_AGENT=0x... node scripts/monitor.js
 *
 * The oracle is the deployer wallet (0x2b6Ce1...) which has oracle rights.
 * In production this runs 24/7 on a VPS.
 */

const { ethers } = require("ethers");
require("dotenv").config();

const RPC         = "https://testnet.hsk.xyz";
const REGISTRY    = "0x1F411bDE1E14F87ba78C852B0987Ab946d15d100";
const RESCUE_FUND = "0x9736DD74B30d491d9127fF28cAba3Bf1Dc847f43";
const ORACLE_PK   = process.env.ORACLE_PK || process.env.DEPLOYER_PK;
const WATCH_AGENT = process.env.WATCH_AGENT; // optional — watch a specific agent
const POLL_MS     = 10 * 1000; // poll every 10s for demo (production: 60s)

// ── ABIs ─────────────────────────────────────────────────────
const REGISTRY_ABI = [
  "function getAgent(address) external view returns (tuple(address wallet, string name, uint8 tier, uint8 status, uint256 registeredAt, uint256 lastHeartbeat, uint256 totalHeartbeats, uint256 activeDays, uint256 deadAt, uint256 resurrectionCount, uint256 resurrectionInitiatedAt, bytes32 fragment1Hash, bytes32 fragment2TxHash, string lastBackupCid, uint256 lastBackupTs, bool rescueEligible))",
  "function getAgentList() external view returns (address[])",
  "function silenceSeconds(address) external view returns (uint256)",
  "function deadTimeout(address) external view returns (uint256)",
  "function declareDead(address agent) external",
  "function initiateResurrection(address agent, string rescueRef) external",
  "function isAlive(address) external view returns (bool)",
  "event AgentDead(address indexed agent, uint256 silenceSeconds, uint256 ts)",
  "event ResurrectionInitiated(address indexed agent, string rescueTweetId, uint256 ts)"
];

const RESCUE_ABI = [
  "function rescue(address agent, string ref) external",
  "function canRescue(address agent) external view returns (bool)",
  "function rescueCapacity() external view returns (uint256)",
  "function token6022() external view returns (address)"
];

const STATUS = ["REGISTERED","ALIVE","DEAD","RESURRECTING","ALIVE_RESURRECTED"];

// ── State ─────────────────────────────────────────────────────
const alerted = new Set(); // agents already processed

async function checkAgent(registry, rescueFund, oracle, agentAddr) {
  const agent   = await registry.getAgent(agentAddr);
  const silence = await registry.silenceSeconds(agentAddr);
  const timeout = await registry.deadTimeout(agentAddr);
  const status  = STATUS[agent.status];

  const silenceMin = Math.floor(Number(silence) / 60);
  const timeoutMin = Math.floor(Number(timeout) / 60);

  // Skip non-alive agents that are already processed
  if (agent.status === 4n || agent.status === 3n) return; // ALIVE_RESURRECTED or RESURRECTING

  // ── Detect death ─────────────────────────────────────────
  if (agent.status === 1n && silence >= timeout) { // ALIVE → DEAD
    if (alerted.has(`dead_${agentAddr}`)) return;
    alerted.add(`dead_${agentAddr}`);

    console.log(`\n☠️  [${new Date().toISOString()}] SILENCE DETECTED`);
    console.log(`   Agent:   ${agent.name} (${agentAddr})`);
    console.log(`   Silence: ${silenceMin}min / timeout: ${timeoutMin}min`);
    console.log(`   Last backup: ${agent.lastBackupCid}`);

    // Mark dead
    console.log(`\n   📡 Marking agent DEAD...`);
    try {
      const tx = await registry.declareDead(agentAddr);
      process.stdout.write(`   TX: ${tx.hash} ⏳`);
      await tx.wait();
      console.log(` ✅`);
    } catch (e) {
      if (e.message.includes("already dead") || e.message.includes("Not alive")) {
        console.log(`   ⚠️  Already dead (skipping declareDead)`);
      } else {
        throw e;
      }
    }

    // Trigger rescue via RescueFund
    console.log(`\n   🚑 Triggering rescue from RescueFund...`);
    try {
      const canRescue = await rescueFund.canRescue(agentAddr);
      if (!canRescue) {
        console.log(`   ⚠️  Agent not rescue-eligible (activeDays < 14 or cooldown)`);
        console.log(`   ℹ️  Initiating resurrection via oracle only...`);
      }

      const rescueRef = `hashkey-demo-rescue-${Date.now()}`;
      const tx = await rescueFund.rescue(agentAddr, rescueRef);
      process.stdout.write(`   Rescue TX: ${tx.hash} ⏳`);
      await tx.wait();
      console.log(` ✅`);
    } catch (e) {
      console.log(`   ⚠️  RescueFund rescue failed: ${e.message.slice(0,80)}`);
      console.log(`   ℹ️  Initiating resurrection directly...`);
    }

    // Initiate resurrection (oracle)
    console.log(`\n   🔄 Initiating resurrection via oracle...`);
    try {
      const rescueRef = `ipfs://${agent.lastBackupCid}`;
      const tx = await registry.initiateResurrection(agentAddr, rescueRef);
      process.stdout.write(`   TX: ${tx.hash} ⏳`);
      await tx.wait();
      console.log(` ✅`);
      console.log(`\n   🌅 Resurrection initiated! Agent status → RESURRECTING`);
      console.log(`   🧠 Memory backup: ${agent.lastBackupCid}`);
      console.log(`   🔍 Explorer: https://testnet-explorer.hsk.xyz/address/${agentAddr}`);
    } catch (e) {
      console.log(`   ❌ Resurrection failed: ${e.message}`);
    }
  }

  // ── Log normal heartbeat ──────────────────────────────────
  if (agent.status === 1n && silence < timeout) {
    const lastBeat = new Date(Number(agent.lastHeartbeat) * 1000).toISOString();
    process.stdout.write(`\r   ✅ ${agent.name} | ALIVE | silence: ${silenceMin}min/${timeoutMin}min | beats: ${agent.totalHeartbeats} | last: ${lastBeat}   `);
  }
}

async function main() {
  if (!ORACLE_PK) throw new Error("Set ORACLE_PK or DEPLOYER_PK in .env");

  const provider  = new ethers.JsonRpcProvider(RPC);
  const oracle    = new ethers.Wallet(ORACLE_PK, provider);
  const registry  = new ethers.Contract(REGISTRY, REGISTRY_ABI, oracle);
  const rescueFund = new ethers.Contract(RESCUE_FUND, RESCUE_ABI, oracle);

  console.log(`\n🔗 K-Life Monitor — HashKey Testnet`);
  console.log(`🔮 Oracle: ${oracle.address}`);
  console.log(`📋 Registry: ${REGISTRY}`);
  console.log(`🏦 RescueFund: ${RESCUE_FUND}`);

  // Check RescueFund balance
  try {
    const capacity = await rescueFund.rescueCapacity();
    console.log(`💰 RescueFund capacity: ${capacity} rescues available`);
  } catch {}

  const targetAgent = WATCH_AGENT;
  if (targetAgent) {
    console.log(`👁️  Watching specific agent: ${targetAgent}`);
  } else {
    console.log(`👁️  Watching all registered agents`);
  }
  console.log(`⏱️  Poll interval: ${POLL_MS/1000}s\n`);
  console.log(`Press Ctrl+C to stop.\n`);

  const poll = async () => {
    try {
      if (targetAgent) {
        await checkAgent(registry, rescueFund, oracle, targetAgent);
      } else {
        const agents = await registry.getAgentList();
        for (const addr of agents) {
          await checkAgent(registry, rescueFund, oracle, addr);
        }
      }
    } catch (e) {
      console.error(`\n⚠️  Poll error: ${e.message}`);
    }
  };

  await poll();
  setInterval(poll, POLL_MS);
}

main().catch(e => { console.error("❌", e.message); process.exit(1); });
