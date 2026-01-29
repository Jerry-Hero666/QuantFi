import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { WagmiProvider } from 'wagmi';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RainbowKitProvider } from '@rainbow-me/rainbowkit';
import { wagmiConfig } from './config/wagmi';
import { Layout } from './components/layout/Layout';
import { Home } from './features/home/Home';
import { Dashboard } from './features/dashboard/Dashboard';
import { Trading } from './features/trading/Trading';
import { Strategy } from './features/strategy/Strategy';
import { Portfolio } from './features/portfolio/Portfolio';
import { Market } from './features/market/Market';
import { ROUTES } from './utils/constants';

const queryClient = new QueryClient();

function App() {
  console.log('App mounted - version 2');
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          <BrowserRouter>
            <Layout>
              <Routes>
                <Route path={ROUTES.HOME} element={<Home />} />
                <Route path={ROUTES.DASHBOARD} element={<Dashboard />} />
                <Route path={ROUTES.TRADING} element={<Trading />} />
                <Route path={ROUTES.STRATEGY} element={<Strategy />} />
                <Route path={ROUTES.PORTFOLIO} element={<Portfolio />} />
                <Route path={ROUTES.MARKET} element={<Market />} />
              </Routes>
            </Layout>
          </BrowserRouter>
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}

export default App;
