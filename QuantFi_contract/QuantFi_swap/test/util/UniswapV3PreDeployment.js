import { network } from "hardhat";
import { expect } from "chai";
const { ethers } = await network.connect()
const {parseUnits} = ethers;

// 按照现实比率设置代币初始供应量
const TOKEN_SUPPLIES = {
    BTC: parseUnits("1000", 18), // 假设1000 BTC
    UNI: parseUnits("1000000", 18), // 假设100万 UNI
    BNB: parseUnits("10000", 18), // 假设1万 BNB
    USDT: parseUnits("10000000", 6), // 假设1000万 USDT (6位小数)
    ETH: parseUnits("10000", 18) // 假设1万 ETH
};

// 按照现实比率设置模拟价格 (1 tokenIn = price tokenOut)
// 价格都按照18位精度计算
const MOCK_PRICES = {
    // BTC相关价格
    BTC_USDT: parseUnits("60000", 6),    // 1 BTC = 60,000 USDT
    BTC_ETH: parseUnits("30", 18),         // 1 BTC = 30 ETH
    BTC_BNB: parseUnits("150", 18),        // 1 BTC = 150 BNB
    BTC_UNI: parseUnits("15000", 18),      // 1 BTC = 15,000 UNI

    // ETH相关价格
    ETH_USDT: parseUnits("2000", 6),      // 1 ETH = 2,000 USDT
    ETH_BNB: parseUnits("5", 18),          // 1 ETH = 5 BNB
    ETH_UNI: parseUnits("500", 18),        // 1 ETH = 500 UNI

    // BNB相关价格
    BNB_USDT: parseUnits("400", 6),       // 1 BNB = 400 USDT
    BNB_UNI: parseUnits("100", 18),        // 1 BNB = 100 UNI

    // UNI相关价格
    UNI_USDT: parseUnits("4", 6)          // 1 UNI = 4 USDT
};

// 代币符号映射
const TOKEN_SYMBOLS = {
    BTC: "BTC",
    UNI: "UNI",
    BNB: "BNB",
    USDT: "USDT",
    ETH: "ETH"
};

export async function deployUniswapV3Mocks(ethers) {
    // console.log("======================开始部署 Uniswap V3 MOCK合约...");
    let tokens = {};
    // 获取测试账户
    const accounts = await ethers.getSigners();
    let owner = accounts[0];

    // 部署工厂合约
    const Factory = await ethers.getContractFactory("MockUniswapV3Factory");
    let factory = await Factory.connect(owner).deploy();
    await factory.waitForDeployment();

    // 部署所有代币
    for (const [key, symbol] of Object.entries(TOKEN_SYMBOLS)) {
        const Token = symbol === "ETH" ? await ethers.getContractFactory("MockETH9") : await ethers.getContractFactory("MockERC20");
        const decimals = symbol === "USDT" ? 6 : 18;
        const name = symbol === "USDT" ? "Tether USD" : `${symbol} Token`;

        // 注意USDT使用6位小数，其他代币使用18位小数
        const token = await Token.connect(owner).deploy(
            name,
            symbol,
            TOKEN_SUPPLIES[key],
            decimals
        );
        await token.waitForDeployment();
        tokens[key] = token;
        // console.log(`${symbol} 代币已部署: ${await token.getAddress()}`);
    }

    // 部署Quoter
    const Quoter = await ethers.getContractFactory("MockUniswapV3Quoter");
    let quoter = await Quoter.connect(owner).deploy(await factory.getAddress());
    await quoter.waitForDeployment();

    // 部署SwapRouter，使用ETH作为WETH9
    const SwapRouter = await ethers.getContractFactory("MockUniswapV3SwapRouter");
    let swapRouter = await SwapRouter.connect(owner).deploy(
        await factory.getAddress(),
        await tokens.ETH.getAddress()
    );
    await swapRouter.waitForDeployment();



    // 创建代币对池子
    const tokenKeys = Object.keys(tokens);
    const fees = [3000]; // 0.3% 费率
    for (let i = 0; i < tokenKeys.length; i++) {
        for (let j = i + 1; j < tokenKeys.length; j++) {
            const tokenA = tokens[tokenKeys[i]];
            const tokenB = tokens[tokenKeys[j]];

            for (const fee of fees) {
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
                    // console.log(`${tokenKeys[i]}-${tokenKeys[j]}-${fee} 池已创建: ${poolAddress}`);
                }
            }
        }
        // 注入代币流动性
        await tokens[tokenKeys[i]].connect(owner).mint(await swapRouter.getAddress(), ethers.parseUnits("1000000", 18));
    }
    const res = {factory, quoter, swapRouter, tokens}
    // 设置模拟价格
    await setMockPrices(res, ethers);
    
    // const uniswapV3FactoryAddress = await factory.getAddress();
    // const uniswapV3QuoterV2Address = await quoter.getAddress();
    // const uniswapV3SwapRouterAddress = await swapRouter.getAddress();    
    // console.log("MOCK UniswapV3Factory deployed to:", uniswapV3FactoryAddress);
    // console.log("MOCK UniswapV3QuoterV2 deployed to:", uniswapV3QuoterV2Address);
    // console.log("MOCK UniswapV3SwapRouter deployed to:", uniswapV3SwapRouterAddress);
    // console.log("==========================Uniswap V3 模拟合约部署完成");
    return res;
}

// 辅助函数：设置所有模拟价格
async function setMockPrices({quoter, swapRouter, tokens}, ethers) {
    const tokenSymbols = Object.keys(tokens)
    for (let i = 0; i < tokenSymbols.length; i++) {
        const symbolA = tokenSymbols[i];
        if (symbolA === "USDT") {
            continue; // 跳过USDT
        }
        for (let j = 0; j < tokenSymbols.length; j++) {
            const symbolB = tokenSymbols[j];
            if (symbolA === symbolB ) {
                continue; // 跳过相同代币
            }
            let price = MOCK_PRICES[symbolA + "_" + symbolB]
            if (!price) {
                // parseUnits("30", 18),         // 1 BTC = 30 ETH
                // 价格取反 1/30 BTC = 1 ETH
                let symbol = symbolB + "_" + symbolA
                let parsePrice = parseFloat(1 / ethers.formatUnits(MOCK_PRICES[symbol], 18)).toFixed(12).toString()       
                price = ethers.parseUnits(parsePrice, 18)
            }
            await quoter.setMockPrice(
                await tokens[symbolA].getAddress(), 
                await tokens[symbolB].getAddress(), 
                price
            );
            await swapRouter.setMockPrice(
                await tokens[symbolA].getAddress(), 
                await tokens[symbolB].getAddress(), 
                price
            );
            const result = await quoter.getMockPrice(
                await tokens[symbolA].getAddress(), 
                await tokens[symbolB].getAddress(), 
            )
            console.log(`设置价格: 1 ${symbolA} = ${ethers.formatUnits(price, symbolB == "USDT" ? 6 : 18)} ${symbolB}, 测试获取价格结果: 1 ${symbolA} = ${ethers.formatUnits(result, symbolB == "USDT" ? 6 : 18)} ${symbolB}`);
        }
    }

    // console.log("所有代币价格已设置完成");
};

