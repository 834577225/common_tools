# 架构模式参考

## 单体架构 (Monolithic)

### 适用场景
- 小型团队（1-3 人）
- 简单业务逻辑
- 快速原型/MVP
- 不需要独立扩展

### 推荐结构
```
src/
├── controllers/     # 请求处理
├── services/        # 业务逻辑
├── models/          # 数据模型
├── middleware/       # 中间件
├── utils/           # 工具函数
└── config/          # 配置
```

### 优点
- 简单，开发快
- 部署简单
- 调试方便

### 缺点
- 扩展性差
- 模块耦合
- 发布影响全局

---

## 模块化单体 (Modular Monolith)

### 适用场景
- 中型项目
- 需要模块隔离但不需要独立部署
- 未来可能拆分为微服务

### 推荐结构
```
src/
├── modules/
│   ├── auth/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── models/
│   │   └── index.ts      # 模块公开接口
│   ├── users/
│   └── orders/
├── shared/                # 共享基础设施
│   ├── database/
│   ├── cache/
│   └── events/
└── app.ts
```

### 核心原则
- 模块间只通过公开接口通信
- 每个模块有自己的数据模型
- 共享基础设施层
- 明确的模块边界

---

## 微服务 (Microservices)

### 适用场景
- 大型团队
- 需要独立部署和扩展
- 不同组件有不同的技术需求
- 高可用要求

### 通信模式
- **同步**: REST / gRPC
- **异步**: 消息队列 (Kafka / RabbitMQ / Redis Streams)
- **事件驱动**: Event Sourcing / CQRS

### 必要基础设施
- 服务发现
- API 网关
- 配置中心
- 日志聚合
- 链路追踪
- 断路器

---

## 无服务器 (Serverless)

### 适用场景
- 事件驱动场景
- 突发流量
- 低运维要求
- 按需付费

### 常见平台
- 腾讯云 SCF
- AWS Lambda
- Azure Functions
- Cloudflare Workers

### 注意事项
- 冷启动延迟
- 执行时间限制
- 供应商锁定
- 本地调试复杂

---

## 常见技术栈组合

### 全栈 TypeScript
```
前端: React/Next.js + TailwindCSS
后端: Node.js + Express/Fastify
数据库: PostgreSQL + Prisma
缓存: Redis
部署: Docker + 腾讯云
```

### Go + React
```
前端: React + Vite + Ant Design
后端: Go + Gin/Fiber
数据库: MySQL + GORM
缓存: Redis
消息: Kafka
部署: K8s
```

### Python + Vue
```
前端: Vue 3 + Element Plus
后端: Python + FastAPI
数据库: PostgreSQL + SQLAlchemy
缓存: Redis
部署: Docker Compose
```

### Java Spring
```
前端: React/Vue
后端: Java + Spring Boot 3
数据库: MySQL + MyBatis-Plus
缓存: Redis
消息: RocketMQ
部署: K8s + Jenkins
```
