interface ModelCardProps {
  model: {
    id: number;
    name: string;
    description: string;
    color: string;
    totalReturn: string;
    sharpeRatio: string;
    maxDrawdown: string;
    winRate: string;
    isTopPerformer: boolean;
  };
}

export const ModelCard = ({ model }: ModelCardProps) => {
  return (
    <div className="bg-gray-900/40 border border-gray-800 rounded-xl p-6 hover:border-gray-700 transition-all">
      {/* Header */}
      <div className="flex items-start justify-between mb-4">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <div className="w-2 h-2 rounded-full" style={{ backgroundColor: model.color }}></div>
            <h3 className="text-xl font-bold text-white">{model.name}</h3>
          </div>
          <p className="text-gray-400 text-sm">{model.description}</p>
        </div>
      </div>

      {/* Metrics */}
      <div className="space-y-3 mt-6">
        {/* Total Return */}
        <div className="flex items-center justify-between py-2 border-b border-gray-800">
          <span className="text-sm text-gray-400">Total Return</span>
          <span
            className="text-lg font-bold"
            style={{ color: model.color }}
          >
            {model.totalReturn}
          </span>
        </div>

        {/* Sharpe Ratio */}
        <div className="flex items-center justify-between py-2 border-b border-gray-800">
          <span className="text-sm text-gray-400">Sharpe Ratio</span>
          <span className="text-lg font-bold text-white">{model.sharpeRatio}</span>
        </div>

        {/* Max Drawdown */}
        <div className="flex items-center justify-between py-2 border-b border-gray-800">
          <span className="text-sm text-gray-400">Max Drawdown</span>
          <span className="text-lg font-bold text-red-400">{model.maxDrawdown}</span>
        </div>

        {/* Win Rate */}
        <div className="flex items-center justify-between py-2">
          <span className="text-sm text-gray-400">Win Rate</span>
          <span className="text-lg font-bold text-green-400">{model.winRate}</span>
        </div>
      </div>

      {/* Top Performer Badge */}
      {model.isTopPerformer && (
        <div className="mt-4 pt-4 border-t border-gray-800">
          <div
            className="flex items-center gap-2 px-3 py-2 rounded-lg"
            style={{ backgroundColor: 'rgba(0, 212, 255, 0.1)', border: '1px solid rgba(0, 212, 255, 0.3)' }}
          >
            <svg className="w-4 h-4 text-cyan" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
            <span className="text-sm font-medium text-cyan">Top Performer</span>
          </div>
        </div>
      )}
    </div>
  );
};
