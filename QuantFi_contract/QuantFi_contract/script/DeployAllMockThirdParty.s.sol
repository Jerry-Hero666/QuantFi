// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "../src/mock/MockCurve.sol";
import "../src/mock/MockCompound.sol";
import "../src/mock/MockNonfungiblePositionManager.sol";
import "../src/mock/MockERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployAllMockThirdParty is Script {
    using stdJson for string;

    string private constant DEPLOYMENT_FILE =
        "script/deployInfo/all-mock-third-party-deployment.json";
    string private constant TOKENS_DEPLOYMENT_FILE =
        "script/deployInfo/all-tokens-deployment.json";

    // Mock third-party contracts
    MockCurve public mockCurve;
    address public mockAavePool; // We'll deploy using new without importing the contract
    MockCToken public mockCToken;
    MockNonfungiblePositionManager public mockPositionManager;

    // Tokens needed for mock contracts
    MockERC20 public usdc;
    MockERC20 public usdt;
    MockERC20 public dai;
    MockERC20 public weth;
    MockERC20 public aToken;

    function run() external {
        bytes32 deployerPrivateKey = vm.envBytes32("PRIVATE_KEY_2");

        // Read token addresses from the tokens deployment file
        string memory tokensDeploymentData = vm.readFile(
            TOKENS_DEPLOYMENT_FILE
        );
        usdc = MockERC20(stdJson.readAddress(tokensDeploymentData, ".usdc"));
        usdt = MockERC20(stdJson.readAddress(tokensDeploymentData, ".usdt"));
        dai = MockERC20(stdJson.readAddress(tokensDeploymentData, ".dai"));
        weth = MockERC20(stdJson.readAddress(tokensDeploymentData, ".weth"));
        aToken = MockERC20(
            stdJson.readAddress(tokensDeploymentData, ".aToken")
        );

        vm.startBroadcast(uint256(deployerPrivateKey));

        // Deploy all mock third-party contracts
        _deployMockContracts();

        vm.stopBroadcast();

        // Output deployment info to console
        _logDeploymentInfo();

        // Write deployment info to file
        _writeDeploymentInfo();
    }

    function _deployMockContracts() internal {
        // Deploy MockCurve
        address[3] memory coins = [address(usdc), address(usdt), address(dai)];
        mockCurve = new MockCurve(msg.sender, coins, 5, 30, 5);

        // Deploy MockAavePool using low-level call to avoid import conflicts
        bytes memory creationCode = vm.getCode(
            "src/mock/MockAavePool.sol:MockAavePool"
        );
        address aavePoolAddress;
        assembly {
            aavePoolAddress := create(
                0,
                add(creationCode, 0x20),
                mload(creationCode)
            )
        }
        require(aavePoolAddress != address(0), "Failed to deploy MockAavePool");
        mockAavePool = aavePoolAddress;

        // Initialize reserve for USDC
        (bool success, ) = mockAavePool.call(
            abi.encodeWithSignature(
                "initReserve(address,address)",
                address(usdc),
                address(aToken)
            )
        );
        require(success, "Failed to initialize Aave reserve");

        // Deploy MockCToken for Compound (using USDC as underlying)
        mockCToken = new MockCToken("cUSDC", "cUSDC", address(usdc), 1e18);

        // Deploy MockNonfungiblePositionManager for Uniswap V3
        mockPositionManager = new MockNonfungiblePositionManager();

        console.log("All mock third-party contracts deployed successfully");
    }

    function _logDeploymentInfo() internal {
        console.log("=====================================");
        console.log("All Mock Third-Party Contracts Deployment Completed");
        console.log("=====================================");
        console.log("MockCurve deployed at:", address(mockCurve));
        console.log("MockAavePool deployed at:", mockAavePool);
        console.log("MockCToken deployed at:", address(mockCToken));
        console.log(
            "MockPositionManager deployed at:",
            address(mockPositionManager)
        );
        console.log("=====================================");
    }

    function _writeDeploymentInfo() internal {
        // Manually build formatted JSON string
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
                '  "mockCurve": "',
                vm.toString(address(mockCurve)),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "mockAavePool": "',
                vm.toString(mockAavePool),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "mockCToken": "',
                vm.toString(address(mockCToken)),
                '",\n'
            )
        );
        formattedJson = string(
            abi.encodePacked(
                formattedJson,
                '  "mockPositionManager": "',
                vm.toString(address(mockPositionManager)),
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

        // Write to file
        vm.writeFile(DEPLOYMENT_FILE, formattedJson);

        console.log("Deployment info written to:", DEPLOYMENT_FILE);
    }
}
