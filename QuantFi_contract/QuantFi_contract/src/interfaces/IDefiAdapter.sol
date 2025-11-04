// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


interface IDefiAdapter {
    // 返回操作类型是否支持
    function supportOperation(uint256 operationType) external virtual view returns (bool);
    // 获取支持的操作类型
    function getSupportedOperations() external virtual view returns (uint256[] memory);
    // 执行操作
    function executeOperation(OperationParams params) external virtual returns (OperationResult);
    // 获取适配器名称
    function getName() external view virtual returns (string memory);
    // 获取适配器版本
    function getVersion() external view virtual returns (string memory);

}

struct OperationParams {
    uint256 operationType;
    bytes data;
    uint256[] tokens;
    uint256[] amounts;
    address recipient;
    uint256 deadline;
     // NFT tokenId (用于 UniswapV3, Aave 等基于 NFT 的协议)
    uint256 tokenId;      
     // 额外的操作特定数据
    bytes extraData;       
}

struct OperationResult {
    uint256[] outputAmounts;
    bytes data;
    bool success;
}

enum OperationType {
    //deposit
    DEPOSIT = 1,
    //withdraw
    WITHDRAW = 2,
    //添加流动性
    ADD_LIQUIDITY = 3,
    //移除流动性
    REMOVE_LIQUIDITY = 4,
    //提取手续费
    COLLECT_FEES = 5,
    // 交换代币
    SWAP = 6
}