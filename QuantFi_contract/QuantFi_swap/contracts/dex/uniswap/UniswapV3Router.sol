// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../IDexRouter.sol";
import "../../lib/Model.sol";
import "./interface/ISwapRouter02.sol";
import "@uniswap/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface WETH9Token {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

/**
 * @title UniswapV3Router
 * @dev 实现IDexRouter接口的Uniswap V3路由器合约
 */
contract UniswapV3Router is IDexRouter, Ownable, ReentrancyGuard {
    // Uniswap V3路由器地址
    ISwapRouter02 public immutable swapRouter;

    // Uniswap V3 Quoter地址
    IQuoterV2 public immutable quoter;

    // Uniswap V3工厂地址
    IUniswapV3Factory public immutable factory;

    WETH9Token public immutable WETH9;

    // 支持的费用层级 (代币对 => 对应的池信息)
    mapping(address token0 => mapping(address token1 => uint24 fee)) public feeTiers;

 
    // 事件
    event SwapTokensForTokens(uint256 amountIn, address inputToken, uint256 amountOut, address to);
    event SetFeeTier(address tokenA, address tokenB, uint24 fee);
    event AddExchangeableToken(address token);
    event RemoveExchangeableToken(address token);

    constructor(
        address _swapRouter,
        address _quoter,
        address _factory,
        address _owner,
        address _WETH9
    ) Ownable(_owner) {
        require(_swapRouter != address(0), "UniswapV3Router: INVALID_ROUTER");
        require(_quoter != address(0), "UniswapV3Router: INVALID_QUOTER");
        require(_factory != address(0), "UniswapV3Router: INVALID_FACTORY");
        require(_owner != address(0), "UniswapV3Router: INVALID_OWNER");
        quoter = IQuoterV2(_quoter);
        swapRouter = ISwapRouter02(_swapRouter);
        factory = IUniswapV3Factory(_factory);
        WETH9 = WETH9Token(_WETH9);
    }

    

    /**
     * @dev 设置代币对的费用层级
     * @param tokenA 代币A地址
     * @param tokenB 代币B地址
     * @param fee 费用层级 500, 3000, 10000
     */
    function setFeeTier(
        address tokenA,
        address tokenB,
        uint24 fee
    ) public onlyOwner {
        address poolAddress = factory.getPool(tokenA, tokenB, fee);
        require(poolAddress != address(0), "UniswapV3Router: POOL_NOT_EXIST");
        feeTiers[tokenA][tokenB] = fee;
        feeTiers[tokenB][tokenA] = fee;
        emit SetFeeTier(tokenA, tokenB, fee);
    }

    /**
     * @dev 实现IDexRouter.swapTokensForTokens
     * 根据给定路径将输入代币交换为输出代币
     */
    function swapTokensForTokens(
        Model.SwapPath memory swapPath,
        address recipient,
        uint256 amountOutMin,
        uint256 deadline
    ) external payable override nonReentrant returns (uint256) {
        require(deadline >= block.timestamp, "UniswapV3Router: EXPIRED");
        require(swapPath.path.length >= 2, "UniswapV3Router: INVALID_PATH");
        require(swapPath.path.length - 1 == swapPath.fees.length, "UniswapV3Router: INVALID_FEE_TIRES");
        require(recipient != address(0), "UniswapV3Router: INVALID_RECIPIENT");

        if (swapPath.inputToken == address(0)) {
            uint256 msgValue = msg.value;
            require(msgValue > 0, "UniswapV3Router: INSUFFICIENT_ETH_SENT");
            WETH9.deposit{value: msgValue}();
            swapPath.inputAmount = msgValue;
            swapPath.inputToken = address(WETH9);
        } else {
            require(swapPath.inputAmount > 0, "UniswapV3Router: INSUFFICIENT_INPUT_AMOUNT");
            // 将代币转入本合约
            IERC20(swapPath.inputToken).transferFrom(msg.sender, address(this), swapPath.inputAmount);
        }

        // 批准路由器使用代币
        IERC20(swapPath.inputToken).approve(address(swapRouter), swapPath.inputAmount);
        // 设置交换参数
        IV3SwapRouter.ExactInputParams memory params = IV3SwapRouter
            .ExactInputParams({
                path: swapPath.pathBytes,
                recipient: recipient,
                amountIn: swapPath.inputAmount,
                amountOutMinimum: amountOutMin
            });

        // 执行交换
        uint256 amountOut = swapRouter.exactInput(params);
        emit SwapTokensForTokens(params.amountIn, swapPath.inputToken, amountOut, params.recipient);
        return amountOut;
    }

    /**
     * @dev 实现IDexRouter.getAmountsOut
     * 返回给定输入数量的最优输出数量、路径
     */
    function getAmountsOut(
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint8 maxHops,
        address[] memory supportedTokens
    ) external override returns (Model.SwapPath memory swapPath) {
        if (tokenIn == address(0)) {
            tokenIn = address(WETH9);
        }
        swapPath.inputAmount = amountIn;
        swapPath.dexRouter = address(this);

        uint256 resultIndex = 0;
        address[] memory directExchange = new address[](2);
        directExchange[0] = tokenIn;
        directExchange[1] = tokenOut;

        uint24 fee = feeTiers[tokenIn][tokenOut];
        if (fee != 0) {
            bytes memory path = abi.encodePacked(tokenIn, fee, tokenOut);
            (uint256 amountOut, , , uint256 gasEstimate) = getAmountOutMulti(path, swapPath.inputAmount);
            swapPath.outputAmount = amountOut;
            swapPath.gasEstimate = gasEstimate;
            swapPath.pathBytes = path;
            swapPath.path = directExchange;
            uint24[] memory fees = new uint24[](1);
            fees[0] = fee;
            swapPath.fees = fees;
        }
        resultIndex++;

        for (uint256 length = 2; length <= maxHops; length++) {
            if (supportedTokens.length < length - 1) continue; // 没有足够的元素

            uint256[] memory used = new uint256[](supportedTokens.length);
            address[] memory combination = new address[](length + 1);
            combination[0] = tokenIn;
            resultIndex = _generatePermutations(
                tokenIn,
                combination,
                1,
                used,
                resultIndex,
                tokenOut,
                swapPath,
                supportedTokens
            );
        }
        return swapPath;
    }

    // 查询币对价格
    function getAmountOutSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) public returns (uint256, uint160, uint32, uint256) {
        try
            quoter.quoteExactInputSingle(
                IQuoterV2.QuoteExactInputSingleParams({
                    tokenIn: tokenIn,
                    tokenOut: tokenOut,
                    amountIn: amountIn,
                    fee: fee,
                    sqrtPriceLimitX96: sqrtPriceLimitX96
                })
            )
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        ) {
            return (
                amountOut,
                sqrtPriceX96After,
                initializedTicksCrossed,
                gasEstimate
            );
        } catch {
            // 如果查询失败，返回零
            return (0, 0, 0, 0);
        }
    }

    // 查询多币对价格
    function getAmountOutMulti(
        bytes memory path,
        uint256 amountIn
    ) public returns (uint256, uint160[] memory, uint32[] memory, uint256) {
        try quoter.quoteExactInput(path, amountIn) returns (
            uint256 amountOut,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        ) {
            return (
                amountOut,
                sqrtPriceX96AfterList,
                initializedTicksCrossedList,
                gasEstimate
            );
        } catch {
            // 如果查询失败，返回零
            return (0, new uint160[](0), new uint32[](0), 0);
        }
    }

 

    // 递归生成排列
    function _generatePermutations(
        address tokenIn,
        address[] memory combination,
        uint256 depth,
        uint256[] memory used,
        uint256 resultIndex,
        address tokenOut,
        Model.SwapPath memory swapPath,
        address[] memory supportedTokens
    ) private returns (uint256) {
        // 达到目标长度，保存组合
        if (depth == combination.length - 1) {
            combination[depth] = tokenOut;
            address[] memory exchangeRecord = new address[](combination.length);
            uint24[] memory fees = new uint24[](combination.length - 1);
            bytes memory path = new bytes(0);
            for (uint256 i = 0; i < combination.length; i++) {
                exchangeRecord[i] = combination[i];
                if (i > 0) {
                    uint24 fee = feeTiers[combination[i - 1]][combination[i]];
                    if (fee == 0) {
                        return resultIndex + 1;
                    }
                    fees[i - 1] = fee;
                    path = bytes.concat(path, abi.encodePacked(uint24(fee), combination[i]));
                } else {
                    path = bytes.concat(path, abi.encodePacked(combination[i]));
                }
            }

            (uint256 amountOut, , , uint256 gasEstimate) = getAmountOutMulti(path, swapPath.inputAmount);
            if (amountOut > swapPath.outputAmount) {
                swapPath.outputAmount = amountOut;
                swapPath.gasEstimate = gasEstimate;
                swapPath.path = exchangeRecord;
                swapPath.pathBytes = path;
                swapPath.fees = fees;
            }

            return resultIndex + 1;
        }

        // 遍历所有元素
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            // 跳过tokenIn和已使用的元素
            if (supportedTokens[i] == tokenIn || used[i] > 0) continue;

            // 标记为已使用
            used[i] = 1;

            // 添加到组合
            combination[depth] = supportedTokens[i];

            // 递归生成下一层
            resultIndex = _generatePermutations(
                tokenIn,
                combination,
                depth + 1,
                used,
                resultIndex,
                tokenOut,
                swapPath,
                supportedTokens
            );

            // 回溯
            used[i] = 0;
        }

        return resultIndex;
    }

    /**
     * @dev 实现IDexRouter.dexName
     * 返回DEX的名称
     */
    function dexName() external pure override returns (string memory) {
        return "UniswapV3";
    }
}
