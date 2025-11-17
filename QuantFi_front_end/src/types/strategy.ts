export interface Strategy {
  id: string;
  name: string;
  type: 'grid' | 'trend' | 'arbitrage' | 'market_making';
  status: 'active' | 'paused' | 'stopped';
  symbol: string;
  config: StrategyConfig;
  performance: StrategyPerformance;
  createdAt: number;
  updatedAt: number;
}

export interface StrategyConfig {
  // Grid Trading
  gridLevels?: number;
  priceRange?: {
    min: number;
    max: number;
  };

  // Common
  initialCapital: number;
  maxPositionSize: number;
  stopLoss?: number;
  takeProfit?: number;

  // Protocol specific
  protocol?: 'uniswap_v3' | 'aave' | 'compound' | 'curve';
  slippage?: number;
}

export interface StrategyPerformance {
  totalPnl: number;
  totalPnlPercent: number;
  winRate: number;
  totalTrades: number;
  sharpeRatio: number;
  maxDrawdown: number;
}

export interface BacktestResult {
  strategyId: string;
  period: {
    start: number;
    end: number;
  };
  performance: StrategyPerformance;
  equity: Array<{
    timestamp: number;
    value: number;
  }>;
  trades: Array<{
    timestamp: number;
    side: 'buy' | 'sell';
    price: number;
    amount: number;
  }>;
}
