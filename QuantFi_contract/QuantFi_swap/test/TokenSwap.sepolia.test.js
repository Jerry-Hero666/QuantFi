import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

const zeroAddress = "0x0000000000000000000000000000000000000000";

const tokenAddrOnSepolia = {
  WETH9: process.env.SEPOLIA_TOKEN_WETH9,
  AAVE: process.env.SEPOLIA_TOKEN_AAVE,
  LINK: process.env.SEPOLIA_TOKEN_LINK,
  UNI: process.env.SEPOLIA_TOKEN_UNI,
  USDT: process.env.SEPOLIA_TOKEN_USDT
}

const contractAddressOnSepolia = {
  TokenSwap: "0x1bfd782183eBBC880FB896a514dFaC1EE2E6A18e",
  UniswapV3Router: "0x333839F88F1Dd8D85a4A287C57f8F61115221c94",
}

const uniswapV3QuoterV2Address = process.env.SEPOLIA_UNISWAP_V3_QUOTERV2;


describe("UniswapV3Router sepolia test", function () {


  it("UniswapV3Router getAmountsOut", async function () {
    const tokenSwap = await ethers.getContractAt("TokenSwap", contractAddressOnSepolia.TokenSwap);

    const amountIn = ethers.parseUnits("1.0", 18); // 1 ETH
    const result = await tokenSwap.getSwapToTargetQuote.staticCall(tokenAddrOnSepolia.WETH9, amountIn);
    console.log("最优路径结果:", result);

    const USDTToken = await ethers.getContractAt("MockERC20", tokenAddrOnSepolia.USDT);
    const USDTDecimals = await USDTToken.decimals.staticCall();
    console.log("USDT Decimals:", USDTDecimals);
    console.log("1 ETH 最多换到的 USDT:", ethers.formatUnits(result[3], USDTDecimals));

    expect(result[0][0]).to.equal(tokenAddrOnSepolia.WETH9);
    expect(result[0][result[0].length - 1]).to.equal(tokenAddrOnSepolia.USDT);

    const quoter = await ethers.getContractAt("MockUniswapV3Quoter", uniswapV3QuoterV2Address);
    const quoterRes = await quoter.quoteExactInput.staticCall(result[2], amountIn);
    console.log("quoter getAmountsOut result2:", quoterRes);
    console.log("quoter 1 ETH 最多换到的 USDT:", ethers.formatUnits(quoterRes[0], USDTDecimals));
    expect(result[3]).to.be.eq(quoterRes[0]);
  })

  it("IDexRouter swapTokensForTokens UNI->USDT", async function () {
    const signers = await ethers.getSigners();
    const account = signers[0];

    const uniAmountIn = ethers.parseUnits("0.0001", 18);
    // 获取路径 (tokenIn + fee + tokenOut)
    const tokenSwap = await ethers.getContractAt("TokenSwap", contractAddressOnSepolia.TokenSwap);
    const swapInfo = await tokenSwap.getSwapToTargetQuote.staticCall(tokenAddrOnSepolia.UNI, uniAmountIn);
    // swapInfo 返回的是一个数组，需要转换为对象
    const swapInfoObj = {
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
    // 设置交易参数
    let params = {
      swapPath: swapInfoObj, 
      recipient: await account.getAddress(),
      amountOutMin: 0,
      deadline: Math.floor(Date.now() / 1000) + 60 * 10
    }
    console.log("交易参数:", params);

    // 检查余额和授权
    const uniToken = await ethers.getContractAt("MockERC20", tokenAddrOnSepolia.UNI);
    const uniBalance = await uniToken.balanceOf(params.recipient)
    console.log(`UNI余额:`, ethers.formatUnits(uniBalance, 18));
    const allowance = await uniToken.allowance(params.recipient, swapInfoObj.dexRouter,);
    // 获取交易前的USDT余额
    const usdtToken = await ethers.getContractAt("MockERC20", tokenAddrOnSepolia.USDT);
    const usdtBalanceBefore = await usdtToken.balanceOf(params.recipient);
    console.log(`交易前USDT余额:`, ethers.formatUnits(usdtBalanceBefore, 6));
    // 检查授权
    if (allowance < uniAmountIn) {
      console.log("需要授权...");
      const approveTx = await uniToken.approve(swapInfoObj.dexRouter, uniAmountIn);
      await approveTx.wait();
      console.log("授权完成");
    }
   
    console.log("执行兑换...");
        // 调用 exactInput 方法
    const dexRouter = await ethers.getContractAt("IDexRouter", swapInfoObj.dexRouter);
    const tx = await dexRouter.swapTokensForTokens(...Object.values(params),
      {
        gasLimit: 3000000, // 设置合适的 gas limit
        gasPrice: ethers.parseUnits("20", "gwei")
      }
    );
    await tx.wait();
    console.log("交易已发送，等待确认...");
    console.log("交易成功！");
    console.log("交易哈希:", tx.hash);

    // 获取交易后的余额
    const uniBalanceAfter = await uniToken.balanceOf(params.recipient);
    const usdtBalanceAfter = await usdtToken.balanceOf(params.recipient);
    console.log(`交易后UNI余额:`, ethers.formatUnits(uniBalanceAfter, 18));
    console.log(`交易后USDT余额:`, ethers.formatUnits(usdtBalanceAfter, 6));
    console.log(`UNI支出:`, ethers.formatUnits(uniAmountIn, 18));
    console.log(`USDT获得:`, ethers.formatUnits(usdtBalanceAfter - usdtBalanceBefore, 6));
    expect(usdtBalanceAfter).to.be.gt(usdtBalanceBefore);
  })
 
  it("IDexRouter swapTokensForTokens ETH->USDT", async function () {
    const signers = await ethers.getSigners();
    const account = signers[0];

    const ethAmountIn = ethers.parseUnits("0.01", 18);
    // 获取路径 (tokenIn + fee + tokenOut)
    const tokenSwap = await ethers.getContractAt("TokenSwap", contractAddressOnSepolia.TokenSwap);
    const swapInfo = await tokenSwap.getSwapToTargetQuote.staticCall(zeroAddress, ethAmountIn);
    // swapInfo 返回的是一个数组，需要转换为对象
    const swapInfoObj = {
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
     // 设置交易参数
     let params = {
      swapPath: swapInfoObj, 
      recipient: await account.getAddress(),
      amountOutMin: 0,
      deadline: Math.floor(Date.now() / 1000) + 60 * 10
    }
    console.log("交易参数:", params);

    // 获取交易前的USDT余额
    const usdtToken = await ethers.getContractAt("MockERC20", tokenAddrOnSepolia.USDT);
    const usdtBalanceBefore = await usdtToken.balanceOf(params.recipient);
    console.log(`交易前USDT余额:`, ethers.formatUnits(usdtBalanceBefore, 6));
   
    console.log("执行兑换...");
        // 调用 exactInput 方法
    const dexRouter = await ethers.getContractAt("IDexRouter", swapInfoObj.dexRouter);
    const tx = await dexRouter.swapTokensForTokens(...Object.values(params),
      {
        value: ethAmountIn,
        gasLimit: 3000000, // 设置合适的 gas limit
        gasPrice: ethers.parseUnits("20", "gwei")
      }
    );
    await tx.wait();
    console.log("交易已发送，等待确认...");
    console.log("交易成功！");
    console.log("交易哈希:", tx.hash);

    // 获取交易后的余额
    const usdtBalanceAfter = await usdtToken.balanceOf(params.recipient);
    console.log(`交易后USDT余额:`, ethers.formatUnits(usdtBalanceAfter, 6));
    console.log(`eth支出:`, ethers.formatUnits(ethAmountIn, 18));
    console.log(`USDT获得:`, ethers.formatUnits(usdtBalanceAfter - usdtBalanceBefore, 6));
    expect(usdtBalanceAfter).to.be.gt(usdtBalanceBefore);
  })
});
