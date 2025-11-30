# QuantFi Swap - 多DEX最优路径代币交换系统

一个基于 Hardhat 3 和 Hardhat Ignition 开发的智能合约项目，实现了跨多个去中心化交易所（DEX）的代币交换功能，能够自动查找并执行最优交换路径。

## 📋 目录

- [项目概述](#项目概述)
- [核心特性](#核心特性)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [环境配置](#环境配置)
- [部署指南](#部署指南)
- [使用说明](#使用说明)
- [合约架构](#合约架构)
- [测试](#测试)


## 项目概述

QuantFi Swap 是一个智能合约系统，允许用户在不同的去中心化交易所之间进行代币交换，并自动找到最优的交换路径。系统设计为可插拔架构，支持多个 DEX 协议，目前主要实现了 Uniswap V3 的集成。

### 主要功能

- 🔄 **多DEX路由**：支持多个去中心化交易所，可动态添加和移除
- 🎯 **最优路径查找**：自动计算从任意代币到目标代币（默认USDT）的最优交换路径
- ⚙️ **可配置参数**：支持配置最大跳数、目标代币、支持的代币列表等
- 🛡️ **安全设计**：使用 OpenZeppelin 库，实现访问控制和重入保护
- 📊 **报价查询**：提供交换前的报价查询功能

## 核心特性

- ✅ 合约本身不持有流动性，仅作为路由层与外部 DEX 交互
- ✅ 可配置的最大交换跳数（默认4跳）
- ✅ 可配置的目标代币（默认USDT）
- ✅ 可插拔的 DEX 接口设计，易于扩展
- ✅ 支持动态添加/移除 DEX 路由器和代币
- ✅ 使用 Hardhat Ignition 进行模块化部署

## 技术栈

- **开发框架**: Hardhat 3.0+
- **部署工具**: Hardhat Ignition 3.0+
- **Solidity**: 0.8.20
- **安全库**: OpenZeppelin Contracts 5.4.0
- **DEX集成**: Uniswap V3 (SwapRouter02, QuoterV2, Factory)
- **测试框架**: Mocha + Chai
- **TypeScript**: 5.8.0

## 项目结构

```
QuantFi_swap/
├── contracts/                    # 智能合约源码
│   ├── dex/                      # DEX 路由器实现
│   │   └── uniswap/
│   │       ├── UniswapV3Router.sol
│   │       └── interface/
│   ├── lib/                      # 库文件
│   │   └── Model.sol            # 数据模型定义
│   ├── mock/                     # 测试用的模拟合约
│   ├── IDexRouter.sol           # DEX 路由器接口
│   ├── PathFinder.sol           # 路径查找合约
│   └── TokenSwap.sol            # 主合约
├── ignition/                     # Hardhat Ignition 部署配置
│   └── modules/
│       └── sepolia/              # Sepolia 测试网部署模块
│           ├── TokenSwapModule.ts
│           └── UniswapV3RouterModule.ts
├── scripts/                      # 部署和工具脚本
│   ├── SetFeeTier.ts
│   └── uniswapRouter#exactInput.ts
├── test/                         # 测试文件
│   ├── TokenSwap.test.js
│   ├── TokenSwap.sepolia.test.js
│   └── MockUniswapV3.tes.js
├── hardhat.config.ts             # Hardhat 配置
├── package.json                  # 项目依赖
└── README.md                     # 项目文档
```

## 快速开始

### 前置要求

- Node.js >= 18.0.0
- npm 或 yarn
- Git

### 安装依赖

```bash
npm install
```

### 编译合约

```bash
npx hardhat compile
```

## 环境配置

在项目根目录创建 `.env` 文件，配置以下环境变量：

```env
# Sepolia 测试网配置
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
PRIVATE_KEY=your_private_key_here

# 代币地址（Sepolia 测试网）
SEPOLIA_TOKEN_USDT=0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0
SEPOLIA_TOKEN_WETH9=0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14
SEPOLIA_TOKEN_AAVE=0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a
SEPOLIA_TOKEN_LINK=0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5
SEPOLIA_TOKEN_UNI=0x1f9840a85d5af5bf1d1762f925bdaddc4201f984

# Uniswap V3 合约地址（Sepolia 测试网）
SEPOLIA_UNISWAP_V3_SWAPROUTER02=0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E
SEPOLIA_UNISWAP_V3_QUOTERV2=0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3
SEPOLIA_UNISWAP_V3_FACTORY=0x0227628f3F023bb0B980b67D528571c95c6DaC1c

# 路径查找配置
MAX_HOPS=4
```

**注意**: 所有环境变量都是必需的，部署前请确保都已正确配置，否则会抛出错误。

## 部署指南

### 使用 Hardhat Ignition 部署

项目使用 Hardhat Ignition 进行模块化部署，支持依赖管理和事务编排。

#### 部署到 Sepolia 测试网

```bash
# 部署 TokenSwap 模块
npx hardhat ignition deploy ignition/modules/sepolia/TokenSwapModule.ts --network sepolia

# 部署 UniswapV3Router 模块（会自动部署 TokenSwap 并配置）
npx hardhat ignition deploy ignition/modules/sepolia/UniswapV3RouterModule.ts --network sepolia
```

#### 部署流程说明

1. **TokenSwapModule**: 部署 `TokenSwap` 合约，同时会创建并部署 `PathFinder` 合约
2. **UniswapV3RouterModule**: 部署 `UniswapV3Router` 合约，并自动将其添加到 `TokenSwap` 的 DEX 路由器列表
3. UniswapV3RouterModule 部署完成后执行 ./scripts/SetFeeTier.ts 设置代币对之间费率

```bash
# 设置代币对之间费率
npx hardhat run ./scripts/SetFeeTier.ts --network sepolia

```

#### 查看部署结果

部署完成后，部署地址会保存在：
```
ignition/deployments/chain-{chainId}/deployed_addresses.json
```

## 使用说明

### 合约交互示例

#### 1. 获取交换报价

```solidity
// 查询从 WETH 到 USDT 的交换报价
Model.SwapPath memory quote = await tokenSwap.getSwapToTargetQuote(
    wethAddress,      // 输入代币地址
    ethers.parseEther("1.0")  // 输入数量（1 WETH）
);

console.log("最优路径:", quote.path);
console.log("预期输出:", quote.outputAmount);
console.log("使用的DEX:", quote.dexRouter);
```

#### 2. 添加新的 DEX 路由器（仅所有者）

```solidity
await tokenSwap.addDexRouter(
    "uniswapV3",           // DEX 名称
    uniswapV3RouterAddress // 路由器地址
);
```

#### 3. 配置支持的代币（仅所有者）

```solidity
// 添加支持的代币
await tokenSwap.addSupportToken(tokenAddress);

// 移除支持的代币
await tokenSwap.removeSupportedToken(tokenAddress);
```

#### 4. 更新配置参数（仅所有者）

```solidity
// 设置最大跳数
await tokenSwap.setMaxHops(5);

// 设置目标代币
await tokenSwap.setTargetToken(newTargetTokenAddress);
```

### 使用 JavaScript/TypeScript

```javascript
const { ethers } = require("hardhat");

async function main() {
  const TokenSwap = await ethers.getContractAt(
    "TokenSwap",
    "0x..." // TokenSwap 合约地址
  );

  // 获取报价
  const quote = await TokenSwap.getSwapToTargetQuote.staticCall(
    "0x...", // 输入代币地址
    ethers.parseEther("1.0")
  );

  console.log("最优路径:", quote.path);
  console.log("预期输出:", quote.outputAmount.toString());
}
```

## 合约架构

### TokenSwap

主合约，提供用户交互接口。主要功能：

- 管理 `PathFinder` 合约实例
- 提供报价查询接口
- 管理 DEX 路由器和代币配置（通过 PathFinder）

**构造函数参数**:
- `_targetToken`: 目标代币地址（默认USDT）
- `_maxHops`: 最大交换跳数（默认4）
- `_supportedTokens`: 初始支持的代币数组
- `_owner`: 合约所有者地址

### PathFinder

路径查找引擎，负责计算最优交换路径。主要功能：

- 遍历所有已注册的 DEX 路由器
- 调用每个路由器的 `getAmountsOut` 方法获取报价
- 比较并返回最优路径

**核心方法**:
- `findOptimalPath()`: 查找最优交换路径
- `addDexRouter()`: 添加 DEX 路由器
- `setMaxHops()`: 设置最大跳数
- `setTargetToken()`: 设置目标代币

### UniswapV3Router

Uniswap V3 的适配器实现，实现了 `IDexRouter` 接口。主要功能：

- 与 Uniswap V3 的 SwapRouter02、QuoterV2 和 Factory 交互
- 支持多跳路径查找
- 管理代币对的费用层级（Fee Tier）

**构造函数参数**:
- `_swapRouter`: Uniswap V3 SwapRouter02 地址
- `_quoter`: Uniswap V3 QuoterV2 地址
- `_factory`: Uniswap V3 Factory 地址
- `_owner`: 合约所有者地址
- `_WETH9`: WETH9 代币地址

### IDexRouter

所有 DEX 路由器必须实现的接口，定义了：

- `swapTokensForTokens()`: 执行代币交换
- `getAmountsOut()`: 获取交换报价和路径
- `dexName()`: 返回 DEX 名称

## 测试

### 运行测试

```bash
# 运行所有测试
npm test

# 运行特定测试文件
npx hardhat test test/TokenSwap.test.js

# 运行 Sepolia 测试网测试
npx hardhat test test/TokenSwap.sepolia.test.js --network sepolia
```

### 测试覆盖

- ✅ TokenSwap 合约功能测试
- ✅ PathFinder 路径查找测试
- ✅ UniswapV3Router 集成测试
- ✅ Mock 合约测试
- ✅ 访问控制测试
- ✅ 边界条件测试


## 开发指南

### 添加新的 DEX 支持

1. 实现 `IDexRouter` 接口
2. 在 `PathFinder` 中注册新的 DEX 路由器
3. 编写相应的测试用例

示例：

```solidity
contract NewDexRouter is IDexRouter, Ownable, ReentrancyGuard {
    function getAmountsOut(
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint8 maxHops,
        address[] memory supportedTokens
    ) external override returns (Model.SwapPath memory) {
        // 实现路径查找逻辑
    }
    
    function swapTokensForTokens(
        Model.SwapPath memory swapPath,
        address recipient,
        uint256 amountOutMin,
        uint256 deadline
    ) external payable override returns (uint256) {
        // 实现交换逻辑
    }
    
    function dexName() external pure override returns (string memory) {
        return "newDex";
    }
}
```

### 代码规范

- 使用 Solidity 0.8.20
- 遵循 Solidity 风格指南
- 所有公共函数必须包含 NatSpec 注释
- 使用有意义的变量和函数名


---

**注意**: 本项目仍在积极开发中，生产环境使用前请进行充分测试和安全审计。
