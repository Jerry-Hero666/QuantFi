// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "../src/mock/MockERC20.sol";

contract DeployAllTokens is Script {
    using stdJson for string;

    string private constant DEPLOYMENT_FILE =
        "script/deployInfo/all-tokens-deployment.json";

    // Token addresses
    MockERC20 public usdc;
    MockERC20 public usdt;
    MockERC20 public dai;
    MockERC20 public weth;
    MockERC20 public aToken;
    MockERC20 public cToken;

    function run() external {
        bytes32 deployerPrivateKey = vm.envBytes32("PRIVATE_KEY_2");
        vm.startBroadcast(uint256(deployerPrivateKey));

        // Deploy all tokens needed for different protocols
        _deployTokens();

        vm.stopBroadcast();

        // Output deployment info to console
        _logDeploymentInfo();

        // Write deployment info to file
        _writeDeploymentInfo();
    }

    function _deployTokens() internal {
        // Deploy tokens for Curve (USDC, USDT, DAI)
        usdc = new MockERC20("USDC", "USDC", 6);
        usdt = new MockERC20("USDT", "USDT", 6);
        dai = new MockERC20("DAI", "DAI", 18);

        // Deploy tokens for Uniswap V3 (WETH)
        weth = new MockERC20("WETH", "WETH", 18);

        // Deploy tokens for Aave (aToken as deposit receipt token)
        aToken = new MockERC20("aUSDC", "aUSDC", 6);

        // Deploy tokens for Compound (cToken as deposit receipt token)
        cToken = new MockERC20("cUSDC", "cUSDC", 8);

        // Mint tokens to the deployer for initial liquidity
        usdc.mint(msg.sender, 1000000 * 10 ** 6);
        usdt.mint(msg.sender, 1000000 * 10 ** 6);
        dai.mint(msg.sender, 1000000 * 10 ** 18);
        weth.mint(msg.sender, 10000 * 10 ** 18);
        aToken.mint(msg.sender, 0); // aToken will be minted by Aave protocol
        cToken.mint(msg.sender, 0); // cToken will be minted by Compound protocol
    }

    function _logDeploymentInfo() internal {
        console.log("=====================================");
        console.log("All Tokens Deployment Completed");
        console.log("=====================================");
        console.log("USDC deployed at:", address(usdc));
        console.log("USDT deployed at:", address(usdt));
        console.log("DAI deployed at:", address(dai));
        console.log("WETH deployed at:", address(weth));
        console.log("aToken (aUSDC) deployed at:", address(aToken));
        console.log("cToken (cUSDC) deployed at:", address(cToken));
        console.log("=====================================");
    }

    function _writeDeploymentInfo() internal {
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
                '  "usdc": "',
                vm.toString(address(usdc)),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "usdt": "',
                vm.toString(address(usdt)),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "dai": "',
                vm.toString(address(dai)),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "weth": "',
                vm.toString(address(weth)),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "aToken": "',
                vm.toString(address(aToken)),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "cToken": "',
                vm.toString(address(cToken)),
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
