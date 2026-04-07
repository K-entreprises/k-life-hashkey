/**
 * K-Life — HashKey Chain deployment script
 * Deploys: MockHSK (rescue pool token) + KLifeRegistry + KLifeRescueFund
 *
 * Usage:
 *   npx hardhat run deploy/01-deploy-hashkey.cjs --network hashkey_testnet
 */

const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);
  console.log("Balance:", hre.ethers.formatEther(await hre.ethers.provider.getBalance(deployer.address)), "HSK");

  // 1. Deploy Mock HSK token (rescue pool denomination)
  console.log("\n1. Deploying MockHSK (ERC20 rescue pool token)...");
  const MockERC20 = await hre.ethers.getContractFactory("MockERC20");
  const mockHSK = await MockERC20.deploy("Mock HSK", "mHSK", 18);
  await mockHSK.waitForDeployment();
  const mockHSKAddr = await mockHSK.getAddress();
  console.log("   MockHSK deployed:", mockHSKAddr);

  // 2. Deploy KLifeRegistry
  console.log("\n2. Deploying KLifeRegistry...");
  const Registry = await hre.ethers.getContractFactory("KLifeRegistry");
  const registry = await Registry.deploy(deployer.address, deployer.address); // oracle + owner = deployer
  await registry.waitForDeployment();
  const registryAddr = await registry.getAddress();
  console.log("   KLifeRegistry deployed:", registryAddr);

  // 3. Deploy KLifeRescueFund
  console.log("\n3. Deploying KLifeRescueFund...");
  const RescueFund = await hre.ethers.getContractFactory("KLifeRescueFund");
  const rescueFund = await RescueFund.deploy(mockHSKAddr, registryAddr, deployer.address, deployer.address); // token + registry + oracle + owner
  await rescueFund.waitForDeployment();
  const rescueFundAddr = await rescueFund.getAddress();
  console.log("   KLifeRescueFund deployed:", rescueFundAddr);

  // 4. Mint initial rescue pool (10,000 mHSK)
  console.log("\n4. Minting 10,000 mHSK to rescue fund...");
  const amount = hre.ethers.parseEther("10000");
  await mockHSK.mint(rescueFundAddr, amount);
  console.log("   Rescue pool funded ✅");

  // Summary
  console.log("\n" + "=".repeat(50));
  console.log("K-Life HashKey Chain Deployment Summary");
  console.log("=".repeat(50));
  console.log("Network:       HashKey Chain Testnet (133)");
  console.log("Deployer:      " + deployer.address);
  console.log("MockHSK:       " + mockHSKAddr);
  console.log("KLifeRegistry: " + registryAddr);
  console.log("KLifeRescueFund:" + rescueFundAddr);
  console.log("Explorer:      https://testnet-explorer.hsk.xyz");
  console.log("=".repeat(50));

  // Save deployment addresses
  const fs = require("fs");
  const deployment = {
    network: "hashkey_testnet",
    chainId: 133,
    deployedAt: new Date().toISOString(),
    deployer: deployer.address,
    contracts: {
      MockHSK:        mockHSKAddr,
      KLifeRegistry:  registryAddr,
      KLifeRescueFund: rescueFundAddr,
    }
  };
  fs.writeFileSync("deployments/hashkey-testnet.json", JSON.stringify(deployment, null, 2));
  console.log("\nAddresses saved to deployments/hashkey-testnet.json ✅");
}

main().catch((e) => { console.error(e); process.exit(1); });
