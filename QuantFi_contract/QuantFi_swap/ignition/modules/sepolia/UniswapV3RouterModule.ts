import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import tokenSwapModule from "./TokenSwapModule.js";

// Uniswap V3 合约地址
const uniswapV3SwapRouterAddress = process.env.SEPOLIA_UNISWAP_V3_SWAPROUTER02 || '';
const uniswapV3QuoterV2Address = process.env.SEPOLIA_UNISWAP_V3_QUOTERV2 || '';
const uniswapV3FactoryAddress = process.env.SEPOLIA_UNISWAP_V3_FACTORY || '';
const WETH9 = process.env.SEPOLIA_TOKEN_WETH9 || ""; // WETH9 address on Sepolia testnet


export default buildModule("UniswapV3RouterModule", (m) => {
  // 获取部署者账户
  const account = m.getAccount(0);

  const params = [
    uniswapV3SwapRouterAddress,
    uniswapV3QuoterV2Address,
    uniswapV3FactoryAddress,
    account,
    WETH9
  ];
  const filterParams = params.filter(addr => addr);
  if (params.length > filterParams.length){
    console.log(params)
    throw new Error("有地址未配置");
  }

  // 部署UniswapV3Router合约
  const UniswapV3Router = m.contract("UniswapV3Router", params);
  // 将UniswapV3Router添加到TokenSwap
  const TokenSwapModule = m.useModule(tokenSwapModule);
  m.call(TokenSwapModule.TokenSwap, "addDexRouter", ["uniswapV3", UniswapV3Router], {id: "addDexRouter_UniswapV3Router"});

  return { UniswapV3Router };
});
