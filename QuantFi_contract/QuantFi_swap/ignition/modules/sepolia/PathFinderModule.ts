import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const usdtAddress = "0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0"; // USDT address on Sepolia testnet
const maxHops = 4; // Default maximum number of hops

export default buildModule("PathFinderModule", (m) => {
  // 获取部署者账户
  const account = m.getAccount(0);

  // 部署PathFinder合约
  const PathFinder = m.contract("PathFinder", [
    usdtAddress,
    maxHops,
    account
  ]);

  return { PathFinder };
});
