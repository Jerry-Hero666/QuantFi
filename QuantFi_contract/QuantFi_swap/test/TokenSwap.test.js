import { expect } from "chai";
import { network } from "hardhat";
import { deployUniswapV3Mocks } from "./util/UniswapV3PreDeployment";

const { ethers } = await network.connect();

const maxHops = 4; // Default maximum number of hops
const fee = 3000;

let factory, quoter, swapRouter, tokens, tokenSwap, pathFinder, uniswapV3Router;

let deployer, account1, account2, account3, account4, account5;

let usdtAddress

describe("UniswapV3Router test", function () {

  beforeEach(async function () {
    const res = await deployUniswapV3Mocks(ethers);
    factory = res.factory;
    quoter = res.quoter;
    swapRouter = res.swapRouter;
    tokens = res.tokens;
    usdtAddress = await res.tokens.USDT.getAddress();
    [deployer, account1, account2, account3, account4, account5] = await ethers.getSigners();


    // Deploy TokenSwap contract
    const TokenSwap = await ethers.getContractFactory("TokenSwap");
    const supportedTokens = [await tokens.ETH.getAddress(), await tokens.BTC.getAddress(), await tokens.BNB.getAddress(), await tokens.UNI.getAddress()];

    tokenSwap = await TokenSwap.deploy(usdtAddress, maxHops, supportedTokens, deployer.address);
    await tokenSwap.waitForDeployment();
    const tokenSwapAddress = await tokenSwap.getAddress();

    let pathFinderAddr = await tokenSwap.pathFinder();
    pathFinder = await ethers.getContractAt("PathFinder", pathFinderAddr);

    const UniswapV3Router = await ethers.getContractFactory("UniswapV3Router");
    const uniswapV3FactoryAddress = await factory.getAddress();
    const uniswapV3QuoterV2Address = await quoter.getAddress();
    const uniswapV3SwapRouterAddress = await swapRouter.getAddress();
    const deployParams = {
      uniswapV3SwapRouterAddress,
      uniswapV3QuoterV2Address,
      uniswapV3FactoryAddress,
      owner: deployer.address,
      weth: await tokens.ETH.getAddress()
    }
    uniswapV3Router = await UniswapV3Router.deploy(...Object.values(deployParams));
    await uniswapV3Router.waitForDeployment();
    await tokenSwap.addDexRouter("uniswapV3", await uniswapV3Router.getAddress());
    for (let i = 0; i < supportedTokens.length; i++) {
      const tokenA = supportedTokens[i];
      for (let j = i + 1; j < supportedTokens.length; j++) {
        const tokenB = supportedTokens[j];
        await uniswapV3Router.setFeeTier(tokenA, tokenB, 3000);
      }
      await uniswapV3Router.setFeeTier(tokenA, usdtAddress, 3000);

    }
    
  })

  it("removeDexRouter", async function () {
    let swapV3Addr = await pathFinder.dexRouters("uniswapV3");
    expect(swapV3Addr).to.not.eq(ethers.ZeroAddress)

    await tokenSwap.removeDexRouter("uniswapV3");
    swapV3Addr = await pathFinder.dexRouters("uniswapV3");
    expect(swapV3Addr).to.eq(ethers.ZeroAddress);
  })

  it("setMaxHops", async () => {
    await tokenSwap.setMaxHops(maxHops);
    const hops = await pathFinder.maxHops();
    expect(hops).to.equal(maxHops);
  })

  it("setTargetToken", async () => {
    await tokenSwap.setTargetToken(await tokens.UNI.getAddress());
    const target = await pathFinder.targetToken();
    expect(target).to.equal(await tokens.UNI.getAddress());
  })

  it("getSwapToTargetQuote", async () => {
    await tokenSwap.setMaxHops(maxHops);
    const tokenAddr = await tokens.ETH.getAddress();
    const result = await tokenSwap.getSwapToTargetQuote.staticCall(tokenAddr, ethers.parseUnits("1", 18));
    console.log("1ETH最多换到的USDT:", ethers.formatUnits(result[3], 6));
    expect(result[3]).to.be.gt(0);
  })

  it("swapToTarget BNB", async () => {
    await tokens.BNB.connect(deployer).transfer(account1.address, ethers.parseUnits("10", 18));
    const balance = await tokens.BNB.balanceOf(account1.address);
    expect(balance).to.equal(ethers.parseUnits("10", 18));

    const tokenAddr = await tokens.BNB.getAddress();
    const amountIn = ethers.parseUnits("1", 18);

    const swapInfo = await tokenSwap.connect(account1).getSwapToTargetQuote.staticCall(tokenAddr, amountIn);
    
    // ethers.js 返回的数组可能是只读的，需要创建新的可写数组
    const swapPath = {
      path: [...swapInfo[0]],
      fees: [...swapInfo[1]],
      pathBytes: swapInfo[2],
      outputAmount: swapInfo[3],
      outputToken: swapInfo[4],
      inputAmount: swapInfo[5],
      inputToken: swapInfo[6],
      gasEstimate: swapInfo[7],
      dexRouter: swapInfo[8]
    };
    
    // console.log("交换参数:", swapPath)
    const balanceBefore = await tokens.USDT.balanceOf(account1.address);
    console.log("account1 USDT balanceBefore:", balanceBefore);

    // 授权给 dexRouter（UniswapV3Router），使用实际的 inputAmount
    const dexRouter = await ethers.getContractAt("IDexRouter", swapPath.dexRouter);
    await tokens.BNB.connect(account1).approve(swapPath.dexRouter, swapPath.inputAmount);
    
    const tx = await dexRouter.connect(account1).swapTokensForTokens(
      swapPath, 
      await account1.getAddress(),
      0,
      Math.floor(Date.now() / 1000) + 60 * 10
    );
    await tx.wait();

    const balanceAfter = await tokens.USDT.balanceOf(account1.address);
    console.log("account1 USDT balanceAfter:", balanceAfter);
    expect(balanceAfter).to.gt(balanceBefore);
  })

  it("swapToTarget ETH", async () => {
    const tokenAddr = ethers.ZeroAddress;
    const amountIn = ethers.parseUnits("1", 18);

    const swapInfo = await tokenSwap.connect(account1).getSwapToTargetQuote.staticCall(tokenAddr, amountIn);
    const swapInfoObj = {
      path: [...swapInfo[0]],
      fees: [...swapInfo[1]],
      pathBytes: swapInfo[2],
      outputAmount: swapInfo[3],
      outputToken: swapInfo[4],
      inputAmount: swapInfo[5],
      inputToken: swapInfo[6],
      gasEstimate: swapInfo[7],
      dexRouter: swapInfo[8],
      recipient: await account1.getAddress(),
      amountOutMin: 0,
      deadline: Math.floor(Date.now() / 1000) + 60 * 10,
    };
    const balanceBefore = await tokens.USDT.balanceOf(account1.address);
    console.log("account1 USDT balanceBefore:", balanceBefore);

    const dexRouter = await ethers.getContractAt("IDexRouter", swapInfoObj.dexRouter);
    const tx = await dexRouter.connect(account1).swapTokensForTokens(
      swapInfoObj, 
      await account1.getAddress(),
      0,
      Math.floor(Date.now() / 1000) + 60 * 10,
      {value: amountIn}
    );
    await tx.wait();

    const balanceAfter = await tokens.USDT.balanceOf(account1.address);
    console.log("account1 USDT balanceAfter:", balanceAfter);
    expect(balanceAfter).to.be.gt(balanceBefore);
  })


});
