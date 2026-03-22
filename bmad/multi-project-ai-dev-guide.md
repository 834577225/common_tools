# 多项目 AI 辅助开发指南

> BMAD + OpenSpec + SuperPowers 三件套实战手册
> 适用场景：A、B、C 多个工程共享数据库、存在调用关系

---

## 一、三个框架的定位与分工

| 框架 | 核心定位 | 关注层面 | 一句话总结 |
|------|---------|---------|-----------|
| **BMAD** | 敏捷AI驱动开发框架，模拟完整敏捷团队 | **流程与角色**：分析师→PM→架构师→Scrum Master→开发者→QA | 管"谁来做" |
| **SuperPowers** | AI编程技能框架，强制工程纪律 | **执行质量**：TDD、代码审查、子代理协作、Git隔离 | 管"怎么做好" |
| **OpenSpec** | 轻量级规范驱动开发层 | **需求对齐**：spec先行、变更管理、产物追踪、跨工具兼容 | 管"做的是什么" |

---

## 二、方案对比：BMAD+SuperPowers vs BMAD+OpenSpec+SuperPowers

### 方案一：BMAD + SuperPowers（无 OpenSpec）

#### 工作方式

```
BMAD 规划阶段（角色协作）
  分析师 → 项目简报
  产品经理 → PRD
  架构师 → 架构文档
  Scrum Master → 开发故事
            ↓
SuperPowers 执行阶段（技能驱动）
  头脑风暴 → 编写计划 → TDD执行 → 子代理审查 → Git合并
```

#### ✅ 优点

1. **角色分工清晰**：BMAD 的 6 大代理角色天然覆盖软件开发全流程
2. **执行质量有保障**：SuperPowers 的 TDD 强制循环 + 子代理审查确保代码质量
3. **上下文工程化**：BMAD 的"超详细开发故事"携带了丰富的上下文
4. **技术栈统一**：两者都以 Markdown 为核心载体，配合 Git 工作流
5. **适合单一大工程**：对 Monorepo 特别友好

#### ❌ 缺点（针对多工程共享数据库场景）

1. **跨工程规范缺乏统一管理层**：BMAD 的 PRD 和架构文档是面向单个项目的，A 改了共享表结构 B/C 无法自动感知
2. **接口契约管理是空白**：调用关系的接口规范只存在于架构文档的文字描述中
3. **变更影响面分析靠人脑**：BMAD 的 Scrum Master 只关注本工程上下文
4. **重量级流程在多工程下成倍膨胀**：一个跨三工程的需求，需要跑 3 轮完整流程

### 方案二：BMAD + OpenSpec + SuperPowers（三件套）

#### 工作方式

```
OpenSpec 规范层（需求对齐 + 变更管理）
  /opsx:propose → 提案（跨工程影响面分析）
  /opsx:spec    → 结构化验收场景
  /opsx:design  → 技术方案（含接口契约）
  /opsx:tasks   → 任务清单
            ↓
BMAD 规划阶段（角色协作，消费 OpenSpec 产物）
  架构师 → 基于 OpenSpec design 补充架构细节
  Scrum Master → 基于 OpenSpec tasks 生成开发故事
            ↓
SuperPowers 执行阶段（技能驱动）
  TDD执行 → 子代理审查 → Git合并
```

#### ✅ 优点

1. **跨工程规范有统一锚点**：spec 文件作为 A/B/C 三工程的共享契约层
2. **变更管理结构化**：Change → Artifacts → Archive 机制天然适合跨工程变更
3. **Delta Spec 解决增量问题**：共享数据库的表结构演进可用 Delta Spec 管理
4. **接口契约前置验证**：先在 OpenSpec 里写 spec，三方对齐后再动代码
5. **BMAD 流程可精简**：OpenSpec 已完成需求分析，BMAD 可跳过分析师和 PM 阶段
6. **工具链兼容性好**：OpenSpec 通过 Slash 命令支持 20+ 种 AI 工具

#### ❌ 缺点

1. **三层框架叠加，认知负担重**：学习曲线陡峭
2. **流程层级可能产生冗余**：OpenSpec 和 BMAD 存在功能重叠，需要裁剪
3. **配置和维护成本高**：三个工程 × 三个框架的配置文件
4. **小需求的过度工程化**：需要明确的"轻量通道"
5. **跨工程 spec 同步仍需人为协调**：没有中央 spec 仓库或自动同步

### 核心对比总结

| 维度 | BMAD + SuperPowers | BMAD + OpenSpec + SuperPowers |
|------|-------------------|------------------------------|
| **跨工程协调** | ❌ 弱，靠文档约定 | ✅ 强，spec 作为共享契约 |
| **共享数据库变更管理** | ❌ 无原生支持 | ✅ Delta Spec + 变更追踪 |
| **接口契约管理** | ❌ 散落在文档中 | ✅ 结构化 spec 前置验证 |
| **上手难度** | ⭐⭐⭐ 中等 | ⭐⭐⭐⭐⭐ 较高 |
| **流程灵活性** | ✅ 两层，相对灵活 | ⚠️ 三层，需要裁剪避免冗余 |
| **小需求友好度** | ✅ 可以快速走 Dev 通道 | ⚠️ 需要建立轻量级旁路 |
| **单工程效果** | ✅✅✅ 非常好 | ✅✅ 好但略重 |
| **多工程协作效果** | ⭐⭐ 不够 | ⭐⭐⭐⭐ 明显更好 |
| **维护成本** | 低 | 中高 |

### 推荐结论

**推荐方案二（BMAD + OpenSpec + SuperPowers），但要做裁剪：**

1. **精简 BMAD 角色**：重点用架构师 + Scrum Master + Dev + QA
2. **建立共享 spec 仓库**：单独建 `shared-specs/` 存放数据库 schema spec 和接口契约 spec
3. **区分变更等级**：大/中/小三级流程（详见下文）
4. **统一入口**：所有跨工程变更必须先在 OpenSpec 里提 proposal

---

## 三、各框架命令速查

### OpenSpec 命令

#### 核心工作流命令（Standard Workflow）

| 命令 | 功能 |
|------|------|
| `openspec init` | 初始化 OpenSpec（首次使用） |
| `openspec update` | 更新 AI 指令和命令集 |
| `openspec config profile` | 切换工作流模式（Standard / Expanded） |
| `/opsx:propose "<想法>"` | 发起提案，AI 生成 proposal.md + specs/ + design.md + tasks.md |
| `/opsx:apply` | 执行实施，AI 按 tasks.md 编写代码 |
| `/opsx:archive` | 归档变更，移至 archive/ 目录 |

#### 扩展工作流命令（Expanded Workflow）

| 命令 | 功能 |
|------|------|
| `/opsx:new` | 创建新的规格变更 |
| `/opsx:continue` | 继续当前工作流 |
| `/opsx:ff` | 快速推进（Fast Forward） |
| `/opsx:verify` | 验证代码是否符合规格 |
| `/opsx:sync` | 同步规格文档与代码库状态 |
| `/opsx:bulk-archive` | 批量归档 |
| `/opsx:onboard` | 将现有项目接入 OpenSpec |

### BMAD 命令

#### 安装与更新

```bash
# 全新安装或更新
npx bmad-method install

# 已有项目更新
git pull
npm run install:bmad
```

#### Web UI 代理调用（规划阶段）

| 命令 | 功能 |
|------|------|
| `*help` | 查看可用命令 |
| `*analyst` | 调用分析师代理，创建项目简报 |
| `*pm` | 调用产品经理代理，创建 PRD |
| `*architect` | 调用架构师代理，创建架构文档 |
| `*sm` | 调用 Scrum Master 代理，生成开发故事 |
| `*dev` | 调用开发者代理 |
| `*qa` | 调用 QA 代理 |
| `#bmad-orchestrator` | 与编排器对话，询问系统运作方式 |

#### IDE 开发阶段

- Scrum Master 将规划文档转化为**超详细开发故事**
- Dev 代理读取故事文件，按上下文指导编码
- QA 代理进行质量审查

### SuperPowers 命令

#### Slash 命令

| 命令 | 功能 |
|------|------|
| `/superpowers:brainstorm` | 头脑风暴，复杂构思任务（可启动 Visual Brainstorming Companion） |
| `/superpowers:write-plan` | 编写实现计划，生成分批次执行方案 |
| `/superpowers:execute-plan` | 执行计划，按批次 TDD 循环 |

#### 核心技能（自动调用）

| 技能 | 功能 |
|------|------|
| `using-superpowers` | 元技能，强制执行 1% 规则 |
| `test-driven-development` | TDD：Red → Green → Refactor 循环 |
| `systematic-debugging` | 4 阶段系统化调试 |
| `subagent-driven-development` | 子代理驱动开发 |
| `using-git-worktrees` | Git Worktree 分支管理 |
| `brainstorming` | 构思与设计 |
| `writing-plans` | 计划编写 |

---

## 四、BMAD 代理角色详解

| 角色 | 英文名 | 主要职责 | 产出物 |
|------|--------|---------|--------|
| 分析师 | ANALYST | 市场研究、头脑风暴、竞争分析、项目发现 | 项目简报 |
| 产品经理 | PM | 产品需求、策略、功能优先级、路线图 | PRD（产品需求文档） |
| 架构师 | ARCHITECT | 系统设计、技术选型、API 设计、基础设施规划 | 架构文档 |
| Scrum Master | SM | 用户故事、史诗管理、敏捷过程指导 | 超详细开发故事 |
| 开发者 | DEV | 代码实现、调试、重构 | 生产代码 |
| QA | QA | 测试架构审查、质量门决策、改进建议 | 测试报告 |

---

## 五、多项目共享数据库场景的特殊考虑

### 共享 spec 仓库结构

建议在三个工程之外，单独维护一个共享规范仓库：

```
shared-specs/
├── openspec/
│   ├── specs/                    # 共享规格
│   │   ├── database/             # 数据库 schema spec
│   │   │   ├── users-table.md
│   │   │   ├── orders-table.md
│   │   │   └── ...
│   │   └── apis/                 # 接口契约 spec
│   │       ├── a-to-b-api.md     # A 调用 B 的接口契约
│   │       ├── b-to-c-api.md     # B 调用 C 的接口契约
│   │       └── ...
│   └── changes/                  # 变更记录
│       ├── active/               # 进行中的变更
│       └── archive/              # 已归档的变更
└── README.md
```

### 共享 DB 操作顺序铁律

```
1. 先改 spec（OpenSpec propose）
2. 三方对齐确认
3. 再改 DB schema（DDL 迁移脚本）
4. 最后改各工程代码
```

**绝对不能**先改代码再补 spec。

### 接口变更协调机制

1. 接口提供方先在共享 spec 仓库发起 `/opsx:propose`
2. 接口消费方审查 design.md 中的接口定义
3. 三方确认后，各自在本工程中执行适配
4. 集成测试通过后 `/opsx:archive`
