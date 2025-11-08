// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../interfaces/IDefiAdapter.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/ICurve.sol";

contract CurveAdapter is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    IDefiAdapter
{
    using SafeERC20 for IERC20;

    address public curve;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _curve, address owner) public initializer {
        __Ownable_init(owner);
        //__UUPSUpgradeable_init();
        _curve = curve;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    event LiquidityAdded(
        address indexed user,
        address indexed pool,
        uint256[3] amounts,
        uint256 lpTokens,
        uint256 timestamp
    );

    event LiquidityRemoved(
        address indexed user,
        address indexed pool,
        uint256 lpTokens,
        uint256[] amounts,
        uint256 timestamp
    );

    //---------实现IDefiAdapter接口---------
    //实现支持的操作类型的方法
    function supportOperation(
        OperationType operationType
    ) external view override returns (bool) {
        return
            operationType == OperationType.ADD_LIQUIDITY ||
            operationType == OperationType.REMOVE_LIQUIDITY;
    }

    // 获取支持的操作类型
    function getSupportedOperations()
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256[] memory operations = new uint256[](2);
        operations[0] = uint256(OperationType.ADD_LIQUIDITY);
        operations[1] = uint256(OperationType.REMOVE_LIQUIDITY);
        return operations;
    }

    // 执行操作
    function executeOperation(
        OperationParams calldata params,
        uint24 feeBaseRate
    ) external override returns (OperationResult memory result) {
        if (params.operationType == OperationType.ADD_LIQUIDITY) {
            // 取款逻辑
            result = _handleAddLiquidity(params, feeBaseRate);
        } else if (params.operationType == OperationType.REMOVE_LIQUIDITY) {
            // 删除流动性逻辑
            result = _handleRemoveLiquidity(params, feeBaseRate);
        } else {
            revert("Unsupported operation");
        }
    }

    // 获取适配器名称
    function getName() external view override returns (string memory) {
        return "CurveAdapter";
    }
    // 获取适配器版本
    function getVersion() external view override returns (string memory) {
        return "1.0.0";
    }

    function _handleAddLiquidity(
        OperationParams calldata params,
        uint24 feeBaseRate
    ) internal returns (OperationResult memory result) {
        require(params.tokens.length >= 1, "Invalid number of tokens");
        require(params.amounts.length == 4, "Invalid number of amounts");

        uint256[3] memory amounts;
        amounts[0] = params.amounts[0];
        amounts[1] = params.amounts[1];
        amounts[2] = params.amounts[2];

        uint256 minLPToken = params.amounts[3];
        for (uint256 i = 0; i < params.tokens.length; i++) {
            //验证用户有没有这么多token
            require(
                IERC20(params.tokens[i]).balanceOf(params.recipient) >=
                    amounts[i],
                "recipient Insufficient balance"
            );
            //验证用户是否授权给合约
            require(
                IERC20(params.tokens[i]).allowance(
                    params.recipient,
                    address(this)
                ) >= amounts[i],
                "Insufficient allowance"
            );
            //用户转给合约
            IERC20(params.tokens[i]).safeTransferFrom(
                params.recipient,
                address(this),
                amounts[i]
            );
            //验证合约余额
            require(
                IERC20(params.tokens[i]).balanceOf(address(this)) >= amounts[i],
                "before add liquidity. contract Insufficient balance"
            );
            //当前合约授权稳定币给curve
            IERC20(params.tokens[i]).approve(curve, amounts[i]);
            //验证curve合约是否成功被授权
            require(
                IERC20(params.tokens[i]).allowance(address(this), curve) >=
                    amounts[i],
                "curve Insufficient allowance"
            );
        }
        // 获取添加流动性前的合约LP代币数量
        uint256 lpBalanceBefore = IERC20(curve).balanceOf(address(this));
        //调用curve的add_liquidity方法
        ICurve(curve).add_liquidity(amounts, minLPToken);
        // 获取添加流动性后的合约LP代币数量
        uint256 lpBalanceAfter = IERC20(curve).balanceOf(address(this));
        //计算出新增的LP代币数量
        uint256 lpTokenAdded = lpBalanceAfter - lpBalanceBefore;
        //验证当前合约是不是已经收到ERC20的curve代币
        require(
            lpTokenAdded >= 0,
            "after add liquidity. current contract Insufficient balance"
        );
        //扣除手续费后的LP token数量
        uint256 netLpTokens = (lpTokenAdded * (10000 - feeBaseRate)) / 10000;
        //将curve代币转给用户
        IERC20(curve).safeTransfer(params.recipient, netLpTokens);

        emit LiquidityAdded(
            params.recipient,
            curve,
            amounts,
            netLpTokens,
            block.timestamp
        );
        uint256[] memory netAmounts = new uint256[](1);
        netAmounts[0] = netLpTokens;

        result = OperationResult({
            success: true,
            message: "Add liquidity successfully",
            outputAmounts: netAmounts,
            data: abi.encode(netLpTokens)
        });
    }

    function _handleRemoveLiquidity(
        OperationParams calldata params,
        uint24 feeBaseRate
    ) internal returns (OperationResult memory result) {
        require(params.tokens.length >= 1, "Invalid number of tokens");
        require(params.amounts.length >= 4, "Invalid number of amounts");
        //验证用户有没有这么多token
        require(
            IERC20(curve).balanceOf(params.recipient) >= params.amounts[0],
            "recipient Insufficient balance"
        );
        //验证用户是否授权给合约
        require(
            IERC20(curve).allowance(params.recipient, address(this)) >=
                params.amounts[0],
            "Insufficient allowance"
        );
        //用户转给合约
        IERC20(curve).safeTransferFrom(
            params.recipient,
            address(this),
            params.amounts[0]
        );
        //验证合约余额
        require(
            IERC20(curve).balanceOf(address(this)) >= params.amounts[0],
            "before remove liquidity. contract Insufficient balance"
        );
        //当前合约授权curve代币的代币给curve
        IERC20(curve).approve(curve, params.amounts[0]);
        //验证curve合约是否成功被授权
        require(
            IERC20(curve).allowance(address(this), curve) >= params.amounts[0],
            "curve Insufficient allowance"
        );
        uint256[] memory amountsBeforeRemove = new uint256[](3);
        //获取移除流动性前的合约3Pool 代币数量
        for (uint256 i = 0; i < params.tokens.length; i++) {
            uint256 balanceBefore = IERC20(params.tokens[i]).balanceOf(
                address(this)
            );
            amountsBeforeRemove[i] = balanceBefore;
        }
        //移除流动性
        ICurve(curve).remove_liquidity(
            params.amounts[0],
            [params.amounts[1], params.amounts[2], params.amounts[3]]
        );
        uint256[] memory amountsAfterRemove = new uint256[](3);
        for (uint256 i = 0; i < params.tokens.length; i++) {
            //获取移除流动性后的合约3Pool 代币数量
            uint256 balanceAfter = IERC20(params.tokens[i]).balanceOf(
                address(this)
            );
            //计算出移除流动性获取的代币数量
            uint256 amountRemoved = balanceAfter - amountsBeforeRemove[i];
            amountsAfterRemove[i] = amountRemoved;
            //验证当前合约是不是已经收到3Pool代币
            require(
                amountRemoved >= 0,
                "after remove liquidity. current contract Insufficient balance"
            );
            //将curve代币转给用户
            IERC20(params.tokens[i]).safeTransfer(
                params.recipient,
                amountRemoved
            );
        }
        emit LiquidityRemoved(
            params.recipient,
            curve,
            params.amounts[0],
            amountsAfterRemove,
            block.timestamp
        );
        result = OperationResult({
            success: true,
            message: "Remove liquidity successfully",
            outputAmounts: amountsAfterRemove,
            data: abi.encode(amountsAfterRemove)
        });
    }
}
