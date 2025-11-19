import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const usdtAddress = "0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0"; // USDT address on Sepolia testnet
const maxHops = 4; // Default maximum number of hops

// SwapRouter02(https://github.com/Uniswap/swap-router-contracts/blob/main/contracts/SwapRouter02.sol) 
// 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E
const uniswapV3SwapRouterAddress = "0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E";
const uniswapV3QuoterV2Address = "0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3";
const uniswapV3FactoryAddress = "0x0227628f3F023bb0B980b67D528571c95c6DaC1c";
// AAVE: 0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a
// LINK: 0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5
// UNI: 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984
const exchangeTokens = [
  "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984",
  "0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a",
  "0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5"
];
const WETH9 = "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14"; // WETH9 address on Sepolia testnet

export default buildModule("TokenSwapModule", (m) => {

  const account = m.getAccount(0)

  const PathFinder = m.contract("PathFinder", [
    usdtAddress,
    maxHops,
    account
  ]);

  const TokenSwap = m.contract("TokenSwap", [
    PathFinder,
    account
  ]);

  m.call(PathFinder, "transferOwnership", [TokenSwap], {id: "transferPathFinderOwnership"});
  m.call(TokenSwap, "setMaxHops", [4], {id: "setMaxHops"});
  m.call(TokenSwap, "setTargetToken", [usdtAddress], {id: "setTargetToken"});
  const UniswapV3Router = m.contract("UniswapV3Router", [
    uniswapV3SwapRouterAddress,
    uniswapV3QuoterV2Address,
    uniswapV3FactoryAddress,
    account,
    WETH9,
    exchangeTokens
  ]);

  for (let i = 0; i < exchangeTokens.length - 1; i++) {
    const tokenA = exchangeTokens[i];
    for (let j = i + 1; j < exchangeTokens.length; j++) {
      const tokenB = exchangeTokens[j];
      m.call(UniswapV3Router, "setFeeTier", [tokenA, tokenB, 3000], {id: `id_${tokenA}_${tokenB}_3000`});
    }
    m.call(UniswapV3Router, "setFeeTier", [tokenA, usdtAddress, 3000], {id: `id_${tokenA}_${usdtAddress}_3000`});
  }
  m.call(TokenSwap, "addDexRouter", ["uniswapV3", UniswapV3Router], {id: "addUniswapV3Router"});

  return { PathFinder, TokenSwap, UniswapV3Router };
});