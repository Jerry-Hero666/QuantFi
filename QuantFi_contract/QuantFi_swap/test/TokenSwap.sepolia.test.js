import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

const zeroAddress = "0x0000000000000000000000000000000000000000";



const tokenAddrOnSepolia = {
  UNI: "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984",
  AAVE: "0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a",
  LINK: "0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5",
  WETH9: "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
  USDT: "0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0",
}

const contractAddressOnSepolia = {
  PathFinder: "0xdB009e240a1EE58146e676D52D91b3B25dcd2d73",
  TokenSwap: "0xacfBE9b1049fa337a718c2581F1dFC147F22da6d",
  UniswapV3Router: "0x76bD5C52EE789FB1f23068A787C04a826d5214Ed",
}

const uniswapV3SwapRouterAddress = "0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E";
const uniswapV3QuoterV2Address = "0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3";
const uniswapV3FactoryAddress = "0x0227628f3F023bb0B980b67D528571c95c6DaC1c";


describe("UniswapV3Router sepolia test", function () {


  it("UniswapV3Router getAmountsOut", async function () {
    // const uniswapV3Router = await ethers.getContractAt("UniswapV3Router", contractAddressOnSepolia.UniswapV3Router);
    const PathFinder = await ethers.getContractAt("PathFinder", contractAddressOnSepolia.PathFinder);

    const amountIn = ethers.parseUnits("1.0", 18); // 1 ETH
    // const result = await uniswapV3Router.findOptimalPath.staticCall(zeroAddress, amountIn, tokenAddrOnSepolia.USDT, 4);
    const result = await PathFinder.findOptimalPath.staticCall(zeroAddress, amountIn);
    console.log("最优路径结果:", result);

    const USDTToken = await ethers.getContractAt("MockERC20", tokenAddrOnSepolia.USDT);
    const USDTDecimals = await USDTToken.decimals.staticCall();
    console.log("USDT Decimals:", USDTDecimals);
    console.log("1 ETH 最多换到的 USDT:", ethers.formatUnits(result[2], USDTDecimals));

    expect(result[0][0]).to.equal(tokenAddrOnSepolia.WETH9);
    expect(result[0][1]).to.equal(tokenAddrOnSepolia.USDT);

    const quoter = await ethers.getContractAt("MockUniswapV3Quoter", uniswapV3QuoterV2Address);
    const pathBytes = ethers.solidityPacked(
      ["address", "uint24", "address"],
      [tokenAddrOnSepolia.WETH9, 3000, tokenAddrOnSepolia.USDT]
    );
    const quoterRes = await quoter.quoteExactInput.staticCall(pathBytes, amountIn);
    console.log("quoter getAmountsOut result2:", quoterRes);
    console.log("quoter 1 ETH 最多换到的 USDT:", ethers.formatUnits(quoterRes[0], 6));
    expect(result[2]).to.be.eq(quoterRes[0]);
  })

  it("IDexRouter swapTokensForTokens", async function () {
    const tokenSwap = await ethers.getContractAt("TokenSwap", contractAddressOnSepolia.TokenSwap);
    const amountIn = ethers.parseUnits("0.000002", 18); // 1 ETH
    const swapInfo = await tokenSwap.getSwapToTargetQuote.staticCall(zeroAddress, amountIn);
    console.log("swapInfo:", swapInfo);


    // swapInfo 返回的是一个数组，需要转换为对象
    const swapInfoObj = {
      path: [...swapInfo[0]],
      pathBytes: swapInfo[1],
      outputAmount: swapInfo[2],
      inputAmount: swapInfo[3],
      dexRouter: swapInfo[4],
    };

    console.log("=======================swapInfoObj:", swapInfoObj);

    const signers = await ethers.getSigners();
    const dexRouter = await ethers.getContractAt("IDexRouter", swapInfoObj.dexRouter);
    const tx = await dexRouter.swapTokensForTokens(
      swapInfoObj,
      zeroAddress,
      amountIn,
      0, 
      signers[0].address,
      Math.floor(Date.now() / 1000) + 6000,
      {
        value: amountIn, 
        gasLimit: 300000, // 设置合适的 gas limit
        gasPrice: ethers.parseUnits("10", "gwei")
      });
    const result = await tx.wait();
    console.log("swapTokensForTokens 交易完成:", result);
  })

  it("UniswapV3SwapRouter", async function () {
    const amountIn = ethers.parseUnits("0.000002", 18); // 1 ETH
    const signers = await ethers.getSigners();
    let params = {
      path: '0xfff9976782d46cc05630d1f6ebab18b2324d6b1400271088541670e55cc00beefd87eb59edd1b7c511ac9a000bb8f8fb3713d459d7c1018bd0a49d19b4c44290ebe5000bb81f9840a85d5af5bf1d1762f925bdaddc4201f984000bb8aa8e23fb1079ea71e0a56f48a2aa51851d8433d0',
      recipient: signers[0].address,
      deadline: Math.floor(Date.now() / 1000) + 6000,
      amountIn: amountIn,
      amountOutMinimum: 0
    }
    const MockUniswapV3SwapRouter = await ethers.getContractAt("MockUniswapV3SwapRouter", uniswapV3SwapRouterAddress);
    const tx = await MockUniswapV3SwapRouter.exactInput(params, 
      {
        gasLimit: 300000, // 设置合适的 gas limit
        gasPrice: ethers.parseUnits("10", "gwei")
      });
    const res = await tx.wait();
    console.log("PathFinder dexRouters uniswapV3:", res);
  });
});
