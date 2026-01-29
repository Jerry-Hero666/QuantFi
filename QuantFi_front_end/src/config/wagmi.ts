import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { supportedChains } from './chains';
import { env } from './env';

export const wagmiConfig = getDefaultConfig({
  appName: 'QuantFi',
  projectId: env.walletConnectProjectId || 'YOUR_PROJECT_ID',
  chains: supportedChains as any,
  ssr: false,
});
