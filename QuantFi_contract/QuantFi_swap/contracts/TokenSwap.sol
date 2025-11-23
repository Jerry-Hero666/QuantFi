// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IDexRouter.sol";
import "./PathFinder.sol";
import "./lib/Model.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/**
 * @title TokenSwap
 * @dev 通过多个DEX进行代币交换的合约，具有最优路径查找功能
 */
contract TokenSwap is Ownable {
    // PathFinder合约
    PathFinder public pathFinder;

    event PathFinderSet(address pathFinder);

    constructor(
        address _targetToken,
        uint8 _maxHops,
        address[] memory _supportedTokens,
        address _owner
    ) Ownable(_owner) {
        pathFinder = new PathFinder(_targetToken, _maxHops, _supportedTokens, address(this));
        emit PathFinderSet(address(pathFinder));
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
     * @dev 将DEX路由器添加到支持列表
     * @param _dexName DEX的名称
     * @param _routerAddress DEX路由器的地址
     */
    function addDexRouter(
        string memory _dexName,
        address _routerAddress
    ) external onlyOwner {
        require(_routerAddress != address(0), "TokenSwap: INVALID_ROUTER_ADDRESS");
        pathFinder.addDexRouter(_dexName, _routerAddress);
    }

    /**
     * @dev 获取所有支持的代币
     * @return 支持的代币数组
     */
    function getAllSupportedTokens() public view returns (address[] memory) {
        return pathFinder.getAllSupportedTokens();
    }

    /**
     * @dev 从支持列表中移除DEX路由器
     * @param _dexName DEX的名称
     */
    function removeDexRouter(string memory _dexName) external onlyOwner {
        pathFinder.removeDexRouter(_dexName);
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
     * @dev 添加可交换的代币
     * @param token 代币地址
     */
    function addSupportToken(address token) public onlyOwner {
        pathFinder.addSupportToken(token);
    }

    /**
     * @dev 移除可交换的代币
     * @param token 代币地址
     */
    function removeSupportedToken(address token) public onlyOwner {
        pathFinder.removeSupportedToken(token);
    }

    function setPathFinder(address _pathFinder) external onlyOwner {
        require(_pathFinder != address(0), "TokenSwap: INVALID_PATH_FINDER_ADDRESS");
        pathFinder = PathFinder(_pathFinder);
        emit PathFinderSet(_pathFinder);
    }

}
