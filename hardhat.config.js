require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require("dotenv").config();




const { MUMBAI_RPC_PROVIDER, MUMBAI_PRIVATE_KEY, POLYGON_RPC_PROVIDER, POLYGON_PRIVATE_KEY, POLYGONSCAN_API_KEY } = process.env


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    polygon: {
      url: POLYGON_RPC_PROVIDER,
      accounts: [
        POLYGON_PRIVATE_KEY,
      ],
    }
  },
  gasReporter: {
    currency: 'CHF',
    gasPrice: 21,
    enabled: true
  }
};
