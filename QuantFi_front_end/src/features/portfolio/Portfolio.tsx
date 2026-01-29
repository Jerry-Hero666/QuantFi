import { useState } from 'react';
import { useAccount } from 'wagmi';
import { protocolService } from '../../services/protocolService';
import { useTokenBalance, useAaveSupply, useCompoundSupply } from '../../hooks/useContracts';
import { env } from '../../config/env';

export const Portfolio = () => {
  const { isConnected } = useAccount();
  const protocols = protocolService.getProtocols();
  const pools = protocolService.getUniswapPools();

  // Token balances
  const { balance: usdcBalance } = useTokenBalance('USDC');
  const { balance: usdtBalance } = useTokenBalance('USDT');
  const { balance: daiBalance } = useTokenBalance('DAI');
  const { balance: wethBalance } = useTokenBalance('WETH');

  // Supply hooks
  const { supply: aaveSupply, isPending: aaveSupplyPending } = useAaveSupply();
  const { supply: compoundSupply, isPending: compoundSupplyPending } = useCompoundSupply();

  // Modal state
  const [selectedProtocol, setSelectedProtocol] = useState<string | null>(null);
  const [supplyAmount, setSupplyAmount] = useState('');
  const [isSupplyModalOpen, setIsSupplyModalOpen] = useState(false);

  // Calculate total balance
  const totalBalance = isConnected
    ? `$${(
        parseFloat(usdcBalance) +
        parseFloat(usdtBalance) +
        parseFloat(daiBalance) +
        parseFloat(wethBalance) * 2450
      ).toFixed(2)}`
    : '$0';

  const handleSupply = async () => {
    if (!supplyAmount || !selectedProtocol) return;

    try {
      if (selectedProtocol === 'Aave') {
        await aaveSupply(env.tokens.usdc, supplyAmount);
      } else if (selectedProtocol === 'Compound') {
        await compoundSupply(env.tokens.usdc, supplyAmount);
      }
      setIsSupplyModalOpen(false);
      setSupplyAmount('');
    } catch (error) {
      console.error('Supply failed:', error);
    }
  };

  return (
    <div className="bg-black text-white min-h-screen">
      <div className="max-w-7xl mx-auto px-8 py-12">
        {/* Header */}
        <div className="mb-12">
          <h1 className="text-5xl font-bold mb-4 title-glow">DeFi Protocols</h1>
          <p className="text-gray-400 text-lg">
            Participate in leading DeFi protocols and maximize your yields
          </p>
          {!isConnected && (
            <div className="mt-4 p-4 bg-yellow-500/10 border border-yellow-500/30 rounded-lg">
              <p className="text-yellow-400">Please connect your wallet to interact with protocols</p>
            </div>
          )}
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
          {/* Total TVL */}
          <div className="bg-gray-900/40 border border-gray-800 rounded-2xl p-6">
            <div className="flex items-center justify-center mb-4">
              <svg className="w-8 h-8 text-cyan" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
            </div>
            <div className="text-3xl font-bold text-white text-center mb-2">$16.0B</div>
            <div className="text-sm text-gray-400 text-center">Total TVL</div>
          </div>

          {/* Active Protocols */}
          <div className="bg-gray-900/40 border border-gray-800 rounded-2xl p-6">
            <div className="flex items-center justify-center mb-4">
              <svg className="w-8 h-8 text-cyan" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
              </svg>
            </div>
            <div className="text-3xl font-bold text-white text-center mb-2">{protocols.length}</div>
            <div className="text-sm text-gray-400 text-center">Active Protocols</div>
          </div>

          {/* Avg APY */}
          <div className="bg-gray-900/40 border border-gray-800 rounded-2xl p-6">
            <div className="flex items-center justify-center mb-4">
              <svg className="w-8 h-8 text-cyan" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z" />
              </svg>
            </div>
            <div className="text-3xl font-bold text-white text-center mb-2">9.5%</div>
            <div className="text-sm text-gray-400 text-center">Avg APY</div>
          </div>

          {/* Your Balance */}
          <div className="bg-gray-900/40 border border-gray-800 rounded-2xl p-6">
            <div className="flex items-center justify-center mb-4">
              <svg className="w-8 h-8 text-cyan" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
            </div>
            <div className="text-3xl font-bold text-white text-center mb-2">{totalBalance}</div>
            <div className="text-sm text-gray-400 text-center">Your Balance</div>
          </div>
        </div>

        {/* Your Token Balances (only show if connected) */}
        {isConnected && (
          <div className="mb-12 bg-gray-900/40 border border-gray-800 rounded-2xl p-6">
            <h3 className="text-lg font-bold mb-4">Your Token Balances</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="bg-gray-900/60 border border-gray-700 rounded-lg p-4">
                <div className="text-sm text-gray-400">USDC</div>
                <div className="text-lg font-bold text-white">{parseFloat(usdcBalance).toFixed(4)}</div>
              </div>
              <div className="bg-gray-900/60 border border-gray-700 rounded-lg p-4">
                <div className="text-sm text-gray-400">USDT</div>
                <div className="text-lg font-bold text-white">{parseFloat(usdtBalance).toFixed(4)}</div>
              </div>
              <div className="bg-gray-900/60 border border-gray-700 rounded-lg p-4">
                <div className="text-sm text-gray-400">DAI</div>
                <div className="text-lg font-bold text-white">{parseFloat(daiBalance).toFixed(4)}</div>
              </div>
              <div className="bg-gray-900/60 border border-gray-700 rounded-lg p-4">
                <div className="text-sm text-gray-400">WETH</div>
                <div className="text-lg font-bold text-white">{parseFloat(wethBalance).toFixed(4)}</div>
              </div>
            </div>
          </div>
        )}

        {/* Protocol Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
          {protocols.map((protocol) => (
            <div
              key={protocol.id}
              className="bg-gray-900/40 border border-gray-800 rounded-2xl p-6 hover:border-cyan/30 transition-all"
            >
              <div className="flex items-start justify-between mb-6">
                <div className="flex items-center gap-3">
                  <div className="text-4xl">{protocol.icon}</div>
                  <div>
                    <h3 className="text-xl font-bold text-white">{protocol.name}</h3>
                    <p className="text-sm text-gray-400">{protocol.description}</p>
                  </div>
                </div>
                <span
                  className="px-3 py-1 rounded-full text-xs font-medium"
                  style={{
                    backgroundColor: `${protocol.color}20`,
                    color: protocol.color,
                    border: `1px solid ${protocol.color}40`,
                  }}
                >
                  {protocol.category}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-4 mb-4">
                <div className="bg-cyan/5 border border-cyan/20 rounded-lg p-4">
                  <div className="text-xs text-gray-400 mb-1">TVL</div>
                  <div className="text-xl font-bold text-cyan">{protocol.tvl}</div>
                </div>
                <div className="bg-purple-500/5 border border-purple-500/20 rounded-lg p-4">
                  <div className="text-xs text-gray-400 mb-1">APY</div>
                  <div className="text-xl font-bold text-purple-400">{protocol.apy}</div>
                </div>
              </div>

              {/* Contract Address */}
              <div className="mb-4">
                <div className="text-xs text-gray-400 mb-1">Contract Address</div>
                <div className="text-xs text-gray-500 font-mono truncate">{protocol.contractAddress}</div>
              </div>

              {/* Action Buttons */}
              {(protocol.name === 'Aave' || protocol.name === 'Compound') && (
                <button
                  onClick={() => {
                    setSelectedProtocol(protocol.name);
                    setIsSupplyModalOpen(true);
                  }}
                  disabled={!isConnected}
                  className="w-full bg-cyan/10 hover:bg-cyan/20 text-cyan border border-cyan/30 font-semibold py-2 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Supply
                </button>
              )}
            </div>
          ))}
        </div>

        {/* Uniswap Pools Section */}
        <div className="bg-gray-900/40 border border-gray-800 rounded-2xl p-8">
          <div className="flex items-center gap-3 mb-6">
            <div className="text-4xl">🦄</div>
            <div>
              <h2 className="text-2xl font-bold text-white">Uniswap V3</h2>
              <p className="text-sm text-gray-400">Concentrated liquidity AMM</p>
            </div>
          </div>

          <h3 className="text-lg font-bold mb-6">Available Pools</h3>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {pools.map((pool, index) => (
              <div
                key={index}
                className="bg-gray-900/60 border border-gray-700 rounded-xl p-6"
              >
                <h4 className="text-lg font-bold text-white mb-4">{pool.pair}</h4>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-400">APY</span>
                    <span className="text-lg font-bold text-green-400">{pool.apy}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-400">TVL</span>
                    <span className="text-lg font-bold text-white">{pool.tvl}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-400">Fee Tier</span>
                    <span className="text-sm font-medium text-gray-300">{pool.fee / 10000}%</span>
                  </div>
                </div>
                <button
                  disabled={!isConnected}
                  className="w-full mt-4 bg-cyan/10 hover:bg-cyan/20 text-cyan border border-cyan/30 font-semibold py-2 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Add Liquidity
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Supply Modal */}
      {isSupplyModalOpen && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-gray-900 border border-gray-700 rounded-2xl p-6 w-full max-w-md">
            <h3 className="text-xl font-bold mb-4">Supply to {selectedProtocol}</h3>
            <div className="mb-4">
              <label className="block text-sm text-gray-400 mb-2">Amount (USDC)</label>
              <input
                type="number"
                value={supplyAmount}
                onChange={(e) => setSupplyAmount(e.target.value)}
                className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white"
                placeholder="0.0"
              />
            </div>
            <div className="flex gap-3">
              <button
                onClick={handleSupply}
                disabled={aaveSupplyPending || compoundSupplyPending}
                className="flex-1 bg-cyan hover:bg-cyan/80 text-black font-semibold py-2 rounded-lg transition-colors disabled:opacity-50"
              >
                {aaveSupplyPending || compoundSupplyPending ? 'Supplying...' : 'Supply'}
              </button>
              <button
                onClick={() => setIsSupplyModalOpen(false)}
                className="flex-1 bg-gray-700 hover:bg-gray-600 text-white font-semibold py-2 rounded-lg transition-colors"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
