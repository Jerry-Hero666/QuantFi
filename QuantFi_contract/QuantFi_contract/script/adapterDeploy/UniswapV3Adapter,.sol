// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/adapters/UniswapV3Adapter.sol";

contract UniswapV3AdapterDeploy is Script {
    using stdJson for string;

    string private constant DEPLOYMENT_FILE = "deployment.json";

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("OWNER_ADDRESS");
        address positionManager = vm.envAddress("POSITION_MANAGER");

        vm.startBroadcast(deployerPrivateKey);

        // 部署实现合约
        UniswapV3Adapter implementation = new UniswapV3Adapter();

        // 准备初始化数据
        bytes memory initData = abi.encodeWithSelector(
            UniswapV3Adapter.initialize.selector,
            positionManager,
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
            "UniswapV3Adapter implementation deployed at:",
            address(implementation)
        );
        console.log("UniswapV3Adapter proxy deployed at:", address(proxy));

        // 将部署信息写入文件
        _writeDeploymentInfo(
            address(implementation),
            address(proxy),
            positionManager,
            owner
        );
    }

    function _writeDeploymentInfo(
        address implementation,
        address proxy,
        address positionManager,
        address owner
    ) internal {
        // 创建JSON对象
        string memory json = "deployment";

        // 添加部署信息
        json.serialize("network", vm.toString(block.chainid));
        json.serialize("implementation", vm.toString(implementation));
        json.serialize("proxy", vm.toString(proxy));
        json.serialize("positionManager", vm.toString(positionManager));
        json.serialize("owner", vm.toString(owner));
        json.serialize("deployedAt", block.timestamp);

        // 完成序列化
        string memory finalJson = json.serialize("chainId", block.chainid);

        // 写入文件
        vm.writeJson(finalJson, DEPLOYMENT_FILE);

        console.log("Deployment info written to:", DEPLOYMENT_FILE);
    }
}
