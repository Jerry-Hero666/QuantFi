// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../interfaces/IDefiAdapter.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IAave.sol";

contract AaveAdapter is
    IDefiAdapter,
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20 for IERC20;

    address public aave;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _aave, address owner) public initializer {
        __Ownable_init(owner);
        //__UUPSUpgradeable_init();
        aave = _aave;
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
        return "AaveAdapter";
    }
    // 获取适配器版本
    function getVersion() external view override returns (string memory) {
        return "1.0.0";
    }

    //-----------内部方法----------
    function _handleWithdraw(
        OperationParams calldata params,
        uint24 feeBaseRate
    ) internal returns (OperationResult memory result) {
        require(params.amounts.length == 1, "Invalid amounts length");
        require(params.tokens.length == 1, "Invalid tokens length");
        require(params.amounts[0] > 0, "Invalid amount");
        require(params.tokens[0] != aave, "Invalid token");

        //校验用户余额是否充足
        require(
            IERC20(aave).balanceOf(params.recipient) >= params.amounts[0],
            "Insufficient balance"
        );
        require(
            IERC20(aave).allowance(params.recipient, address(this)) >=
                params.amounts[0],
            "Insufficient allowance"
        );
        //授权转账给合约输入金额
        IERC20(aave).safeTransferFrom(
            params.recipient,
            address(this),
            params.amounts[0]
        );
        // 授权给aave合约token
        IERC20(aave).approve(aave, params.amounts[0]);
        // 调用aave合约取款
        uint256 outputAmount = IAavePool(aave).withdraw(
            aave,
            params.amounts[0],
            params.recipient
        );

        result.outputAmounts = new uint256[](1);
        result.outputAmounts[0] = outputAmount;
        result.success = true;
        result.message = "Withdraw successful";
        return result;
    }

    function _handleDeposit(
        OperationParams calldata params,
        uint24 feeBaseRate
    ) internal returns (OperationResult memory result) {
        require(params.amounts.length == 1, "Invalid amounts length");
        require(params.tokens.length == 1, "Invalid tokens length");

        uint256 inputAmount = params.amounts[0];
        require(inputAmount > 0, "Invalid amount");
        require(params.tokens[0] != address(0), "Invalid token");

        //校验用户余额是否充足
        require(
            IERC20(params.tokens[0]).balanceOf(params.recipient) >= inputAmount,
            "Insufficient balance"
        );

        //验证用户是否授权给合约
        require(
            IERC20(params.tokens[0]).allowance(
                params.recipient,
                address(this)
            ) >= inputAmount,
            "Insufficient allowance"
        );

        //授权转账给合约输入金额
        IERC20(params.tokens[0]).safeTransferFrom(
            params.recipient,
            address(this),
            inputAmount
        );
        //扣除手续费
        uint256 fee = (inputAmount * feeBaseRate) / 1e4;
        uint256 amountToAave = inputAmount - fee;

        // 转账给aave合约
        IERC20(params.tokens[0]).safeTransfer(aave, amountToAave);
        // 调用aave合约存款
        IAavePool(aave).supply(
            params.tokens[0],
            amountToAave,
            params.recipient,
            0
        );

        result.outputAmounts = new uint256[](1);
        result.outputAmounts[0] = amountToAave;
        result.success = true;
        result.message = "Deposit successful";
        return result;
    }
}
