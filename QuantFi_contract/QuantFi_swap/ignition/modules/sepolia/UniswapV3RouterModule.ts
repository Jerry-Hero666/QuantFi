import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import tokenSwapModule from "./TokenSwapModule.js";

// Uniswap V3 合约地址
const uniswapV3SwapRouterAddress = "0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E";
const uniswapV3QuoterV2Address = "0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3";
const uniswapV3FactoryAddress = "0x0227628f3F023bb0B980b67D528571c95c6DaC1c";
const WETH9 = "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14"; // WETH9 address on Sepolia testnet

// AAVE: 0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a
// LINK: 0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5
// UNI: 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984
const exchangeTokens = [
  "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984",
  "0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a",
  "0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5",
  "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14"
];


export default buildModule("UniswapV3RouterModule", (m) => {
  // 获取部署者账户
  const account = m.getAccount(0);
  const TokenSwapModule = m.useModule(tokenSwapModule);
  // 部署UniswapV3Router合约
  const UniswapV3Router = m.contract("UniswapV3Router", [
    uniswapV3SwapRouterAddress,
    uniswapV3QuoterV2Address,
    uniswapV3FactoryAddress,
    account,
    WETH9,
    exchangeTokens
  ]);
  // 将UniswapV3Router添加到TokenSwap
  m.call(TokenSwapModule.TokenSwap, "addDexRouter", ["uniswapV3", UniswapV3Router], {id: "addUniswapV3Router"});

  return { UniswapV3Router };
});
