
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IDexRouter.sol";
import "./lib/Model.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PathFinder
 * @dev 用于查找代币之间最优交换路径的合约
 */
contract PathFinder is Ownable {

    // 路径中允许的最大跳数（可配置）
    uint8 public maxHops;

    // 目标代币地址（默认为USDT，但可配置）
    address public targetToken;

    // 支持的DEX路由器映射
    mapping(string => address) public dexRouters;

    // 支持的DEX名称数组
    string[] public supportedDexes;

    // 事件
    event MaxHopsUpdated(uint256 newMaxHops);
    event TargetTokenUpdated(address newTargetToken);
    event DexRouterAdded(string dexName, address routerAddress);
    event DexRouterRemoved(string dexName);

    constructor(address _targetToken, uint8 _maxHops, address _owner) Ownable(_owner) {
        targetToken = _targetToken;
        maxHops = _maxHops;
    }

    /**
     * @dev 设置路径中允许的最大跳数
     * @param _maxHops 新的最大跳数
     */
    function setMaxHops(uint8 _maxHops) external onlyOwner {
        maxHops = _maxHops;
        emit MaxHopsUpdated(_maxHops);
    }

    /**
     * @dev 设置目标代币
     * @param _targetToken 新的目标代币地址
     */
    function setTargetToken(address _targetToken) external onlyOwner {
        targetToken = _targetToken;
        emit TargetTokenUpdated(_targetToken);
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
        emit DexRouterAdded(_dexName, _routerAddress);
    }

    /**
     * @dev 从支持列表中移除DEX路由器
     * @param _dexName DEX的名称
     */
    function removeDexRouter(string memory _dexName) external onlyOwner {
        require(dexRouters[_dexName] != address(0), "PathFinder: DEX not supported");

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

        emit DexRouterRemoved(_dexName);
    }

    /**
     * @dev 查找从代币到目标代币的最优交换路径
     * @param tokenIn 输入代币地址
     * @param amountIn 输入代币数量
     * @return bestPath 最优交换路径
     */
    function findOptimalPath(address tokenIn, uint256 amountIn) external returns (Model.SwapPath memory bestPath) {
        // require(tokenIn != address(0), "PathFinder: INVALID_TOKEN");
        require(amountIn > 0, "PathFinder: INVALID_AMOUNT");

        // 如果tokenIn已经是目标代币，返回直接路径
        if (tokenIn == targetToken) {
            address[] memory directPath = new address[](2);
            directPath[0] = tokenIn;

            return Model.SwapPath({
                path: directPath,
                pathBytes: "", // 无需路径字节
                outputAmount: amountIn,
                inputAmount: amountIn,
                dexRouter: address(0) // 无需交换
            });
        }

        // 初始化最佳路径为零输出
        bestPath.outputAmount = 0;

        // 尝试每个支持的DEX
        for (uint256 i = 0; i < supportedDexes.length; i++) {
            address routerAddress = dexRouters[supportedDexes[i]];
            IDexRouter router = IDexRouter(routerAddress);

            Model.SwapPath memory swapPath = router.getAmountsOut(tokenIn, amountIn, targetToken, maxHops);
            if (swapPath.outputAmount > bestPath.outputAmount) {
                bestPath = swapPath;
            }
        }

        return bestPath;
    }

}
