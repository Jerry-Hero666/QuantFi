
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IDexRouter.sol";
import "./lib/Model.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title PathFinder
 * @dev 用于查找代币之间最优交换路径的合约
 */
contract PathFinder is Ownable, ReentrancyGuard {

    // 路径中允许的最大跳数（可配置）
    uint8 public maxHops;

    // 目标代币地址（默认为USDT，可配置）
    address public targetToken;

    // 支持的DEX路由器映射
    mapping(string => address) public dexRouters;

    // 支持的DEX名称数组
    string[] public supportedDexes;
    
    // 支持的代币数组
    address[] public supportedTokens;

    // 事件
    event MaxHopsUpdated(uint256 newMaxHops);
    event TargetTokenUpdated(address newTargetToken);
    event DexRouterAdded(string dexName, address routerAddress);
    event DexRouterRemoved(string dexName);
    event SupportedTokenAdded(address token);
    event SupportedTokenRemoved(address token);

    constructor(address _targetToken, uint8 _maxHops, address[] memory _supportedTokens, address _owner) Ownable(_owner) {
        targetToken = _targetToken;
        maxHops = _maxHops;
        supportedTokens = _supportedTokens;
    }

    /**
     * @dev 获取所有支持的代币
     * @return 支持的代币数组
     */
    function getAllSupportedTokens() public view returns (address[] memory) {
        return supportedTokens;
    }

    /**
     * @dev 添加可交换的代币
     * @param token 代币地址
     */
    function addSupportToken(address token) public onlyOwner {
        require(token != address(0), "PathFinder: INVALID_TOKEN");
        bool exists = false;
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == token) {
                exists = true;
                break;
            }
        }
        require(!exists, "PathFinder: TOKEN_ALREADY_EXIST");
        supportedTokens.push(token);
        emit SupportedTokenAdded(token);
    }

    /**
     * @dev 移除可交换的代币
     * @param token 代币地址
     */
    function removeSupportedToken(address token) public onlyOwner {
        require(token != address(0), "PathFinder: INVALID_TOKEN_ADDRESS");
        uint256 length = supportedTokens.length; // 获取数组长度
        bool exists = false;
        uint256 index = 0;
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == token) {
                exists = true;
                index = i;
                break;
            }
        }
        require(!exists, "PathFinder: TOKEN_NOT_EXIST");
        supportedTokens[index] = supportedTokens[length - 1];
        supportedTokens.pop();
        emit SupportedTokenRemoved(token);
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
        require(_routerAddress != address(0), "PathFinder: INVALID_ROUTER_ADDRESS");
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
        require(amountIn > 0, "PathFinder: INVALID_AMOUNT");
        require(tokenIn != targetToken, "PathFinder: TOKEN_IS_TARGET_TOKEN");

        // 尝试每个支持的DEX
        for (uint256 i = 0; i < supportedDexes.length; i++) {
            address routerAddress = dexRouters[supportedDexes[i]];
            IDexRouter router = IDexRouter(routerAddress);

            Model.SwapPath memory swapPath = router.getAmountsOut(tokenIn, amountIn, targetToken, maxHops, supportedTokens);
            if (swapPath.outputAmount > bestPath.outputAmount) {
                bestPath = swapPath;
            }
        }
        bestPath.inputAmount = amountIn;
        bestPath.inputToken = tokenIn;
        bestPath.outputToken = targetToken;
        return bestPath;
    }

}
