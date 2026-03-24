# Review：基于原版 BMAD-METHOD / OpenSpec / Superpowers 的混合架构验证

> **审查目标**：用 GitHub 原版项目的真实能力，重新验证之前讨论中提出的"BMAD 规划 + Agent Teams 交叉验证 + Superpowers 质量控制"混合架构，确认结论是否需要变更。

---

## 一、三个项目的原版真实面貌

### 1. BMAD-METHOD（bmad-code-org/BMAD-METHOD）

| 项目 | 详情 |
|---|---|
| **版本** | v6.2.0（2026-03-15） |
| **Stars** | 41.4k |
| **核心定位** | AI 驱动的敏捷开发框架，"Build More Architect Dreams" |
| **关键变化** | v6.1 起全面转向 **Skills Architecture**——所有 agent、workflow、task 统一为 SKILL.md 技能 |

#### 原版 BMAD Skills 全景（v6.2）

```
Phase 1 - Analysis（分析阶段）
├── bmad-agent-analyst        — 业务分析师 Mary
├── bmad-agent-tech-writer    — 技术写作
├── bmad-document-project     — 项目文档化
├── bmad-product-brief        — 产品简报
└── research                  — 领域调研

Phase 2 - Plan Workflows（规划阶段）
├── bmad-agent-pm             — 产品经理
├── bmad-agent-ux-designer    — UX 设计师
├── bmad-create-prd           — 创建 PRD
├── bmad-create-ux-design     — 创建 UX 设计
├── bmad-edit-prd             — 编辑 PRD
├── bmad-validate-prd         — 验证 PRD
└── create-prd                — PRD 创建（简化版）

Phase 3 - Solutioning（架构阶段）
├── bmad-agent-architect      — 架构师
├── bmad-check-implementation-readiness — 实施就绪检查
├── bmad-create-architecture  — 创建架构文档
├── bmad-create-epics-and-stories — 创建 Epic 和 Story
└── bmad-generate-project-context — 生成项目上下文

Phase 4 - Implementation（实施阶段）
├── bmad-agent-dev            — 开发者 Agent
├── bmad-agent-qa             — QA Agent
├── bmad-agent-quick-flow-solo-dev — 快速流程独立开发
├── bmad-agent-sm             — Scrum Master
├── bmad-code-review          — 代码审查
├── bmad-correct-course       — 纠偏
├── bmad-create-story         — 创建 Story
├── bmad-dev-story            — Story 开发
├── bmad-qa-generate-e2e-tests — 生成 E2E 测试
├── bmad-quick-dev            — 快速开发
├── bmad-retrospective        — 回顾
├── bmad-sprint-planning      — Sprint 规划
└── bmad-sprint-status        — Sprint 状态

Core Skills（跨阶段核心技能）
├── bmad-advanced-elicitation        — 高级需求引出
├── bmad-brainstorming               — 头脑风暴
├── bmad-distillator                 — 信息蒸馏
├── bmad-editorial-review-prose      — 编辑审查（散文）
├── bmad-editorial-review-structure  — 编辑审查（结构）
├── bmad-help                        — 智能帮助
├── bmad-index-docs                  — 文档索引
├── bmad-init                        — 初始化
├── bmad-party-mode                  — 聚会模式（多 Agent 角色共存）
├── bmad-review-adversarial-general  — 对抗性审查
├── bmad-review-edge-case-hunter     — 边界条件猎手
└── bmad-shard-doc                   — 文档分片
```

#### 原版 BMAD 的关键发现

1. **Party Mode**：BMAD v6 原生支持在**一个会话**中引入多个 Agent 角色进行协作讨论——这与我们之前设想的 Agent Teams 交叉验证有异曲同工之处
2. **Edge Case Hunter**：作为**并行代码审查层**运行，专门捕捉其他审查遗漏的边界条件
3. **bmad-check-implementation-readiness**：在架构阶段末尾做**实施就绪检查**，这本身就是一种"门控"机制
4. **Dev Loop Automation**：v6 支持开发循环自动化
5. **跨平台 Agent Team 优化**：v6 的 release notes 明确提到了对 "Cross Platform Agent Team" 的优化

---

### 2. OpenSpec（Fission-AI/OpenSpec）

| 项目 | 详情 |
|---|---|
| **版本** | v1.2.0（2026-02-23） |
| **Stars** | 33.4k |
| **核心定位** | 轻量级规范驱动开发（SDD）框架，"Agree before you build" |
| **支持工具** | 20+ AI 编码助手，包括 Claude Code, Cursor, CodeBuddy 等 |

#### OpenSpec 原版工作流

```
/opsx:propose "添加暗黑模式"
        ↓
openspec/changes/add-dark-mode/
├── proposal.md     — 变更提案（为什么改、改什么）
├── design.md       — 技术方案
├── tasks.md        — 实施任务清单
└── specs/          — 规范增量（需求如何变化）
        ↓
/opsx:apply         — 执行任务
        ↓
/opsx:archive       — 归档到 archive/，更新主规范
```

#### OpenSpec 的核心特性

1. **Spec Delta**（规范增量）：不是全量重写规范，而是管理每次变更带来的**增量**
2. **活文档**：规范文件保留在代码库中，成为项目的持久上下文
3. **流畅而非僵化**：随时可以更新任何文档，不强制严格阶段关卡
4. **变更隔离**：每个变更有自己的文件夹，互不干扰
5. **归档机制**：完成的变更归档为历史知识库

#### OpenSpec 在我们架构中的角色

之前的讨论**完全没有涉及 OpenSpec**（因为当时搜索不到）。但现在来看，OpenSpec 解决的是一个非常关键的问题：**规范层的变更管理**。

---

### 3. Superpowers（obra/superpowers）

| 项目 | 详情 |
|---|---|
| **版本** | v5.0.5（2026-03-17） |
| **Stars** | 107k |
| **核心定位** | Agent 技能框架 & 软件开发方法论，"让 AI 遵循工程纪律" |
| **作者** | Jesse Vincent（Prime Radiant） |

#### Superpowers 原版 14 个 Skills

| # | Skill | 类别 | 核心功能 |
|---|---|---|---|
| 1 | **brainstorming** | 协作 | 苏格拉底式需求精炼，2-3 方案权衡 |
| 2 | **writing-plans** | 协作 | 任务拆分为 2-5 分钟原子操作，精确到文件路径和命令 |
| 3 | **executing-plans** | 协作 | 带检查点的批量执行 |
| 4 | **subagent-driven-development** | 协作 | 子代理逐任务实施 + 两阶段审查（规范合规 → 代码质量） |
| 5 | **test-driven-development** | 测试 | RED-GREEN-REFACTOR，不写测试就不许写代码 |
| 6 | **systematic-debugging** | 调试 | 4 阶段根因分析 |
| 7 | **verification-before-completion** | 调试 | 证据驱动，必须跑命令贴输出 |
| 8 | **requesting-code-review** | 协作 | 预审查清单 |
| 9 | **receiving-code-review** | 协作 | 禁止表演性同意，独立技术验证 |
| 10 | **using-git-worktrees** | 协作 | 隔离工作空间，支持并行开发 |
| 11 | **finishing-a-development-branch** | 协作 | 合并/PR 决策工作流 |
| 12 | **dispatching-parallel-agents** | 协作 | **并发子代理工作流** |
| 13 | **using-superpowers** | 元 | 技能系统入口，强制检查 |
| 14 | **writing-skills** | 元 | 自定义新技能 |

#### Superpowers 的关键发现

1. **dispatching-parallel-agents**：原版 Superpowers 已内置并行代理调度——这与我们的 Agent Teams 并行执行完全吻合
2. **using-git-worktrees**：原生支持 worktree 隔离——完美解决并行开发的代码冲突问题
3. **subagent-driven-development**：两阶段审查（规范合规 + 代码质量）是核心质量保障
4. **技能自动触发**：代理在任何任务前自动检查相关技能，**不是建议而是强制**

---

## 二、之前结论的逐项 Review

### ✅ 结论 1："BMAD 做规划、Agent Teams 做执行"的混合架构

**之前的结论**：用 BMAD 串行做需求→架构→拆分，切换到 Agent Teams 并行执行。

**Review 结果**：✅ **结论基本正确，但需要补充**

- BMAD v6 的 4 阶段 Skills 架构（Analysis → Plan → Solutioning → Implementation）比我们之前理解的更完善
- v6 的 `bmad-check-implementation-readiness` 在 Phase 3 结束时做"实施就绪检查"——这是一个天然的**阶段门控**，比我们之前设计的更成熟
- **新发现**：BMAD 的 `bmad-party-mode` 允许在一个会话中引入多个 Agent 角色讨论，这为 Phase 1 交叉验证提供了一种**更轻量的替代方案**（见下文）

**🔄 变更**：BMAD 的规划阶段应该更精确地对应为 Phase 1-3（Analysis + Plan + Solutioning），而非之前粗略的 "PO → Architect → SM"。

---

### ✅ 结论 2："Agent Teams 做交叉验证，弥补信息瓶颈"

**之前的结论**：BMAD 规划阶段信息不全面，需要多个 Project Owner 互相验证任务拆分。

**Review 结果**：✅ **核心洞察完全正确，但实现方式可以有两种**

#### 方案 A：Agent Teams 模式（之前的方案）
每个 Project Owner 作为 Team Member，通过 `send_message` 互相确认。

**优点**：真正的并行 + 持久通信通道
**缺点**：Token 消耗大、通信带宽低

#### 方案 B：BMAD Party Mode（新发现）
利用 BMAD v6 原生的 Party Mode，在一个会话中让多个 Agent 角色同时参与讨论。

**优点**：信息共享无障碍（同一上下文窗口）、实现简单
**缺点**：受上下文窗口限制、无法真正并行

#### 建议选择

| 场景 | 推荐方案 |
|---|---|
| 3 个以下 Project，信息量适中 | **Party Mode**——同一上下文内直接对齐，效率最高 |
| 3 个以上 Project，信息量大 | **Agent Teams**——避免上下文溢出，真正并行验证 |
| 混合场景 | 先用 Party Mode 做初步对齐，再用 Agent Teams 深入确认 |

**🔄 变更**：增加了 Party Mode 作为轻量替代方案。

---

### ✅ 结论 3："并行开发中引入 Superpowers 控制质量"

**之前的结论**：每个 Project Owner 在并行开发时，使用 Superpowers 的 TDD、subagent-driven-development、verification 等强制质量纪律。

**Review 结果**：✅ **完全正确，且原版能力比预期更强**

之前的讨论已经非常准确地描述了 Superpowers 的能力。原版确认的关键能力：

1. ✅ `subagent-driven-development` 的两阶段审查——之前描述完全匹配
2. ✅ `test-driven-development` 的 RED-GREEN-REFACTOR 铁律——之前描述完全匹配
3. ✅ `verification-before-completion` 的证据驱动——之前描述完全匹配
4. ✅ `using-git-worktrees` 的隔离工作空间——之前描述完全匹配
5. ✅✅ `dispatching-parallel-agents` 的并发子代理——**之前讨论中遗漏了**

**🔄 变更**：`dispatching-parallel-agents` 是 Superpowers 原版的内置 Skill，它可以直接在一个 Owner Agent 内部调度多个并行子代理。这比我们之前设想的"Owner 手动用 Subagent 并行执行 Task"更加系统化。

---

### 🆕 结论 4：引入 OpenSpec 作为规范管理层（新增）

**之前的讨论完全没有涉及 OpenSpec**，但原版 OpenSpec 解决的问题对我们的架构至关重要：

#### OpenSpec 在混合架构中的位置

```
BMAD Phase 1-3（宏观规划）
    ↓ 产出 PRD + 架构 + Story 列表
    ↓
交叉验证阶段（Party Mode 或 Agent Teams）
    ↓ 确认和修正后的 Task 列表
    ↓
═══════════════════════════════════════════
   ★ OpenSpec 在此处介入 ★
═══════════════════════════════════════════
    ↓
每个 Project Owner 对自己负责的模块执行：
  /opsx:propose "实现用户注册 API"
    → proposal.md   — 变更提案
    → design.md     — 技术设计
    → tasks.md      — 原子任务清单
    → specs/        — 规范增量
    ↓
Superpowers 按照 OpenSpec 的 tasks.md 执行
    → TDD + subagent-driven-development + verification
    ↓
/opsx:archive — 归档为项目长期知识
```

#### OpenSpec 带来的独特价值

| 价值 | 说明 |
|---|---|
| **规范持久化** | BMAD 的规划文档在上下文中，会话结束就丢失；OpenSpec 把规范保存在代码库中 |
| **变更可追溯** | 每个功能变更有独立的 proposal → design → tasks 链条 |
| **跨会话上下文** | 新启动的 Agent 可以读取 openspec/ 目录获得完整上下文 |
| **增量管理** | Spec Delta 机制——不用重写整个规范，只管理增量变化 |
| **知识沉淀** | 归档的历史规范成为项目"长期记忆" |

**这恰恰解决了 Agent Teams 中各 Owner Agent 的上下文传递问题**——每个 Owner 的 OpenSpec 文件就是它的"工作记忆"，即使重新启动也不会丢失上下文。

---

## 三、修正后的完整架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Phase 0: BMAD 规划（串行 Skill 调用）                                     │
│                                                                         │
│  bmad-agent-analyst → bmad-create-prd → bmad-agent-architect            │
│  → bmad-create-architecture → bmad-create-epics-and-stories             │
│  → bmad-check-implementation-readiness  ← 门控！                        │
│                                                                         │
│  产出：PRD + 架构文档 + Epic/Story 列表 + 依赖关系                         │
│                                                                         │
│  ┌────────────────────────────────────────────────┐                     │
│  │ 🧠 BMAD Core Skills 全程可用：                   │                     │
│  │   brainstorming / advanced-elicitation /        │                     │
│  │   adversarial-review / edge-case-hunter         │                     │
│  └────────────────────────────────────────────────┘                     │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ Phase 1: 交叉验证                                                        │
│                                                                         │
│  ┌─── 小规模（≤3 Project）──┐  ┌─── 大规模（>3 Project）──────────┐     │
│  │                           │  │                                  │     │
│  │  BMAD Party Mode          │  │  Agent Teams                     │     │
│  │  同一会话中多角色讨论       │  │  每个 Owner 独立 Agent            │     │
│  │  信息共享无障碍             │  │  通过 send_message 确认           │     │
│  │  适合快速对齐               │  │  适合深度验证                     │     │
│  │                           │  │                                  │     │
│  └───────────────────────────┘  └──────────────────────────────────┘     │
│                                                                         │
│  验证内容：接口契约 / 隐式依赖 / 遗漏 Task / 粒度均衡 / 执行顺序           │
│  产出：修正后的 Story/Task 列表 + 补充的接口定义 + 新增的公共模块 Task       │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ Phase 2: OpenSpec 规范化（每个 Project 独立）               ★ 新增阶段 ★  │
│                                                                         │
│  每个 Project Owner 对自己的 Story 执行：                                 │
│                                                                         │
│  /opsx:propose "实现 [Story 名称]"                                       │
│    → openspec/changes/[story-id]/                                       │
│      ├── proposal.md    — 变更提案                                       │
│      ├── design.md      — 技术设计细节                                    │
│      ├── tasks.md       — 原子任务清单                                    │
│      └── specs/         — 规范增量                                       │
│                                                                         │
│  ★ 价值：                                                                │
│  - 将 BMAD 的宏观 Story 细化为可执行的原子任务                              │
│  - 规范文件持久化在代码库中，不受上下文窗口限制                              │
│  - 为后续 Superpowers 执行提供精确的"施工图纸"                             │
│  - 支持跨会话恢复上下文                                                    │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ Phase 3: 并行开发（Agent Teams + Superpowers 嵌套）                       │
│                                                                         │
│ ┌─ Project-A-Owner (Team Member) ────────────────────────────────┐      │
│ │                                                                 │      │
│ │  读取 openspec/changes/[story-A]/ 获取完整上下文                  │      │
│ │                                                                 │      │
│ │  Superpowers 强制执行：                                          │      │
│ │  ┌──────────────────────────────────────────────────────────┐   │      │
│ │  │ dispatching-parallel-agents                              │   │      │
│ │  │   → 可并行 Task → 多个子代理同时执行                        │   │      │
│ │  │   → 串行 Task → 逐个执行                                  │   │      │
│ │  │                                                          │   │      │
│ │  │ 每个 Task 内部：                                          │   │      │
│ │  │   using-git-worktrees → 隔离工作空间                      │   │      │
│ │  │   test-driven-development → RED → GREEN → REFACTOR        │   │      │
│ │  │   subagent-driven-development:                           │   │      │
│ │  │     → Implementer（实现）                                 │   │      │
│ │  │     → Spec Reviewer（对照 OpenSpec 规范审查）              │   │      │
│ │  │     → Code Quality Reviewer（代码质量审查）                │   │      │
│ │  │   verification-before-completion → 跑测试 + 贴证据         │   │      │
│ │  └──────────────────────────────────────────────────────────┘   │      │
│ │                                                                 │      │
│ │  需要跨 Project 确认 → send_message("B-Owner", ...)             │      │
│ │  Task 完成 → /opsx:archive 归档规范                              │      │
│ └─────────────────────────────────────────────────────────────────┘      │
│                                                                         │
│    ↕ Agent Teams 消息通道 ↕                                              │
│                                                                         │
│ ┌─ Project-B-Owner ─┐  ┌─ Project-C-Owner ─┐                           │
│ │ （同样结构）        │  │ （同样结构）        │                           │
│ └────────────────────┘  └────────────────────┘                          │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ Phase 4: 集成与验证                                                      │
│                                                                         │
│  BMAD Skills:                                                           │
│    bmad-code-review          → 全局代码审查                               │
│    bmad-review-edge-case-hunter → 边界条件猎杀                            │
│    bmad-qa-generate-e2e-tests → 生成端到端测试                            │
│    bmad-retrospective        → 回顾总结                                  │
│                                                                         │
│  Superpowers:                                                           │
│    systematic-debugging      → 集成问题的根因分析                         │
│    finishing-a-development-branch → 合并/PR 决策                         │
│                                                                         │
│  OpenSpec:                                                              │
│    /opsx:archive             → 全部规范归档为项目长期知识                   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 四、对比：之前的结论 vs 修正后

| 维度 | 之前的结论 | 修正后 | 变更类型 |
|---|---|---|---|
| BMAD 规划阶段 | "PO → Architect → SM" 三步 | BMAD v6 的 4 阶段 Skills（Analysis → Plan → Solutioning → Implementation），含 `check-implementation-readiness` 门控 | 🔄 细化 |
| 交叉验证方式 | 只考虑了 Agent Teams | 增加 BMAD Party Mode 作为轻量替代方案，按规模选择 | 🆕 新增 |
| 规范管理 | 完全缺失 | 引入 OpenSpec 作为规范管理层，每个 Story 产出 proposal + design + tasks + specs | 🆕 新增 |
| Superpowers 的能力 | 基本准确，描述了 TDD/审查/验证 | 补充了 `dispatching-parallel-agents`（并行子代理调度）和 `using-git-worktrees`（隔离工作空间） | 🔄 补充 |
| OpenSpec | "环境中不存在" | 原版确认存在（33.4k Stars），且是三剑客中"管理者"角色 | 🆕 纠正 |
| 三者关系 | BMAD 规划 + Superpowers 执行 | **BMAD 立法（做什么）+ OpenSpec 管理（怎么改）+ Superpowers 施工（怎么做好）** | 🔄 深化 |
| 质量保障层数 | 3 层（BMAD 规划 + Teams 验证 + Superpowers 审查） | **5 层**（见下方） | 🔄 增强 |
| Token 消耗评估 | "较高" | 因增加 OpenSpec 层，**进一步增加**，但换来了规范持久化和跨会话上下文 | ⚠️ 注意 |

---

## 五、修正后的五层质量保障体系

```
Layer 0: BMAD Analysis + Plan + Solutioning
         → 需求质量 + 架构质量 + 实施就绪检查
         → Core: adversarial-review + edge-case-hunter

Layer 1: Party Mode / Agent Teams 交叉验证
         → 任务拆分质量 + 接口一致性 + 依赖完整性

Layer 2: OpenSpec 规范化                              ★ 新增
         → 每个 Story 的详细规范 + 技术设计 + 原子任务清单
         → 规范持久化 + 变更可追溯

Layer 3: Superpowers TDD + 两阶段审查
         → 代码实现质量（测试覆盖 + 规范合规 + 代码质量）

Layer 4: BMAD 集成审查 + Superpowers 验证
         → 系统集成质量 + 边界条件 + E2E 测试 + 证据验证
```

---

## 六、总结：结论变更清单

### 不变的结论（完全验证通过）

1. ✅ **三层嵌套模型**：BMAD（串行规划）+ Agent Teams（并行协调）+ Subagent（Task 加速）——原版能力完全支持
2. ✅ **信息瓶颈问题**：BMAD 规划者不可能掌握所有细节，需要分布式验证——这依然是核心洞察
3. ✅ **Superpowers 管质量**：TDD + subagent-driven-development + verification 强制质量纪律——原版确认完全一致
4. ✅ **Git Worktree 解决并行冲突**：Superpowers 原生支持——完全验证

### 变更和新增的结论

1. 🔄 **BMAD 阶段细化**：从粗略的"PO→Architect→SM"细化为 4 阶段 Skills 架构
2. 🆕 **交叉验证双方案**：小规模用 Party Mode，大规模用 Agent Teams
3. 🆕 **引入 OpenSpec**：作为 BMAD 和 Superpowers 之间的桥梁——宏观规划（BMAD）→ 规范化（OpenSpec）→ 质量执行（Superpowers）
4. 🔄 **并行调度升级**：Superpowers 的 `dispatching-parallel-agents` 原生支持并行子代理，比之前设想的更系统
5. 🆕 **三剑客角色明确**：BMAD 是"立法者"，OpenSpec 是"管理者"，Superpowers 是"工程师"
6. 🔄 **质量层数升级**：从 3 层升级到 5 层

### 核心结论

> **之前的混合架构方向完全正确，但缺少了 OpenSpec 这个关键拼图。**
>
> BMAD 做的是**宏观规划**（PRD、架构、Story），Superpowers 做的是**微观执行**（TDD、审查、验证）。
> 但两者之间存在一个**粒度断层**——BMAD 产出的 Story 对于 Superpowers 来说太粗，Superpowers 需要的原子任务太细。
>
> **OpenSpec 恰好填补了这个断层**：它把 BMAD 的 Story 转化为带有 proposal/design/tasks/specs 的结构化规范，为 Superpowers 提供精确的"施工图纸"。
>
> 最终架构：**BMAD（做什么）→ OpenSpec（怎么改）→ Superpowers（怎么做好）**，Agent Teams 在需要跨模块协调时提供并行通信能力。
