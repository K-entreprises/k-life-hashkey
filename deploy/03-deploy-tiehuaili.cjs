const hre = require("hardhat");
const fs  = require("fs");
const path = require("path");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying KLifeRegistryDemo (7-day) with:", deployer.address);

  // Override DEAD_TIMEOUT to 7 days in a fresh deploy
  // We reuse KLifeRegistryDemo but patch the constant via a modified version
  const Demo = await hre.ethers.getContractFactory("KLifeRegistry7Days");
  const demo = await Demo.deploy(deployer.address);
  await demo.waitForDeployment();

  const addr = await demo.getAddress();
  console.log("KLifeRegistry7Days deployed to:", addr);

  // Save
  const dep = JSON.parse(fs.readFileSync(
    path.join(__dirname, "../deployments/hashkey-testnet.json"), "utf8"
  ));
  dep.contracts["KLifeRegistry7Days"] = addr;
  dep.notes["KLifeRegistry7Days"] = "Opération 铁拐李 — 7-day timeout, started 2026-04-07";
  fs.writeFileSync(
    path.join(__dirname, "../deployments/hashkey-testnet.json"),
    JSON.stringify(dep, null, 2)
  );
  console.log("Deployments updated.");
  return addr;
}

main().catch(e => { console.error(e); process.exit(1); });
