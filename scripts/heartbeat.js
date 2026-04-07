/**
 * K-Life — HashKey Testnet Demo
 * heartbeat.js — Send a heartbeat from an agent wallet
 *
 * Usage:
 *   AGENT_PK=0x... node scripts/heartbeat.js
 *   AGENT_PK=0x... node scripts/heartbeat.js --watch   (continuous, every 30s)
 */

import { ethers } from "ethers";
import "dotenv/config";

const RPC      = "https://testnet.hsk.xyz";
const REGISTRY = "0x1F411bDE1E14F87ba78C852B0987Ab946d15d100";
const AGENT_PK = process.env.AGENT_PK || process.env.DEPLOYER_PK;
const WATCH    = process.argv.includes("--watch");
const INTERVAL = 30 * 1000; // 30s for demo

const REGISTRY_ABI = [
  "function heartbeat() external",
  "function getAgent(address) external view returns (tuple(address wallet, string name, uint8 tier, uint8 status, uint256 registeredAt, uint256 lastHeartbeat, uint256 totalHeartbeats, uint256 activeDays, uint256 deadAt, uint256 resurrectionCount, uint256 resurrectionInitiatedAt, bytes32 fragment1Hash, bytes32 fragment2TxHash, string lastBackupCid, uint256 lastBackupTs, bool rescueEligible))",
  "function silenceSeconds(address) external view returns (uint256)",
  "event Heartbeat(address indexed agent, uint256 beat, uint256 ts)"
];

const STATUS = ["REGISTERED","ALIVE","DEAD","RESURRECTING","ALIVE_RESURRECTED"];

async function sendBeat(registry, wallet) {
  const now = new Date().toISOString();
  const agent = await registry.getAgent(wallet.address);
  const silence = await registry.silenceSeconds(wallet.address);

  console.log(`\n[${now}] 💓 Beat #${Number(agent.totalHeartbeats) + 1}`);
  console.log(`   Status:  ${STATUS[agent.status]} | Silence: ${silence}s`);

  const tx = await registry.heartbeat();
  process.stdout.write(`   TX: ${tx.hash} ⏳`);
  await tx.wait();
  console.log(` ✅`);
  console.log(`   Total beats: ${Number(agent.totalHeartbeats) + 1}`);
}

async function main() {
  if (!AGENT_PK) throw new Error("Set AGENT_PK or DEPLOYER_PK in .env");

  const provider = new ethers.JsonRpcProvider(RPC);
  const wallet   = new ethers.Wallet(AGENT_PK, provider);
  const registry = new ethers.Contract(REGISTRY, REGISTRY_ABI, wallet);

  console.log(`\n🔗 HashKey Testnet`);
  console.log(`👤 Agent: ${wallet.address}`);
  if (WATCH) console.log(`🔄 Watch mode — beating every ${INTERVAL/1000}s (Ctrl+C to stop)\n`);

  await sendBeat(registry, wallet);

  if (WATCH) {
    setInterval(async () => {
      try { await sendBeat(registry, wallet); }
      catch (e) { console.error(`   ⚠️ Beat failed: ${e.message}`); }
    }, INTERVAL);
  }
}

main().catch(e => { console.error("❌", e.message); process.exit(1); });
