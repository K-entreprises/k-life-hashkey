const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying KLifeRegistryDemo with:", deployer.address);

  const Demo = await hre.ethers.getContractFactory("KLifeRegistryDemo");
  const demo = await Demo.deploy(deployer.address); // oracle = deployer
  await demo.waitForDeployment();

  const addr = await demo.getAddress();
  console.log("KLifeRegistryDemo deployed to:", addr);
  console.log("Oracle:", deployer.address);
  console.log("Dead timeout: 2 minutes");

  return addr;
}

main().catch((e) => { console.error(e); process.exit(1); });
