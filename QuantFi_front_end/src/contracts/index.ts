import { env } from '../config/env';
import UniswapV3AdapterABI from './abis/uniswap-v3-adapter.abi.json';
import AaveAdapterABI from './abis/aave-adapter.abi.json';
import CompoundAdapterABI from './abis/compound-adapter.abi.json';
import CurveAdapterABI from './abis/curve-adapter.abi.json';

// Contract configurations
export const contracts = {
  uniswapV3Adapter: {
    address: env.contracts.uniswapV3Adapter,
    abi: UniswapV3AdapterABI,
  },
  aaveAdapter: {
    address: env.contracts.aaveAdapter,
    abi: AaveAdapterABI,
  },
  compoundAdapter: {
    address: env.contracts.compoundAdapter,
    abi: CompoundAdapterABI,
  },
  curveAdapter: {
    address: env.contracts.curveAdapter,
    abi: CurveAdapterABI,
  },
} as const;

// ERC20 Token ABI (minimal)
export const ERC20_ABI = [
  {
    inputs: [{ name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { name: 'spender', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    name: 'approve',
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { name: 'owner', type: 'address' },
      { name: 'spender', type: 'address' },
    ],
    name: 'allowance',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'decimals',
    outputs: [{ name: '', type: 'uint8' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'symbol',
    outputs: [{ name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

// Token addresses
export const tokenAddresses = {
  USDC: env.tokens.usdc,
  USDT: env.tokens.usdt,
  DAI: env.tokens.dai,
  WETH: env.tokens.weth,
} as const;

export type TokenSymbol = keyof typeof tokenAddresses;
