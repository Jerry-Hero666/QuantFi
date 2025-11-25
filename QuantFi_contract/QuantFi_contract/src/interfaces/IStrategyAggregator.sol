// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStrategyAggregator {
    // 代币金库存款
    function deposit(
        DepositParams calldata params
    ) external returns (DepositResult memory);
    // 代币金库取款
    function withdraw(
        WithdrawParams calldata params
    ) external returns (WithdrawResult memory);

    struct DepositParams {
        string strategyType;
        uint256 weight;
        address user;
        address token;
        uint256 amount;
    }

    struct DepositResult {
        address recipient;
        bool success;
        string message;
        uint256 actualAmount;
    }

    struct WithdrawParams {
        string strategyType;
        uint256 weight;
        address user;
        address token;
        uint256 shareAmount;
    }

    struct WithdrawResult {
        address recipient;
        bool success;
        string message;
        uint256 actualAmount;
    }

    enum StrategyTypes {
        Stock,
        DeFi,
        Hyperliquid,
        Mix,
        AI
    }
}