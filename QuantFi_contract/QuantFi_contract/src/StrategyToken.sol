//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/utils/PausableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC4626Upgradeable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";

contract StrategyToken is
    Initializable,
    ERC4626Upgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable
{
    using SafeERC20 for IERC20;
    //存储每个地址的份额
    mapping(address => uint256) public shareHolder;
    //底层资产
    IERC20 public underlyingToken;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initialOwner,
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol
    ) public initializer {
        __ERC20_init(_name, _symbol);
        __Ownable_init(_initialOwner);
        __ReentrancyGuard_init();
        __ERC4626_init(_underlyingToken);
        __UUPSUpgradeable_init();
        __Pausable_init();
        underlyingToken = _underlyingToken;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    /**
     * @notice 存入资产并获得金库代币
     * @param _assets 资产代币数量
     */
    function _deposit(uint _assets) public whenNotPaused nonReentrant {
        // checks that the deposited amount is greater than zero.
        require(_assets > 0, "Deposit less than Zero");
        // calling the deposit function from the ERC-4626 library to perform all the necessary functionality
        uint256 shares = deposit(_assets, msg.sender);
        //增加用户份额
        shareHolder[msg.sender] += shares;
    }

    /**
     * @notice 允许msg.sender提取存款及应计利息
     * @param _shares 用户想要转换的份额数量
     * @param _receiver 接收资产的用户地址
     */
    function _withdraw(
        uint _shares,
        address _receiver
    ) public whenNotPaused nonReentrant {
        //检查提取份额大于零
        require(_shares > 0, "withdraw must be greater than Zero");
        //检查接收地址不为零地址
        require(_receiver != address(0), "Zero Address");
        //检查调用者是份额持有者
        require(shareHolder[msg.sender] > 0, "Not a share holder");
        //检查调用者拥有足够份额
        require(shareHolder[msg.sender] >= _shares, "Not enough shares");
        //计算提取金额的10%收益
        uint256 percent = (10 * _shares) / 100;
        //计算总资金额为份额金额加上10%收益
        uint256 assets = _shares + percent;
        //调用ERC-4626库的redeem函数执行必要功能
        redeem(assets, _receiver, msg.sender);
        //减少用户份额
        shareHolder[msg.sender] -= _shares;
    }

    //返回总资产数量
    function totalAssets() public view override returns (uint256) {
        return underlyingToken.balanceOf(address(this));
    }

    //返回用户的总余额
    function totalAssetsOfUser(address _user) public view returns (uint256) {
        return underlyingToken.balanceOf(_user);
    }

    //获取链下资产地址
    function getUnderlyingToken() public view returns (address) {
        return address(underlyingToken);
    }

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
