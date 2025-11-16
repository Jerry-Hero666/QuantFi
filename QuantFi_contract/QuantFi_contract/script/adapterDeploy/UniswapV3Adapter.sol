// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../src/adapters/UniswapV3Adapter.sol";
import "../../src/mock/MockERC20.sol";

contract UniswapV3AdapterDeploy is Script {
    using stdJson for string;

    string private constant DEPLOYMENT_FILE =
        "script/deployInfo/uniswap-adapter-deployment.json";
    string private constant TOKENS_DEPLOYMENT_FILE =
        "script/deployInfo/all-tokens-deployment.json";

    function run() external {
        bytes32 deployerPrivateKey = vm.envBytes32("PRIVATE_KEY_1");
        address positionManager = vm.envAddress("POSITION_MANAGER");
        bytes32 ownerPrivateKey = vm.envBytes32("PRIVATE_KEY_2");
        address owner = vm.addr(uint256(ownerPrivateKey));

        // 读取已部署的代币地址
        string memory tokensDeploymentData = vm.readFile(
            TOKENS_DEPLOYMENT_FILE
        );
        address usdc = stdJson.readAddress(tokensDeploymentData, ".usdc");
        address weth = stdJson.readAddress(tokensDeploymentData, ".weth");

        vm.startBroadcast(uint256(deployerPrivateKey));

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
            owner,
            usdc,
            weth
        );
    }

    function _writeDeploymentInfo(
        address implementation,
        address proxy,
        address positionManager,
        address owner,
        address usdc,
        address weth
    ) internal {
        // 手动构建格式化的JSON字符串
        string memory formattedJson = "{\n";
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "network": "',
                vm.toString(block.chainid),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "chainId": ',
                vm.toString(block.chainid),
                ",\n"
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "implementation": "',
                vm.toString(implementation),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "proxy": "',
                vm.toString(proxy),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "positionManager": "',
                vm.toString(positionManager),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "owner": "',
                vm.toString(owner),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "mockUsdc": "',
                vm.toString(usdc),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "mockWeth": "',
                vm.toString(weth),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "deployedAt": ',
                vm.toString(block.timestamp),
                "\n"
            )
        );
        formattedJson = string(abi.encodePacked(formattedJson, "}\n"));

        // 写入文件
        vm.writeFile(DEPLOYMENT_FILE, formattedJson);

        console.log("Deployment info written to:", DEPLOYMENT_FILE);
    }
}
