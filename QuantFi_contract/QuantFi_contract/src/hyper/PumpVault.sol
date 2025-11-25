// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../interfaces/IPumpOracle.sol";
import "../interfaces/IPumpStake.sol";

contract PumpVault is 
    Initializable, 
    ERC20Upgradeable, 
    OwnableUpgradeable, 
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable 
{

    // Asset and share variables
    uint256 public totalPooledAsset;             // Total asset amount
    uint256 public externallyStakedAsset;        // Externally staked asset amount
    uint256 private _totalShares;                // Total internal shares
    uint256 public sharePrice;                   // Value of one share in assets
    
    // Fee parameters
    uint256 public performanceFee;               // Performance fee rate (basis points, 1000 = 10%)
    uint256 public instantWithdrawalFee;         // Instant withdrawal fee rate (basis points, 100 = 1%)

    // Rebase parameters
    uint256 public lastRebaseTime;               // Timestamp of the last rebase
    uint256 public rebaseInterval;               // Minimum time interval for rebase (seconds)

    // Withdrawal parameters
    uint256 public withdrawalLimit;              // Maximum withdrawal amount per transaction
    uint256 public withdrawalDelay;              // Withdrawal delay period (default 8 days)
    bool public withdrawalsEnabled;              // Withdrawal switch

    // Token configuration
    address public supportedToken;               // Supported token address
    bool public isNativeToken;                   // Whether native token is supported
    uint8 public supportedTokenDecimals;         // Decimals of the supported asset

    // Address configuration
    address public feeRecipient;                 // Fee recipient address
    address public stakeContractAddress;         // Stake contract address
    address public PUMP_ORACLE;              // Pump Oracle interface address

    // Mappings
    mapping(address => uint256) private _shares; // User shares
    mapping(address => mapping(address => uint256)) private _sharesAllowances;

    // Withdrawal request structure
    struct WithdrawalRequest {
        uint256 sharesAmount;    // Request shares amount
        uint256 sharePrice;      // Share price at request time
        uint256 timestamp;       // Request timestamp
        bool exists;             // Request existence
    }
    mapping(address => WithdrawalRequest) public withdrawalRequests;
    
    event AssetStaked(address indexed user, uint256 assetAmount, uint256 sharesAmount);
    event AssetWithdrawn(address indexed user, uint256 assetAmount, uint256 sharesAmount);
    event TokenRebased(uint256 indexed reportTimestamp, uint256 timeElapsed, uint256 preTotalShares, uint256 preTotalPooledAsset, uint256 postTotalShares, uint256 postTotalPooledAsset);
    event WithdrawalLimitUpdated(uint256 newLimit);
    event WithdrawalsToggled(bool enabled);
    event RebaseIntervalUpdated(uint256 newInterval);
    event WithdrawalRequested(address indexed user, uint256 sharesAmount, uint256 assetAmount, uint256 unlockTime);
    event WithdrawalCompleted(address indexed user, uint256 assetAmount);
    event WithdrawalDelayUpdated(uint256 newDelay);
    event InstantWithdrawalFeeUpdated(uint256 newFee);
    event FeeRecipientUpdated(address indexed previousRecipient, address indexed newRecipient);
    event OracleAddressUpdated(address oldAddress, address newAddress);
    event PerformanceFeeUpdated(uint256 oldFee, uint256 newFee);
    event PerformanceFeeCollected(uint256 feeAmount, uint256 sharesAmount);
    event StakeContractUpdated(address oldAddress, address newAddress);
    event TransferredToStake(uint256 amount);
    event RequestedAssetsFromStake(uint256 amount);
    event NativeTokenReceived(address indexed sender, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    /**
     * @dev Initialize function, replacing constructor
     * @param initialOwner Initial owner
     * @param _supportedToken Supported token address (address(0) represents native token)
     * @param _decimals Supported asset decimal places
     */
    function initialize(
        address initialOwner, 
        address _supportedToken,
        uint8 _decimals
    ) public initializer {
        __ERC20_init("PumpHYPE", "PumpHYPE");
        __Ownable_init(initialOwner);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        __Pausable_init();
        
        supportedToken = _supportedToken;
        isNativeToken = (_supportedToken == address(0));
        supportedTokenDecimals = _decimals;
        
        sharePrice = 10**_decimals;
        withdrawalLimit = type(uint256).max;
        withdrawalsEnabled = true;
        
        feeRecipient = initialOwner;
        
        withdrawalDelay = 8 days;
        instantWithdrawalFee = 100;
        performanceFee = 1000;
        lastRebaseTime = 0;
        rebaseInterval = 1 days;

    }
    
    /**
     * @dev Handler for receiving native token transfers, only active when vault supports native token
     */
    receive() external payable {
        require(isNativeToken, "Contract only accepts the supported token");
        emit NativeTokenReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev UUPS upgrade authorization
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    
    /**
     * @dev Stake assets to get PUMP
     * @param amount Stake ERC20 token amount (when staking native token, set amount to 0)
     */
    function stake(uint256 amount) public payable nonReentrant whenNotPaused {
        uint256 stakeAmount;
        uint256 sharesAmount;
        
        if (isNativeToken) {
            // Stake native token
            require(msg.value > 0, "Asset amount must be greater than 0");
            require(amount == 0, "Amount must be 0 for native token");
            stakeAmount = msg.value;
        } else {
            // Stake ERC20 token
            require(amount > 0, "Asset amount must be greater than 0");
            require(msg.value == 0, "Cannot send ETH with ERC20 stake");
            
            // Transfer token to contract
            IERC20 token = IERC20(supportedToken);
            require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
            stakeAmount = amount;
        }
        
        // Calculate shares - maintain 1:1 ratio
        sharesAmount = (stakeAmount * 10**decimals()) / sharePrice;
        
        // Update state
        _shares[msg.sender] += sharesAmount;
        _totalShares += sharesAmount;
        totalPooledAsset += stakeAmount;
        
        emit Transfer(address(0), msg.sender, getAssetByShares(sharesAmount));
        emit AssetStaked(msg.sender, stakeAmount, sharesAmount);
    }
    
    /**
     * @dev Set the minimum rebase time interval
     * @param interval New time interval (seconds)
     */
    function setRebaseInterval(uint256 interval) external onlyOwner {
        rebaseInterval = interval;
        emit RebaseIntervalUpdated(interval);
    }
    
    /**
     * @dev Project side executes rebase operation, updating token ratio based on staking rewards
     * Uses Oracle to automatically calculate total assets
     */
    function rebase() external onlyOwner {
        require(_totalShares > 0, "No shares exist");
        require(PUMP_ORACLE != address(0), "Oracle address not set");
        
        // Check time interval
        uint256 currentTime = block.timestamp;
        if (lastRebaseTime > 0) {
            require(currentTime >= lastRebaseTime + rebaseInterval, "Rebase too frequent");
        }
        
        // Get on-chain balance (assets in this contract)
        uint256 contractBalance = isNativeToken ? address(this).balance : IERC20(supportedToken).balanceOf(address(this));
        
        // Get staked balance via Oracle
        uint64 stakedBalance = IPumpOracle(PUMP_ORACLE).getStakedTotal(stakeContractAddress);

        // Get assets balance from stake contract
        uint256 stakeContractBalance = IPumpStake(stakeContractAddress).getContractBalance();

        uint256 outsideBalance = stakedBalance + stakeContractBalance;
        
        // Calculate total assets
        uint256 totalAssets = contractBalance + outsideBalance;
        
        // Store previous values for event
        uint256 preTotalShares = _totalShares;
        uint256 preTotalPooledAsset = totalPooledAsset;
        uint256 timeElapsed = lastRebaseTime > 0 ? currentTime - lastRebaseTime : 0;
        
        // Calculate staking rewards (if any)
        uint256 stakingRewards = 0;
        if (outsideBalance > externallyStakedAsset) {
            stakingRewards = outsideBalance - externallyStakedAsset;

            // Calculate performance fee
            uint256 feeAmount = (stakingRewards * performanceFee) / 10000;
            
            // Update share price based on total assets minus fee
            sharePrice = ((totalAssets - feeAmount) * 10**decimals()) / _totalShares;
            
            // Calculate shares for fee recipient based on new share price
            uint256 feeShares = (feeAmount * 10**decimals()) / sharePrice;
            
            // Mint shares to fee recipient
            _shares[feeRecipient] += feeShares;
            _totalShares += feeShares;
            
            // Emit fee collection event
            emit PerformanceFeeCollected(feeAmount, feeShares);
        } else {
            // In case of no rewards or negative returns, just update with current values
            sharePrice = (totalAssets * 10**decimals()) / _totalShares;
        }

        totalPooledAsset = totalAssets;
        externallyStakedAsset = outsideBalance;
        lastRebaseTime = currentTime;
        
        emit TokenRebased(
            currentTime,
            timeElapsed,
            preTotalShares,
            preTotalPooledAsset,
            _totalShares,
            totalPooledAsset
        );
    }
    
    
    /**
     * @dev Set the maximum single withdrawal limit
     * @param newLimit New withdrawal limit
     */
    function setWithdrawalLimit(uint256 newLimit) external onlyOwner {
        withdrawalLimit = newLimit;
        emit WithdrawalLimitUpdated(newLimit);
    }
    
    /**
     * @dev Enable/disable withdrawal function
     * @param enabled Whether to enable withdrawal
     */
    function toggleWithdrawals(bool enabled) external onlyOwner {
        withdrawalsEnabled = enabled;
        emit WithdrawalsToggled(enabled);
    }
    
    /**
     * @dev Get the available asset balance of the contract
     * @return Available asset amount
     */
    function getAvailableContractBalance() public view returns (uint256) {
        if (isNativeToken) {
            return address(this).balance;
        } else {
            IERC20 token = IERC20(supportedToken);
            return token.balanceOf(address(this));
        }
    }
    
    /**
     * @dev Convert asset amount to internal shares
     * @param assetAmount Asset amount
     * @return Corresponding shares amount
     */
    function getSharesByAsset(uint256 assetAmount) public view returns (uint256) {
        return (assetAmount * 10**decimals()) / sharePrice;
    }
    
    /**
     * @dev Convert internal shares to asset amount
     * @param sharesAmount Shares amount
     * @return Corresponding asset amount
     */
    function getAssetByShares(uint256 sharesAmount) public view returns (uint256) {
        return (sharesAmount * sharePrice) / 10**decimals();
    }
    
    /**
     * @dev Get the number of shares held by the user
     * @param account User address
     * @return Shares amount
     */
    function sharesOf(address account) external view returns (uint256) {
        return _shares[account];
    }
    
    /**
     * @dev Get the total number of shares
     * @return Total shares
     */
    function totalShares() external view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Override balanceOf method to ensure return based on shares and current sharePrice
     */
    function balanceOf(address account) public view override returns (uint256) {
        return getAssetByShares(_shares[account]);
    }

    /**
     * @dev Override totalSupply method to ensure return current total asset amount
     */
    function totalSupply() public view override returns (uint256) {
        return totalPooledAsset;
    }
    
    /**
     * @dev Override transfer method to ensure transfer shares based on asset amount
     */
    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        address owner = _msgSender();
        
        // Calculate shares to transfer
        uint256 sharesToTransfer = getSharesByAsset(amount);
        
        // Ensure user has enough shares
        require(_shares[owner] >= sharesToTransfer, "Insufficient shares");
        
        // Update shares
        _shares[owner] -= sharesToTransfer;
        _shares[to] += sharesToTransfer;
        
        emit Transfer(owner, to, amount);
        
        return true;
    }
    
    /**
     * @dev Override transferFrom method to ensure transfer shares based on asset amount
     */
    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        address spender = _msgSender();
        
        // Check and update allowance first
        _spendAllowance(from, spender, amount);
        
        // Calculate shares to transfer
        uint256 sharesToTransfer = getSharesByAsset(amount);
        
        // Ensure user has enough shares
        require(_shares[from] >= sharesToTransfer, "Insufficient shares");
        
        // Update shares
        _shares[from] -= sharesToTransfer;
        _shares[to] += sharesToTransfer;
        
        emit Transfer(from, to, amount);
        
        return true;
    }
    
    /**
     * @dev Override ERC20 approve method - manages allowances using internal share accounting
     */
    function approve(address spender, uint256 amount) public override whenNotPaused returns (bool) {
        // Special handling for infinite authorization
        if (amount == type(uint256).max) {
            // For maximum value authorization, directly set the shares authorization to the maximum value
            _sharesAllowances[msg.sender][spender] = type(uint256).max;
        } else {
            // Convert token amount to shares
            uint256 sharesToApprove = getSharesByAsset(amount);
            _sharesAllowances[msg.sender][spender] = sharesToApprove;
        }
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    /**
     * @dev Override allowance method to ensure return the approved share amount
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        // Special handling for maximum value authorization
        if (_sharesAllowances[owner][spender] == type(uint256).max) {
            return type(uint256).max;
        }
        // Get authorization from shares mapping and convert to current token amount
        return getAssetByShares(_sharesAllowances[owner][spender]);
    }
    
    /**
     * @dev Override _spendAllowance method to ensure use shares for authorization consumption
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual override {
        uint256 currentAllowance = _sharesAllowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            uint256 sharesToSpend = getSharesByAsset(value);
            if (currentAllowance < sharesToSpend) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            _sharesAllowances[owner][spender] -= sharesToSpend;
        }
    }
    
    // Add pause and unpause functionality
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Override decimals function to return the same number of decimals as the supported token
     */
    function decimals() public view override returns (uint8) {
        return supportedTokenDecimals;
    }

    /**
     * @dev Set withdrawal waiting period
     * @param newDelay New waiting period (seconds)
     */
    function setWithdrawalDelay(uint256 newDelay) external onlyOwner {
        withdrawalDelay = newDelay;
        emit WithdrawalDelayUpdated(newDelay);
    }

    /**
     * @dev Set instant withdrawal fee rate
     * @param newFee New fee rate (basis points, 100 = 1%)
     */
    function setInstantWithdrawalFee(uint256 newFee) external onlyOwner {
        require(newFee <= 1000, "Fee cannot exceed 10%"); // Limit maximum fee to 10%
        instantWithdrawalFee = newFee;
        emit InstantWithdrawalFeeUpdated(newFee);
    }

    /**
     * @dev Request withdrawal (start delayed withdrawal process)
     * @param assetAmount Amount to withdraw
     */
    function requestWithdrawal(uint256 assetAmount) external nonReentrant whenNotPaused {
        require(withdrawalsEnabled, "Withdrawals are currently disabled");
        require(assetAmount > 0, "Withdrawal amount must be greater than 0");
        require(assetAmount <= withdrawalLimit, "Exceeds withdrawal limit");
        require(!withdrawalRequests[msg.sender].exists, "Existing withdrawal request pending");
        
        // Calculate corresponding shares
        uint256 sharesToWithdraw = getSharesByAsset(assetAmount);
        
        // Check if user has enough shares
        require(_shares[msg.sender] >= sharesToWithdraw, "Insufficient shares");
        
        // Deduct shares from user balance (but not from total shares)
        _shares[msg.sender] -= sharesToWithdraw;
        
        // Record withdrawal request
        withdrawalRequests[msg.sender] = WithdrawalRequest({
            sharesAmount: sharesToWithdraw,
            sharePrice: sharePrice,
            timestamp: block.timestamp,
            exists: true
        });
        
        // Calculate unlock time
        uint256 unlockTime = block.timestamp + withdrawalDelay;
        
        emit WithdrawalRequested(msg.sender, sharesToWithdraw, assetAmount, unlockTime);
    }

    /**
     * @dev Complete withdrawal (after delay period)
     */
    function completeWithdrawal() external nonReentrant whenNotPaused {
        WithdrawalRequest storage request = withdrawalRequests[msg.sender];
        
        require(request.exists, "No withdrawal request found");
        require(block.timestamp >= request.timestamp + withdrawalDelay, "Withdrawal delay not passed");
        
        // Calculate the asset amount to withdraw (based on the sharePrice at the time of request)
        uint256 assetToWithdraw = (request.sharesAmount * request.sharePrice) / 10**decimals();
        
        // Check if the contract has enough assets
        uint256 availableAsset = getAvailableContractBalance();
        require(availableAsset >= assetToWithdraw, "Insufficient contract balance");
        
        // Deduct from total shares
        _totalShares -= request.sharesAmount;
        totalPooledAsset -= assetToWithdraw;
        
        // Clear request
        delete withdrawalRequests[msg.sender];
        
        // Transfer assets to user
        if (isNativeToken) {
            (bool success, ) = payable(msg.sender).call{value: assetToWithdraw}("");
            require(success, "Native token transfer failed");
        } else {
            IERC20 token = IERC20(supportedToken);
            require(token.transfer(msg.sender, assetToWithdraw), "Token transfer failed");
        }
        
        emit WithdrawalCompleted(msg.sender, assetToWithdraw);
        emit Transfer(msg.sender, address(0), assetToWithdraw);
    }

    /**
     * @dev Set fee recipient address
     * @param newFeeRecipient New fee recipient address
     */
    function setFeeRecipient(address newFeeRecipient) external onlyOwner {
        require(newFeeRecipient != address(0), "Fee recipient is the zero address");
        address oldFeeRecipient = feeRecipient;
        feeRecipient = newFeeRecipient;
        emit FeeRecipientUpdated(oldFeeRecipient, newFeeRecipient);
    }

    /**
     * @dev Instant withdrawal (pay fee)
     * @param assetAmount Amount to withdraw
     */
    function instantWithdrawal(uint256 assetAmount) external nonReentrant whenNotPaused {
        require(withdrawalsEnabled, "Withdrawals are currently disabled");
        require(assetAmount > 0, "Withdrawal amount must be greater than 0");
        require(assetAmount <= withdrawalLimit, "Exceeds withdrawal limit");
        
        // Calculate corresponding shares
        uint256 sharesToWithdraw = getSharesByAsset(assetAmount);
        
        // Check if user has enough shares
        require(_shares[msg.sender] >= sharesToWithdraw, "Insufficient shares");
        
        // Calculate fee
        uint256 feeAmount = (assetAmount * instantWithdrawalFee) / 10000;
        uint256 netAmount = assetAmount - feeAmount;
        
        // Calculate fee shares
        uint256 feeShares = getSharesByAsset(feeAmount);
        
        // Check if the contract has enough assets
        uint256 availableAsset = getAvailableContractBalance();
        require(availableAsset >= assetAmount, "Insufficient contract balance");
        
        // Update user state
        _shares[msg.sender] -= sharesToWithdraw;
        
        // Update global state (note: only deduct netAmount, as feeAmount will be transferred to feeRecipient)
        _totalShares = _totalShares - sharesToWithdraw + feeShares;
        totalPooledAsset -= netAmount;
        
        // Mint fee shares to fee recipient
        _shares[feeRecipient] += feeShares;
        
        // Transfer assets to user
        if (isNativeToken) {
            (bool success, ) = payable(msg.sender).call{value: netAmount}("");
            require(success, "Native token transfer failed");
        } else {
            IERC20 token = IERC20(supportedToken);
            require(token.transfer(msg.sender, netAmount), "Token transfer failed");
        }
        
        emit AssetWithdrawn(msg.sender, netAmount, sharesToWithdraw);
        emit Transfer(msg.sender, address(0), netAmount);
        emit Transfer(msg.sender, feeRecipient, feeAmount);
    }

    /**
     * @dev Check if user has pending withdrawal requests
     * @param user User address
     * @return hasPending Whether there is a pending request
     * @return sharesAmount Shares amount of the request
     * @return assetAmount Asset amount of the request
     * @return unlockTime Unlock time of the request
     */
    function getPendingWithdrawal(address user) external view returns (
        bool hasPending,
        uint256 sharesAmount,
        uint256 assetAmount,
        uint256 unlockTime
    ) {
        WithdrawalRequest storage request = withdrawalRequests[user];
        
        if (!request.exists) {
            return (false, 0, 0, 0);
        }
        
        hasPending = true;
        sharesAmount = request.sharesAmount;
        assetAmount = (request.sharesAmount * request.sharePrice) / 10**decimals();
        unlockTime = request.timestamp + withdrawalDelay;
    }

    /**
     * @dev Set the Pump Oracle interface address
     * @param newAddress New Oracle interface address
     */
    function setOracleAddress(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Invalid Oracle address");
        address oldAddress = PUMP_ORACLE;
        PUMP_ORACLE = newAddress;
        emit OracleAddressUpdated(oldAddress, newAddress);
    }

    /**
     * @dev Update performance fee rate
     * @param newFee New fee rate (basis points, e.g., 1000 = 10%)
     */
    function setPerformanceFee(uint256 newFee) external onlyOwner {
        require(newFee <= 3000, "Fee too high"); // Maximum 30%
        uint256 oldFee = performanceFee;
        performanceFee = newFee;
        emit PerformanceFeeUpdated(oldFee, newFee);
    }

    /**
     * @dev Set the stake contract address
     * @param newAddress New stake contract address
     */
    function setStakeContract(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Invalid stake contract address");
        address oldAddress = stakeContractAddress;
        stakeContractAddress = newAddress;
        emit StakeContractUpdated(oldAddress, newAddress);
    }

    /**
     * @dev Transfer assets to stake contract
     * @param amount Amount to transfer
     */
    function transferToStakeContract(uint256 amount) external onlyOwner nonReentrant {
        require(stakeContractAddress != address(0), "Stake contract not set");
        require(amount > 0, "Amount must be greater than 0");
        
        if (isNativeToken) {
            require(address(this).balance >= amount, "Insufficient balance");
            
            // Transfer native assets to stake contract
            (bool success, ) = payable(stakeContractAddress).call{value: amount}("");
            require(success, "Transfer to stake contract failed");
        } else {
            IERC20 token = IERC20(supportedToken);
            require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
            
            // Transfer tokens to stake contract
            require(token.transfer(stakeContractAddress, amount), "Token transfer failed");
        }
        externallyStakedAsset += amount;
        
        emit TransferredToStake(amount);
    }

    /**
     * @dev Request assets back from stake contract
     * @param amount Amount to request
     */
    function requestAssetsFromStake(uint256 amount) external onlyOwner nonReentrant {
        require(stakeContractAddress != address(0), "Stake contract not set");
        require(amount > 0, "Amount must be greater than 0");
        
        uint256 stakeBalance = IPumpStake(stakeContractAddress).getContractBalance();
        require(stakeBalance >= amount, "Insufficient balance in stake contract");
        
        IPumpStake(stakeContractAddress).transferAssetsToVault(amount);

        if (amount >= externallyStakedAsset) {
            externallyStakedAsset = 0;
        } else {
            externallyStakedAsset -= amount;
        }
        
        emit RequestedAssetsFromStake(amount);
    }

    /**
     * @dev Get the current balance of the stake contract
     * @return balance Current balance of the stake contract
     */
    function getStakeContractBalance() external view returns (uint256 balance) {
        require(stakeContractAddress != address(0), "Stake contract not set");
        return IPumpStake(stakeContractAddress).getContractBalance();
    }
} 