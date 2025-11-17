// Navigation routes
export const ROUTES = {
  HOME: '/',
  DASHBOARD: '/dashboard',
  TRADING: '/trading',
  STRATEGY: '/strategy',
  PORTFOLIO: '/portfolio',
  MARKET: '/market',
} as const;

// DeFi Protocols
export const PROTOCOLS = {
  UNISWAP_V3: 'Uniswap V3',
  AAVE: 'Aave',
  COMPOUND: 'Compound',
  CURVE: 'Curve',
} as const;

// Trading pairs
export const TRADING_PAIRS = [
  'ETH/USDT',
  'BTC/USDT',
  'ETH/USDC',
  'BTC/USDC',
] as const;

// Strategy types
export const STRATEGY_TYPES = {
  GRID_TRADING: 'Grid Trading',
  TREND_FOLLOWING: 'Trend Following',
  ARBITRAGE: 'Arbitrage',
  MARKET_MAKING: 'Market Making',
} as const;

// API endpoints
export const API_ENDPOINTS = {
  HEALTH: '/health',
  USER: '/user',
  TRADING: '/trading',
  STRATEGY: '/strategy',
  MARKET_DATA: '/market-data',
} as const;
