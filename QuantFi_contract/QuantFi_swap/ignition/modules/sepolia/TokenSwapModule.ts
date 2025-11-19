import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import pathfinder from "./PathFinderModule.js";

const usdtAddress = "0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0"; // USDT address on Sepolia testnet

export default buildModule("TokenSwapModule", (m) => {
  const PathFinderModule = m.useModule(pathfinder);
  
  // 获取部署者账户
  const account = m.getAccount(0);

  // 部署TokenSwap合约
  const TokenSwap = m.contract("TokenSwap", [
    PathFinderModule.PathFinder,
    account
  ]);

  // 将PathFinder的所有权转移给TokenSwap
  m.call(PathFinderModule.PathFinder, "transferOwnership", [TokenSwap], {id: "transferPathFinderOwnership"});
  // // 设置TokenSwap参数
  // m.call(TokenSwap, "setMaxHops", [4], {id: "setMaxHops", after: [call1]});
  // m.call(TokenSwap, "setTargetToken", [usdtAddress], {id: "setTargetToken", after: [call1]});

  
  return { TokenSwap };
});
