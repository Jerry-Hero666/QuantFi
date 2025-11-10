// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MockUniswapV3SwapRouter is ISwapRouter {
    using SafeERC20 for IERC20;

    address public factory;
    address public WETH9;
    
    // 价格模拟，与Quoter保持一致
    mapping(address => mapping(address => uint256)) public mockPrices;

    constructor(address _factory, address _WETH9) {
        factory = _factory;
        WETH9 = _WETH9;
    }

    // 设置模拟价格
    function setMockPrice(address tokenIn, address tokenOut, uint256 price) external {
        mockPrices[tokenIn][tokenOut] = price;
    }

    // 获取模拟价格
    function getMockPrice(address tokenIn, address tokenOut) internal view returns (uint256) {
        uint256 price = mockPrices[tokenIn][tokenOut];
        if (price == 0) {
            return 1e18; // 默认1:1
        }
        return price;
    }

    // 计算路径上的输出金额，支持多级跳转
    function getAmountOut(uint256 amountIn, address[] memory path) internal view returns (uint256 amountOut) {
        amountOut = amountIn;
        
        for (uint i = 0; i < path.length - 1; i++) {
            address currentTokenIn = path[i];
            address currentTokenOut = path[i + 1];
            
            // 获取价格并计算输出金额
            uint256 price = getMockPrice(currentTokenIn, currentTokenOut);
            // 假设都是18位精度的代币
            amountOut = (amountOut * price) / 1e18;
            
            // 模拟滑点和手续费（0.3%）
            amountOut = (amountOut * 997) / 1000;
        }
    }

    // 实现ISwapRouter接口的函数
    function exactInputSingle(
        ISwapRouter.ExactInputSingleParams calldata params
    ) external override payable returns (uint256 amountOut) {
        require(params.deadline >= block.timestamp, "Transaction too old");
        
        address[] memory path = new address[](2);
        path[0] = params.tokenIn;
        path[1] = params.tokenOut;
        
        // 转移输入代币
        if (params.tokenIn == WETH9 && msg.value > 0) {
            // 处理WETH情况
        } else {
            IERC20(params.tokenIn).safeTransferFrom(msg.sender, address(this), params.amountIn);
        }
        
        // 计算输出金额
        amountOut = getAmountOut(params.amountIn, path);
        
        // 转移输出代币
        if (params.tokenOut == WETH9) {
            (bool success, ) = payable(msg.sender).call{value: amountOut}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(params.tokenOut).safeTransfer(params.recipient, amountOut);
        }
        
        // 退还多余的ETH
        if (msg.value > params.amountIn) {
            (bool success, ) = payable(msg.sender).call{value: msg.value - params.amountIn}("");
            require(success, "ETH refund failed");
        }
    }

    function exactInput(
        ISwapRouter.ExactInputParams calldata params
    ) external override payable returns (uint256 amountOut) {
        require(params.deadline >= block.timestamp, "Transaction too old");
        
        // 解析路径
        address[] memory path = decodePath(params.path);
        
        // 转移输入代币
        address tokenIn = path[0];
        if (tokenIn == WETH9 && msg.value > 0) {
            // 处理WETH情况
        } else {
            IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), params.amountIn);
        }
        
        // 计算输出金额
        amountOut = getAmountOut(params.amountIn, path);
        
        // 转移输出代币
        address tokenOut = path[path.length - 1];
        if (tokenOut == WETH9) {
            (bool success, ) = payable(params.recipient).call{value: amountOut}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(tokenOut).safeTransfer(params.recipient, amountOut);
        }
    }

    function exactOutputSingle(
        ISwapRouter.ExactOutputSingleParams calldata params
    ) external override payable returns (uint256 amountIn) {
        require(params.deadline >= block.timestamp, "Transaction too old");
        
        // 反向计算输入金额
        uint256 price = getMockPrice(params.tokenIn, params.tokenOut);
        // 考虑滑点和手续费，需要更多的输入
        amountIn = (params.amountOut * 1e18 * 1003) / (price * 997);
        
        // 确保不超过最大输入金额
        require(amountIn <= params.amountInMaximum, "Too much input needed");
        
        // 转移输入代币
        if (params.tokenIn == WETH9 && msg.value >= amountIn) {
            // 处理WETH情况
        } else {
            IERC20(params.tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        }
        
        // 转移输出代币
        if (params.tokenOut == WETH9) {
            (bool success, ) = payable(params.recipient).call{value: params.amountOut}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(params.tokenOut).safeTransfer(params.recipient, params.amountOut);
        }
        
        // 退还多余的输入代币和ETH
        if (params.tokenIn == WETH9 && msg.value > amountIn) {
            (bool success, ) = payable(msg.sender).call{value: msg.value - amountIn}("");
            require(success, "ETH refund failed");
        } else if (params.tokenIn != WETH9 && params.amountInMaximum > amountIn) {
            uint256 refundAmount = params.amountInMaximum - amountIn;
            if (refundAmount > 0) {
                IERC20(params.tokenIn).safeTransfer(msg.sender, refundAmount);
            }
        }
    }

    function exactOutput(
        ISwapRouter.ExactOutputParams calldata params
    ) external override payable returns (uint256 amountIn) {
        require(params.deadline >= block.timestamp, "Transaction too old");
        
        // 解析路径
        address[] memory path = decodePath(params.path);
        
        // 反向计算输入金额
        uint256 tempAmount = params.amountOut;
        
        for (uint i = path.length - 1; i > 0; i--) {
            address currentTokenIn = path[i - 1];
            address currentTokenOut = path[i];
            
            uint256 price = getMockPrice(currentTokenIn, currentTokenOut);
            // 反向计算，考虑滑点和手续费
            tempAmount = (tempAmount * 1e18 * 1003) / (price * 997);
        }
        
        amountIn = tempAmount;
        
        // 确保不超过最大输入金额
        require(amountIn <= params.amountInMaximum, "Too much input needed");
        
        // 转移输入代币
        address tokenIn = path[0];
        if (tokenIn == WETH9 && msg.value >= amountIn) {
            // 处理WETH情况
        } else {
            IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        }
        
        // 转移输出代币
        address tokenOut = path[path.length - 1];
        if (tokenOut == WETH9) {
            (bool success, ) = payable(params.recipient).call{value: params.amountOut}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(tokenOut).safeTransfer(params.recipient, params.amountOut);
        }
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

    // 实现IUniswapV3SwapCallback接口的函数
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external override {
        // 在模拟环境中，我们不需要实际的流动性池交互
        // 这个函数在真实实现中会处理代币的转移
        // 由于这是一个模拟合约，我们只需要确保接口一致性
    }
    
    // 支持接收ETH
    receive() external payable {}
    fallback() external payable {}
}
