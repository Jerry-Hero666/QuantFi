// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../src/adapters/AaveAdapter.sol";

contract AaveAdapterDeploy is Script {
    using stdJson for string;

    string private constant DEPLOYMENT_FILE =
        "script/deployInfo/aave-adapter-deployment.json";
    string private constant THIRD_PARTY_DEPLOYMENT_FILE =
        "script/deployInfo/all-mock-third-party-deployment.json";
    string private constant TOKENS_DEPLOYMENT_FILE =
        "script/deployInfo/all-tokens-deployment.json";
    string private constant ABI_FILE = 
        "out/adapters/AaveAdapter.sol/AaveAdapter.json";

    function run() external {
        bytes32 deployerPrivateKey = vm.envBytes32("PRIVATE_KEY_1");
        bytes32 ownerPrivateKey = vm.envBytes32("PRIVATE_KEY_2");
        address owner = vm.addr(uint256(ownerPrivateKey));
        
        // 从部署文件中读取地址
        string memory thirdPartyDeploymentData = vm.readFile(THIRD_PARTY_DEPLOYMENT_FILE);
        address aaveAddress = stdJson.readAddress(thirdPartyDeploymentData, ".mockAavePool");
        
        string memory tokensDeploymentData = vm.readFile(TOKENS_DEPLOYMENT_FILE);
        address aTokenAddress = stdJson.readAddress(tokensDeploymentData, ".aToken");
        address underlyingTokenAddress = stdJson.readAddress(tokensDeploymentData, ".usdc");
        
        vm.startBroadcast(uint256(deployerPrivateKey));

        // 部署实现合约
        AaveAdapter implementation = new AaveAdapter();

        // 准备初始化数据
        bytes memory initData = abi.encodeWithSelector(
            AaveAdapter.initialize.selector,
            aaveAddress,
            aTokenAddress,
            underlyingTokenAddress,
            owner
        );

        // 部署代理合约
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );

        vm.stopBroadcast();

        // 输出部署信息到控制台
        console.log(
            "AaveAdapter implementation deployed at:",
            address(implementation)
        );
        console.log("AaveAdapter proxy deployed at:", address(proxy));

        // 将部署信息写入文件
        _writeDeploymentInfo(
            address(implementation),
            address(proxy),
            aaveAddress,
            aTokenAddress,
            underlyingTokenAddress,
            owner
        );
        
        // 生成ABI文件
        _generateAbiFile(address(implementation));
    }

    function _writeDeploymentInfo(
        address implementation,
        address proxy,
        address aaveAddress,
        address aTokenAddress,
        address underlyingTokenAddress,
        address owner
    ) internal {
        // 手动构建格式化的JSON字符串
        string memory formattedJson = "{\n";
        formattedJson = string(abi.encodePacked(formattedJson, "  \"network\": \"", vm.toString(block.chainid), "\",\n"));
        formattedJson = string(abi.encodePacked(formattedJson, "  \"chainId\": ", vm.toString(block.chainid), ",\n"));
        formattedJson = string(abi.encodePacked(formattedJson, "  \"implementation\": \"", vm.toString(implementation), "\",\n"));
        formattedJson = string(abi.encodePacked(formattedJson, "  \"proxy\": \"", vm.toString(proxy), "\",\n"));
        formattedJson = string(abi.encodePacked(formattedJson, "  \"aaveAddress\": \"", vm.toString(aaveAddress), "\",\n"));
        formattedJson = string(abi.encodePacked(formattedJson, "  \"aTokenAddress\": \"", vm.toString(aTokenAddress), "\",\n"));
        formattedJson = string(abi.encodePacked(formattedJson, "  \"underlyingTokenAddress\": \"", vm.toString(underlyingTokenAddress), "\",\n"));
        formattedJson = string(abi.encodePacked(formattedJson, "  \"owner\": \"", vm.toString(owner), "\",\n"));
        formattedJson = string(abi.encodePacked(formattedJson, "  \"deployedAt\": ", vm.toString(block.timestamp), "\n"));
        formattedJson = string(abi.encodePacked(formattedJson, "}\n"));

        // 写入文件
        vm.writeFile(DEPLOYMENT_FILE, formattedJson);

        console.log("Deployment info written to:", DEPLOYMENT_FILE);
    }
    
    function _generateAbiFile(address implementation) internal {
        // 读取ABI文件内容
        string memory abiContent = vm.readFile(ABI_FILE);
        
        // 提取ABI部分
        string memory abiJson = stdJson.parse(abiContent, ".abi").serialize("abi", abiContent);
        string memory finalAbi = stdJson.serialize(abiJson, "abi", stdJson.parse(abiContent, ".abi"));
        
        // 写入ABI到部署信息目录
        string memory abiOutputPath = "script/deployInfo/aave-adapter.abi.json";
        vm.writeJson(finalAbi, abiOutputPath);
        
        console.log("ABI written to:", abiOutputPath);
    }
}