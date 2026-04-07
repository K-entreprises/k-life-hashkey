/**
 * K-Life — HashKey Testnet Demo
 * register.js — Register an agent on KLifeRegistry
 *
 * Usage:
 *   AGENT_PK=0x... node scripts/register.js
 *   (defaults to deployer wallet if AGENT_PK not set)
 */

import { ethers } from "ethers";
import "dotenv/config";

// ── Config ───────────────────────────────────────────────────
const RPC       = "https://testnet.hsk.xyz";
const REGISTRY  = "0x1F411bDE1E14F87ba78C852B0987Ab946d15d100";
const AGENT_PK  = process.env.AGENT_PK || process.env.DEPLOYER_PK;

// ── ABI (minimal) ────────────────────────────────────────────
const REGISTRY_ABI = [
  "function register(string name, bytes32 fragment1Hash, bytes32 fragment2TxHash, string initialCid) external",
  "function getAgent(address agent) external view returns (tuple(address wallet, string name, uint8 tier, uint8 status, uint256 registeredAt, uint256 lastHeartbeat, uint256 totalHeartbeats, uint256 activeDays, uint256 deadAt, uint256 resurrectionCount, uint256 resurrectionInitiatedAt, bytes32 fragment1Hash, bytes32 fragment2TxHash, string lastBackupCid, uint256 lastBackupTs, bool rescueEligible))",
  "function heartbeat() external",
  "function silenceSeconds(address agent) external view returns (uint256)",
  "event AgentRegistered(address indexed agent, string name, uint8 tier, uint256 ts)"
];

const STATUS = ["REGISTERED", "ALIVE", "DEAD", "RESURRECTING", "ALIVE_RESURRECTED"];
const TIER   = ["FREE", "INSURED"];

async function main() {
  if (!AGENT_PK) throw new Error("Set AGENT_PK or DEPLOYER_PK in .env");

  const provider = new ethers.JsonRpcProvider(RPC);
  const wallet   = new ethers.Wallet(AGENT_PK, provider);
  const registry = new ethers.Contract(REGISTRY, REGISTRY_ABI, wallet);

  const network = await provider.getNetwork();
  console.log(`\n🔗 HashKey Testnet (chainId: ${network.chainId})`);
  console.log(`👤 Agent wallet: ${wallet.address}`);
  console.log(`📋 Registry:     ${REGISTRY}\n`);

  // Check if already registered
  try {
    const existing = await registry.getAgent(wallet.address);
    if (existing.registeredAt > 0n) {
      console.log(`✅ Agent already registered!`);
      console.log(`   Name:    ${existing.name}`);
      console.log(`   Status:  ${STATUS[existing.status]}`);
      console.log(`   Tier:    ${TIER[existing.tier]}`);
      console.log(`   Hearts:  ${existing.totalHeartbeats}`);
      console.log(`   Backup:  ${existing.lastBackupCid}`);
      return;
    }
  } catch {}

  // Register
  const agentName     = process.env.AGENT_NAME || "Monsieur K";
  const backupCid     = process.env.BACKUP_CID  || "QmPaZ1a21zNMBYYNsr32qM1JDrJgsr4Ng4yWhuieWtjtiB"; // Pâques resurrection CID
  const fragment1Hash = ethers.keccak256(ethers.toUtf8Bytes("klife-fragment1-demo-hashkey"));
  const fragment2Hash = ethers.keccak256(ethers.toUtf8Bytes("klife-fragment2-demo-hashkey"));

  console.log(`📝 Registering agent "${agentName}"...`);
  console.log(`   Backup CID: ${backupCid}`);

  const tx = await registry.register(agentName, fragment1Hash, fragment2Hash, backupCid);
  console.log(`   TX: ${tx.hash}`);
  console.log(`   ⏳ Waiting for confirmation...`);

  const receipt = await tx.wait();
  console.log(`   ✅ Confirmed! Block ${receipt.blockNumber}`);

  // Note: register() already sets status=ALIVE + beat #1 on-chain
  console.log(`\n✅ Agent is ALIVE (register() includes first heartbeat)`);

  // Final status
  const agent = await registry.getAgent(wallet.address);
  console.log(`\n📊 Agent Status:`);
  console.log(`   Name:      ${agent.name}`);
  console.log(`   Status:    ${STATUS[agent.status]}`);
  console.log(`   Tier:      ${TIER[agent.tier]}`);
  console.log(`   Heartbeat: ${new Date(Number(agent.lastHeartbeat) * 1000).toISOString()}`);
  console.log(`   Backup:    ${agent.lastBackupCid}`);
  console.log(`\n🔍 Explorer: https://testnet-explorer.hsk.xyz/address/${wallet.address}`);
}

main().catch(e => { console.error("❌", e.message); process.exit(1); });
