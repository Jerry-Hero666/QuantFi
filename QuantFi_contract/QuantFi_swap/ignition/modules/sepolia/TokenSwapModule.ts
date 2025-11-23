import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const tokenAddrs = {
  WETH9: process.env.SEPOLIA_TOKEN_WETH9 || "",
  AAVE: process.env.SEPOLIA_TOKEN_AAVE || "",
  LINK: process.env.SEPOLIA_TOKEN_LINK || "",
  UNI: process.env.SEPOLIA_TOKEN_UNI || "",
  USDT: process.env.SEPOLIA_TOKEN_USDT || ""
};

const maxHops = process.env.MAX_HOPS ? parseInt(process.env.MAX_HOPS, 10) : 4;

export default buildModule("TokenSwapModule", (m) => {
  const addrs = Object.values(tokenAddrs);
  const filterAddr = addrs.filter(addr => addr);
  if (addrs.length > filterAddr.length){
    console.log(tokenAddrs)
    throw new Error("有地址未配置");
  }
  // 获取部署者账户
  const account = m.getAccount(0);

  // 部署TokenSwap合约
  const TokenSwap = m.contract("TokenSwap", [
    tokenAddrs.USDT,
    maxHops,
    [tokenAddrs.WETH9, tokenAddrs.AAVE, tokenAddrs.LINK, tokenAddrs.UNI],
    account
  ]);

  return { TokenSwap };
});
