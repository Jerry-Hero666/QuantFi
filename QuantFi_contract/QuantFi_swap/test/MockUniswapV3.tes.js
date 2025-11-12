import { network } from "hardhat";
import { expect } from "chai";

const { ethers } = await network.connect()


// 按照现实比率设置代币初始供应量
const TOKEN_SUPPLIES = {
  BTC: ethers.parseUnits("1000", 18), // 假设1000 BTC
  UNI: ethers.parseUnits("1000000", 18), // 假设100万 UNI
  BNB: ethers.parseUnits("10000", 18), // 假设1万 BNB
  USDT: ethers.parseUnits("10000000", 6), // 假设1000万 USDT (6位小数)
  ETH: ethers.parseUnits("10000", 18) // 假设1万 ETH
};

// 按照现实比率设置模拟价格 (1 tokenIn = price tokenOut)
// 价格都按照18位精度计算
const MOCK_PRICES = {
  // BTC相关价格
  BTC_USDT: ethers.parseUnits("60000", 18),    // 1 BTC = 60,000 USDT
  BTC_ETH: ethers.parseUnits("30", 18),         // 1 BTC = 30 ETH
  BTC_BNB: ethers.parseUnits("150", 18),        // 1 BTC = 150 BNB
  BTC_UNI: ethers.parseUnits("15000", 18),      // 1 BTC = 15,000 UNI
  
  // ETH相关价格
  ETH_USDT: ethers.parseUnits("2000", 18),      // 1 ETH = 2,000 USDT
  ETH_BNB: ethers.parseUnits("5", 18),          // 1 ETH = 5 BNB
  ETH_UNI: ethers.parseUnits("500", 18),        // 1 ETH = 500 UNI
  
  // BNB相关价格
  BNB_USDT: ethers.parseUnits("400", 18),       // 1 BNB = 400 USDT
  BNB_UNI: ethers.parseUnits("100", 18),        // 1 BNB = 100 UNI
  
  // UNI相关价格
  UNI_USDT: ethers.parseUnits("4", 18)          // 1 UNI = 4 USDT
};

// 代币符号映射
const TOKEN_SYMBOLS = {
  BTC: "BTC",
  UNI: "UNI",
  BNB: "BNB",
  USDT: "USDT",
  ETH: "ETH"
};

describe("Uniswap V3 流动性池测试", function () {
  let factory;
  let quoter;
  let swapRouter;
  let tokens = {};
  let owner;

  beforeEach(async function () {
    // 获取测试账户
    const accounts = await ethers.getSigners();
    owner = accounts[0];

    // 部署工厂合约
    const Factory = await ethers.getContractFactory("MockUniswapV3Factory");
    factory = await Factory.deploy();
    await factory.waitForDeployment();

    // 部署所有代币
    for (const [key, symbol] of Object.entries(TOKEN_SYMBOLS)) {
      const Token = await ethers.getContractFactory("MockERC20");
      const decimals = symbol === "USDT" ? 6 : 18;
      const name = symbol === "USDT" ? "Tether USD" : `${symbol} Token`;
      
      // 注意USDT使用6位小数，其他代币使用18位小数
      const token = await Token.deploy(
        name,
        symbol,
        TOKEN_SUPPLIES[key],
        decimals
      );
      await token.waitForDeployment();
      tokens[key] = token;
    }

    // 部署Quoter
    const Quoter = await ethers.getContractFactory("MockUniswapV3Quoter");
    quoter = await Quoter.deploy(await factory.getAddress());
    await quoter.waitForDeployment();

    // 部署SwapRouter，使用ETH作为WETH9
    const SwapRouter = await ethers.getContractFactory("MockUniswapV3SwapRouter");
    swapRouter = await SwapRouter.deploy(
      await factory.getAddress(),
      await tokens.ETH.getAddress()
    );
    await swapRouter.waitForDeployment();

    // 设置模拟价格
    await setMockPrices();
  });

  it("应该成功部署所有代币", async function () {
    for (const [key, token] of Object.entries(tokens)) {
      expect(await token.symbol()).to.equal(TOKEN_SYMBOLS[key]);
      const decimals = key === "USDT" ? 6 : 18;
      expect(await token.decimals()).to.equal(decimals);
      expect(await token.balanceOf(owner.address)).to.equal(TOKEN_SUPPLIES[key]);
    }
  });

  it("应该成功创建BTC-USDT流动性池", async function () {
    const btc = tokens.BTC;
    const usdt = tokens.USDT;
    const fee = 3000; // 0.3% 费率

    // 创建池
    const tx = await factory.createPool(await btc.getAddress(), await usdt.getAddress(), fee);
    await tx.wait();

    // 验证池是否创建成功
    const poolAddress = await factory.getPool(
      await btc.getAddress(),
      await usdt.getAddress(),
      fee
    );
    expect(poolAddress).to.not.equal(ethers.ZeroAddress);
    
    console.log(`BTC-USDT 池已创建: ${poolAddress}`);
  });

  it("应该成功创建ETH-USDT流动性池", async function () {
    const eth = tokens.ETH;
    const usdt = tokens.USDT;
    const fee = 3000; // 0.3% 费率

    // 创建池
    const tx = await factory.createPool(await eth.getAddress(), await usdt.getAddress(), fee);
    await tx.wait();

    // 验证池是否创建成功
    const poolAddress = await factory.getPool(
      await eth.getAddress(),
      await usdt.getAddress(),
      fee
    );
    expect(poolAddress).to.not.equal(ethers.ZeroAddress);
    
    console.log(`ETH-USDT 池已创建: ${poolAddress}`);
  });

  it("应该成功创建BNB-USDT流动性池", async function () {
    const bnb = tokens.BNB;
    const usdt = tokens.USDT;
    const fee = 3000; // 0.3% 费率

    // 创建池
    const tx = await factory.createPool(await bnb.getAddress(), await usdt.getAddress(), fee);
    await tx.wait();

    // 验证池是否创建成功
    const poolAddress = await factory.getPool(
      await bnb.getAddress(),
      await usdt.getAddress(),
      fee
    );
    expect(poolAddress).to.not.equal(ethers.ZeroAddress);
    
    console.log(`BNB-USDT 池已创建: ${poolAddress}`);
  });

  it("应该成功创建UNI-USDT流动性池", async function () {
    const uni = tokens.UNI;
    const usdt = tokens.USDT;
    const fee = 3000; // 0.3% 费率

    // 创建池
    const tx = await factory.createPool(await uni.getAddress(), await usdt.getAddress(), fee);
    await tx.wait();

    // 验证池是否创建成功
    const poolAddress = await factory.getPool(
      await uni.getAddress(),
      await usdt.getAddress(),
      fee
    );
    expect(poolAddress).to.not.equal(ethers.ZeroAddress);
    
    console.log(`UNI-USDT 池已创建: ${poolAddress}`);
  });

  it("应该成功创建BTC-ETH流动性池", async function () {
    const btc = tokens.BTC;
    const eth = tokens.ETH;
    const fee = 3000; // 0.3% 费率

    // 创建池
    const tx = await factory.createPool(await btc.getAddress(), await eth.getAddress(), fee);
    await tx.wait();

    // 验证池是否创建成功
    const poolAddress = await factory.getPool(
      await btc.getAddress(),
      await eth.getAddress(),
      fee
    );
    expect(poolAddress).to.not.equal(ethers.ZeroAddress);
    
    console.log(`BTC-ETH 池已创建: ${poolAddress}`);
  });

  it("应该为所有代币对创建流动性池", async function () {
    const tokenKeys = Object.keys(tokens);
    const fee = 3000; // 0.3% 费率

    // 创建所有可能的代币对
    for (let i = 0; i < tokenKeys.length; i++) {
      for (let j = i + 1; j < tokenKeys.length; j++) {
        const tokenA = tokens[tokenKeys[i]];
        const tokenB = tokens[tokenKeys[j]];

        // 检查池是否已存在
        const existingPool = await factory.getPool(
          await tokenA.getAddress(),
          await tokenB.getAddress(),
          fee
        );

        if (existingPool === ethers.ZeroAddress) {
          // 创建池
          const tx = await factory.createPool(
            await tokenA.getAddress(),
            await tokenB.getAddress(),
            fee
          );
          await tx.wait();

          // 验证池是否创建成功
          const poolAddress = await factory.getPool(
            await tokenA.getAddress(),
            await tokenB.getAddress(),
            fee
          );
          expect(poolAddress).to.not.equal(ethers.ZeroAddress);
          
          console.log(`${tokenKeys[i]}-${tokenKeys[j]} 池已创建: ${poolAddress}`);
        }
      }
    }
  });

  it("应该使用Quoter正确报价BTC到USDT的交换", async function () {
    const btcAmount = ethers.parseUnits("1", 18);
    
    // 调用quoteExactInputSingle
    const quoteResult = await quoter.quoteExactInputSingle.staticCall({
      tokenIn: await tokens.BTC.getAddress(),
      tokenOut: await tokens.USDT.getAddress(),
      fee: 3000,
      amountIn: btcAmount,
      sqrtPriceLimitX96: 0
    });
    
    // 验证报价是否合理（考虑到1%的滑点）
    const expectedAmount = MOCK_PRICES.BTC_USDT;
    const minExpected = expectedAmount * 99n / 100n; // 允许1%的滑点
    const maxExpected = expectedAmount;
    
    expect(quoteResult.amountOut).to.be.at.least(minExpected);
    expect(quoteResult.amountOut).to.be.at.most(maxExpected);
    
    console.log(`1 BTC 兑换 USDT 报价: ${ethers.formatUnits(quoteResult.amountOut, 18)}`);
  });

  it("应该使用SwapRouter正确设置价格", async function () {
    // 验证SwapRouter中的价格设置
    const price = await swapRouter.mockPrices(
      await tokens.ETH.getAddress(),
      await tokens.USDT.getAddress()
    );
    
    expect(price).to.equal(MOCK_PRICES.ETH_USDT);
    
    console.log(`ETH-USDT 价格设置正确: ${ethers.formatUnits(price, 18)}`);
  });

  // 辅助函数：设置所有模拟价格
  async function setMockPrices() {
    // 设置BTC相关价格
    await quoter.setMockPrice(
      await tokens.BTC.getAddress(),
      await tokens.USDT.getAddress(),
      MOCK_PRICES.BTC_USDT
    );
    await swapRouter.setMockPrice(
      await tokens.BTC.getAddress(),
      await tokens.USDT.getAddress(),
      MOCK_PRICES.BTC_USDT
    );

    await quoter.setMockPrice(
      await tokens.BTC.getAddress(),
      await tokens.ETH.getAddress(),
      MOCK_PRICES.BTC_ETH
    );
    await swapRouter.setMockPrice(
      await tokens.BTC.getAddress(),
      await tokens.ETH.getAddress(),
      MOCK_PRICES.BTC_ETH
    );

    await quoter.setMockPrice(
      await tokens.BTC.getAddress(),
      await tokens.BNB.getAddress(),
      MOCK_PRICES.BTC_BNB
    );
    await swapRouter.setMockPrice(
      await tokens.BTC.getAddress(),
      await tokens.BNB.getAddress(),
      MOCK_PRICES.BTC_BNB
    );

    await quoter.setMockPrice(
      await tokens.BTC.getAddress(),
      await tokens.UNI.getAddress(),
      MOCK_PRICES.BTC_UNI
    );
    await swapRouter.setMockPrice(
      await tokens.BTC.getAddress(),
      await tokens.UNI.getAddress(),
      MOCK_PRICES.BTC_UNI
    );

    // 设置ETH相关价格
    await quoter.setMockPrice(
      await tokens.ETH.getAddress(),
      await tokens.USDT.getAddress(),
      MOCK_PRICES.ETH_USDT
    );
    await swapRouter.setMockPrice(
      await tokens.ETH.getAddress(),
      await tokens.USDT.getAddress(),
      MOCK_PRICES.ETH_USDT
    );

    await quoter.setMockPrice(
      await tokens.ETH.getAddress(),
      await tokens.BNB.getAddress(),
      MOCK_PRICES.ETH_BNB
    );
    await swapRouter.setMockPrice(
      await tokens.ETH.getAddress(),
      await tokens.BNB.getAddress(),
      MOCK_PRICES.ETH_BNB
    );

    await quoter.setMockPrice(
      await tokens.ETH.getAddress(),
      await tokens.UNI.getAddress(),
      MOCK_PRICES.ETH_UNI
    );
    await swapRouter.setMockPrice(
      await tokens.ETH.getAddress(),
      await tokens.UNI.getAddress(),
      MOCK_PRICES.ETH_UNI
    );

    // 设置BNB相关价格
    await quoter.setMockPrice(
      await tokens.BNB.getAddress(),
      await tokens.USDT.getAddress(),
      MOCK_PRICES.BNB_USDT
    );
    await swapRouter.setMockPrice(
      await tokens.BNB.getAddress(),
      await tokens.USDT.getAddress(),
      MOCK_PRICES.BNB_USDT
    );

    await quoter.setMockPrice(
      await tokens.BNB.getAddress(),
      await tokens.UNI.getAddress(),
      MOCK_PRICES.BNB_UNI
    );
    await swapRouter.setMockPrice(
      await tokens.BNB.getAddress(),
      await tokens.UNI.getAddress(),
      MOCK_PRICES.BNB_UNI
    );

    // 设置UNI相关价格
    await quoter.setMockPrice(
      await tokens.UNI.getAddress(),
      await tokens.USDT.getAddress(),
      MOCK_PRICES.UNI_USDT
    );
    await swapRouter.setMockPrice(
      await tokens.UNI.getAddress(),
      await tokens.USDT.getAddress(),
      MOCK_PRICES.UNI_USDT
    );

    // 为USDT设置反向价格（因为价格是单向的）
    // 例如：如果 1 ETH = 2000 USDT，那么 1 USDT = 1/2000 ETH
    const usdtToEthPrice = ethers.parseUnits("1", 18) * 10n ** 18n / MOCK_PRICES.ETH_USDT;
    await quoter.setMockPrice(
      await tokens.USDT.getAddress(),
      await tokens.ETH.getAddress(),
      usdtToEthPrice
    );
    await swapRouter.setMockPrice(
      await tokens.USDT.getAddress(),
      await tokens.ETH.getAddress(),
      usdtToEthPrice
    );

    console.log("所有代币价格已设置完成");
  };
});