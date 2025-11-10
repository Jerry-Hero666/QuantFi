// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";

contract MockUniswapV3Quoter is IQuoterV2 {
    address public factory;
    mapping(address => mapping(address => uint256)) public mockPrices; // tokenIn => tokenOut => price (1 tokenIn = price tokenOut)

    constructor(address _factory) {
        factory = _factory;
    }

    // 设置模拟价格
    function setMockPrice(address tokenIn, address tokenOut, uint256 price) external {
        mockPrices[tokenIn][tokenOut] = price;
    }

    // 获取模拟价格，如果不存在则使用1:1的价格
    function getMockPrice(address tokenIn, address tokenOut) internal view returns (uint256) {
        uint256 price = mockPrices[tokenIn][tokenOut];
        if (price == 0) {
            return 1e18; // 默认1:1
        }
        return price;
    }

    // 计算路径上的价格，支持多级跳转
    function getAmountOut(uint256 amountIn, address[] memory path) internal view returns (uint256 amountOut) {
        amountOut = amountIn;
        
        for (uint i = 0; i < path.length - 1; i++) {
            address tokenIn = path[i];
            address tokenOut = path[i + 1];
            
            // 获取价格并计算输出金额
            uint256 price = getMockPrice(tokenIn, tokenOut);
            // 假设都是18位精度的代币
            amountOut = (amountOut * price) / 1e18;
            
            // 模拟滑点（1%）
            amountOut = (amountOut * 9900) / 10000;
        }
    }

    // 实现IQuoterV2接口的函数
    function quoteExactInputSingle(
        IQuoterV2.QuoteExactInputSingleParams memory params
    ) external override returns (
        uint256 amountOut,
        uint160 sqrtPriceX96After,
        uint32 initializedTicksCrossed,
        uint256 gasEstimate
    ) {
        address[] memory path = new address[](2);
        path[0] = params.tokenIn;
        path[1] = params.tokenOut;
        
        amountOut = getAmountOut(params.amountIn, path);
        sqrtPriceX96After = 0;
        initializedTicksCrossed = 0;
        gasEstimate = 50000;
    }

    function quoteExactInput(
        bytes memory path,
        uint256 amountIn
    ) external override returns (
        uint256 amountOut,
        uint160[] memory sqrtPriceX96AfterList,
        uint32[] memory initializedTicksCrossedList,
        uint256 gasEstimate
    ) {
        // 解析路径字节数组
        address[] memory tokenPath = decodePath(path);
        
        // 计算输出金额
        amountOut = getAmountOut(amountIn, tokenPath);
        
        // 模拟其他返回值
        sqrtPriceX96AfterList = new uint160[](tokenPath.length - 1);
        initializedTicksCrossedList = new uint32[](tokenPath.length - 1);
        gasEstimate = 50000 * (tokenPath.length / 2); // 模拟gas消耗
    }

    function quoteExactOutputSingle(
        IQuoterV2.QuoteExactOutputSingleParams memory params
    ) external override returns (
        uint256 amountIn,
        uint160 sqrtPriceX96After,
        uint32 initializedTicksCrossed,
        uint256 gasEstimate
    ) {
        // 反向计算输入金额
        uint256 price = getMockPrice(params.tokenIn, params.tokenOut);
        // 考虑滑点，需要更多的输入
        amountIn = (params.amount * 1e18 * 10100) / (price * 10000);
        sqrtPriceX96After = 0;
        initializedTicksCrossed = 0;
        gasEstimate = 50000;
    }

    function quoteExactOutput(
        bytes memory path,
        uint256 amountOut
    ) external override returns (
        uint256 amountIn,
        uint160[] memory sqrtPriceX96AfterList,
        uint32[] memory initializedTicksCrossedList,
        uint256 gasEstimate
    ) {
        // 解析路径字节数组
        address[] memory tokenPath = decodePath(path);
        
        // 反向计算输入金额
        amountIn = amountOut;
        
        for (uint i = tokenPath.length - 1; i > 0; i--) {
            address tokenIn = tokenPath[i - 1];
            address tokenOut = tokenPath[i];
            
            uint256 price = getMockPrice(tokenIn, tokenOut);
            // 反向计算，考虑滑点
            amountIn = (amountIn * 1e18 * 10100) / (price * 10000);
        }
        
        // 模拟其他返回值
        sqrtPriceX96AfterList = new uint160[](tokenPath.length - 1);
        initializedTicksCrossedList = new uint32[](tokenPath.length - 1);
        gasEstimate = 50000; // 模拟gas消耗
    }

    // 辅助函数：解析路径字节数组为地址数组
    function decodePath(bytes memory path) internal pure returns (address[] memory) {
        uint256 length = path.length;
        require(length % 20 == 0, "Invalid path length");
        
        uint256 numTokens = length / 20;
        address[] memory tokens = new address[](numTokens);
        
        for (uint i = 0; i < numTokens; i++) {
            address token;
            assembly {
                token := mload(add(add(path, 20), mul(i, 20)))
            }
            tokens[i] = token;
        }
        
        return tokens;
    }

    
}
