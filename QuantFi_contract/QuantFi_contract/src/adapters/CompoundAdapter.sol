// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../interfaces/IDefiAdapter.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/ICompound.sol";

contract CompoundAdapter is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    IDefiAdapter
{
    using SafeERC20 for IERC20;

    address public compound;

    // USDT 代币地址 - 可配置支持不同网络
    address public usdtToken;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _compound,
        address _usdtToken,
        address _owner
    ) public initializer {
        require(_compound != address(0), "Invalid cUSDT address");
        require(_usdtToken != address(0), "Invalid USDT address");
        require(_owner != address(0), "Invalid owner address");

        __Ownable_init(_owner);
        //__UUPSUpgradeable_init();
        compound = _compound;
        usdtToken = _usdtToken;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    //---------实现IDefiAdapter接口---------
    //实现支持的操作类型的方法
    function supportOperation(
        OperationType operationType
    ) external view override returns (bool) {
        return
            operationType == OperationType.DEPOSIT ||
            operationType == OperationType.WITHDRAW;
    }

    // 获取支持的操作类型
    function getSupportedOperations()
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256[] memory operations = new uint256[](2);
        operations[0] = uint256(OperationType.DEPOSIT);
        operations[1] = uint256(OperationType.WITHDRAW);
        return operations;
    }

    // 执行操作
    function executeOperation(
        OperationParams calldata params,
        uint24 feeBaseRate
    ) external override returns (OperationResult memory result) {
        if (params.operationType == OperationType.WITHDRAW) {
            // 取款逻辑
            result = _handleWithdraw(params, feeBaseRate);
        } else if (params.operationType == OperationType.DEPOSIT) {
            // 存款逻辑
            result = _handleDeposit(params, feeBaseRate);
        } else {
            revert("Unsupported operation");
        }
    }

    // 获取适配器名称
    function getName() external view override returns (string memory) {
        return "CompoundAdapter";
    }
    // 获取适配器版本
    function getVersion() external view override returns (string memory) {
        return "1.0.0";
    }

    // 处理存款
    function _handleDeposit(
        OperationParams calldata params,
        uint256 feeRateBps
    ) internal returns (OperationResult memory result) {
        require(params.tokens.length == 1, "Invalid token");
        require(params.tokens[0] == usdtToken, "Only USDT withdraws supported");
        require(params.amounts.length == 1, "Invalid amount length");
        require(params.amounts[0] > 0, "Amount must be greater than 0");
        require(
            params.recipient != address(0),
            "Recipient address must be specified"
        );
        // 检查用户余额
        require(
            IERC20(params.tokens[0]).balanceOf(params.recipient) >=
                params.amounts[0],
            "Insufficient balance"
        );
        // 检查用户是否授权合约充足的代币
        require(
            IERC20(params.tokens[0]).allowance(
                params.recipient,
                address(this)
            ) >= params.amounts[0],
            "Insufficient allowance"
        );
        // 用户转账给适配器合约
        IERC20(params.tokens[0]).safeTransferFrom(
            params.recipient,
            address(this),
            params.amounts[0]
        );
        // 扣除手续费
        uint256 amountAfterFee = (params.amounts[0] * (10000 - feeRateBps)) /
            10000;
        //适配器合约授权给compound合约
        IERC20(params.tokens[0]).approve(compound, amountAfterFee);
        // 获取存款之前的适配器合约对应的ICToken数量
        uint256 icTokenAmountsBeforeDeposit = ICToken(compound).balanceOf(
            address(this)
        );
        // 调用compound合约进行存款
        uint256 mintResult = ICToken(compound).mint(amountAfterFee);
        // 获取存款之后的适配器合约对应的ICToken数量
        uint256 icTokenAmountsAfterDeposit = ICToken(compound).balanceOf(
            address(this)
        );
        uint256 icTokenAmounts = icTokenAmountsAfterDeposit -
            icTokenAmountsBeforeDeposit;
        require(mintResult == 0, "Compound mint failed");
        //将ICToken转给用户
        IERC20(compound).safeTransfer(params.recipient, icTokenAmounts);

        uint256[] memory optAmounts = new uint256[](1);
        optAmounts[0] = icTokenAmounts;
        result = OperationResult({
            success: true,
            message: "Deposit successful",
            outputAmounts: optAmounts,
            data: abi.encodePacked(optAmounts)
        });
    }

    // 处理取款
    function _handleWithdraw(
        OperationParams calldata params,
        uint256 feeRateBps
    ) internal returns (OperationResult memory result) {
        require(params.tokens.length == 1, "Invalid token");
        require(params.tokens[0] == usdtToken, "Only USDT withdraws supported");
        require(params.amounts.length == 1, "Invalid amount length");
        require(params.amounts[0] > 0, "Amount must be greater than 0");
        require(
            params.recipient != address(0),
            "Recipient address must be specified"
        );

        //验证用户有足够的ICToken代币
        //计算指定的usdtToken转换成ICToken的数量
        uint256 exchangeRate = ICToken(compound).exchangeRateCurrent();
        uint256 icTokenAmounts = (params.amounts[0] * 1e18) / exchangeRate;
        require(
            IERC20(compound).balanceOf(params.recipient) >= icTokenAmounts,
            "Insufficient balance"
        );
        //验证用户是否授权适配器合约ICToken代币
        require(
            IERC20(compound).allowance(params.recipient, address(this)) >=
                icTokenAmounts,
            "Insufficient allowance"
        );
        //转账给适配器合约
        IERC20(compound).safeTransferFrom(
            params.recipient,
            address(this),
            icTokenAmounts
        );
        //适配器合约授权ICToken给compound合约
        IERC20(compound).approve(compound, params.amounts[0]);
        //获取取款之后的适配器合约对应的代币数量
        uint256 tokenAmountsBeforeWithdraw = IERC20(params.tokens[0]).balanceOf(
            address(this)
        );
        //调用compound合约进行赎回
        uint256 redeemResult = ICToken(compound).redeemUnderlying(
            params.amounts[0]
        );
        require(redeemResult == 0, "Compound redeem failed");
        //获取取款之后的适配器合约对应的代币数量
        uint256 tokenAmountsAfterWithdraw = IERC20(params.tokens[0]).balanceOf(
            address(this)
        );
        uint256 tokenAmounts = tokenAmountsAfterWithdraw -
            tokenAmountsBeforeWithdraw;
        //把底层资产转移给用户
        IERC20(params.tokens[0]).safeTransfer(params.recipient, tokenAmounts);
        uint256[] memory optAmounts = new uint256[](1);
        optAmounts[0] = tokenAmounts;
        result = OperationResult({
            success: true,
            message: "Withdraw successful",
            outputAmounts: optAmounts,
            data: abi.encodePacked(optAmounts)
        });
        return result;
    }
}
