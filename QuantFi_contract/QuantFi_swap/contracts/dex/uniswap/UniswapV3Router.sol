// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../IDexRouter.sol";
import "../../lib/Model.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
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
    ISwapRouter public immutable swapRouter;

    // Uniswap V3 Quoter地址
    IQuoterV2 public immutable quoter;

    // Uniswap V3工厂地址
    IUniswapV3Factory public immutable factory;

    WETH9Token public immutable WETH9;

    // 支持交换的tokens
    address[] public exchangeableTokens;

    // 支持的费用层级 (代币对 => 对应的池信息)
    mapping(address token0 => mapping(address token1 => uint24 fee)) public feeTiers;

 
    // 事件
    event SwapTokensForTokens(uint256 amountIn, uint256 amountOut, address to);
    event SetFeeTier(address tokenA, address tokenB, uint24 fee);
    event AddExchangeableToken(address token);
    event RemoveExchangeableToken(address token);

    constructor(
        address _swapRouter,
        address _quoter,
        address _factory,
        address _owner,
        address _WETH9,
        address[] memory _exchangeableTokens
    ) Ownable(_owner) {
        require(_exchangeableTokens.length > 1, "UniswapV3Router: INVALID_TOKENS_LENGTH");
        require(_swapRouter != address(0), "UniswapV3Router: INVALID_ROUTER");
        require(_quoter != address(0), "UniswapV3Router: INVALID_QUOTER");
        require(_factory != address(0), "UniswapV3Router: INVALID_FACTORY");
        require(_owner != address(0), "UniswapV3Router: INVALID_OWNER");
        quoter = IQuoterV2(_quoter);
        swapRouter = ISwapRouter(_swapRouter);
        factory = IUniswapV3Factory(_factory);
        WETH9 = WETH9Token(_WETH9);
        exchangeableTokens = _exchangeableTokens;
    }

    /**
     * @dev 添加可交换的代币
     * @param token 代币地址
     */
    function addExchangeableToken(address token) public onlyOwner {
        require(token != address(0), "UniswapV3Router: INVALID_TOKEN");
        bool exists = false;
        for (uint256 i = 0; i < exchangeableTokens.length; i++) {
            if (exchangeableTokens[i] == token) {
                exists = true;
                break;
            }
        }
        require(!exists, "UniswapV3Router: TOKEN_ALREADY_EXIST");
        exchangeableTokens.push(token);
        emit AddExchangeableToken(token);
    }

    /**
     * @dev 移除可交换的代币
     * @param token 代币地址
     */
    function removeExchangeableToken(address token) public onlyOwner {
        uint256 length = exchangeableTokens.length; // 获取数组长度
        for (uint256 i = 0; i < length; i++) {
            if (exchangeableTokens[i] == token) {
                // 将最后一个元素移动到当前位置
                exchangeableTokens[i] = exchangeableTokens[length - 1];
                // 删除最后一个元素
                exchangeableTokens.pop();
                emit RemoveExchangeableToken(token);
                break;
            }
        }
    }

    function getAllExchangeableTokens() public view returns (address[] memory) {
        return exchangeableTokens;
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
     * 根据给定路径将精确数量的输入代币交换为输出代币
     */
    function swapTokensForTokens(
        Model.SwapPath memory swapPath,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    ) external payable override nonReentrant returns (uint256) {
        require(deadline >= block.timestamp, "UniswapV3Router: EXPIRED");
        require(swapPath.path.length >= 2, "UniswapV3Router: INVALID_PATH");

        if (tokenIn == address(0) || tokenIn == address(WETH9)) {
            require(msg.value > 0, "UniswapV3Router: INSUFFICIENT_ETH_SENT");
            // ETH 转 WETH
            WETH9.deposit{value: msg.value}();
            amountIn = msg.value;
            tokenIn = address(WETH9);
        } else {
            // 将代币转入本合约
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        }

        // 批准路由器使用代币
        IERC20(tokenIn).approve(address(swapRouter), amountIn);
        // 设置交换参数
        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: swapPath.pathBytes,
                recipient: to,
                deadline: deadline,
                amountIn: amountIn,
                amountOutMinimum: amountOutMin
            });

        // 执行交换
        uint256 amountOut = swapRouter.exactInput(params);
        emit SwapTokensForTokens(amountIn, amountOut, to);
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
        uint8 maxHops
    ) external override returns (Model.SwapPath memory swapPath) {
        if (tokenIn == address(0)) {
            tokenIn = address(WETH9);
        }
        swapPath.inputAmount = amountIn;
        swapPath.dexRouter = address(this);
        // 所有路径组合
        uint256 totalCombinations = _calculateTotalCombinations(exchangeableTokens.length - 1);
        address[][] memory pathRecord = new address[][](totalCombinations);

        uint256 resultIndex = 0;
        address[] memory directExchange = new address[](2);
        directExchange[0] = tokenIn;
        directExchange[1] = tokenOut;
        pathRecord[resultIndex] = directExchange;

        uint24 fee = feeTiers[tokenIn][tokenOut];
        // require(fee != 0, "UniswapV3Router: NO_FEE_TIER_SET");
        if (fee != 0) {
            bytes memory path = abi.encodePacked(tokenIn, fee, tokenOut);
            (uint256 amountOut, , , ) = getAmountOutMulti(path, swapPath.inputAmount);
            swapPath.outputAmount = amountOut;
            swapPath.pathBytes = path;
            swapPath.path = pathRecord[resultIndex];
        }
        resultIndex++;

        for (uint256 length = 2; length <= maxHops; length++) {
            if (exchangeableTokens.length < length - 1) continue; // 没有足够的元素

            uint256[] memory used = new uint256[](exchangeableTokens.length);
            address[] memory combination = new address[](length + 1);
            combination[0] = tokenIn;
            resultIndex = _generatePermutations(
                tokenIn,
                combination,
                1,
                used,
                pathRecord,
                resultIndex,
                tokenOut,
                swapPath
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

    // 计算组合总数
    function _calculateTotalCombinations(uint256 n) private pure returns (uint256) {
        if (n == 0) return 1; // 只有长度为1的组合

        uint256 total = 1; // 长度为1
        uint256 currentPermutation = 1;

        for (uint256 k = 1; k <= n; k++) {
            currentPermutation *= (n - (k - 1));
            total += currentPermutation;
        }

        return total;
    }

    // 递归生成排列
    function _generatePermutations(
        address tokenIn,
        address[] memory combination,
        uint256 depth,
        uint256[] memory used,
        address[][] memory pathRecord,
        uint256 resultIndex,
        address tokenOut,
        Model.SwapPath memory swapPath
    ) private returns (uint256) {
        // 达到目标长度，保存组合
        if (depth == combination.length - 1) {
            combination[depth] = tokenOut;
            pathRecord[resultIndex] = new address[](combination.length);
            bytes memory path = new bytes(0);
            for (uint256 i = 0; i < combination.length; i++) {
                pathRecord[resultIndex][i] = combination[i];
                if (i > 0) {
                    uint24 fee = feeTiers[combination[i - 1]][combination[i]];
                    if (fee == 0) {
                        return resultIndex + 1;
                    }
                    // require(fee != 0, "UniswapV3Router: NO_FEE_TIER_SET");
                    path = bytes.concat(path, abi.encodePacked(uint24(fee), combination[i]));
                } else {
                    path = bytes.concat(path, abi.encodePacked(combination[i]));
                }
            }

            (uint256 amountOut, , , ) = getAmountOutMulti(path, swapPath.inputAmount);
            if (amountOut > swapPath.outputAmount) {
                swapPath.outputAmount = amountOut;
                swapPath.path = pathRecord[resultIndex];
                swapPath.pathBytes = path;
            }

            return resultIndex + 1;
        }

        // 遍历所有元素
        for (uint256 i = 0; i < exchangeableTokens.length; i++) {
            // 跳过tokenIn和已使用的元素
            if (exchangeableTokens[i] == tokenIn || used[i] > 0) continue;

            // 标记为已使用
            used[i] = 1;

            // 添加到组合
            combination[depth] = exchangeableTokens[i];

            // 递归生成下一层
            resultIndex = _generatePermutations(
                tokenIn,
                combination,
                depth + 1,
                used,
                pathRecord,
                resultIndex,
                tokenOut,
                swapPath
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
