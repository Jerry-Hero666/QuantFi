import { ModelCard } from './components/ModelCard';
import { ComparisonChart } from './components/ComparisonChart';

export const Trading = () => {
  const models = [
    {
      id: 1,
      name: 'DeepSeek',
      description: 'Advanced reasoning model with strong quantitative analysis',
      color: '#00D4FF',
      totalReturn: '128%',
      sharpeRatio: '2.8',
      maxDrawdown: '-8.2%',
      winRate: '68%',
      isTopPerformer: true,
    },
    {
      id: 2,
      name: 'GPT-4',
      description: "OpenAI's flagship model with comprehensive market understanding",
      color: '#10B981',
      totalReturn: '96%',
      sharpeRatio: '2.3',
      maxDrawdown: '-12.5%',
      winRate: '62%',
      isTopPerformer: false,
    },
    {
      id: 3,
      name: 'Qwen',
      description: "Alibaba's model optimized for financial data processing",
      color: '#A855F7',
      totalReturn: '101%',
      sharpeRatio: '2.5',
      maxDrawdown: '-10.8%',
      winRate: '64%',
      isTopPerformer: false,
    },
    {
      id: 4,
      name: 'Gemini',
      description: "Google's advanced AI model for market analysis",
      color: '#F59E0B',
      totalReturn: '88%',
      sharpeRatio: '2.1',
      maxDrawdown: '-14.2%',
      winRate: '59%',
      isTopPerformer: false,
    },
    {
      id: 5,
      name: 'Grok',
      description: "X's AI model with real-time market insights",
      color: '#EF4444',
      totalReturn: '121%',
      sharpeRatio: '2.6',
      maxDrawdown: '-9.5%',
      winRate: '66%',
      isTopPerformer: false,
    },
  ];

  const chartData = [
    { month: 'Jan', DeepSeek: 110, GPT4: 108, Qwen: 109, Gemini: 107, Grok: 110 },
    { month: 'Feb', DeepSeek: 115, GPT4: 112, Qwen: 113, Gemini: 110, Grok: 114 },
    { month: 'Mar', DeepSeek: 120, GPT4: 115, Qwen: 117, Gemini: 113, Grok: 119 },
    { month: 'Apr', DeepSeek: 125, GPT4: 120, Qwen: 122, Gemini: 118, Grok: 124 },
    { month: 'May', DeepSeek: 132, GPT4: 124, Qwen: 126, Gemini: 122, Grok: 130 },
    { month: 'Jun', DeepSeek: 145, GPT4: 132, Qwen: 135, Gemini: 128, Grok: 142 },
    { month: 'Jul', DeepSeek: 168, GPT4: 148, Qwen: 155, Gemini: 142, Grok: 165 },
    { month: 'Aug', DeepSeek: 185, GPT4: 165, Qwen: 172, Gemini: 158, Grok: 180 },
    { month: 'Sep', DeepSeek: 208, GPT4: 178, Qwen: 188, Gemini: 172, Grok: 202 },
    { month: 'Oct', DeepSeek: 228, GPT4: 196, Qwen: 201, Gemini: 188, Grok: 221 },
  ];

  return (
    <div className="bg-black text-white min-h-screen">
      <div className="max-w-7xl mx-auto px-8 py-12">
        {/* Header */}
        <div className="mb-8">
          <p className="text-gray-400 text-base">
            Compare performance of leading AI models in quantitative trading strategies
          </p>
        </div>

        {/* Comparison Chart */}
        <ComparisonChart data={chartData} models={models} />

        {/* Performance Analysis */}
        <div className="mb-12 bg-gray-900/40 border border-cyan/20 rounded-lg p-4">
          <div className="flex items-start gap-3">
            <div className="mt-1">
              <svg className="w-5 h-5 text-cyan" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
              </svg>
            </div>
            <div>
              <span className="font-semibold text-white">Performance Analysis:</span>
              <span className="text-gray-400 ml-2">
                DeepSeek leads with 128% returns, followed by Grok at 121%. All models show consistent upward trends with DeepSeek demonstrating superior risk-adjusted returns (Sharpe Ratio: 2.8).
              </span>
            </div>
          </div>
        </div>

        {/* Model Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {models.map((model) => (
            <ModelCard key={model.id} model={model} />
          ))}
        </div>
      </div>
    </div>
  );
};
