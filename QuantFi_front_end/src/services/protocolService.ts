import { env } from '../config/env';

export interface ProtocolData {
  id: number;
  name: string;
  description: string;
  icon: string;
  tvl: string;
  apy: string;
  category: string;
  color: string;
  contractAddress: string;
  isActive: boolean;
}

export interface PoolData {
  pair: string;
  apy: string;
  tvl: string;
  token0: string;
  token1: string;
  fee: number;
}

export interface UserPosition {
  protocol: string;
  amount: string;
  value: string;
  rewards: string;
}

class ProtocolService {
  // Get all available protocols
  getProtocols(): ProtocolData[] {
    return [
      {
        id: 1,
        name: 'Uniswap V3',
        description: 'Decentralized exchange protocol with concentrated liquidity',
        icon: '🦄',
        tvl: '$4.2B',
        apy: '12.5%',
        category: 'DEX',
        color: '#FF007A',
        contractAddress: env.contracts.uniswapV3Adapter,
        isActive: true,
      },
      {
        id: 2,
        name: 'Aave',
        description: 'Decentralized lending and borrowing protocol',
        icon: '👻',
        tvl: '$5.8B',
        apy: '8.2%',
        category: 'Lending',
        color: '#B6509E',
        contractAddress: env.contracts.aaveAdapter,
        isActive: true,
      },
      {
        id: 3,
        name: 'Compound',
        description: 'Algorithmic money market protocol',
        icon: '🏦',
        tvl: '$3.1B',
        apy: '6.8%',
        category: 'Lending',
        color: '#00D395',
        contractAddress: env.contracts.compoundAdapter,
        isActive: true,
      },
      {
        id: 4,
        name: 'Curve',
        description: 'Stablecoin-focused decentralized exchange',
        icon: '🌊',
        tvl: '$2.9B',
        apy: '10.3%',
        category: 'DEX',
        color: '#0070F3',
        contractAddress: env.contracts.curveAdapter,
        isActive: true,
      },
    ];
  }

  // Get protocol by name
  getProtocolByName(name: string): ProtocolData | undefined {
    return this.getProtocols().find((p) => p.name.toLowerCase().includes(name.toLowerCase()));
  }

  // Get Uniswap pools (this would normally fetch from blockchain/API)
  getUniswapPools(): PoolData[] {
    return [
      {
        pair: 'ETH/USDC',
        apy: '15.2%',
        tvl: '$850M',
        token0: env.tokens.weth,
        token1: env.tokens.usdc,
        fee: 3000, // 0.3%
      },
      {
        pair: 'WETH/USDT',
        apy: '18.7%',
        tvl: '$420M',
        token0: env.tokens.weth,
        token1: env.tokens.usdt,
        fee: 3000,
      },
      {
        pair: 'DAI/USDC',
        apy: '8.3%',
        tvl: '$320M',
        token0: env.tokens.dai,
        token1: env.tokens.usdc,
        fee: 500, // 0.05%
      },
    ];
  }

  // Fetch user positions from blockchain (mock implementation)
  async getUserPositions(userAddress: string): Promise<UserPosition[]> {
    // In a real implementation, this would:
    // 1. Query each adapter contract for user balances
    // 2. Calculate current value and rewards
    // 3. Return aggregated data

    console.log('Fetching positions for:', userAddress);

    // Mock data for now
    return [
      {
        protocol: 'Uniswap V3',
        amount: '0.5 ETH',
        value: '$1,225.00',
        rewards: '$45.20',
      },
      {
        protocol: 'Aave',
        amount: '1000 USDC',
        value: '$1,000.00',
        rewards: '$82.00',
      },
    ];
  }

  // Get protocol statistics (would fetch from API/blockchain)
  async getProtocolStats(protocolName: string) {
    const protocol = this.getProtocolByName(protocolName);
    if (!protocol) return null;

    // Mock implementation - in reality, query the blockchain
    return {
      totalValueLocked: protocol.tvl,
      averageAPY: protocol.apy,
      activeUsers: Math.floor(Math.random() * 10000) + 1000,
      totalTransactions: Math.floor(Math.random() * 100000) + 10000,
    };
  }
}

export const protocolService = new ProtocolService();
