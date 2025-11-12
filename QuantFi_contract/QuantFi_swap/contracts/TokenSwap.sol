
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IDexRouter.sol";
import "./PathFinder.sol";
import "./lib/Model.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title TokenSwap
 * @dev 通过多个DEX进行代币交换的合约，具有最优路径查找功能
 */
contract TokenSwap is Ownable, ReentrancyGuard {
    // PathFinder合约
    PathFinder public immutable pathFinder;

    // 支持的DEX路由器映射
    mapping(string => address) public dexRouters;

    // 支持的DEX名称数组
    string[] public supportedDexes;

    // 事件
    event DexRouterAdded(string dexName, address routerAddress);
    event DexRouterRemoved(string dexName);
    event Swapped(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        string dexName
    );

    constructor(address _pathFinder, address _owner) Ownable(_owner) {
        pathFinder = PathFinder(_pathFinder);
    }

    /**
     * @dev 将DEX路由器添加到支持列表
     * @param _dexName DEX的名称
     * @param _routerAddress DEX路由器的地址
     */
    function addDexRouter(string memory _dexName, address _routerAddress) external onlyOwner {
        if (dexRouters[_dexName] == address(0)) {
            supportedDexes.push(_dexName);
        }
        dexRouters[_dexName] = _routerAddress;
        pathFinder.addDexRouter(_dexName, _routerAddress);
        emit DexRouterAdded(_dexName, _routerAddress);
    }

    /**
     * @dev 从支持列表中移除DEX路由器
     * @param _dexName DEX的名称
     */
    function removeDexRouter(string memory _dexName) external onlyOwner {
        require(dexRouters[_dexName] != address(0), "TokenSwap: DEX not supported");

        // 从映射中移除
        delete dexRouters[_dexName];

        // 从数组中移除
        for (uint256 i = 0; i < supportedDexes.length; i++) {
            if (keccak256(bytes(supportedDexes[i])) == keccak256(bytes(_dexName))) {
                supportedDexes[i] = supportedDexes[supportedDexes.length - 1];
                supportedDexes.pop();
                break;
            }
        }

        pathFinder.removeDexRouter(_dexName);
        emit DexRouterRemoved(_dexName);
    }

    /**
     * @dev 将代币交换为目标代币（默认为USDT）
     * @param tokenIn 输入代币地址
     * @param amountIn 输入代币数量
     * @param minAmountOut 可接受的输出代币最小数量
     * @param deadline 交易截止时间
     * @return amountOut 收到的输出代币数量
     */
    function swapToTarget(
        address tokenIn,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline
    ) external payable nonReentrant returns (uint256 amountOut) {
        require(block.timestamp <= deadline, "TokenSwap: TRANSACTION_EXPIRED");
        require(amountIn > 0, "TokenSwap: INVALID_AMOUNT");

        // 查找最优路径
        Model.SwapPath memory bestPath = pathFinder.findOptimalPath(tokenIn, amountIn);
        require(bestPath.outputAmount >= minAmountOut, "TokenSwap: INSUFFICIENT_OUTPUT_AMOUNT");
        require(bestPath.dexRouter != address(0), "TokenSwap: NO_VALID_PATH");

        // 获取DEX名称
        string memory dexName = IDexRouter(bestPath.dexRouter).dexName();

        if(tokenIn == address(0)) {
            require(msg.value > 0, "TokenSwap: INSUFFICIENT_ETH_SENT");
            amountIn = msg.value;
            // 执行交换
            amountOut = IDexRouter(bestPath.dexRouter).swapTokensForTokens{value: amountIn}(
                bestPath,
                tokenIn,
                amountIn,
                minAmountOut,
                msg.sender,
                deadline
            );
        } else {
            // 批准路由器使用代币
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
            IERC20(tokenIn).approve(bestPath.dexRouter, amountIn);
            // 执行交换
            amountOut = IDexRouter(bestPath.dexRouter).swapTokensForTokens(
                bestPath,
                tokenIn,
                amountIn,
                minAmountOut,
                msg.sender,
                deadline
            );
        }
        

        emit Swapped(
            tokenIn,
            pathFinder.targetToken(),
            amountIn,
            amountOut,
            dexName
        );

        return amountOut;
    }

    /**
     * @dev 获取交换到目标代币的预期输出数量
     * @param tokenIn 输入代币地址
     * @param amountIn 输入代币数量
     * @return bestPath 最优路径
     */
    function getSwapToTargetQuote(
        address tokenIn,
        uint256 amountIn
    ) external returns (Model.SwapPath memory bestPath) {
        bestPath = pathFinder.findOptimalPath(tokenIn, amountIn);
        return bestPath;
    }

    /**
     * @dev 设置路径中允许的最大跳数
     * @param _maxHops 新的最大跳数
     */
    function setMaxHops(uint8 _maxHops) external onlyOwner {
        pathFinder.setMaxHops(_maxHops);
    }

    /**
     * @dev 设置目标代币
     * @param _targetToken 新的目标代币地址
     */
    function setTargetToken(address _targetToken) external onlyOwner {
        pathFinder.setTargetToken(_targetToken);
    }

    /**
     * @dev 从合约中提取代币
     * @param token 代币地址
     * @param amount 要提取的数量
     */
    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }
}
