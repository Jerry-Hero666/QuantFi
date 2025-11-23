// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import '../../dex/uniswap/interface/ISwapRouter02.sol';
import '@uniswap/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../MockERC20.sol";
import "hardhat/console.sol";

contract MockUniswapV3SwapRouter02 is ISwapRouter02 {
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
    function getMockPrice(address tokenIn, address tokenOut) public view returns (uint256) {
        uint256 price = mockPrices[tokenIn][tokenOut];
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
            amountOut = (amountOut * price) / 10**MockERC20(currentTokenIn).decimals();
            
            // 模拟滑点和手续费（0.3%）
            amountOut = (amountOut * 997) / 1000;
        }
    }

    // 实现IV3SwapRouter接口的函数
    function exactInputSingle(
        IV3SwapRouter.ExactInputSingleParams calldata params
    ) external override payable returns (uint256 amountOut) {
        address[] memory path = new address[](2);
        path[0] = params.tokenIn;
        path[1] = params.tokenOut;
        
        // 转移输入代币
        IERC20(params.tokenIn).safeTransferFrom(msg.sender, address(this), params.amountIn);
        
        // 计算输出金额
        amountOut = getAmountOut(params.amountIn, path);
        
        // 转移输出代币
        if (params.tokenOut == WETH9) {
            (bool success, ) = payable(params.recipient).call{value: amountOut}("");
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
        IV3SwapRouter.ExactInputParams calldata params
    ) external override payable returns (uint256 amountOut) {
        // 解析路径
        (address[] memory path, ) = decodePath(params.path);
        
        // 转移输入代币
        address tokenIn = path[0];
        uint256 amountIn = params.amountIn; // 初始输入金额

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        
        // 计算输出金额
        amountOut = getAmountOut(amountIn, path);
        // 转移输出代币
        address tokenOut = path[path.length - 1];
        IERC20(tokenOut).safeTransfer(params.recipient, amountOut);
    }

    function exactOutputSingle(
        IV3SwapRouter.ExactOutputSingleParams calldata params
    ) external override payable returns (uint256 amountIn) {
        // 反向计算输入金额
        uint256 price = getMockPrice(params.tokenIn, params.tokenOut);
        // 考虑滑点和手续费，需要更多的输入
        amountIn = (params.amountOut * 10**MockERC20(params.tokenIn).decimals() * 1003) / (price * 997);
        
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
        IV3SwapRouter.ExactOutputParams calldata params
    ) external override payable returns (uint256 amountIn) {
        // 解析路径
        (address[] memory path, ) = decodePath(params.path);
        
        // 反向计算输入金额
        uint256 tempAmount = params.amountOut;
        
        for (uint i = path.length - 1; i > 0; i--) {
            address currentTokenIn = path[i - 1];
            address currentTokenOut = path[i];
            
            uint256 price = getMockPrice(currentTokenIn, currentTokenOut);
            // 反向计算，考虑滑点和手续费
            tempAmount = (tempAmount * 10**MockERC20(currentTokenIn).decimals() * 1003) / (price * 997);
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
        require(offset + 20 <= path.length, "Address read out of bounds");
        
        address addr;
        assembly {
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
        require(offset + 3 <= path.length, "Fee read out of bounds");
        
        uint24 fee;
        assembly {
            fee := and(shr(232, mload(add(add(path, 32), offset))), 0xFFFFFF)
        }
        return fee;
    }

    // 实现IUniswapV3SwapCallback接口的函数
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external override {
        // 在模拟环境中，我们不需要实际的流动性池交互
    }

    // IV2SwapRouter 方法（简单实现）
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to
    ) external payable override returns (uint256 amountOut) {
        // 简单实现，复用V3逻辑
        address[] memory pathMemory = new address[](path.length);
        for (uint i = 0; i < path.length; i++) {
            pathMemory[i] = path[i];
        }
        
        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountIn);
        amountOut = getAmountOut(amountIn, pathMemory);
        require(amountOut >= amountOutMin, "Insufficient output amount");
        IERC20(path[path.length - 1]).safeTransfer(to, amountOut);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to
    ) external payable override returns (uint256 amountIn) {
        // 反向计算输入金额
        address[] memory pathMemory = new address[](path.length);
        for (uint i = 0; i < path.length; i++) {
            pathMemory[i] = path[i];
        }
        
        uint256 tempAmount = amountOut;
        for (uint i = pathMemory.length - 1; i > 0; i--) {
            address currentTokenIn = pathMemory[i - 1];
            address currentTokenOut = pathMemory[i];
            uint256 price = getMockPrice(currentTokenIn, currentTokenOut);
            tempAmount = (tempAmount * 10**MockERC20(currentTokenIn).decimals() * 1003) / (price * 997);
        }
        
        amountIn = tempAmount;
        require(amountIn <= amountInMax, "Too much input needed");
        
        // 转移输入代币（先转移最大金额）
        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountInMax);
        
        // 转移输出代币
        IERC20(path[path.length - 1]).safeTransfer(to, amountOut);
        
        // 退还多余的输入代币
        if (amountInMax > amountIn) {
            uint256 refundAmount = amountInMax - amountIn;
            if (refundAmount > 0) {
                IERC20(path[0]).safeTransfer(msg.sender, refundAmount);
            }
        }
    }

    // IMulticallExtended 方法
    function multicall(uint256 deadline, bytes[] calldata data) external payable override returns (bytes[] memory results) {
        require(deadline >= block.timestamp, "Transaction too old");
        results = new bytes[](data.length);
        for (uint i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success, "Multicall failed");
            results[i] = result;
        }
    }

    function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success, "Multicall failed");
            results[i] = result;
        }
    }

    function multicall(bytes32 previousBlockhash, bytes[] calldata data)
        external
        payable
        override
        returns (bytes[] memory results)
    {
        require(blockhash(block.number - 1) == previousBlockhash, "Invalid blockhash");
        results = new bytes[](data.length);
        for (uint i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success, "Multicall failed");
            results[i] = result;
        }
    }

    // IApproveAndCall 方法（简单实现，留空）
    function getApprovalType(address, uint256) external pure override returns (IApproveAndCall.ApprovalType) {
        return IApproveAndCall.ApprovalType.NOT_REQUIRED;
    }

    function approveMax(address) external payable override {}
    function approveMaxMinusOne(address) external payable override {}
    function approveZeroThenMax(address) external payable override {}
    function approveZeroThenMaxMinusOne(address) external payable override {}
    
    function callPositionManager(bytes memory) external payable override returns (bytes memory) {
        return "";
    }

    function mint(IApproveAndCall.MintParams calldata) external payable override returns (bytes memory) {
        return "";
    }

    function increaseLiquidity(IApproveAndCall.IncreaseLiquidityParams calldata) external payable override returns (bytes memory) {
        return "";
    }

    // ISelfPermit 方法（简单实现，留空）
    function selfPermit(
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external payable override {}

    function selfPermitIfNecessary(
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external payable override {}

    function selfPermitAllowed(
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external payable override {}

    function selfPermitAllowedIfNecessary(
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external payable override {}
    
    // 支持接收ETH
    receive() external payable {}
    fallback() external payable {}
}