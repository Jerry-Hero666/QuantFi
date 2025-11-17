export const Dashboard = () => {
  const tasks = [
    {
      id: 1,
      title: 'Connect Wallet',
      description: 'Connect your wallet to get started',
      reward: 50,
      status: 'basic',
      statusLabel: 'Basic',
      progress: null,
      current: null,
      total: null,
      inProgress: true,
    },
    {
      id: 2,
      title: 'First Trade',
      description: 'Complete your first token swap',
      reward: 100,
      status: 'trading',
      statusLabel: 'Trading',
      progress: null,
      current: null,
      total: null,
      inProgress: true,
    },
    {
      id: 3,
      title: 'Invest in Strategy',
      description: 'Invest in any quantitative strategy',
      reward: 200,
      status: 'strategy',
      statusLabel: 'Strategy',
      progress: null,
      current: null,
      total: null,
      inProgress: true,
    },
    {
      id: 4,
      title: 'DeFi Explorer',
      description: 'Deposit into 3 different DeFi protocols',
      reward: 300,
      status: 'defi',
      statusLabel: 'DeFi',
      progress: 0,
      current: 0,
      total: 3,
      inProgress: true,
    },
    {
      id: 5,
      title: 'Volume Trader',
      description: 'Complete $10,000 in total trading volume',
      reward: 500,
      status: 'trading',
      statusLabel: 'Trading',
      progress: 25,
      current: 2500,
      total: 10000,
      inProgress: true,
    },
    {
      id: 6,
      title: 'Strategy Master',
      description: 'Invest in 5 different strategies',
      reward: 400,
      status: 'strategy',
      statusLabel: 'Strategy',
      progress: 20,
      current: 1,
      total: 5,
      inProgress: true,
    },
    {
      id: 7,
      title: 'Referral Champion',
      description: 'Refer 10 friends to the platform',
      reward: 1000,
      status: 'social',
      statusLabel: 'Social',
      progress: 30,
      current: 3,
      total: 10,
      inProgress: true,
    },
    {
      id: 8,
      title: 'Daily Login Streak',
      description: 'Login for 7 consecutive days',
      reward: 150,
      status: 'basic',
      statusLabel: 'Basic',
      progress: 57,
      current: 4,
      total: 7,
      inProgress: true,
    },
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'basic':
        return { bg: 'rgba(0, 112, 243, 0.15)', color: '#0070F3', border: 'rgba(0, 112, 243, 0.3)' };
      case 'trading':
        return { bg: 'rgba(16, 185, 129, 0.15)', color: '#10B981', border: 'rgba(16, 185, 129, 0.3)' };
      case 'strategy':
        return { bg: 'rgba(168, 85, 247, 0.15)', color: '#A855F7', border: 'rgba(168, 85, 247, 0.3)' };
      case 'defi':
        return { bg: 'rgba(0, 212, 255, 0.15)', color: '#00D4FF', border: 'rgba(0, 212, 255, 0.3)' };
      case 'social':
        return { bg: 'rgba(236, 72, 153, 0.15)', color: '#EC4899', border: 'rgba(236, 72, 153, 0.3)' };
      default:
        return { bg: 'rgba(107, 114, 128, 0.15)', color: '#6B7280', border: 'rgba(107, 114, 128, 0.3)' };
    }
  };

  return (
    <div className="bg-black text-white min-h-screen">
      <div className="max-w-7xl mx-auto px-8 py-12">
        {/* Header */}
        <div className="mb-12">
          <h1 className="text-5xl font-bold mb-4 title-glow">Airdrop Rewards</h1>
          <p className="text-gray-400 text-lg">
            Complete tasks and earn tokens to boost your trading power
          </p>
        </div>

        {/* Tasks Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {tasks.map((task) => {
            const statusColors = getStatusColor(task.status);
            return (
              <div
                key={task.id}
                className="bg-gray-900/40 border border-gray-800 rounded-2xl p-6 hover:border-cyan/20 transition-all"
              >
                {/* Header */}
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <h3 className="text-xl font-bold text-white mb-2">{task.title}</h3>
                    <p className="text-sm text-gray-400">{task.description}</p>
                  </div>
                  <div className="text-right ml-4">
                    <div className="text-2xl font-bold text-cyan mb-1">+{task.reward}</div>
                    <div className="text-xs text-gray-400">tokens</div>
                  </div>
                </div>

                {/* Status Badge */}
                <div className="mb-4">
                  <span
                    className="px-3 py-1 rounded-full text-xs font-medium"
                    style={{
                      backgroundColor: statusColors.bg,
                      color: statusColors.color,
                      border: `1px solid ${statusColors.border}`,
                    }}
                  >
                    {task.statusLabel}
                  </span>
                </div>

                {/* Progress */}
                {task.progress !== null ? (
                  <div>
                    <div className="flex items-center justify-between text-sm mb-2">
                      <span className="text-gray-400">Progress</span>
                      {task.current !== null && task.total !== null && (
                        <span className="text-white font-medium">
                          {task.current} / {task.total}
                        </span>
                      )}
                    </div>
                    <div className="w-full bg-gray-800 rounded-full h-2">
                      <div
                        className="bg-cyan h-2 rounded-full transition-all"
                        style={{ width: `${task.progress}%` }}
                      ></div>
                    </div>
                  </div>
                ) : (
                  <div className="flex items-center gap-2 text-sm text-gray-500">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                      />
                    </svg>
                    <span>In Progress</span>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
