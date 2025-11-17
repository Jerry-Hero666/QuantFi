import { mainnet, sepolia, polygon, arbitrum } from 'wagmi/chains';
import { env } from './env';

export const supportedChains = env.enableTestnet
  ? [mainnet, sepolia, polygon, arbitrum]
  : [mainnet, polygon, arbitrum];

export const defaultChain = env.enableTestnet ? sepolia : mainnet;
