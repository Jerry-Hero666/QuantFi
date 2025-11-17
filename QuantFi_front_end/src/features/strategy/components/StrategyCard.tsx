interface StrategyCardProps {
  strategy: {
    id: number;
    name: string;
    description: string;
    risk: string;
    tags: string[];
    apy: string;
    tvl: string;
    return6m: string;
    chartData: { month: string; value: number }[];
  };
}

export const StrategyCard = ({ strategy }: StrategyCardProps) => {
  const getRiskColor = (risk: string) => {
    switch (risk) {
      case 'High':
        return 'bg-red-500/20 text-red-400 border-red-500/30';
      case 'Medium':
        return 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30';
      case 'Low':
        return 'bg-green-500/20 text-green-400 border-green-500/30';
      default:
        return 'bg-gray-500/20 text-gray-400 border-gray-500/30';
    }
  };

  // Calculate min and max for chart scaling
  const values = strategy.chartData.map((d) => d.value);
  const minValue = Math.min(...values);
  const maxValue = Math.max(...values);
  const range = maxValue - minValue;

  return (
    <div className="bg-gray-900/60 border border-gray-800 rounded-2xl p-6 hover:border-cyan/30 transition-all">
      {/* Header */}
      <div className="flex items-start justify-between mb-4">
        <div>
          <h3 className="text-xl font-bold text-white mb-2">{strategy.name}</h3>
          <p className="text-gray-400 text-sm mb-3">{strategy.description}</p>
          <div className="flex gap-2">
            {strategy.tags.map((tag) => (
              <span
                key={tag}
                style={{ backgroundColor: 'rgba(0, 212, 255, 0.15)', borderColor: 'rgba(0, 212, 255, 0.4)' }}
                className="px-2.5 py-1 text-cyan text-xs rounded border"
              >
                {tag}
              </span>
            ))}
          </div>
        </div>
        <span
          className={`px-2.5 py-0.5 rounded-full text-xs font-medium border ${getRiskColor(
            strategy.risk
          )}`}
        >
          {strategy.risk}
        </span>
      </div>

      {/* Metrics - 3 column layout */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '12px' }} className="my-6">
        {/* APY - Cyan/Teal background */}
        <div style={{ backgroundColor: 'rgba(0, 180, 180, 0.15)', borderColor: 'rgba(0, 212, 255, 0.25)' }} className="border rounded-lg p-4">
          <div className="text-cyan mb-1" style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>
            {strategy.apy}
          </div>
          <div className="text-xs text-gray-400">APY</div>
        </div>
        {/* TVL - Purple background */}
        <div style={{ backgroundColor: 'rgba(139, 92, 246, 0.15)', borderColor: 'rgba(168, 85, 247, 0.25)' }} className="border rounded-lg p-4">
          <div className="text-purple-400 mb-1" style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>
            {strategy.tvl}
          </div>
          <div className="text-xs text-gray-400">TVL</div>
        </div>
        {/* 6M Return - Dark background */}
        <div style={{ backgroundColor: 'rgba(31, 41, 55, 0.6)', borderColor: 'rgba(75, 85, 99, 0.4)' }} className="border rounded-lg p-4">
          <div className="text-white mb-1" style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>
            {strategy.return6m}
          </div>
          <div className="text-xs text-gray-400">6M Return</div>
        </div>
      </div>

      {/* Chart */}
      <div className="relative mb-4" style={{ backgroundColor: 'rgba(17, 24, 39, 0.4)', padding: '20px 16px', borderRadius: '8px' }}>
        <svg width="100%" height="120" className="overflow-visible">
          {/* Horizontal grid lines only */}
          <line x1="0" y1="0" x2="100%" y2="0" stroke="#374151" strokeWidth="1" opacity="0.2" />
          <line x1="0" y1="30" x2="100%" y2="30" stroke="#374151" strokeWidth="1" opacity="0.2" />
          <line x1="0" y1="60" x2="100%" y2="60" stroke="#374151" strokeWidth="1" opacity="0.2" />
          <line x1="0" y1="90" x2="100%" y2="90" stroke="#374151" strokeWidth="1" opacity="0.2" />
          <line x1="0" y1="120" x2="100%" y2="120" stroke="#374151" strokeWidth="1" opacity="0.2" />

          {/* Line chart */}
          <polyline
            fill="none"
            stroke={`url(#gradient-${strategy.id})`}
            strokeWidth="2"
            points={strategy.chartData
              .map((point, index) => {
                const x = (index / (strategy.chartData.length - 1)) * 100;
                const y = 120 - ((point.value - minValue) / range) * 100;
                return `${x}%,${y}`;
              })
              .join(' ')}
          />

          {/* Data points */}
          {strategy.chartData.map((point, index) => {
            const x = (index / (strategy.chartData.length - 1)) * 100;
            const y = 120 - ((point.value - minValue) / range) * 100;
            return (
              <circle
                key={index}
                cx={`${x}%`}
                cy={y}
                r="3.5"
                fill="#00D4FF"
              />
            );
          })}

          {/* Gradient definition */}
          <defs>
            <linearGradient id={`gradient-${strategy.id}`} x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="#00D4FF" />
              <stop offset="100%" stopColor="#A855F7" />
            </linearGradient>
          </defs>
        </svg>

        {/* X-axis labels */}
        <div className="flex justify-between text-xs text-gray-500 mt-3">
          {strategy.chartData.map((point) => (
            <span key={point.month}>{point.month}</span>
          ))}
        </div>
      </div>

      {/* Details Button */}
      <button className="w-full text-cyan hover:text-cyan-light text-sm font-semibold transition-colors text-right">
        Details →
      </button>
    </div>
  );
};
