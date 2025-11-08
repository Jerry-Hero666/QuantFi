// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IDefiAdapter.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/INonfungiblePositionManager.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract UniswapV3Adapter is
    IDefiAdapter,
    Initializable,
    OwnableUpgradeable,
    IERC721Receiver,
    UUPSUpgradeable
{
    address public inonfungiblePositionManager;
    using SafeERC20 for IERC20;

    constructor() {
        _disableInitializers();
    }

    //  初始化函数
    function initialize(
        address positonManager,
        address _owner
    ) public initializer {
        __Ownable_init(_owner);
        inonfungiblePositionManager = positonManager;
    }
    // 实现UUPSUpgradeable升级逻辑
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    // ---------------事件------------------
    event AddLiquidity(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient,
        uint256 deadline,
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0Actual,
        uint256 amount1Actual
    );
    event RemoveLiquidity(
        uint24 indexed fee,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient,
        uint256 deadline,
        uint256 amount0Actual,
        uint256 amount1Actual
    );
    event CollectFees(
        uint128 amount0,
        uint128 amount1,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient,
        uint256 deadline,
        uint256 amount0Actual,
        uint256 amount1Actual
    );

    // ---------------实现IDefiAdapter适配器接口------------------

    //实现支持的操作类型的方法
    function supportOperation(
        OperationType operationType
    ) external view override returns (bool) {
        return
            operationType == OperationType.ADD_LIQUIDITY ||
            operationType == OperationType.REMOVE_LIQUIDITY ||
            operationType == OperationType.COLLECT_FEES;
    }

    // 获取支持的操作类型
    function getSupportedOperations()
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256[] memory operations = new uint256[](3);
        operations[0] = uint256(OperationType.ADD_LIQUIDITY);
        operations[1] = uint256(OperationType.REMOVE_LIQUIDITY);
        operations[2] = uint256(OperationType.COLLECT_FEES);
        return operations;
    }

    // 执行操作
    function executeOperation(
        OperationParams calldata params,
        uint24 feeBaseRate
    ) external override returns (OperationResult memory result) {
        if (params.operationType == OperationType.ADD_LIQUIDITY) {
            // 添加流动性逻辑
            result = _addLiquidity(params, feeBaseRate);
        } else if (params.operationType == OperationType.REMOVE_LIQUIDITY) {
            // 移除流动性逻辑
            result = _removeLiquidity(params);
        } else if (params.operationType == OperationType.COLLECT_FEES) {
            result = _collectFees(params);
        } else {
            revert("Unsupported operation");
        }
    }

    // 获取适配器名称
    function getName() external view override returns (string memory) {
        return "UniswapV3Adapter";
    }
    // 获取适配器版本
    function getVersion() external view override returns (string memory) {
        return "1.0.0";
    }

    //----------内部方法----------

    //添加流动性
    function _addLiquidity(
        OperationParams calldata params,
        uint24 feeBaseRate
    ) internal returns (OperationResult memory result) {
        require(params.tokens.length == 2, "Invalid token length");
        //索引0和1是代币数量 2和3是最小代币数量
        require(params.amounts.length == 4, "Invalid amount length");
        require(
            params.recipient != address(0),
            "Recipient address must be specified"
        );

        //查看用户是否有代币
        for (uint256 i = 0; i < params.tokens.length; i++) {
            IERC20 token = IERC20(params.tokens[i]);
            uint256 balance = token.balanceOf(params.recipient);
            require(balance >= params.amounts[i], "Insufficient balance");
            //验证授权
            require(
                token.allowance(params.recipient, address(this)) >=
                    params.amounts[i],
                "Insufficient allowance"
            );
            //转账给当前合约
            token.safeTransferFrom(
                params.recipient,
                address(this),
                params.amounts[i]
            );
        }

        //计算手续费
        uint256 amount0DecreaseFee = params.amounts[0] -
            (params.amounts[0] * 30) /
            10000;
        uint256 amount1DecreaseFee = params.amounts[1] -
            (params.amounts[1] * 30) /
            10000;
        //授权给NonfungiblePositionManager
        IERC20(params.tokens[0]).approve(
            inonfungiblePositionManager,
            amount0DecreaseFee
        );
        IERC20(params.tokens[1]).approve(
            inonfungiblePositionManager,
            amount1DecreaseFee
        );

        //tick范围(需要设置提供流动性的tick范围 uniswap V3特性)
        int24 tickLower = -887220;
        int24 tickUpper = 887220;

        // 从 extraData 中解析 tick 参数
        if (params.extraData.length > 0) {
            // extraData 格式: abi.encode(tickLower, tickUpper)
            try this.decodeTicks(params.extraData) returns (
                int24 _tickLower,
                int24 _tickUpper
            ) {
                tickLower = _tickLower;
                tickUpper = _tickUpper;
            } catch {
                // 如果解析失败，使用默认值
            }
        }
        //创建mintParams参数
        INonfungiblePositionManager.MintParams
            memory mintParams = INonfungiblePositionManager.MintParams({
                token0: params.tokens[0],
                token1: params.tokens[1],
                fee: feeBaseRate,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: amount0DecreaseFee,
                amount1Desired: amount1DecreaseFee,
                amount0Min: params.amounts[2],
                amount1Min: params.amounts[3],
                recipient: params.recipient,
                deadline: params.deadline
            });

        (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0Actual,
            uint256 amount1Actual
        ) = INonfungiblePositionManager(inonfungiblePositionManager).mint(
                mintParams
            );

        //发送添加流动性的事件
        emit AddLiquidity(
            params.tokens[0],
            params.tokens[1],
            feeBaseRate,
            tickLower,
            tickUpper,
            amount0DecreaseFee,
            amount1DecreaseFee,
            params.amounts[2],
            params.amounts[3],
            params.recipient,
            params.deadline,
            tokenId,
            liquidity,
            amount0Actual,
            amount1Actual
        );

        result.outputAmounts = new uint256[](1);
        //返回添加的tokenId（ERC721代币）
        result.outputAmounts[0] = tokenId;
        result.success = true;
        result.message = "Add liquidity successful";
        return result;
    }

    //移除流动性
    function _removeLiquidity(
        OperationParams calldata params
    ) internal returns (OperationResult memory result) {
        require(params.tokenId > 0, "Invalid tokenId");
        //验证tokenId是否属于用户
        require(
            INonfungiblePositionManager(inonfungiblePositionManager).ownerOf(
                params.tokenId
            ) == params.recipient,
            "Not owner"
        );
        //获取用户头寸
        (, , , , , , , uint256 liquidity, , , , ) = INonfungiblePositionManager(
            inonfungiblePositionManager
        ).positions(params.tokenId);
        require(liquidity > 0, "Invalid liquidity");
        //创建removeLiquidity参数
        INonfungiblePositionManager.DecreaseLiquidityParams
            memory decreaseLiquidityParams = INonfungiblePositionManager
                .DecreaseLiquidityParams({
                    tokenId: params.tokenId,
                    liquidity: uint128(liquidity),
                    amount0Min: params.amounts[0],
                    amount1Min: params.amounts[1],
                    deadline: params.deadline
                });
        //减少流动性
        (uint256 amount0, uint256 amount1) = INonfungiblePositionManager(
            inonfungiblePositionManager
        ).decreaseLiquidity(decreaseLiquidityParams);

        //创建collectParams参数
        INonfungiblePositionManager.CollectParams
            memory collectParams = INonfungiblePositionManager.CollectParams({
                tokenId: params.tokenId,
                recipient: params.recipient,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });
        //收集手续费代币
        (amount0, amount1) = INonfungiblePositionManager(
            inonfungiblePositionManager
        ).collect(collectParams);

        emit RemoveLiquidity(
            uint24(3000),
            uint128(liquidity),
            amount0,
            amount1,
            params.amounts[0],
            params.amounts[1],
            params.recipient,
            params.deadline,
            amount0,
            amount1
        );
        //返回移除流动性释放的代币数量
        result.outputAmounts = new uint256[](2);
        result.outputAmounts[0] = amount0;
        result.outputAmounts[1] = amount1;
        result.success = true;
        result.message = "Remove liquidity successful";
        return result;
    }

    //提取手续费
    function _collectFees(
        OperationParams calldata params
    ) internal returns (OperationResult memory result) {
        require(params.tokenId > 0, "Invalid tokenId");
        require(params.amounts.length == 2, "Invalid amount length");
        //验证tokenId是否属于用户
        require(
            INonfungiblePositionManager(inonfungiblePositionManager).ownerOf(
                params.tokenId
            ) == params.recipient,
            "Not owner"
        );
        //创建collectParams参数
        INonfungiblePositionManager.CollectParams
            memory collectParams = INonfungiblePositionManager.CollectParams({
                tokenId: params.tokenId,
                recipient: params.recipient,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });
        (uint256 amount0, uint256 amount1) = INonfungiblePositionManager(
            inonfungiblePositionManager
        ).collect(collectParams);
        emit CollectFees(
            uint128(amount0),
            uint128(amount1),
            0,
            0,
            params.recipient,
            params.deadline,
            amount0,
            amount1
        );
        result.outputAmounts = new uint256[](2);
        result.outputAmounts[0] = amount0;
        result.outputAmounts[1] = amount1;
        result.success = true;
        result.message = "Collect fees successful";

        return result;
    }

    /**
     * @dev 从 extraData 中解码 tick 参数
     * @param data 编码的数据 (abi.encode(tickLower, tickUpper))
     * @return tickLower 下限 tick
     * @return tickUpper 上限 tick
     */
    function decodeTicks(
        bytes calldata data
    ) external pure returns (int24 tickLower, int24 tickUpper) {
        (tickLower, tickUpper) = abi.decode(data, (int24, int24));
    }
    function position(
        uint256 tokenId
    )
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        )
    {
        return
            INonfungiblePositionManager(inonfungiblePositionManager).positions(
                tokenId
            );
    }

    /**
     * @dev 实现 IERC721Receiver 接口以接收 NFT
     */
    function onERC721Received(
        address /* operator */,
        address /* from */,
        uint256 /* tokenId */,
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
