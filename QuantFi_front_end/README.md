# QuantFi Frontend

QuantFi 是一个去中心化量化交易平台，支持多种 DeFi 协议（Uniswap V3, Aave, Compound, Curve）的自动化交易策略。

## 技术栈

- **框架**: React 19 + TypeScript
- **构建工具**: Vite 7
- **样式**: Tailwind CSS v4
- **Web3**: wagmi + viem + RainbowKit
- **路由**: React Router v6
- **状态管理**: Zustand + TanStack Query

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 配置环境变量

复制 `.env.example` 到 `.env` 并配置：

```bash
cp .env.example .env
```

需要配置的主要变量：
- `VITE_WALLETCONNECT_PROJECT_ID`: 从 [WalletConnect Cloud](https://cloud.walletconnect.com) 获取
- `VITE_API_BASE_URL`: 后端 API 地址
- 合约地址：根据部署的智能合约更新

### 3. 启动开发服务器

```bash
npm run dev
```

访问 http://localhost:5173

### 4. 构建生产版本

```bash
npm run build
```

构建产物在 `dist/` 目录

### 5. 预览生产版本

```bash
npm run preview
```

## 项目结构

```
src/
├── components/          # 通用组件
│   ├── layout/         # 布局组件（Header, Sidebar）
│   ├── wallet/         # 钱包相关组件
│   └── common/         # 通用 UI 组件（Button, Card）
├── features/           # 功能模块
│   ├── dashboard/      # 仪表板
│   ├── trading/        # 交易
│   ├── strategy/       # 策略管理
│   ├── portfolio/      # 投资组合
│   └── market/         # 市场数据
├── hooks/              # 自定义 Hooks
├── services/           # API 服务
├── store/              # 状态管理
├── types/              # TypeScript 类型
├── utils/              # 工具函数
├── config/             # 配置文件
│   ├── env.ts         # 环境变量
│   ├── chains.ts      # 区块链网络配置
│   └── wagmi.ts       # wagmi 配置
├── App.tsx
└── main.tsx
```

## 主要功能

### ✅ 已完成

- [x] 项目初始化和基础架构
- [x] Web3 钱包连接（支持 MetaMask, WalletConnect 等）
- [x] 响应式布局（Header + Sidebar）
- [x] 路由系统
- [x] Dashboard 仪表板页面框架
- [x] Tailwind CSS 样式系统

### 🚧 开发中

- [ ] 交易界面
  - [ ] 交易表单
  - [ ] 实时价格展示
  - [ ] 订单簿
  - [ ] 交易历史
- [ ] 策略管理
  - [ ] 策略列表
  - [ ] 策略配置
  - [ ] 回测功能
  - [ ] 策略性能监控
- [ ] 投资组合
  - [ ] 资产概览
  - [ ] 收益统计
  - [ ] 风险指标
- [ ] 市场数据
  - [ ] 价格列表
  - [ ] K线图（TradingView）
  - [ ] 市场深度
- [ ] 后端 API 对接
- [ ] 智能合约集成
  - [ ] Uniswap V3 Adapter
  - [ ] Aave Adapter
  - [ ] Compound Adapter
  - [ ] Curve Adapter

## 开发规范

### 代码风格

- 使用 TypeScript 严格模式
- 组件使用函数式组件 + Hooks
- 样式使用 Tailwind CSS utility classes
- 文件命名：PascalCase for components, camelCase for utils

### Git 提交规范

```
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式（不影响功能）
refactor: 重构
test: 测试
chore: 构建/工具链更新
```

## 常见问题

### 1. RainbowKit 钱包连接失败

确保设置了正确的 `VITE_WALLETCONNECT_PROJECT_ID`

### 2. Tailwind CSS 样式不生效

检查 `tailwind.config.js` 中的 `content` 配置是否正确

### 3. 构建警告：chunks 过大

这是正常的，Web3 相关库比较大。生产环境建议：
- 启用代码分割
- 使用 CDN 加载大型库
- 配置 `manualChunks`

## License

MIT
