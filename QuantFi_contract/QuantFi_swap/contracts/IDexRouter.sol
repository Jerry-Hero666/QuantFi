
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./lib/Model.sol";

/**
 * @title IDexRouter
 * @dev 可插入我们交换合约的DEX路由器接口
 */
interface IDexRouter {
    /**
     * @dev 将精确数量的输入代币交换为输出代币
     * @param path 定义路由的代币地址数组
     * @param tokenIn 输入代币地址
     * @param amountIn 要发送的输入代币数量
     * @param amountOutMin 要接收的输出代币最小数量
     * @param to 输出代币的接收者
     * @param deadline 交易将回滚的Unix时间戳
     * @return amount 输入代币数量和所有后续输出代币数量
     */
    function swapTokensForTokens(
        Model.SwapPath memory path,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);

    /**
     * @dev 返回给定输入数量的最佳输出代币数量，以及交换路径
     * @param tokenIn 输入代币地址
     * @param amountIn 输入代币数量
     * @param tokenOut 输出代币地址
     * @param maxHops 最大跳数
     * @return path 包含最佳路径和输出数量的SwapPath结构体
     */
    function getAmountsOut(address tokenIn, uint256 amountIn, 
                address tokenOut, uint8 maxHops) external returns (Model.SwapPath memory path);

    /**
     * @dev 返回DEX的名称
     * @return DEX的名称
     */
    function dexName() external pure returns (string memory);
}
