interface ComparisonChartProps {
  data: Array<{
    month: string;
    DeepSeek: number;
    GPT4: number;
    Qwen: number;
    Gemini: number;
    Grok: number;
  }>;
  models: Array<{
    name: string;
    color: string;
  }>;
}

export const ComparisonChart = ({ data }: ComparisonChartProps) => {
  // Calculate chart dimensions
  const height = 300;
  const padding = { top: 20, right: 20, bottom: 50, left: 60 };
  const chartHeight = height - padding.top - padding.bottom;

  // Find min and max values across all models
  const allValues = data.flatMap((d) => [d.DeepSeek, d.GPT4, d.Qwen, d.Gemini, d.Grok]);
  const minValue = Math.min(...allValues);
  const maxValue = Math.max(...allValues);
  const valueRange = maxValue - minValue;

  // Generate Y-axis ticks
  const yTicks = [0, 60, 120, 180, 240];

  // Calculate point positions for each model
  const getPoints = (modelKey: 'DeepSeek' | 'GPT4' | 'Qwen' | 'Gemini' | 'Grok') => {
    return data
      .map((point, index) => {
        const x = (index / (data.length - 1)) * 100;
        const y = chartHeight - ((point[modelKey] - minValue) / valueRange) * chartHeight;
        return `${x}%,${y}`;
      })
      .join(' ');
  };

  return (
    <div className="mb-12">
      {/* Chart Header */}
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-bold text-white">Cumulative Returns Comparison</h2>
        <span className="px-3 py-1 bg-cyan/10 text-cyan text-sm rounded-md border border-cyan/30">
          10-Month Performance
        </span>
      </div>

      {/* Chart Container */}
      <div className="bg-gray-900/30 border border-gray-800 rounded-2xl p-8">
        <div className="relative" style={{ height: `${height}px` }}>
          <svg width="100%" height="100%" className="overflow-visible">
            {/* Y-axis label */}
            <text
              x="-150"
              y="15"
              transform="rotate(-90)"
              fill="#9CA3AF"
              fontSize="12"
              textAnchor="middle"
            >
              Return (%)
            </text>

            {/* Y-axis ticks and grid lines */}
            {yTicks.map((tick) => {
              const y = padding.top + chartHeight - ((tick - minValue) / valueRange) * chartHeight;
              return (
                <g key={tick}>
                  {/* Grid line */}
                  <line
                    x1={`${padding.left}`}
                    y1={y}
                    x2="95%"
                    y2={y}
                    stroke="#374151"
                    strokeWidth="1"
                    opacity="0.2"
                  />
                  {/* Y-axis tick label */}
                  <text
                    x={padding.left - 10}
                    y={y + 4}
                    fill="#9CA3AF"
                    fontSize="11"
                    textAnchor="end"
                  >
                    {tick}
                  </text>
                </g>
              );
            })}

            {/* Chart lines group */}
            <g transform={`translate(${padding.left}, ${padding.top})`}>
              {/* DeepSeek line */}
              <polyline
                fill="none"
                stroke="#00D4FF"
                strokeWidth="2.5"
                points={getPoints('DeepSeek')}
              />
              {data.map((point, index) => {
                const x = (index / (data.length - 1)) * 100;
                const y = chartHeight - ((point.DeepSeek - minValue) / valueRange) * chartHeight;
                return (
                  <circle key={`ds-${index}`} cx={`${x}%`} cy={y} r="4" fill="#00D4FF" />
                );
              })}

              {/* GPT-4 line */}
              <polyline
                fill="none"
                stroke="#10B981"
                strokeWidth="2.5"
                points={getPoints('GPT4')}
              />
              {data.map((point, index) => {
                const x = (index / (data.length - 1)) * 100;
                const y = chartHeight - ((point.GPT4 - minValue) / valueRange) * chartHeight;
                return (
                  <circle key={`gpt-${index}`} cx={`${x}%`} cy={y} r="4" fill="#10B981" />
                );
              })}

              {/* Qwen line */}
              <polyline
                fill="none"
                stroke="#A855F7"
                strokeWidth="2.5"
                points={getPoints('Qwen')}
              />
              {data.map((point, index) => {
                const x = (index / (data.length - 1)) * 100;
                const y = chartHeight - ((point.Qwen - minValue) / valueRange) * chartHeight;
                return (
                  <circle key={`qwen-${index}`} cx={`${x}%`} cy={y} r="4" fill="#A855F7" />
                );
              })}

              {/* Gemini line */}
              <polyline
                fill="none"
                stroke="#F59E0B"
                strokeWidth="2.5"
                points={getPoints('Gemini')}
              />
              {data.map((point, index) => {
                const x = (index / (data.length - 1)) * 100;
                const y = chartHeight - ((point.Gemini - minValue) / valueRange) * chartHeight;
                return (
                  <circle key={`gemini-${index}`} cx={`${x}%`} cy={y} r="4" fill="#F59E0B" />
                );
              })}

              {/* Grok line */}
              <polyline
                fill="none"
                stroke="#EF4444"
                strokeWidth="2.5"
                points={getPoints('Grok')}
              />
              {data.map((point, index) => {
                const x = (index / (data.length - 1)) * 100;
                const y = chartHeight - ((point.Grok - minValue) / valueRange) * chartHeight;
                return (
                  <circle key={`grok-${index}`} cx={`${x}%`} cy={y} r="4" fill="#EF4444" />
                );
              })}
            </g>

            {/* X-axis labels */}
            {data.map((point, index) => {
              const x = padding.left + (index / (data.length - 1)) * (100 - padding.left - padding.right);
              return (
                <text
                  key={point.month}
                  x={`${x}%`}
                  y={height - 20}
                  fill="#9CA3AF"
                  fontSize="11"
                  textAnchor="middle"
                >
                  {point.month}
                </text>
              );
            })}
          </svg>
        </div>

        {/* Legend */}
        <div className="flex items-center justify-center gap-6 mt-6 flex-wrap">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#00D4FF' }}></div>
            <span className="text-sm text-gray-400">DeepSeek</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#10B981' }}></div>
            <span className="text-sm text-gray-400">GPT4</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#A855F7' }}></div>
            <span className="text-sm text-gray-400">Qwen</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#F59E0B' }}></div>
            <span className="text-sm text-gray-400">Gemini</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#EF4444' }}></div>
            <span className="text-sm text-gray-400">Grok</span>
          </div>
        </div>
      </div>
    </div>
  );
};
