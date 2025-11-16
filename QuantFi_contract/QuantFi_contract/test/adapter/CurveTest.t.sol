// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../../src/adapters/CurveAdapter.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../../src/mock/MockCurve.sol";
import "../../src/mock/MockERC20.sol";

contract CurveTest is Test {
    address public owner;
    address public user;
    address public user1;
    address public deployer;
    MockERC20 public usdc;
    MockERC20 public usdt;
    MockERC20 public dai;
    CurveAdapter public impl;
    CurveAdapter public curveAdapter;
    MockCurve public mockCurve;

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");
        user1 = makeAddr("user1");
        deployer = makeAddr("deployer");
        vm.startPrank(deployer);
        usdc = new MockERC20("USDC", "USDC", 6);
        usdt = new MockERC20("USDT", "USDT", 6);
        dai = new MockERC20("DAI", "DAI", 18);
        address[3] memory coins = [address(usdc), address(usdt), address(dai)];
        //初始化MockCurve
        mockCurve = new MockCurve(owner, coins, 5, 30, 5);
        console.log("MockCurve:", address(mockCurve));
        impl = new CurveAdapter();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeWithSelector(
                CurveAdapter.initialize.selector,
                address(mockCurve),
                owner
            )
        );
        curveAdapter = CurveAdapter(address(proxy));
        console.log("curveAdapter: ", address(curveAdapter));
        usdc.mint(user, 10000);
        usdt.mint(user, 10000);
        dai.mint(user, 10000);
        usdc.mint(user1, 10000);
        vm.stopPrank();
    }

    function testCurve() public {
        //第一次添加流动性
        _addLiquidity(1000, 1000, 1000, 3000);
        uint256 userCurveBalance = IERC20(address(mockCurve)).balanceOf(user);
        console.log("userCurveBalance: ", userCurveBalance);
        uint256 adapterCurveBalance = IERC20(address(mockCurve)).balanceOf(
            address(curveAdapter)
        );
        console.log("adapter CurveBalance: ", adapterCurveBalance);
        //第二次添加流动性
        _addLiquidity(1000, 1000, 1000, 3000);
        uint256 userCurveBalance2 = IERC20(address(mockCurve)).balanceOf(user);
        console.log("userCurveBalance2: ", userCurveBalance2);
        uint256 adapterCurveBalance2 = IERC20(address(mockCurve)).balanceOf(
            address(curveAdapter)
        );
        console.log("adapter CurveBalance2: ", adapterCurveBalance2);
        vm.startPrank(user1);
        //交易手续费收益
        int128 i = 0;
        int128 j = 1;
        uint256 dx = 1000;
        uint256 min_dy = 990;
        IERC20(usdc).approve(address(mockCurve), dx);
        mockCurve.exchange(i, j, dx, min_dy);
        IERC20(usdt).approve(address(mockCurve), 997);
        mockCurve.exchange(j, i, 997, min_dy);
        vm.stopPrank();
        uint256 curveBalance3 = mockCurve.getBalance(0);
        console.log("CurveBalance: ", curveBalance3);
        //第一次移除流动性
        _removeLiquidity(3000, 997, 997, 997);
        uint256 curveBalance4 = mockCurve.getBalance(0);
        console.log("CurveBalance: ", curveBalance4);
        uint256 curveBalance41 = mockCurve.getBalance(1);
        console.log("CurveBalance: ", curveBalance41);
        uint256 curveBalance42 = mockCurve.getBalance(2);
        console.log("CurveBalance: ", curveBalance42);
        uint256 userCurveBalance22 = IERC20(address(mockCurve)).balanceOf(user);
        console.log("userCurveBalance2: ", userCurveBalance22);
        //第二次移除流动性
        //todo 这里为什么手续费没有算进去？
        _removeLiquidity(userCurveBalance2 - 3000, 994, 994, 994);
    }

    function _addLiquidity(
        uint256 usdcAmount,
        uint256 usdtAmount,
        uint256 daiAmount,
        uint256 minLPToken
    ) internal {
        vm.startPrank(user);
        OperationParams memory params;
        params.tokens = new address[](3);
        params.tokens[0] = address(usdc);
        params.tokens[1] = address(usdt);
        params.tokens[2] = address(dai);
        params.amounts = new uint256[](4);
        params.amounts[0] = usdcAmount;
        params.amounts[1] = usdtAmount;
        params.amounts[2] = daiAmount;
        params.amounts[3] = minLPToken;
        for (uint256 i = 0; i < params.tokens.length; i++) {
            IERC20(params.tokens[i]).approve(
                address(curveAdapter),
                params.amounts[i]
            );
        }
        params.operationType = OperationType.ADD_LIQUIDITY;
        params.recipient = user;
        params.deadline = block.timestamp + 1000;

        uint24 feeBaseRate = 30;
        OperationResult memory result = curveAdapter.executeOperation(
            params,
            feeBaseRate
        );
        assertEq(result.success, true);
        vm.stopPrank();
    }

    function _removeLiquidity(
        uint256 lpTokenAmount,
        uint256 expectedUsdcAmount,
        uint256 expectedUsdtAmount,
        uint256 expectedDaiAmount
    ) internal {
        vm.startPrank(user);
        OperationParams memory params;
        params.operationType = OperationType.REMOVE_LIQUIDITY;
        params.amounts = new uint256[](4);
        params.amounts[0] = lpTokenAmount;
        params.amounts[1] = expectedUsdcAmount;
        params.amounts[2] = expectedUsdtAmount;
        params.amounts[3] = expectedDaiAmount;
        params.tokens = new address[](3);
        params.tokens[0] = address(usdc);
        params.tokens[1] = address(usdt);
        params.tokens[2] = address(dai);
        params.recipient = user;
        params.deadline = block.timestamp + 1000;
        uint24 feeBaseRate = 30;
        IERC20(address(mockCurve)).approve(
            address(curveAdapter),
            lpTokenAmount
        );
        uint256 totalSupply = mockCurve.totalSupply();
        console.log("totalSupply", totalSupply);
        OperationResult memory result = curveAdapter.executeOperation(
            params,
            feeBaseRate
        );

        assertEq(result.success, true);
        vm.stopPrank();
    }
}
