export const env = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api',
  wsUrl: import.meta.env.VITE_WS_URL || 'ws://localhost:8080/ws',
  chainId: Number(import.meta.env.VITE_CHAIN_ID) || 11155111,
  enableTestnet: import.meta.env.VITE_ENABLE_TESTNET === 'true',
  walletConnectProjectId: import.meta.env.VITE_WALLETCONNECT_PROJECT_ID || '',
  contracts: {
    uniswapV3Adapter: import.meta.env.VITE_UNISWAP_V3_ADAPTER as `0x${string}`,
    aaveAdapter: import.meta.env.VITE_AAVE_ADAPTER as `0x${string}`,
    compoundAdapter: import.meta.env.VITE_COMPOUND_ADAPTER as `0x${string}`,
    curveAdapter: import.meta.env.VITE_CURVE_ADAPTER as `0x${string}`,
  },
  tokens: {
    usdc: import.meta.env.VITE_USDC_ADDRESS as `0x${string}`,
    usdt: import.meta.env.VITE_USDT_ADDRESS as `0x${string}`,
    dai: import.meta.env.VITE_DAI_ADDRESS as `0x${string}`,
    weth: import.meta.env.VITE_WETH_ADDRESS as `0x${string}`,
  },
  thirdParty: {
    uniswapPositionManager: import.meta.env.VITE_UNISWAP_POSITION_MANAGER as `0x${string}`,
    aavePool: import.meta.env.VITE_AAVE_POOL as `0x${string}`,
    compoundAddress: import.meta.env.VITE_COMPOUND_ADDRESS as `0x${string}`,
    curvePool: import.meta.env.VITE_CURVE_POOL as `0x${string}`,
  },
} as const;
