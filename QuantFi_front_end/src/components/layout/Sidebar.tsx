import { Link, useLocation } from 'react-router-dom';
import { ROUTES } from '../../utils/constants';

interface NavItem {
  path: string;
  label: string;
  icon: string;
}

const navItems: NavItem[] = [
  { path: ROUTES.DASHBOARD, label: 'Dashboard', icon: '📊' },
  { path: ROUTES.TRADING, label: 'Trading', icon: '💹' },
  { path: ROUTES.STRATEGY, label: 'Strategy', icon: '🎯' },
  { path: ROUTES.PORTFOLIO, label: 'Portfolio', icon: '💼' },
  { path: ROUTES.MARKET, label: 'Market', icon: '📈' },
];

export const Sidebar = () => {
  const location = useLocation();

  return (
    <aside className="w-64 bg-dark-sidebar border-r border-dark-border min-h-screen flex flex-col">
      {/* Logo */}
      <div className="px-4 py-6 border-b border-dark-border/30">
        <Link to="/" className="flex items-center space-x-2 group">
          <div className="w-8 h-8 bg-gradient-to-br from-primary-500 to-primary-600 rounded flex items-center justify-center">
            <span className="text-white font-bold text-xl">Q</span>
          </div>
          <span className="text-xl font-semibold text-white">QuantFi</span>
        </Link>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-4 space-y-1">
        {navItems.map((item) => {
          const isActive = location.pathname === item.path;
          return (
            <Link
              key={item.path}
              to={item.path}
              className={`flex items-center space-x-3 px-3 py-2.5 rounded-md transition-all ${
                isActive
                  ? 'bg-primary-600/90 text-white shadow-lg'
                  : 'text-gray-400 hover:bg-dark-hover hover:text-gray-200'
              }`}
            >
              <span className="text-lg">{item.icon}</span>
              <span className="font-medium text-sm">{item.label}</span>
            </Link>
          );
        })}
      </nav>

      {/* Quick Stats */}
      <div className="px-3 pb-4">
        <div className="bg-dark-card/50 backdrop-blur-sm rounded-lg p-3 border border-dark-border/50">
          <h3 className="text-xs font-semibold text-gray-400 mb-3 uppercase tracking-wide">
            Quick Stats
          </h3>
          <div className="space-y-2.5 text-xs">
            <div className="flex justify-between items-center">
              <span className="text-gray-500">Total PnL</span>
              <span className="text-green-400 font-semibold">+$0.00</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-500">Active Strategies</span>
              <span className="text-gray-200 font-semibold">0</span>
            </div>
          </div>
        </div>
      </div>
    </aside>
  );
};
