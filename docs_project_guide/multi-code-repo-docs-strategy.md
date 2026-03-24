# 多代码工程场景下的文档工程组织策略

> 基于前两版方案：[交接机制与统一文档目录设计](./handoff-and-docs-structure.md)、[文档工程与代码工程分离分析](./docs-code-separation-analysis.md)
>
> **核心问题**：当一个需求涉及多个代码工程（如前端、后端 API、微服务 A、微服务 B）时，文档工程应该如何组织？

---

## 一、结论先行

**推荐方案：单一文档工程 + 多代码工程（Hub-Spoke 模式）**

不需要为每个代码工程创建对应的文档工程。一个需求涉及多个代码工程时，用一个统一的文档工程做"中央枢纽"，各代码工程只保留必须跟代码绑定的实施文件（Superpowers Plans）。

三种方案的快速对比：

| 方案 | 描述 | 推荐度 | 适用场景 |
|---|---|---|---|
| A. 单一文档工程（Hub-Spoke） | 一个文档工程统管所有需求和规范 | ⭐⭐⭐⭐⭐ | 绝大多数场景 |
| B. 按代码工程 1:1 对应 | 每个代码工程配一个专属文档工程 | ⭐⭐ | 几乎不推荐 |
| C. 分层文档工程 | 一个全局 + 每个代码工程各一个局部 | ⭐⭐⭐ | 超大规模/多团队 |

下面逐一拆解。

---

## 二、为什么 1:1 对应的文档工程是错误的

先解释为什么最直觉的方案（每个代码工程配一个文档工程）是错误的。

### 2.1 根本问题：需求天然跨仓

一个业务需求几乎不可能恰好落在一个代码工程内：

```
需求："用户可以用微信支付购买会员"

涉及的代码工程：
├── frontend/          → 支付页面 UI、支付结果展示
├── backend-api/       → 创建订单接口、支付回调接口
├── payment-service/   → 对接微信支付 API
└── user-service/      → 更新会员状态
```

如果每个代码工程有自己的文档工程：

```
问题 1：PRD 放在哪个文档工程？
  → 它描述的是业务需求，不属于任何单一代码工程
  → 强行放一个？其他三个文档工程要引用它，引用链变成意大利面

问题 2：architecture.md 放在哪个文档工程？
  → 架构是全局的（"前端调后端，后端调支付服务"）
  → 每个文档工程各复制一份？→ 版本分裂

问题 3：OpenSpec proposal.md 怎么写？
  → "添加微信支付"这个变更横跨 4 个代码工程
  → 拆成 4 个 proposal？→ 它们其实是同一个业务变更，拆了就丢失了整体视角
  → 合成 1 个 proposal？→ 放在哪个文档工程？

问题 4：BMAD 的 Story 怎么映射？
  → 一个 Story 拆出的 OpenSpec Changes 分散在 4 个文档工程
  → 追溯链断裂：你无法从一个 Story 看到它的全部实施状态
```

### 2.2 违反工具设计假设

| 工具 | 假设 | 1:1 对应后的问题 |
|---|---|---|
| **BMAD** | 一个 `project-context.md` 描述整个项目 | 4 个 project-context.md，内容大量重叠，维护成本 ×4 |
| **OpenSpec** | `openspec/specs/` 是系统行为的唯一事实来源 | 4 套 specs/，同一个业务流程的 spec 碎片化分布在 4 个仓库 |
| **Superpowers** | Plan 引用的代码路径是当前仓库相对路径 | ✅ 这个倒没问题——Plan 确实属于各自的代码工程 |

### 2.3 结论

**1:1 对应的文档工程把"全局视角"撕碎了。** 需求管理、架构设计、行为规范——这些天然是跨工程的。强行按代码工程拆分文档工程，等于用代码的组织方式去管理文档，而文档和代码的组织维度是不同的。

---

## 三、推荐方案：单一文档工程（Hub-Spoke 模式）

### 3.1 架构拓扑

```
workspace/
│
├── project-docs/                    # ★ 唯一的文档工程 ★（Hub）
│   │
│   ├── .git/
│   │
│   ├── _bmad/                       # BMAD 框架配置
│   ├── _bmad-output/                # BMAD 产出（PRD、架构、Epics）
│   │   ├── planning-artifacts/
│   │   │   ├── PRD.md
│   │   │   ├── architecture.md
│   │   │   └── epics/
│   │   └── project-context.md       # 全局项目"宪法"
│   │
│   ├── docs/
│   │   ├── INDEX.md                 # 全局路由表
│   │   │
│   │   ├── global/                  # 全局文档
│   │   │   ├── PRD.md
│   │   │   ├── architecture.md
│   │   │   └── project-context.md
│   │   │
│   │   └── projects/                # ═══ 按业务模块分区（不是按代码工程！）═══
│   │       ├── user-auth/
│   │       │   ├── README.md
│   │       │   ├── epics/
│   │       │   └── stories/
│   │       ├── payment/
│   │       │   ├── README.md
│   │       │   ├── epics/
│   │       │   └── stories/
│   │       └── content-mgmt/
│   │
│   └── openspec/                    # OpenSpec 规范（全局唯一）
│       ├── specs/                   # ═══ 按行为域分区 ═══
│       │   ├── auth/
│       │   │   └── spec.md          # 认证行为规范
│       │   ├── payment/
│       │   │   └── spec.md          # 支付行为规范
│       │   └── membership/
│       │       └── spec.md          # 会员行为规范
│       │
│       ├── changes/                 # 活跃变更
│       │   └── add-wechat-pay/      # ← 一个变更，横跨多个代码工程
│       │       ├── proposal.md
│       │       ├── design.md
│       │       ├── tasks.md         # ← 按代码工程分组的任务清单
│       │       ├── .openspec.yaml
│       │       └── specs/
│       │           ├── payment/
│       │           │   └── spec.md  # Delta Spec
│       │           └── membership/
│       │               └── spec.md  # Delta Spec
│       └── archive/
│
│
├── frontend/                        # ★ 代码工程 A ★（Spoke）
│   ├── .git/
│   ├── .project-context.md          # ← 同步自文档工程（只读副本）
│   ├── docs/
│   │   └── superpowers/
│   │       └── plans/               # 属于这个代码工程的 Plans
│   │           └── 2026-03-24-wechat-pay-ui.md
│   └── src/
│
├── backend-api/                     # ★ 代码工程 B ★（Spoke）
│   ├── .git/
│   ├── .project-context.md          # ← 同步自文档工程（只读副本）
│   ├── docs/
│   │   └── superpowers/
│   │       └── plans/
│   │           └── 2026-03-24-wechat-pay-order-api.md
│   └── src/
│
├── payment-service/                 # ★ 代码工程 C ★（Spoke）
│   ├── .git/
│   ├── .project-context.md
│   ├── docs/
│   │   └── superpowers/
│   │       └── plans/
│   │           └── 2026-03-24-wechat-pay-integration.md
│   └── src/
│
└── user-service/                    # ★ 代码工程 D ★（Spoke）
    ├── .git/
    ├── .project-context.md
    ├── docs/
    │   └── superpowers/
    │       └── plans/
    │           └── 2026-03-24-update-membership.md
    └── src/
```

### 3.2 核心设计要点

#### 要点 1：`docs/projects/` 按业务模块分，不是按代码工程分

```
❌ 错误做法：
docs/projects/
├── frontend/          # 按代码工程分
├── backend-api/
├── payment-service/
└── user-service/

✅ 正确做法：
docs/projects/
├── user-auth/         # 按业务域分
├── payment/
└── content-mgmt/
```

**为什么？** 因为 BMAD 的 Epic/Story 是业务视角的（"用户可以支付"），不是工程视角的（"backend-api 新增接口"）。按业务域分区，一个 Story 就完整地待在一个目录下，不需要跨目录拼凑。

#### 要点 2：`openspec/specs/` 按行为域分，不是按代码工程分

```
❌ 错误做法：
openspec/specs/
├── frontend/          # "前端的认证 spec" vs "后端的认证 spec"？
│   └── auth/spec.md   # → 同一个"认证"行为，两个 spec，必然冲突
├── backend-api/
│   └── auth/spec.md

✅ 正确做法：
openspec/specs/
├── auth/              # "认证"是一个行为域
│   └── spec.md        # 描述的是系统整体的认证行为，不关心哪个代码工程实现
├── payment/
│   └── spec.md
└── membership/
    └── spec.md
```

**为什么？** OpenSpec 的 spec 描述的是**系统行为**（"当用户注册时，系统 MUST 返回 JWT"），不是**实现行为**（"backend-api 的 /api/auth/register 返回 JWT"）。系统行为不以代码工程为单位。

#### 要点 3：OpenSpec `tasks.md` 按代码工程分组任务

这是 Hub-Spoke 模式的核心接口——`tasks.md` 是文档工程通往各代码工程的"分发器"：

```markdown
# Tasks: add-wechat-pay

## 变更概述
添加微信支付购买会员功能。

## 代码工程任务分配

### 🔹 frontend （代码工程 A）
- [ ] Task F1: 创建支付页面组件
- [ ] Task F2: 添加支付结果轮询逻辑
- [ ] Task F3: 添加会员状态刷新

### 🔹 backend-api （代码工程 B）
- [ ] Task B1: 创建订单接口 POST /api/orders
- [ ] Task B2: 微信支付回调接口 POST /api/webhooks/wechat-pay
- [ ] Task B3: 订单状态查询接口 GET /api/orders/:id

### 🔹 payment-service （代码工程 C）
- [ ] Task P1: 对接微信支付统一下单 API
- [ ] Task P2: 实现支付结果通知验签
- [ ] Task P3: 添加支付幂等性保障

### 🔹 user-service （代码工程 D）
- [ ] Task U1: 添加会员开通接口
- [ ] Task U2: 实现会员到期自动降级

## 跨工程依赖
- Task B1 依赖 Task P1（创建订单需要调用支付服务）
- Task B2 依赖 Task P2（回调接口需要验签能力）
- Task F1 依赖 Task B1（前端调用后端订单接口）
- Task U1 依赖 Task B2（会员开通由支付成功回调触发）

## 建议实施顺序
1. payment-service (P1, P2, P3) → 无前置依赖
2. user-service (U1, U2) → 无前置依赖
3. backend-api (B1, B2, B3) → 依赖 payment-service 和 user-service
4. frontend (F1, F2, F3) → 依赖 backend-api
```

#### 要点 4：每个代码工程从 tasks.md 中"领取"自己的任务生成 Plan

```
文档工程                                    代码工程
────────                                    ────────

tasks.md                                    frontend/docs/superpowers/plans/
  ├── 🔹 frontend 的任务 ──────────────→       2026-03-24-wechat-pay-ui.md
  │     (Task F1, F2, F3)                     （引用路径：frontend/src/...）
  │
  ├── 🔹 backend-api 的任务 ──────────→    backend-api/docs/superpowers/plans/
  │     (Task B1, B2, B3)                     2026-03-24-wechat-pay-order-api.md
  │                                           （引用路径：backend-api/src/...）
  │
  ├── 🔹 payment-service 的任务 ──────→   payment-service/docs/superpowers/plans/
  │     (Task P1, P2, P3)                     2026-03-24-wechat-pay-integration.md
  │
  └── 🔹 user-service 的任务 ─────────→   user-service/docs/superpowers/plans/
        (Task U1, U2)                         2026-03-24-update-membership.md
```

Superpowers 的 `writing-plans` 在**各自的代码工程目录**中执行，读取文档工程的 tasks.md 中属于自己的部分，生成代码工程本地的 Plan 文件。

#### 要点 5：INDEX.md 承担跨工程追踪

```markdown
# 项目文档索引

## 全局文档
- [PRD](./global/PRD.md)
- [架构](./global/architecture.md)
- [项目规则](./global/project-context.md)

## 系统规范（Source of Truth）
- [认证规范](../openspec/specs/auth/spec.md)
- [支付规范](../openspec/specs/payment/spec.md)
- [会员规范](../openspec/specs/membership/spec.md)

## 活跃变更

### add-wechat-pay（添加微信支付）
- 提案: [proposal.md](../openspec/changes/add-wechat-pay/proposal.md)
- 设计: [design.md](../openspec/changes/add-wechat-pay/design.md)
- 任务: [tasks.md](../openspec/changes/add-wechat-pay/tasks.md)
- 实施计划:
  - `[frontend]` docs/superpowers/plans/2026-03-24-wechat-pay-ui.md — 🟡 进行中
  - `[backend-api]` docs/superpowers/plans/2026-03-24-wechat-pay-order-api.md — 🟢 已完成
  - `[payment-service]` docs/superpowers/plans/2026-03-24-wechat-pay-integration.md — 🟢 已完成
  - `[user-service]` docs/superpowers/plans/2026-03-24-update-membership.md — ⚪ 待开始

## 代码工程清单
| 工程 | 仓库 | 技术栈 | 对应 project-context 版本 |
|---|---|---|---|
| frontend | git@.../frontend.git | React + TypeScript | v3 (2026-03-24) |
| backend-api | git@.../backend-api.git | Node.js + Express | v3 (2026-03-24) |
| payment-service | git@.../payment-service.git | Go | v3 (2026-03-24) |
| user-service | git@.../user-service.git | Go | v3 (2026-03-24) |
```

---

### 3.3 project-context.md 的多代码工程适配

前一版设计中 `project-context.md` 是单工程的。多代码工程场景下需要**分层**：

#### 文档工程中：全局 project-context.md

```markdown
# Project Context（全局版）

## 项目概述
在线教育平台——支持课程购买、视频学习、互动问答。

## 全局技术决策
- 微服务架构，服务间通过 gRPC 通信
- 统一使用 PostgreSQL 数据库
- 统一使用 Redis 作为缓存
- 所有服务部署在 Kubernetes

## 代码工程拓扑
| 工程 | 语言 | 职责 |
|---|---|---|
| frontend | TypeScript (React) | 用户界面 |
| backend-api | TypeScript (Express) | BFF 层，API 聚合 |
| payment-service | Go | 支付业务 |
| user-service | Go | 用户和会员业务 |

## 全局编码规则
- API 命名遵循 RESTful 规范
- 所有时间字段使用 ISO 8601 格式
- 错误响应统一格式: { code, message, details }

## 各工程特有规则
→ 见各代码工程的 .project-context.md
```

#### 各代码工程中：局部 .project-context.md

```markdown
# Project Context — frontend

> 全局规则见文档工程的 project-context.md
> 本文件仅描述 frontend 代码工程特有的规则

## 技术栈
- React 18 + TypeScript 5
- Vite 构建
- Tailwind CSS
- React Query 做数据获取

## 代码规则
- 组件使用 PascalCase 命名
- hooks 使用 useXxx 命名
- 测试使用 Vitest + Testing Library

## 目录约定
- src/components/ — 共享组件
- src/features/{feature}/ — 按功能模块组织
- src/hooks/ — 共享 hooks
- src/api/ — API 调用封装

## 常用命令
- 开发: `npm run dev`
- 测试: `npx vitest`
- 构建: `npm run build`
- Lint: `npm run lint`
```

**同步规则**：
- **全局 → 局部**：文档工程的 project-context.md 变更后，手动/脚本更新各代码工程的 `.project-context.md`
- **局部 → 全局**：代码工程的特有规则**不需要**同步回文档工程——全局版本只引用，不复制

---

## 四、完整工作流：多代码工程下的 BMAD → OpenSpec → Superpowers

### 4.1 阶段图

```
时间线 ──────────────────────────────────────────────────────────────────→

┌──────────────┐
│ BMAD Phase   │  ← 活跃工程：文档工程
│ 1-3          │
│              │  产出：PRD、架构、Epic/Story
│ (文档工程)    │  ★ architecture.md 中明确各代码工程的职责边界
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ 交接 1:       │  ← 活跃工程：文档工程
│ BMAD→OpenSpec │
│              │  操作：
│ (文档工程)    │  1. 持久化到 docs/
│              │  2. 初始化 openspec/specs/ 基线
│              │  3. 同步全局 project-context.md 到各代码工程
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ OpenSpec     │  ← 活跃工程：文档工程
│ propose →    │
│ design →     │  关键：tasks.md 按代码工程分组任务
│ tasks        │  关键：design.md 描述跨工程交互（接口契约、数据流）
│              │
│ (文档工程)    │
└──────┬───────┘
       │
       ▼ tasks.md 按代码工程分发
       │
       ├─────────────────────┬───────────────────┬──────────────────┐
       ▼                     ▼                   ▼                  ▼
┌────────────┐      ┌────────────┐      ┌────────────┐    ┌────────────┐
│ Superpowers │      │ Superpowers │      │ Superpowers │    │ Superpowers │
│ write-plan  │      │ write-plan  │      │ write-plan  │    │ write-plan  │
│             │      │             │      │             │    │             │
│ (frontend)  │      │(backend-api)│      │ (payment)   │    │   (user)    │
└──────┬──────┘      └──────┬──────┘      └──────┬──────┘    └──────┬──────┘
       │                     │                   │                  │
       ▼                     ▼                   ▼                  ▼
┌────────────┐      ┌────────────┐      ┌────────────┐    ┌────────────┐
│ Superpowers │      │ Superpowers │      │ Superpowers │    │ Superpowers │
│ exec-plan   │      │ exec-plan   │      │ exec-plan   │    │ exec-plan   │
│             │      │             │      │             │    │             │
│ (frontend)  │      │(backend-api)│      │ (payment)   │    │   (user)    │
└──────┬──────┘      └──────┬──────┘      └──────┬──────┘    └──────┬──────┘
       │                     │                   │                  │
       └─────────────────────┴───────────────────┴──────────────────┘
                                    │
                                    ▼
                           ┌────────────────┐
                           │ OpenSpec verify │  ← 活跃工程：文档工程（对照各代码工程）
                           │ + archive      │
                           │                │  操作：
                           │ (文档工程)      │  1. 验证各代码工程的实现符合 spec
                           │                │  2. Delta Specs 合并到 specs/
                           │                │  3. 归档到 archive/
                           │                │  4. 更新 INDEX.md
                           └────────────────┘
```

### 4.2 跨工程依赖的处理

tasks.md 中已经定义了跨工程依赖和建议实施顺序。Superpowers 执行各代码工程的 Plan 时，有两种策略：

#### 策略 A：串行执行（简单稳定）

按依赖顺序逐个执行：

```
1. payment-service 的 Plan → 完成 → 提交
2. user-service 的 Plan → 完成 → 提交
3. backend-api 的 Plan → 完成 → 提交（此时可以集成测试调用 payment + user）
4. frontend 的 Plan → 完成 → 提交
```

**适用场景**：个人开发、Agent 单线程执行。

#### 策略 B：并行执行 + 接口契约（高效）

无依赖的工程并行执行，有依赖的通过接口契约（Mock/Stub）解耦：

```
并行批次 1（无依赖）:
  payment-service 的 Plan ─────→
  user-service 的 Plan    ─────→
                                  ↓ 两者完成后
并行批次 2（依赖批次 1）:
  backend-api 的 Plan     ─────→
                                  ↓ 完成后
串行批次 3（依赖批次 2）:
  frontend 的 Plan        ─────→
```

**接口契约定义在 `design.md` 中**：

```markdown
## 服务间接口契约

### payment-service → backend-api
- gRPC: `PaymentService.CreateOrder(req) → OrderResponse`
- Proto 文件: `proto/payment.proto`

### user-service → backend-api
- gRPC: `UserService.ActivateMembership(req) → MembershipResponse`
- Proto 文件: `proto/user.proto`

### backend-api → frontend
- REST: `POST /api/orders` → `{ orderId, paymentUrl }`
- REST: `GET /api/orders/:id` → `{ orderId, status, membership }`
```

backend-api 的 Plan 生成时，即使 payment-service 尚未完成，也可以基于 Proto 定义生成 Mock 进行开发和测试。

---

## 五、与方案 B（1:1 对应）的详细对比

### 5.1 文件碎片化对比

```
场景：需求"添加微信支付"

=== 方案 B（1:1 对应，4 个文档工程） ===

frontend-docs/
  openspec/changes/add-wechat-pay-ui/
    proposal.md    ← 只描述前端部分，丢失全局视角
    design.md      ← 只有前端设计，看不到后端接口
    tasks.md
  openspec/specs/payment-ui/spec.md    ← "前端的支付 spec"？语义奇怪

backend-docs/
  openspec/changes/add-wechat-pay-api/
    proposal.md    ← 另一份"为什么要做微信支付"——和前端的 proposal 内容重叠 80%
    design.md      ← 有接口设计，但看不到前端怎么用
    tasks.md

payment-docs/
  openspec/changes/add-wechat-pay-integration/
    proposal.md    ← 又一份……
    ...

user-docs/
  openspec/changes/add-membership-update/
    proposal.md    ← 再一份……
    ...

总共：4 份 proposal，4 份 design，4 份 tasks
  → 信息高度重叠
  → 跨工程依赖描述分散在各自的 design.md 中
  → 没有一个地方能看到"微信支付"这个需求的全貌


=== 方案 A（单一文档工程） ===

project-docs/
  openspec/changes/add-wechat-pay/
    proposal.md    ← 一份，完整描述业务需求
    design.md      ← 一份，包含所有工程的设计和接口契约
    tasks.md       ← 一份，按代码工程分组，含跨工程依赖

总共：1 份 proposal，1 份 design，1 份 tasks
  → 信息不重复
  → 跨工程依赖集中管理
  → INDEX.md 一眼看到全部实施状态
```

### 5.2 维护成本对比

| 维护项 | 方案 A (单一文档工程) | 方案 B (1:1 对应) |
|---|---|---|
| PRD 更新 | 改 1 处 | 改 1 处（但引用它的 4 个文档工程要同步确认） |
| 架构变更 | 改 1 处 | 改 1 处 + 4 个 project-context 同步 |
| 新增代码工程 | INDEX.md 加一行 | 新建一个文档工程 + 初始化全套目录 |
| 跨工程需求 | 1 个 proposal + 1 个 design + 1 个 tasks | 4 个 proposal + 4 个 design + 4 个 tasks |
| OpenSpec verify | 1 次（对照唯一的 spec 验证所有工程） | 4 次（各自验证各自的 spec，但跨工程行为谁来验？） |

---

## 六、方案 C：分层文档工程（供超大规模参考）

当组织规模达到一定程度（例如 10+ 代码工程、3+ 独立团队），单一文档工程可能过于庞大。此时可以考虑分层：

### 6.1 架构

```
global-docs/                         # ★ 全局文档工程 ★（L0 层）
├── _bmad/
├── _bmad-output/
│   ├── PRD.md                       # 全局 PRD
│   ├── architecture.md              # 全局架构
│   └── project-context.md           # 全局规则
├── docs/
│   ├── INDEX.md                     # 全局索引
│   └── global/
└── openspec/
    ├── specs/                       # 全局行为规范
    │   ├── auth/spec.md
    │   └── payment/spec.md
    └── changes/                     # 跨域变更在这里
        └── add-wechat-pay/          # ← 涉及多个域的变更

domain-payment-docs/                 # ★ 支付域文档工程 ★（L1 层）
├── docs/
│   ├── INDEX.md                     # 域级索引
│   └── projects/
│       ├── payment-service/
│       └── order-service/
└── openspec/
    ├── specs/                       # 支付域行为规范（更细粒度）
    │   ├── wechat-pay/spec.md
    │   ├── alipay/spec.md
    │   └── refund/spec.md
    └── changes/                     # 仅涉及支付域内部的变更
        └── add-refund-v2/

domain-user-docs/                    # ★ 用户域文档工程 ★（L1 层）
├── ...
└── openspec/
    ├── specs/
    └── changes/
```

### 6.2 什么时候需要方案 C

| 信号 | 说明 |
|---|---|
| 代码工程 > 10 个 | 单一文档工程的 openspec/specs/ 目录太深 |
| 独立团队 > 3 个 | 不同团队对同一份文档的修改频繁冲突 |
| 变更很少跨域 | 80% 以上的变更只涉及一个业务域 |
| 域间接口已稳定 | 域间通过 API 契约通信，不需要频繁协调 |

### 6.3 方案 C 的额外成本

- 跨域变更（如"微信支付"涉及支付域+用户域）需要在全局文档工程发起
- 全局 → 域级的 spec 同步机制需要额外设计
- INDEX.md 需要多级链接（全局 INDEX → 域 INDEX → 代码工程 Plans）

**结论：除非确实需要，否则不要过早引入方案 C。单一文档工程能覆盖绝大多数场景。**

---

## 七、Agent 配置与操作

### 7.1 多代码工程的工作空间配置

```jsonc
// my-project.code-workspace
{
  "folders": [
    { "path": "./project-docs",     "name": "📄 文档工程" },
    { "path": "./frontend",         "name": "🖥️ frontend" },
    { "path": "./backend-api",      "name": "🔌 backend-api" },
    { "path": "./payment-service",  "name": "💳 payment-service" },
    { "path": "./user-service",     "name": "👤 user-service" }
  ]
}
```

### 7.2 同步脚本升级（多代码工程版）

```powershell
# sync-docs-to-all-code-repos.ps1
# 将文档工程的关键文件同步到所有代码工程

param(
    [string]$DocsDir = ".\project-docs",
    [string[]]$CodeDirs = @(
        ".\frontend",
        ".\backend-api",
        ".\payment-service",
        ".\user-service"
    )
)

foreach ($CodeDir in $CodeDirs) {
    $repoName = Split-Path $CodeDir -Leaf
    Write-Host "━━━ 同步到 $repoName ━━━"

    # 1. 同步全局 project-context.md
    Copy-Item "$DocsDir\_bmad-output\project-context.md" `
              "$CodeDir\.project-context-global.md" -Force
    Write-Host "  ✅ project-context.md (global)"

    # 2. 同步 OpenSpec specs（verify 阶段需要）
    $mirrorDir = "$CodeDir\.openspec-mirror"
    if (Test-Path $mirrorDir) { Remove-Item $mirrorDir -Recurse -Force }
    Copy-Item "$DocsDir\openspec\specs" "$mirrorDir\specs" -Recurse
    Write-Host "  ✅ openspec/specs/"

    # 3. 同步当前活跃变更的 tasks/design（writing-plans 阶段需要）
    $changesDir = "$DocsDir\openspec\changes"
    if (Test-Path $changesDir) {
        Copy-Item $changesDir "$mirrorDir\changes" -Recurse
        Write-Host "  ✅ openspec/changes/"
    }

    Write-Host ""
}

Write-Host "🎉 全部同步完成"
```

各代码工程的 `.gitignore`：

```gitignore
# 从文档工程同步的镜像文件
.project-context-global.md
.openspec-mirror/
```

### 7.3 Agent IDENTITY 配置（代码工程侧）

每个代码工程的 `.workbuddy/IDENTITY.md` 中添加：

```markdown
## 工程拓扑

本项目采用 Hub-Spoke 模式：
- 文档工程（Hub）: ../project-docs/
- 当前代码工程: ./ (frontend)
- 其他代码工程: ../backend-api/, ../payment-service/, ../user-service/

### 我的职责
- 本工程负责: 用户界面（React + TypeScript）
- 全局规则: .project-context-global.md（同步自文档工程，只读）
- 局部规则: .project-context.md（本工程特有规则）

### 跨工程读取
当需要：
- OpenSpec spec → 从 .openspec-mirror/specs/ 读取（或直接从 ../project-docs/openspec/ 读取）
- BMAD 产出 → 从 ../project-docs/_bmad-output/ 读取
- 其他工程的 Plan → 从 ../xxx/docs/superpowers/plans/ 读取
```

---

## 八、OpenSpec verify 的多代码工程操作

### 8.1 问题

一个 OpenSpec change 的验证需要检查多个代码工程的实现。例如 `add-wechat-pay` 的 spec 说"当用户支付成功时，系统 MUST 更新会员状态"——这个行为跨越了 backend-api、payment-service 和 user-service。

### 8.2 方案

分两层验证：

```
┌──────────────────────────────────────────────────────────────────────┐
│ 第一层：各代码工程内部验证（Superpowers verification-before-completion）│
│                                                                      │
│  每个代码工程在 Plan 执行完成后，用 Superpowers 的验证机制检查：         │
│  - 单元测试通过                                                       │
│  - 内联的验收标准（从 spec 提取的）满足                                 │
│  - 代码质量检查通过                                                    │
│                                                                      │
│  ★ 这是"局部正确性"验证                                               │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│ 第二层：跨工程系统级验证（OpenSpec /opsx:verify）                       │
│                                                                      │
│  在文档工程中执行，读取所有代码工程的实现结果：                           │
│  - 对照 openspec/specs/payment/spec.md 检查支付完整流程                │
│  - 对照 openspec/specs/membership/spec.md 检查会员状态更新             │
│  - 验证跨工程的接口契约是否一致                                        │
│                                                                      │
│  ★ 这是"全局正确性"验证                                               │
│                                                                      │
│  Agent 在文档工程目录下执行，通过多文件夹工作空间访问各代码工程            │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 九、决策矩阵：什么时候用哪个方案

| 场景 | 代码工程数 | 团队规模 | 推荐方案 |
|---|---|---|---|
| 个人/小项目，前后端分离 | 2-3 | 1-3 人 | **A（单一文档工程）** |
| 中等项目，微服务架构 | 3-8 | 3-10 人 | **A（单一文档工程）** |
| 大型项目，多业务域 | 8-15 | 10-30 人 | **A 起步，痛点出现后考虑 C** |
| 超大规模，多独立团队 | 15+ | 30+ 人 | **C（分层文档工程）** |
| 各代码工程完全独立，无共享需求 | 任意 | 任意 | **各自维护文档，不需要统一文档工程** |

**关键判断标准**：如果你的需求经常跨越多个代码工程，就需要单一文档工程做 Hub；如果各代码工程的需求高度独立（像独立产品而非微服务），那各自维护文档反而更清晰。

---

## 十、总结

### 一句话答案

**用单一文档工程做中央枢纽（Hub），各代码工程只保留自己的 Superpowers Plans 和局部 project-context。**

### 核心设计原则

| 原则 | 说明 |
|---|---|
| **需求和规范是全局的，实施是局部的** | PRD/架构/Spec 放文档工程（全局），Plan/代码/测试放代码工程（局部） |
| **按业务域组织文档，按代码工程组织实施** | docs/projects/ 按业务模块分，Plans 按代码工程分 |
| **tasks.md 是分发器** | 一份 tasks.md 按代码工程分组，各工程"领取"自己的任务 |
| **INDEX.md 是全景图** | 一个地方看到需求 → 设计 → 各工程实施状态 |
| **project-context 分层** | 全局版在文档工程，局部版在各代码工程 |

### 和前两版方案的关系

```
第一版：三工具交接机制和统一文档目录设计
  → 解决了"单项目中 BMAD/OpenSpec/Superpowers 如何协作"
  
第二版：文档工程与代码工程分离分析
  → 解决了"文档和代码可以分成两个仓库吗"

第三版（本文）：多代码工程下的文档工程组织
  → 解决了"一个需求跨多个代码工程时，文档工程怎么组织"
  → 答案：单一文档工程做 Hub，tasks.md 做分发器
```
