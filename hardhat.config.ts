import * as dotenv from 'dotenv';
dotenv.config();

import '@nomiclabs/hardhat-etherscan';
import '@typechain/hardhat';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-dependency-compiler';
import 'hardhat-abi-exporter';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import 'hardhat-gas-reporter';
import 'solidity-coverage';
import { HardhatUserConfig } from 'hardhat/config';
import networks from './hardhat.network';

const optimizerEnabled = !process.env.OPTIMIZER_DISABLED;

const config: HardhatUserConfig = {
  abiExporter: {
    path: './abis',
    runOnCompile: true,
    clear: true,
    flat: false,
    except: ['./abis/ERC20.sol', './abis/ERC721.sol'],
  },
  typechain: {
    outDir: 'types',
    target: 'ethers-v5',
  },
  dependencyCompiler: {
    paths: [
          '@erc721k/core-sol/contracts/ERC721K.sol',
          '@erc721k/core-sol/contracts/ERC721Storage.sol',
          '@erc721k/periphery-sol/contracts/svg/svg.sol',
          '@erc721k/periphery-sol/contracts/svg/svgUtils.sol',
          '@erc721k/periphery-sol/contracts/svg/SVGColor.sol',
          '@erc721k/periphery-sol/contracts/svg/SVGLibrary.sol',
          '@erc721k/periphery-sol/contracts/svg/SVGRegistry.sol',
      ],
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 100,
    enabled: process.env.REPORT_GAS ? true : false,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    maxMethodDiff: 10,
  },
  mocha: {
    timeout: 30000,
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks,
  solidity: {
    version: '0.8.15',
    settings: {
      optimizer: {
        enabled: optimizerEnabled,
        runs: 200,
      },
      evmVersion: 'istanbul',
    },
  },
};

export default config;
