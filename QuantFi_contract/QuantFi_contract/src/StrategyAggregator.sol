// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./interfaces/IStrategyAggregator.sol";
import "./interfaces/IAssetsAdapter.sol";
import "./TokenFactory.sol";
import "./StrategyToken.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StrategyAggregator is
    IStrategyAggregator,
    IAssetsAdapter,
    Initializable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable
{
    TokenFactory public tokenFactory;

    event Deposit(
        string indexed _strategyType,
        address indexed _token,
        address indexed _user,
        uint256 _amount
    );

    event Withdraw(
        string indexed _strategyType,
        address indexed _token,
        address indexed _user,
        uint256 _amount
    );

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initOwner,
        address _tokenFactoryAddress
    ) public initializer {
        __Ownable_init(_initOwner);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        __Pausable_init();
        tokenFactory = TokenFactory(_tokenFactoryAddress);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function deposit(
        DepositParams memory params
    )
        external
        whenNotPaused
        nonReentrant
        returns (DepositResult memory result)
    {
        require(params.amount > 0, "Amount must be greater than 0");

        string memory strategyType = params.strategyType;
        //获取策略代币金库合约地址
        address strategyAddress = tokenFactory.getStrategyToken(strategyType);
        require(strategyAddress != address(0), "Strategy not found");
        //验证用户是否有足够的代币余额
        require(
            IERC20(params.token).balanceOf(params.user) >= params.amount,
            "Insufficient balance"
        );
        StrategyToken strategyToken = StrategyToken(strategyAddress);
        address underlyingToken = strategyToken.getUnderlyingToken();
        //调用策略代币金库合约存款
        strategyToken._deposit(params.amount);

        //触发存款事件
        emit Deposit(
            strategyType,
            underlyingToken,
            result.recipient,
            result.actualAmount
        );
        result.success = true;
        result.recipient = params.user;
        result.actualAmount = params.amount;
        result.message = "Deposit successful";
    }

    function withdraw(
        WithdrawParams memory params
    )
        external
        whenNotPaused
        nonReentrant
        returns (WithdrawResult memory result)
    {
        require(params.shareAmount > 0, "shares must > 0");
        string memory strategyType = params.strategyType;
        //获取策略代币金库合约地址
        address strategyAddress = tokenFactory.getStrategyToken(strategyType);
        require(strategyAddress != address(0), "Strategy not found");
        //验证用户是否有策略代币
        require(
            IERC20(strategyAddress).balanceOf(params.user) >=
                params.shareAmount,
            "Insufficient strategy token"
        );
        //获取策略代币合约
        StrategyToken strategyToken = StrategyToken(strategyAddress);
        // 获取策略代币对应的链下资产
        address underlyingToken = strategyToken.getUnderlyingToken();
        strategyToken._withdraw(params.shareAmount, params.user);
        emit Withdraw(
            strategyType,
            underlyingToken,
            result.recipient,
            result.actualAmount
        );
        result.success = true;
        result.recipient = params.user;
        result.actualAmount = params.shareAmount;
        result.message = "Withdraw successful";
    }

    //调用策略适配器执行真实资产注入
    function addAssets(
        address _token,
        uint256 _amount
    ) external override whenNotPaused nonReentrant {}

    //调用策略适配器执行真实资产取出
    function removeAssets(
        address _token,
        uint256 _amount
    ) external override whenNotPaused nonReentrant {}

    /**
     * @dev 紧急暂停
     */
    function emergencyPause() external onlyOwner {
        _pause();
    }

    /**
     * @dev 取消暂停
     */
    function emergencyUnpause() external onlyOwner {
        _unpause();
    }
}
