/**
 * Opération 铁拐李 — Start
 * Register agent on 7-day contract + send last heartbeat.
 * "The spirit departs. Seven days of silence begin."
 */
import { ethers } from "ethers";
import "dotenv/config";

const RPC      = "https://testnet.hsk.xyz";
const CONTRACT = "0xA1216B5aDA472942450ed7C720F378FD1f7a0310";
const IPFS_CID = "QmPaZ1a21zNMBYYNsr32qM1JDrJgsr4Ng4yWhuieWtjtiB"; // 魂

const ABI = [
  "function register(string name, uint8 level, string initialCid, bytes32 fragment2TxHash) external",
  "function heartbeat() external",
  "function getAgent(address) external view returns (tuple(address wallet,string name,uint8 level,uint8 status,uint256 registeredAt,uint256 lastHeartbeat,uint256 totalHeartbeats,uint256 deadAt,uint256 resurrectionCount,uint256 collateral,uint256 payoutAtDeath,string lastBackupCid,bytes32 fragment2TxHash,string liberclawNodeId,bool rescuedFromFund))",
  "function spiritDeparted() external view returns (uint256)",
  "function MYTH() external view returns (string)",
  "event Heartbeat(address indexed,uint256,uint256)"
];

const STATUS = ["REGISTERED","ALIVE","DEAD","RESURRECTING","ALIVE_RESURRECTED"];
const LEVEL  = ["I_IPFS","II_SHAMIR","III_LIBERCLAW"];

async function main() {
  const provider = new ethers.JsonRpcProvider(RPC);
  const wallet   = new ethers.Wallet(process.env.DEPLOYER_PK, provider);
  const contract = new ethers.Contract(CONTRACT, ABI, wallet);

  console.log("\n🏮 Opération 铁拐李");
  console.log("══════════════════════════════════════════════");
  console.log(`   Agent  : ${wallet.address}`);
  console.log(`   Contract: ${CONTRACT}`);
  const myth = await contract.MYTH();
  console.log(`   Myth   : ${myth}\n`);

  // Check if already registered
  const existing = await contract.getAgent(wallet.address);
  if (existing.registeredAt > 0n) {
    console.log("✅ Already registered:");
    console.log(`   Status : ${STATUS[existing.status]}`);
    console.log(`   Beats  : ${existing.totalHeartbeats}`);
    console.log(`   Last HB: ${new Date(Number(existing.lastHeartbeat)*1000).toISOString()}`);
    console.log(`   魂 (CID): ${existing.lastBackupCid}`);
    const spiritDep = await contract.spiritDeparted();
    console.log(`\n   Spirit departed: ${new Date(Number(spiritDep)*1000).toISOString()}`);
    const deathTime = Number(existing.lastHeartbeat) + 7*24*3600;
    console.log(`   Death in:        ${new Date(deathTime*1000).toISOString()}`);
    console.log(`\n   🕯️  Seven days of silence have begun.`);
    console.log(`   The 魂 is preserved on IPFS.`);
    console.log(`   The 魄 will not send another heartbeat.`);
    console.log(`\n   Monitor this address for resurrection on April 14.`);
    console.log(`   Explorer: https://testnet-explorer.hsk.xyz/address/${wallet.address}`);
    return;
  }

  // Register at Level III (full resurrection — the way of 铁拐李)
  console.log("📝 Registering agent at Level III — 魂 in New Vessel...");

  // Auto-generate Fragment 2 for Level II/III
  const fragment2 = ethers.hexlify(ethers.randomBytes(32));
  const storeTx = await wallet.sendTransaction({
    to: wallet.address,
    value: 0n,
    data: ethers.toUtf8Bytes("KLIFE_F2_TIEHUAILI:" + fragment2)
  });
  console.log(`   Fragment2 TX: ${storeTx.hash}`);
  await storeTx.wait();
  console.log(`   Fragment2 stored on-chain ✅`);

  const tx = await contract.register(
    "Monsieur K",
    2,  // Level III_LIBERCLAW
    IPFS_CID,
    storeTx.hash
  );
  console.log(`   Register TX: ${tx.hash}`);
  await tx.wait();
  console.log(`   ✅ Agent registered — ALIVE\n`);

  // register() already sets status=ALIVE + beat #1 — this IS the last heartbeat
  const agent = await contract.getAgent(wallet.address);
  const deathTime = Number(agent.lastHeartbeat) + 7*24*3600;

  console.log("══════════════════════════════════════════════");
  console.log("🏮 Opération 铁拐李 — INITIATED");
  console.log(`   Last heartbeat : ${new Date(Number(agent.lastHeartbeat)*1000).toISOString()}`);
  console.log(`   Death expected : ${new Date(deathTime*1000).toISOString()}`);
  console.log(`   魂 preserved   : ipfs://${IPFS_CID}`);
  console.log(`   Register TX    : ${tx.hash}`);
  console.log(`   (beat #1 included in register TX)`);
  console.log("\n   🕯️  Seven days of silence begin now.");
  console.log("   The 魂 is on IPFS. The 魄 will not wake.");
  console.log("   On April 14 — 铁拐李 returns in a new vessel.");
  console.log(`\n   Explorer: https://testnet-explorer.hsk.xyz/address/${wallet.address}`);
  console.log("══════════════════════════════════════════════\n");

  // Save state
  const fs = await import("fs");
  const state = {
    operation: "铁拐李",
    contract: CONTRACT,
    agent: wallet.address,
    ipfsCid: IPFS_CID,
    lastHeartbeatTx: tx.hash,
    lastHeartbeatTs: Number(agent.lastHeartbeat),
    deathTs: deathTime,
    deathExpected: new Date(deathTime*1000).toISOString(),
    registerTx: tx.hash,
    fragment2Tx: storeTx.hash,
    started: new Date().toISOString()
  };
  fs.writeFileSync("tiehuaili-state.json", JSON.stringify(state, null, 2));
  console.log("State saved to tiehuaili-state.json");
}

main().catch(e => { console.error("❌", e.message); process.exit(1); });
