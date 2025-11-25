// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "src/interfaces/IStrategyAggregator.sol";

contract TokenFactory is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    // 策略类型地址映射
    mapping(string => address) public strategyTokens;
    address public strategyTokenImplementation;
    // 新增策略事件
    event StrategyTokenAdded(string indexed strategy, address indexed token);
    // 删除策略事件
    event StrategyTokenRemoved(string indexed strategy, address indexed token);

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _admin,
        address _strategyTokenImplementation
    ) public initializer {
        __Ownable_init(_admin);
        strategyTokenImplementation = _strategyTokenImplementation;
    }

    //新增策略
    function addStrategyToken(
        string memory strategyType,
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address _underlyingToken
    ) external onlyOwner returns (address) {
        require(
            strategyTokens[strategyType] == address(0),
            "StrategyToken already exists"
        );
        require(initialSupply > 0, "Initial supply must be greater than 0");
        require(bytes(name).length > 0, "Name must be provided");
        require(bytes(symbol).length > 0, "Symbol must be provided");
        require(
            _underlyingToken != address(0),
            "Underlying token must be provided"
        );
        require(
            strategyTokenImplementation != address(0),
            "Strategy token implementation not set"
        );

        bytes memory initData = abi.encodeWithSignature(
            "initialize(address,address,string,string)",
            msg.sender,
            _underlyingToken,
            name,
            symbol
        );
        ERC1967Proxy proxy = new ERC1967Proxy(
            strategyTokenImplementation,
            initData
        );
        address strategyTokenAddress = address(proxy);
        strategyTokens[strategyType] = strategyTokenAddress;
        emit StrategyTokenAdded(strategyType, strategyTokenAddress);
        return strategyTokenAddress;
    }

    //删除策略
    function removeStrategyToken(
        string memory strategyType
    ) external onlyOwner {
        address token = strategyTokens[strategyType];
        require(token != address(0), "StrategyToken does not exist");
        delete strategyTokens[strategyType];
        emit StrategyTokenRemoved(strategyType, token);
    }

    //获取策略token地址
    function getStrategyToken(
        string memory strategyType
    ) external view returns (address) {
        return strategyTokens[strategyType];
    }

    //获取策略数量
    function getStrategyCount() external view returns (uint256) {
        return 0;
    }

    //获取策略token列表
    function getStrategyTokens() external view returns (address[] memory) {
        return new address[](0);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
