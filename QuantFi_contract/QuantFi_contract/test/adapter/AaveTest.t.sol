// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../../src/adapters/AaveAdapter.sol";
import {MockAavePool} from "../../src/mock/MockAavePool.sol";
import {OperationParams, OperationType, OperationResult} from "../../src/interfaces/IDefiAdapter.sol";
import {MockERC20} from "../../src/mock/MockERC20.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract AaveTest is Test {
    address public owner;
    address public user1;
    address public user2;
    MockAavePool public aavePool;
    MockERC20 public usdc;
    MockERC20 public aToken;
    AaveAdapter public aaveAdapter;

    function setUp() public {
        // 创建测试用户
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        aavePool = new MockAavePool();
        usdc = new MockERC20("USDC", "USDC", 18);
        aToken = new MockERC20("aToken", "aToken", 18);
        AaveAdapter impl = new AaveAdapter();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeWithSelector(
                AaveAdapter.initialize.selector,
                address(aavePool),
                address(aToken),
                address(usdc),
                owner
            )
        );
        //需要初始化底层资产和aToken存款代币凭证
        aavePool.initReserve(address(usdc), address(aToken));
        aaveAdapter = AaveAdapter(address(proxy));
        usdc.mint(user1, 20000);
    }

    function _executeDeposit(uint256 amount) internal {
        console.log(unicode"====== DEPOSIT TEST 💰 ======");
        console.log("Deposit Amount: %s", amount);

        // 使用 startPrank 维持 user1 身份
        vm.startPrank(user1);
        //获取user1初始余额
        uint256 initBalance = usdc.balanceOf(user1);
        console.log(unicode"[📊] User USDC Balance (Initial): %s", initBalance);

        OperationParams memory params;
        params.tokens = new address[](1);
        params.tokens[0] = address(usdc);
        params.amounts = new uint256[](1);
        params.amounts[0] = amount;
        params.operationType = OperationType.DEPOSIT;
        params.recipient = user1;
        params.deadline = block.timestamp + 100;
        uint24 feeRateBps = 30;
        uint256 balanceBeforeDeposit = IERC20(address(aToken)).balanceOf(user1);
        console.log(
            unicode"[📊] User aToken Balance (Before Deposit): %s",
            balanceBeforeDeposit
        );

        bool approveRes = IERC20(usdc).approve(address(aaveAdapter), amount);
        console.log(unicode"[✅] Approval Result: %s", approveRes);

        OperationResult memory result = aaveAdapter.executeOperation(
            params,
            feeRateBps
        );

        uint256 balanceAfterDeposit = IERC20(address(aToken)).balanceOf(user1);
        console.log(
            unicode"[📊] User aToken Balance (After Deposit): %s",
            balanceAfterDeposit
        );

        uint256 usdcBalance = usdc.balanceOf(user1);
        console.log(
            unicode"[📊] User USDC Balance (After Deposit): %s",
            usdcBalance
        );

        assertEq(result.success, true, "Deposit operation should succeed");
        //usdc存入之后会发等量的atoken (减去手续费)
        uint256 expectedATokenMint = (amount * (10000 - feeRateBps)) / 10000;
        assertEq(
            balanceAfterDeposit,
            balanceBeforeDeposit + expectedATokenMint,
            "aToken balance should increase by deposited amount minus fees"
        );
        assertEq(
            usdcBalance,
            initBalance - amount,
            "USDC balance should decrease by deposit amount"
        );
        // 停止 prank
        vm.stopPrank();

        console.log(unicode"====== DEPOSIT TEST PASSED ✅ ======");
    }

    //测试单次存款
    function testDeposit() public {
        // 存款
        _executeDeposit(5000);
    }

    //测试多次存款
    function testMultipleDepositAndWithdraw() public {
        console.log(
            unicode"====== MULTIPLE DEPOSIT AND WITHDRAW TEST 🔁 ======"
        );
        // 第一次存款
        _executeDeposit(5000);
        // 第二次存款
        _executeDeposit(5000);

        // 检查存款后的总余额
        uint256 totalATokenBalance = aToken.balanceOf(user1);
        console.log(
            unicode"[INFO] Total aToken balance before withdrawals: %s",
            totalATokenBalance
        );
        //模拟aToken增值，假设80%的存款使用率时，借贷有8%的利率
        //在aToken总供应量不变的前提下，usdc通过借贷利率的收取使得借贷池中的usdc增加
        usdc.mint(address(aavePool), ((5000 + 5000) * 8) / 100);
        // 第一次提款
        _executeWithdraw(5000);

        // 检查第一次提款后的余额
        uint256 aTokenBalanceAfterFirstWithdraw = aToken.balanceOf(user1);
        console.log(
            unicode"[INFO] aToken balance after first withdrawal: %s",
            aTokenBalanceAfterFirstWithdraw
        );

        // 第二次提款 - 使用正确的金额（应该是4985而不是5000）
        _executeWithdraw(4970);

        console.log(
            unicode"====== MULTIPLE DEPOSIT AND WITHDRAW TEST PASSED ✅ ======"
        );
    }

    //测试提款
    function _executeWithdraw(uint256 amount) internal {
        console.log(unicode"====== WITHDRAW TEST 💸 ======");
        console.log("Withdraw Amount: %s", amount);

        vm.startPrank(user1);

        // 检查提款前的余额
        uint256 aTokenBeforeWithdraw = aToken.balanceOf(user1);
        uint256 usdcBeforeWithdraw = usdc.balanceOf(user1);
        console.log(
            unicode"[📊] User aToken Balance (Before Withdraw): %s",
            aTokenBeforeWithdraw
        );
        console.log(
            unicode"[📊] User USDC Balance (Before Withdraw): %s",
            usdcBeforeWithdraw
        );

        // 确保有足够的aToken余额
        require(
            aTokenBeforeWithdraw >= amount,
            unicode"Insufficient aToken balance for withdrawal 💸"
        );

        OperationParams memory params;
        params.amounts = new uint256[](1);
        params.amounts[0] = amount;
        params.tokens = new address[](1);
        params.tokens[0] = address(usdc);
        params.operationType = OperationType.WITHDRAW;
        params.deadline = block.timestamp + 1 days;
        params.recipient = user1;
        uint24 feeRateBps = 30;

        //授权给适配器
        aToken.approve(address(aaveAdapter), params.amounts[0]);
        console.log(
            unicode"[✅] Approved aToken for adapter: %s",
            params.amounts[0]
        );

        OperationResult memory result = aaveAdapter.executeOperation(
            params,
            feeRateBps
        );

        uint256 aTokenAfterWithdraw = aToken.balanceOf(user1);
        uint256 usdcAfterWithdraw = usdc.balanceOf(user1);

        console.log(
            unicode"[📊] User aToken Balance (After Withdraw): %s",
            aTokenAfterWithdraw
        );
        console.log(
            unicode"[📊] User USDC Balance (After Withdraw): %s",
            usdcAfterWithdraw
        );

        vm.stopPrank();
        assertEq(result.success, true, "Withdraw operation should succeed");
        assertEq(
            aTokenAfterWithdraw,
            aTokenBeforeWithdraw - params.amounts[0],
            "aToken balance should decrease by withdrawn amount"
        );
        // 注意：由于 MockAavePool 中添加了利息，实际收到的 USDC 会比提取的 aToken 数量多
        // 我们需要根据 MockAavePool 的利息率来计算预期值
        uint256 expectedUsdcReceived = params.amounts[0] +
            ((params.amounts[0] * 50) / 10000); // 0.5% 利息
        assertEq(
            usdcAfterWithdraw,
            usdcBeforeWithdraw + expectedUsdcReceived,
            "USDC balance should increase by withdrawn amount plus interest"
        );

        console.log(unicode"====== WITHDRAW TEST PASSED ✅ ======");
    }
}
