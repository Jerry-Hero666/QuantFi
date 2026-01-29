import { useState } from 'react';

export const Market = () => {
  const [fromToken, setFromToken] = useState('ETH');
  const [toToken, setToToken] = useState('USDT');
  const [fromAmount, setFromAmount] = useState('0.0');
  const [toAmount, setToAmount] = useState('0.0');

  const tokenPrices = [
    { symbol: 'ETH', name: 'Ethereum', price: '$2450.32', change: '+2.5%', isPositive: true },
    { symbol: 'BTC', name: 'Bitcoin', price: '$45230.18', change: '+2.5%', isPositive: true },
    { symbol: 'USDT', name: 'Tether', price: '$1.00', change: '+2.5%', isPositive: true },
    { symbol: 'SOL', name: 'Solana', price: '$98.45', change: '+2.5%', isPositive: true },
  ];

  const recentTrades = [
    { from: 'ETH', to: 'USDT', amount: '1.5 ETH', time: '2 mins ago' },
    { from: 'BTC', to: 'USDC', amount: '0.05 BTC', time: '5 mins ago' },
    { from: 'SOL', to: 'ETH', amount: '100 SOL', time: '12 mins ago' },
    { from: 'USDT', to: 'BNB', amount: '500 USDT', time: '18 mins ago' },
  ];

  const handleSwapTokens = () => {
    setFromToken(toToken);
    setToToken(fromToken);
    setFromAmount(toAmount);
    setToAmount(fromAmount);
  };

  return (
    <div className="bg-black text-white min-h-screen">
      <div className="max-w-7xl mx-auto px-8 py-12">
        {/* Header */}
        <div className="mb-12">
          <h1 className="text-5xl font-bold mb-4 title-glow">Token Swap</h1>
          <p className="text-gray-400 text-lg">
            Trade tokens with optimal routing and best prices
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column - Swap Panel */}
          <div className="lg:col-span-2">
            <div className="bg-gray-900/40 border border-gray-800 rounded-2xl p-6">
              {/* Header */}
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-bold">Swap Tokens</h2>
                <button className="p-2 hover:bg-gray-800 rounded-lg transition-colors">
                  <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                </button>
              </div>

              {/* From Token */}
              <div className="mb-4">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm text-gray-400">From</span>
                  <span className="text-sm text-gray-400">Balance: 2.5</span>
                </div>
                <div className="bg-gray-900/60 border border-gray-700 rounded-xl p-4">
                  <div className="flex items-center gap-3">
                    <button className="px-4 py-2 bg-cyan/10 text-cyan rounded-lg font-semibold border border-cyan/30 hover:bg-cyan/20 transition-colors">
                      {fromToken}
                    </button>
                    <input
                      type="text"
                      value={fromAmount}
                      onChange={(e) => setFromAmount(e.target.value)}
                      className="flex-1 bg-transparent text-white text-2xl outline-none"
                      placeholder="0.0"
                    />
                  </div>
                  <div className="text-sm text-gray-500 mt-2">≈ $0.00</div>
                </div>
              </div>

              {/* Swap Button */}
              <div className="flex justify-center -my-2 relative z-10">
                <button
                  onClick={handleSwapTokens}
                  className="p-2 bg-gray-800 hover:bg-gray-700 rounded-lg border border-gray-700 transition-colors"
                >
                  <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4" />
                  </svg>
                </button>
              </div>

              {/* To Token */}
              <div className="mb-6">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm text-gray-400">To</span>
                  <span className="text-sm text-gray-400">Balance: 10000</span>
                </div>
                <div className="bg-gray-900/60 border border-gray-700 rounded-xl p-4">
                  <div className="flex items-center gap-3">
                    <button className="px-4 py-2 bg-purple-500/10 text-purple-400 rounded-lg font-semibold border border-purple-500/30 hover:bg-purple-500/20 transition-colors">
                      {toToken}
                    </button>
                    <input
                      type="text"
                      value={toAmount}
                      onChange={(e) => setToAmount(e.target.value)}
                      className="flex-1 bg-transparent text-white text-2xl outline-none"
                      placeholder="0.0"
                    />
                  </div>
                  <div className="text-sm text-gray-500 mt-2">≈ $0.00</div>
                </div>
              </div>

              {/* Rate Info */}
              <div className="space-y-3 mb-6 bg-gray-900/40 rounded-xl p-4">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-400">Rate</span>
                  <span className="text-white">1 ETH = 2450.3200 USDT</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-400">Network Fee</span>
                  <span className="text-white">~$2.50</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-400">Route</span>
                  <span className="text-cyan">Optimal Path</span>
                </div>
              </div>

              {/* Footer */}
              <div className="flex items-center gap-2 text-xs text-gray-500">
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
                </svg>
                <span>Powered by optimal routing algorithm</span>
              </div>
            </div>
          </div>

          {/* Right Column */}
          <div className="space-y-6">
            {/* Token Prices */}
            <div className="bg-gray-900/40 border border-gray-800 rounded-2xl p-6">
              <h3 className="text-lg font-bold mb-4">Token Prices</h3>
              <div className="space-y-4">
                {tokenPrices.map((token) => (
                  <div key={token.symbol} className="flex items-center justify-between">
                    <div>
                      <div className="font-semibold text-white">{token.symbol}</div>
                      <div className="text-xs text-gray-400">{token.name}</div>
                    </div>
                    <div className="text-right">
                      <div className="font-semibold text-white">{token.price}</div>
                      <div className={`text-xs ${token.isPositive ? 'text-green-400' : 'text-red-400'}`}>
                        {token.change}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Recent Trades */}
            <div className="bg-gray-900/40 border border-gray-800 rounded-2xl p-6">
              <h3 className="text-lg font-bold mb-4">Recent Trades</h3>
              <div className="space-y-4">
                {recentTrades.map((trade, index) => (
                  <div key={index} className="border-b border-gray-800 pb-4 last:border-0 last:pb-0">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="font-semibold text-white">{trade.from}</span>
                      <svg className="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                      </svg>
                      <span className="font-semibold text-white">{trade.to}</span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-gray-400">{trade.amount}</span>
                      <span className="text-gray-500">{trade.time}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
