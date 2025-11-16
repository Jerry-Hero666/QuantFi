// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

contract GenerateAdapterAbis is Script {
    using stdJson for string;

    function run() external {
        // 生成Curve适配器ABI
        _generateCurveAdapterAbi();

        // 生成Compound适配器ABI
        _generateCompoundAdapterAbi();

        // 生成Aave适配器ABI
        _generateAaveAdapterAbi();

        console.log("All adapter ABIs generated successfully");
    }

    function _generateCurveAdapterAbi() internal {
        string memory abiFilePath = "out/CurveAdapter.sol/CurveAdapter.json";
        string memory abiContent = vm.readFile(abiFilePath);

        // 提取ABI部分并写入部署信息目录
        bytes memory abiBytes = abiContent.parseRaw(".abi");
        string memory abiString = vm.toString(abiBytes);

        string memory outputPath = "script/deployInfo/abi/curve-adapter.abi.json";
        vm.writeFile(outputPath, abiString);

        console.log("CurveAdapter ABI written to:", outputPath);
    }

    function _generateCompoundAdapterAbi() internal {
        string
            memory abiFilePath = "out/CompoundAdapter.sol/CompoundAdapter.json";
        string memory abiContent = vm.readFile(abiFilePath);

        // 提取ABI部分并写入部署信息目录
        bytes memory abiBytes = abiContent.parseRaw(".abi");
        string memory abiString = vm.toString(abiBytes);

        string
            memory outputPath = "script/deployInfo/abi/compound-adapter.abi.json";
        vm.writeFile(outputPath, abiString);

        console.log("CompoundAdapter ABI written to:", outputPath);
    }

    function _generateAaveAdapterAbi() internal {
        string memory abiFilePath = "out/AaveAdapter.sol/AaveAdapter.json";
        string memory abiContent = vm.readFile(abiFilePath);

        // 提取ABI部分并写入部署信息目录
        bytes memory abiBytes = abiContent.parseRaw(".abi");
        string memory abiString = vm.toString(abiBytes);

        string memory outputPath = "script/deployInfo/abi/aave-adapter.abi.json";
        vm.writeFile(outputPath, abiString);
        
        console.log("AaveAdapter ABI written to:", outputPath);
    }
}