// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {UniswapV3Adapter} from "../../src/adapters/UniswapV3Adapter.sol";
import {OperationParams, OperationType, OperationResult} from "../../src/interfaces/IDefiAdapter.sol";
import {MockERC20} from "../../src/mock/MockERC20.sol";
import {MockNonfungiblePositionManager} from "../../src/mock/MockNonfungiblePositionManager.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract UniswapV3Test is Test {
    UniswapV3Adapter public uniswapV3Adapter;
    MockNonfungiblePositionManager public positionManager;
    MockERC20 public usdc;
    MockERC20 public weth;
    uint256 public tokenId;

    function setUp() public {
        //生成一个用户
        address owner = address(this);
        UniswapV3Adapter impl = new UniswapV3Adapter();

        positionManager = new MockNonfungiblePositionManager();
        //打印positionManager地址
        console.log("positionManager: %s", address(positionManager));
        //初始化
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeWithSelector(
                UniswapV3Adapter.initialize.selector,
                address(positionManager),
                address(this)
            )
        );

        // 获取代理合约实例
        uniswapV3Adapter = UniswapV3Adapter(address(proxy));
    }

    function testAddLiquidity() public {
        usdc = new MockERC20("USDC", "USDC", 6);
        weth = new MockERC20("WETH", "WETH", 18);
        //获取usdc地址
        address usdcAddress = address(usdc);
        //获取weth地址
        address wethAddress = address(weth);

        // 确保代币地址按正确顺序排列
        address tokenA = usdcAddress < wethAddress ? usdcAddress : wethAddress;
        address tokenB = usdcAddress < wethAddress ? wethAddress : usdcAddress;

        //模拟用户
        //授权
        usdc.approve(address(uniswapV3Adapter), 10000);
        weth.approve(address(uniswapV3Adapter), 10000);
        OperationParams memory params;
        params.operationType = OperationType.ADD_LIQUIDITY;
        params.tokens = new address[](2);
        params.tokens[0] = tokenA;
        params.tokens[1] = tokenB;

        params.amounts = new uint256[](4);
        params.amounts[0] = 10000;
        params.amounts[1] = 10000;
        params.amounts[2] = 9900;
        params.amounts[3] = 9900;
        params.recipient = address(this);
        params.deadline = block.timestamp + 1000;
        //编码流动性区间（先测试提供最大区间）
        params.extraData = abi.encode(int24(-887272), int24(887272));
        //手续费是30个基点
        uint24 feeBaseRate = 30;

        OperationResult memory result = uniswapV3Adapter.executeOperation(
            params,
            feeBaseRate
        );
        assertEq(result.success, true);
        tokenId = result.outputAmounts[0];
        console.log("tokenId:", tokenId);
        (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = uniswapV3Adapter.position(tokenId);
        console.log("liquidity:", liquidity);
        address positionOwner = IERC721(positionManager).ownerOf(tokenId);
        console.log("positionOwner:", positionOwner);
        assertEq(positionOwner, address(this));
        // assertEq(tokensOwed0, 10000 - (10000 * 30) / 10000);
    }

    function testRemoveLiquidity() public {
        //先添加流动性
        testAddLiquidity();
        uint256 amount = 10000;
        //mock合约中默认是50个基点的手续费收入
        uint256 MOCK_YIELD_RATE = 50;
        OperationParams memory params;
        params.operationType = OperationType.REMOVE_LIQUIDITY;
        params.tokenId = tokenId;
        params.amounts = new uint256[](2);
        params.amounts[0] = 9900;
        params.amounts[1] = 9900;

        params.recipient = address(this);
        params.deadline = block.timestamp + 1000;
        uint24 feeBaseRate = 30;
        //把erc721代币授权给合约
        IERC721(address(positionManager)).approve(
            address(uniswapV3Adapter),
            tokenId
        );
        OperationResult memory result = uniswapV3Adapter.executeOperation(
            params,
            feeBaseRate
        );
        assertEq(result.success, true);
        console.log(result.outputAmounts[0]);
        console.log(result.outputAmounts[1]);

        uint256 amountActual = (((amount * (10000 - feeBaseRate)) / 10000) *
            (10000 + MOCK_YIELD_RATE)) / 10000;
        assertEq(result.outputAmounts[0], amountActual);
        assertEq(result.outputAmounts[1], amountActual);
    }

    function testCollectFee() public {
        //先添加流动性
        testAddLiquidity();
        uint256 amount = 10000;
        //mock合约中默认是50个基点的手续费收入
        uint256 MOCK_YIELD_RATE = 50;
        OperationParams memory params;
        params.operationType = OperationType.COLLECT_FEES;
        params.tokenId = tokenId;
        params.amounts = new uint256[](2);
        params.amounts[0] = 9900;
        params.amounts[1] = 9900;

        params.recipient = address(this);
        params.deadline = block.timestamp + 1000;
        uint24 feeBaseRate = 30;
        //把erc721代币授权给合约
        IERC721(address(positionManager)).approve(
            address(uniswapV3Adapter),
            tokenId
        );
        OperationResult memory result = uniswapV3Adapter.executeOperation(
            params,
            feeBaseRate
        );
        assertEq(result.success, true);
        console.log("result.amount0:", result.outputAmounts[0]);
        console.log("result.amount1:", result.outputAmounts[1]);
    }
}
