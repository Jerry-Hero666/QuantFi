// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract MockUniswapV3Pool {
    address public token0;
    address public token1;
    uint24 public fee;
    int24 public tickSpacing;
    address public factory;
    address public owner;

    constructor(
        address _token0,
        address _token1,
        uint24 _fee,
        int24 _tickSpacing,
        address _factory
    ) {
        token0 = _token0;
        token1 = _token1;
        fee = _fee;
        tickSpacing = _tickSpacing;
        factory = _factory;
        owner = msg.sender;
    }
}

contract MockUniswapV3Factory is IUniswapV3Factory {
    mapping(uint24 => int24) public override feeAmountTickSpacing;
    mapping(address => mapping(address => mapping(uint24 => address))) public override getPool;

    address public override owner;
    address public feeProtocolSetter;
    mapping(address => uint8) private _feeProtocols;

    constructor() {
        owner = msg.sender;
        feeProtocolSetter = msg.sender;
        
        // 设置默认的费率和tick间距
        feeAmountTickSpacing[500] = 10;    // 0.05%
        feeAmountTickSpacing[3000] = 60;    // 0.3%
        feeAmountTickSpacing[10000] = 200;  // 1%
    }

    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external override returns (address pool) {
        require(tokenA != tokenB, "UniswapV3Factory: IDENTICAL_ADDRESSES");
        require(tokenA != address(0) && tokenB != address(0), "UniswapV3Factory: ZERO_ADDRESS");
        require(getPool[tokenA][tokenB][fee] == address(0), "UniswapV3Factory: POOL_EXISTS");
        require(feeAmountTickSpacing[fee] > 0, "UniswapV3Factory: INVALID_FEE");

        // 确保token0 < token1 用于一致性
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        // 创建新的池合约
        pool = address(new MockUniswapV3Pool(token0, token1, fee, feeAmountTickSpacing[fee], address(this)));

        // 更新映射
        getPool[tokenA][tokenB][fee] = pool;
        getPool[tokenB][tokenA][fee] = pool;

        emit PoolCreated(token0, token1, fee, feeAmountTickSpacing[fee], pool);
    }

    function setOwner(address _owner) external override {
        require(msg.sender == owner, "UniswapV3Factory: FORBIDDEN");
        owner = _owner;
    }

    function setFeeProtocol(address pool, uint8 feeProtocol0, uint8 feeProtocol1) external {
        require(msg.sender == feeProtocolSetter, "UniswapV3Factory: FORBIDDEN");
        _feeProtocols[pool] = (feeProtocol1 << 4) | feeProtocol0;
    }

    function feeProtocol(address pool) external view returns (uint8 feeProtocol0, uint8 feeProtocol1) {
        uint8 packed = _feeProtocols[pool];
        feeProtocol0 = packed & 0x0F;
        feeProtocol1 = packed >> 4;
    }

    function setFeeProtocolSetter(address setter) external {
        require(msg.sender == owner, "UniswapV3Factory: FORBIDDEN");
        feeProtocolSetter = setter;
    }

    function enableFeeAmount(uint24 fee, int24 tickSpacing) external override {
        require(msg.sender == owner, "UniswapV3Factory: FORBIDDEN");
        require(feeAmountTickSpacing[fee] == 0, "UniswapV3Factory: FEE_ALREADY_ENABLED");
        require(fee <= 1000000, "UniswapV3Factory: FEE_TOO_HIGH");
        // tickSpacing必须是正数，并且是2的幂次方
        require(tickSpacing > 0 && (tickSpacing & (tickSpacing - 1)) == 0, "UniswapV3Factory: TICK_SPACING_NOT_POW_2");
        
        feeAmountTickSpacing[fee] = tickSpacing;
    }
}
