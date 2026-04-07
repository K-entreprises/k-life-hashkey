require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const PK = process.env.WALLET_PRIVATE_KEY || "0x" + "0".repeat(64);

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: { optimizer: { enabled: true, runs: 200 } }
  },
  networks: {
    // ── HashKey Chain Testnet ──────────────────────────────
    hashkey_testnet: {
      url:      "https://testnet.hsk.xyz",
      chainId:  133,
      accounts: [PK],
      timeout:  120000,
    },
    // ── HashKey Chain Mainnet ──────────────────────────────
    hashkey: {
      url:      "https://mainnet.hsk.xyz",
      chainId:  177,
      accounts: [PK],
      timeout:  120000,
      gasPrice: "auto",
    },
    // ── Hardhat local ──────────────────────────────────────
    hardhat: {
      chainId: 31337,
    },
  },
  etherscan: {
    apiKey: {
      hashkey_testnet: process.env.HASHKEY_EXPLORER_API_KEY || "no-key",
      hashkey:         process.env.HASHKEY_EXPLORER_API_KEY || "no-key",
    },
    customChains: [
      {
        network: "hashkey_testnet",
        chainId: 133,
        urls: {
          apiURL:     "https://testnet-explorer.hsk.xyz/api",
          browserURL: "https://testnet-explorer.hsk.xyz",
        },
      },
      {
        network: "hashkey",
        chainId: 177,
        urls: {
          apiURL:     "https://explorer.hsk.xyz/api",
          browserURL: "https://explorer.hsk.xyz",
        },
      },
    ],
  },
  paths: {
    sources:   "./contracts",
    tests:     "./test",
    cache:     "./cache",
    artifacts: "./artifacts",
  },
};
