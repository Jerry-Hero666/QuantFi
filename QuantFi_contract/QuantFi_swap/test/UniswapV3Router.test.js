import {expect} from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();
const maxHops = 4; // Default maximum number of hops
const usdtAddress = "0x7169d38820dfd117c3fa1f22a697dba58d90ba06"; // USDT address on Sepolia testnet
// Deploy UniswapV3Router
const uniswapV3SwapRouterAddress = "0x0227628f3F023bb0B980b67D528571c95c6DaC1c";
const uniswapV3QuoterV2Address = "0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3";
const uniswapV3FactoryAddress = "0x0227628f3F023bb0B980b67D528571c95c6DaC1c";
// btc: 0x66194f6c999b28965e0303a84cb8b797273b6b8b DAI: 0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357 UNI: 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984
const exchangeTokens = ["0x66194f6c999b28965e0303a84cb8b797273b6b8b", "0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357", "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984"];
const feeTiers = [3000n, 3000n];

let deployer;

describe("UniswapV3Router sepolia deploy test", function () {

  beforeEach(async function () {
    [deployer] = await ethers.getSigners();

    // Get the deployer account
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());
  
  
    const PathFinder = await ethers.getContractFactory("PathFinder");
    const pathFinder = await PathFinder.deploy(usdtAddress, maxHops, deployer);
    await pathFinder.waitForDeployment();
    const pathFinderAddress = await pathFinder.getAddress();
    console.log("PathFinder deployed to:", pathFinderAddress);
  
    // Deploy TokenSwap contract
    const TokenSwap = await ethers.getContractFactory("TokenSwap");
    const tokenSwap = await TokenSwap.deploy(pathFinderAddress, deployer);
    await tokenSwap.waitForDeployment();
    console.log("TokenSwap deployed to:", await tokenSwap.getAddress());
  
  
    const UniswapV3Router = await ethers.getContractFactory("UniswapV3Router");
    const uniswapV3Router = await UniswapV3Router.deploy(
      uniswapV3SwapRouterAddress,
      uniswapV3QuoterV2Address,
      uniswapV3FactoryAddress,
      deployer.address,
      exchangeTokens,
      feeTiers
    );
    await uniswapV3Router.waitForDeployment();
    console.log("UniswapV3Router deployed to:", await uniswapV3Router.getAddress());
  
    console.log("Deployment completed!");
  })

  it("deploy", async function () {
    console.log("hre")
  })

});
