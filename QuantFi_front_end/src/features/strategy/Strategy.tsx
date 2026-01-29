import { StrategyCard } from './components/StrategyCard';

export const Strategy = () => {
  const strategies = [
    {
      id: 1,
      name: 'Alpha Momentum Strategy',
      description: 'High-frequency momentum trading across US stocks',
      risk: 'Medium',
      tags: ['AAPL', 'MSFT', 'GOOGL'],
      apy: '45.2%',
      tvl: '$125M',
      return6m: '45%',
      chartData: [
        { month: 'Jan', value: 100 },
        { month: 'Feb', value: 110 },
        { month: 'Mar', value: 115 },
        { month: 'Apr', value: 125 },
        { month: 'May', value: 135 },
        { month: 'Jun', value: 145 },
      ],
    },
    {
      id: 2,
      name: 'Crypto Arbitrage Bot',
      description: 'Cross-exchange arbitrage for BTC, ETH, SOL',
      risk: 'High',
      tags: ['BTC', 'ETH', 'SOL'],
      apy: '62.8%',
      tvl: '$89M',
      return6m: '63%',
      chartData: [
        { month: 'Jan', value: 90 },
        { month: 'Feb', value: 110 },
        { month: 'Mar', value: 125 },
        { month: 'Apr', value: 140 },
        { month: 'May', value: 150 },
        { month: 'Jun', value: 163 },
      ],
    },
    {
      id: 3,
      name: 'DeFi Yield Optimizer',
      description: 'Automated yield farming across Uniswap, Aave, Compound',
      risk: 'Low',
      tags: ['UNI', 'AAVE', 'COMP'],
      apy: '38.5%',
      tvl: '$210M',
      return6m: '39%',
      chartData: [
        { month: 'Jan', value: 100 },
        { month: 'Feb', value: 105 },
        { month: 'Mar', value: 112 },
        { month: 'Apr', value: 120 },
        { month: 'May', value: 130 },
        { month: 'Jun', value: 139 },
      ],
    },
    {
      id: 4,
      name: 'Market Neutral Strategy',
      description: 'Delta-neutral positions across stocks and crypto',
      risk: 'Low',
      tags: ['SPY', 'BTC', 'ETH'],
      apy: '28.3%',
      tvl: '$156M',
      return6m: '28%',
      chartData: [
        { month: 'Jan', value: 100 },
        { month: 'Feb', value: 105 },
        { month: 'Mar', value: 110 },
        { month: 'Apr', value: 117 },
        { month: 'May', value: 122 },
        { month: 'Jun', value: 128 },
      ],
    },
  ];

  return (
    <div className="bg-black text-white min-h-screen">
      <div className="max-w-7xl mx-auto px-8 py-16">
        {/* Header */}
        <div className="mb-12">
          <h1 className="text-5xl font-bold mb-4 title-glow">Quantitative Strategies</h1>
          <p className="text-gray-400 text-lg">
            Invest in tokenized trading strategies powered by advanced algorithms
          </p>
        </div>

        {/* Strategy Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {strategies.map((strategy) => (
            <StrategyCard key={strategy.id} strategy={strategy} />
          ))}
        </div>
      </div>
    </div>
  );
};
