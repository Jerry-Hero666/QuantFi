import { expect } from "chai";
import { network } from "hardhat";
import { deployUniswapV3Mocks } from "./util/UniswapV3PreDeployment";

const { ethers } = await network.connect();

const maxHops = 4; // Default maximum number of hops
const fee = 3000;

let factory, quoter, swapRouter, tokens, tokenSwap, pathFinder, uniswapV3Router;

let deployer, account1, account2, account3, account4, account5;

let exchangeTokens = [];

describe("UniswapV3Router test", function () {

  beforeEach(async function () {
    const res = await deployUniswapV3Mocks(ethers);
    factory = res.factory;
    quoter = res.quoter;
    swapRouter = res.swapRouter;
    tokens = res.tokens;
    [deployer, account1, account2, account3, account4, account5] = await ethers.getSigners();
    // console.log("deployer.address:", deployer.address);

    const PathFinder = await ethers.getContractFactory("PathFinder");
    const usdtAddress = await tokens.USDT.getAddress();
    pathFinder = await PathFinder.deploy(usdtAddress, maxHops, deployer.address);
    await pathFinder.waitForDeployment();
    const pathFinderAddress = await pathFinder.getAddress();
    // console.log("PathFinder deployed to:", pathFinderAddress);

    // Deploy TokenSwap contract
    const TokenSwap = await ethers.getContractFactory("TokenSwap");
    tokenSwap = await TokenSwap.deploy(pathFinderAddress, deployer.address);
    await tokenSwap.waitForDeployment();
    const tokenSwapAddress = await tokenSwap.getAddress();
    // console.log("TokenSwap deployed to:", tokenSwapAddress);
    await pathFinder.transferOwnership(tokenSwapAddress);



    const UniswapV3Router = await ethers.getContractFactory("UniswapV3Router");
    const uniswapV3FactoryAddress = await factory.getAddress();
    const uniswapV3QuoterV2Address = await quoter.getAddress();
    const uniswapV3SwapRouterAddress = await swapRouter.getAddress();
    exchangeTokens = [await tokens.ETH.getAddress(), await tokens.BTC.getAddress(), await tokens.BNB.getAddress(), await tokens.UNI.getAddress()];
    const deployParams = {
      uniswapV3SwapRouterAddress,
      uniswapV3QuoterV2Address,
      uniswapV3FactoryAddress,
      owner: deployer.address,
      weth: await tokens.ETH.getAddress(),
      exchangeTokens
    }
    // console.log("UniswapV3Router deployParams:", deployParams);
    uniswapV3Router = await UniswapV3Router.deploy(...Object.values(deployParams));
    await uniswapV3Router.waitForDeployment();
    // console.log("UniswapV3Router deployed to:", await uniswapV3Router.getAddress());
    for (let i = 0; i < exchangeTokens.length; i++) {
      const tokenA = exchangeTokens[i];
      for (let j = i + 1; j < exchangeTokens.length; j++) {
        const tokenB = exchangeTokens[j];
        await uniswapV3Router.setFeeTier(tokenA, tokenB, 3000);
      }
      await uniswapV3Router.setFeeTier(tokenA, usdtAddress, 3000);

    }
    await tokenSwap.addDexRouter("uniswapV3", await uniswapV3Router.getAddress());
    // console.log("Deployment completed!");
  })

  it("removeDexRouter", async function () {

    let swapV3Addr = await tokenSwap.dexRouters("uniswapV3");
    let finderV3Addr = await pathFinder.dexRouters("uniswapV3");
    expect(swapV3Addr).to.equal(finderV3Addr);

    await tokenSwap.removeDexRouter("uniswapV3");
    swapV3Addr = await tokenSwap.dexRouters("uniswapV3");
    expect(swapV3Addr).to.equal(ethers.ZeroAddress);
    finderV3Addr = await pathFinder.dexRouters("uniswapV3");
    expect(finderV3Addr).to.equal(ethers.ZeroAddress);
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
    console.log("最优路径结果:", result);
    console.log("1ETH最多换到的USDT:", ethers.formatUnits(result[2], 6));
    expect(result[2]).to.be.gt(0);
  })

  it("swapToTarget BNB", async () => {
    // await tokens.BNB.mint(account1.address, ethers.parseUnits("10", 18));
    await tokens.BNB.connect(deployer).transfer(account1.address, ethers.parseUnits("10", 18));
    const balance = await tokens.BNB.balanceOf(account1.address);
    expect(balance).to.equal(ethers.parseUnits("10", 18));

    const tokenAddr = await tokens.BNB.getAddress();
    const amountIn = ethers.parseUnits("1", 18);
    const block = await ethers.provider.getBlock("latest")
    await tokens.BNB.connect(account1).approve(await tokenSwap.getAddress(), amountIn);
    const res = await tokenSwap.connect(account1).swapToTarget(tokenAddr, amountIn, 0, block.timestamp + 600);
    // console.log("swapToTarget 交易完成:", res);
    // 1 BNB = 400 USDT
    for (let i = 0; i < 8; i++) {
      // 跳过8个区块
      await ethers.provider.send("evm_mine", []);
    }
    console.log("account1 USDT balance:", ethers.formatUnits(await tokens.USDT.balanceOf(account1.address), 6));
    expect(await tokens.USDT.balanceOf(account1.address)).to.be.gte(ethers.parseUnits("390", 6));
  })

  it("swapToTarget ETH", async () => {

    const tokenAddr = ethers.ZeroAddress;
    const amountIn = ethers.parseUnits("100", 18);
    const block = await ethers.provider.getBlock("latest")
    const res = await tokenSwap.connect(account1).swapToTarget(tokenAddr, amountIn, 0, block.timestamp + 600, { value: amountIn });
    // console.log("swapToTarget 交易完成:", res);
    // 1 ETH = 2000 USDT
    console.log("account1 USDT balance:", ethers.formatUnits(await tokens.USDT.balanceOf(account1.address), 6));
    expect(await tokens.USDT.balanceOf(account1.address)).to.be.gte(ethers.parseUnits("190000", 6));
  })

  it("dexRouter swapTokensForTokens", async () => {
    
    const amountIn = ethers.parseUnits("1", 18); // 1 ETH
    const swapInfo = await tokenSwap.getSwapToTargetQuote.staticCall(ethers.ZeroAddress, amountIn);
    console.log("swapInfo:", swapInfo);
    // swapInfo 返回的是一个数组，需要转换为对象
    const swapInfoObj = {
      path: [...swapInfo[0]],
      pathBytes: swapInfo[1],
      outputAmount: swapInfo[2],
      inputAmount: swapInfo[3],
      dexRouter: swapInfo[4],
    };
    const dexRouter = await ethers.getContractAt("IDexRouter", swapInfoObj.dexRouter);
    const res1 = await tokens.USDT.balanceOf(account1.address);
    const tx = await dexRouter.swapTokensForTokens(
      swapInfoObj,
      ethers.ZeroAddress,
      amountIn,
      0,
      account1.address,
      Math.floor(Date.now() / 1000) + 6000,
      {
        value: amountIn,
        gasLimit: 300000, // 设置合适的 gas limit
        gasPrice: ethers.parseUnits("10", "gwei")
      });
    await tx.wait();
    const res2 = await tokens.USDT.balanceOf(account1.address);
    expect(res2).to.be.gt(res1);
  })

});
