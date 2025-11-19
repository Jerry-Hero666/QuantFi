import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();


const uniswapV3RouterAddress = "0x76bD5C52EE789FB1f23068A787C04a826d5214Ed";


const tokenAddrOnSepolia = {
  UNI: "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984",
  AAVE: "0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a",
  LINK: "0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5",
  WETH9: "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
  USDT: "0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0",
}

async function main() {

  const uniswapV3Router = await ethers.getContractAt("UniswapV3Router", uniswapV3RouterAddress)

  const tx1 = await uniswapV3Router.setFeeTier(tokenAddrOnSepolia.AAVE, tokenAddrOnSepolia.LINK, 3000);
  const res1 = await tx1.wait();
  console.log("Set fee tier tx1 mined:", res1);
  const tx2 = await uniswapV3Router.setFeeTier(tokenAddrOnSepolia.UNI, tokenAddrOnSepolia.AAVE, 3000);
  const res2 = await tx2.wait();
  console.log("Set fee tier tx2 mined:", res2);
  const tx3 = await uniswapV3Router.setFeeTier(tokenAddrOnSepolia.UNI, tokenAddrOnSepolia.LINK, 3000);
  const res3 = await tx3.wait();
  console.log("Set fee tier tx3 mined:", res3);

  const tx4 = await uniswapV3Router.setFeeTier(tokenAddrOnSepolia.WETH9, tokenAddrOnSepolia.LINK, 3000);
  const res4 = await tx4.wait();
  console.log("Set fee tier tx4 mined:", res4);
  const tx5 = await uniswapV3Router.setFeeTier(tokenAddrOnSepolia.WETH9, tokenAddrOnSepolia.AAVE, 10000);
  const res5 = await tx5.wait();
  console.log("Set fee tier tx5 mined:", res5);
  const tx6 = await uniswapV3Router.setFeeTier(tokenAddrOnSepolia.WETH9, tokenAddrOnSepolia.UNI, 3000);
  const res6 = await tx6.wait();
  console.log("Set fee tier tx6 mined:", res6);

  const tx7 = await uniswapV3Router.setFeeTier(tokenAddrOnSepolia.AAVE, tokenAddrOnSepolia.USDT, 3000);
  const res7 = await tx7.wait();
  console.log("Set fee tier tx7 mined:", res7);
  const tx8 = await uniswapV3Router.setFeeTier(tokenAddrOnSepolia.UNI, tokenAddrOnSepolia.USDT, 3000);
  const res8 = await tx8.wait();
  console.log("Set fee tier tx8 mined:", res8);
  const tx9 = await uniswapV3Router.setFeeTier(tokenAddrOnSepolia.LINK, tokenAddrOnSepolia.USDT, 3000);
  const res9 = await tx9.wait();
  console.log("Set fee tier tx9 mined:", res9);
  const tx10 = await uniswapV3Router.setFeeTier(tokenAddrOnSepolia.WETH9, tokenAddrOnSepolia.USDT, 3000);
  const res10 = await tx10.wait();
  console.log("Set fee tier tx10 mined:", res10);
  

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
