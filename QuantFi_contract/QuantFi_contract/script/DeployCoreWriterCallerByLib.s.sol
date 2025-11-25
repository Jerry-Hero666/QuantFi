// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/hyper/BridgingExample.sol";
import "../src/hyper/TradingExample.sol";

contract DeployCoreWriterCallerByLib is Script {
    function run() external {
        // 开始广播以记录和发送交易
        vm.startBroadcast();

        // 部署 PriceOracleReader 合约
        Bridging bridgeContract = new Bridging();
        Trading tradingContract = new Trading();
        console.log("BridgingExample deployed at:", address(bridgeContract));
        console.log("TradingExample deployed at:", address(tradingContract));

        // 结束广播
        vm.stopBroadcast();
    }
}
