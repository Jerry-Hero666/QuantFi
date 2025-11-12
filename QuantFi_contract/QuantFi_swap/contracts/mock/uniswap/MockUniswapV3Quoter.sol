// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import "../MockERC20.sol";
import "hardhat/console.sol";

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
    function getMockPrice(address tokenIn, address tokenOut) public view returns (uint256) {
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
            // 获取代币精度
            uint256 tokenInDecimals = MockERC20(tokenIn).decimals();
            // 考虑代币精度
            amountOut = (amountOut * price) / 10**tokenInDecimals;
            
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
        (address[] memory tokenPath, uint24[] memory fees) = decodePath(path);
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
        amountIn = (params.amount * 10**MockERC20(params.tokenIn).decimals() * 10100) / (price * 10000);
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
        (address[] memory tokenPath, uint24[] memory fees) = decodePath(path);
        
        // 反向计算输入金额
        amountIn = amountOut;

        for (uint i = tokenPath.length - 1; i > 0; i--) {
            address tokenIn = tokenPath[i - 1];
            address tokenOut = tokenPath[i];
            
            uint256 price = getMockPrice(tokenIn, tokenOut);
            // 反向计算，考虑滑点
            amountIn = (amountIn * 10**MockERC20(tokenIn).decimals() * 10100) / (price * 10000);
        }
        
        // 模拟其他返回值
        sqrtPriceX96AfterList = new uint160[](tokenPath.length - 1);
        initializedTicksCrossedList = new uint32[](tokenPath.length - 1);
        gasEstimate = 50000; // 模拟gas消耗
    }

    // 辅助函数：解析路径字节数组为地址数组
    function decodePath(bytes memory path) internal pure returns (address[] memory tokens, uint24[] memory fees) {
        uint256 length = path.length;
        require(length >= 20, "Path too short");
        
        // 计算跳数（每跳 = 20字节 token + 3字节 fee）
        uint256 hops = (path.length - 20) / 23;
        tokens = new address[](hops + 1);
        fees = new uint24[](hops);
        
        // 提取第一个地址
        tokens[0] = readAddress(path, 0);
        
        // 循环提取后续的费用和地址
        for (uint256 i = 0; i < hops; ++i) {
            // 计算费用的起始位置
            uint256 feeOffset = 20 + i * 23;
            // 提取费用
            fees[i] = readFee(path, feeOffset);
            
            // 计算下一个地址的起始位置
            uint256 addressOffset = feeOffset + 3;
            // 提取地址
            tokens[i + 1] = readAddress(path, addressOffset);

        }
        
        return (tokens, fees);

    }

    /**
     * @dev 从路径中读取地址
     * @param path 路径字节数组
     * @param offset 偏移量
     * @return 读取的地址
     */
    function readAddress(bytes memory path, uint256 offset) private pure returns (address) {
        // 确保偏移量不会导致越界访问
        require(offset + 20 <= path.length, "Address read out of bounds");
        
        address addr;
        assembly {
            // 从path中读取ADDRESS_SIZE长度的字节，并转换为地址
            // 由于address是20字节，而calldataload读取32字节，我们需要清除高12字节
            addr := shr(96, mload(add(add(path, 32), offset)))
        }
        return addr;
    }

    /**
     * @dev 从路径中读取费用
     * @param path 路径字节数组
     * @param offset 偏移量
     * @return 读取的费用（uint24类型）
     */
    function readFee(bytes memory path, uint256 offset) private pure returns (uint24) {
        // 确保偏移量不会导致越界访问
        require(offset + 3 <= path.length, "Fee read out of bounds");
        
        uint24 fee;
        assembly {
            // 从path中读取FEE_SIZE长度的字节，并转换为uint24
            // 由于calldataload读取32字节，我们需要将读取的值右移232位（29字节）以获取低3字节
            // 然后用0xFFFFFF掩码确保只保留低3字节
            fee := and(shr(232, mload(add(add(path, 32), offset))), 0xFFFFFF)
        }
        return fee;
    }

    
}
