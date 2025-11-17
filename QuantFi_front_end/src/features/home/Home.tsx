export const Home = () => {
  const stats = [
    { value: '$2.5B+', label: 'Total Value Locked' },
    { value: '150+', label: 'Active Strategies' },
    { value: '45.2%', label: 'Average APY' },
    { value: '50K+', label: 'Total Users' },
  ];

  const features = [
    {
      title: 'Tokenized Strategies',
      description: 'Invest in quantitative trading strategies through tokenized assets',
    },
    {
      title: 'Decentralized & Secure',
      description: 'Built on blockchain technology for maximum security and transparency',
    },
    {
      title: 'High Performance',
      description: 'Optimized algorithms for US stocks, crypto, and DeFi protocols',
    },
    {
      title: 'Multi-Asset Support',
      description: 'Trade across stocks, BTC, ETH, SOL, and major DeFi platforms',
    },
  ];

  return (
    <div className="bg-black text-white min-h-screen">
      {/* Hero Section */}
      <section className="max-w-7xl mx-auto px-8 pt-24 pb-16 text-center">
        <h1 className="text-6xl font-bold mb-6 leading-tight">
          <span className="hero-title-glow">Decentralized</span>
          <br />
          <span className="hero-title-glow">Quantitative Trading</span>
        </h1>

        <p className="text-lg text-gray-400 mb-10 max-w-3xl mx-auto leading-relaxed">
          Tokenize strategies, maximize returns. Trade smarter with AI-powered
          <br />
          algorithms across stocks, crypto, and DeFi protocols.
        </p>

        <button className="text-cyan hover:text-cyan-light font-medium text-sm transition-colors">
          Start Trading
        </button>

        {/* Stats */}
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6 mt-20 max-w-6xl mx-auto">
          {stats.map((stat, index) => (
            <div
              key={index}
              className="bg-gray-900/60 border border-gray-800 rounded-2xl p-8 text-center hover:border-cyan/40 transition-all"
            >
              <div className="text-4xl font-bold text-cyan mb-2">{stat.value}</div>
              <div className="text-sm text-gray-400">{stat.label}</div>
            </div>
          ))}
        </div>
      </section>

      {/* Why Choose QuantFi */}
      <section className="max-w-7xl mx-auto px-8 py-24">
        <h2 className="text-4xl font-bold text-center mb-20">Why Choose QuantFi?</h2>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 max-w-6xl mx-auto">
          {features.map((feature, index) => (
            <div key={index} className="text-center">
              <h3 className="text-xl font-bold mb-4 text-white">{feature.title}</h3>
              <p className="text-gray-400 text-sm leading-relaxed">{feature.description}</p>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};
