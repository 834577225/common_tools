# BMAD ↔ OpenSpec ↔ Superpowers：交接机制与统一文档目录设计

> **目标**：基于三个工具的原版文件组织约定，设计一个统一的 `docs/` 目录结构，解决交接断层问题，实现三层工具的文档无缝流转。

---

## 一、三个工具的原版文件约定（现状）

先搞清楚每个工具"原生"把文件放在哪里，才能设计合理的统一方案。

### 1. BMAD 原版约定

```
your-project/
├── _bmad/                          # BMAD 框架配置（agents/skills/workflows）
└── _bmad-output/                   # BMAD 产出物
    ├── planning-artifacts/
    │   ├── PRD.md                  # 产品需求文档
    │   ├── architecture.md         # 架构文档
    │   └── epics/                  # Epic 和 Story
    │       ├── epic-1.md
    │       └── epic-2.md
    ├── implementation-artifacts/
    │   └── sprint-status.yaml      # Sprint 状态追踪
    └── project-context.md          # 项目"宪法"——实施规则、技术栈、代码约定
```

**关键特征**：
- 使用 `_bmad-output/` 前缀（下划线前缀表示框架管理目录）
- `project-context.md` 是核心，所有 BMAD Skills 自动加载
- PRD、架构、Epic/Story 全部在 `planning-artifacts/` 下

### 2. OpenSpec 原版约定

```
your-project/
└── openspec/
    ├── specs/                      # 系统当前状态的"唯一事实来源"
    │   ├── auth/
    │   │   └── spec.md
    │   ├── payments/
    │   │   └── spec.md
    │   └── ui/
    │       └── spec.md
    └── changes/                    # 变更管理
        ├── add-dark-mode/          # 活跃变更
        │   ├── proposal.md         # 为什么改、改什么
        │   ├── design.md           # 技术方案
        │   ├── tasks.md            # 实施任务清单
        │   ├── .openspec.yaml      # 元数据
        │   └── specs/              # Delta Specs（增量规格）
        │       └── ui/
        │           └── spec.md
        └── archive/                # 已完成的变更归档
            └── 2026-03-24-add-2fa/
                ├── proposal.md
                ├── design.md
                └── ...
```

**关键特征**：
- `openspec/specs/` 是系统行为的"唯一事实来源"
- 每个变更是独立的文件夹，包含完整的 proposal → design → tasks → specs 链条
- Delta Specs 机制：变更只记录增量，不重写整个 spec
- 归档按日期前缀排序

### 3. Superpowers 原版约定

```
your-project/
└── docs/
    └── superpowers/
        └── plans/                  # 实施计划
            ├── 2026-03-24-user-auth.md
            └── 2026-03-24-payment-flow.md
```

**关键特征**：
- 计划文件放在 `docs/superpowers/plans/` 下（日期+功能名命名）
- 计划文件是高度结构化的 Markdown（含 TDD 步骤、精确文件路径、验证命令）
- 执行时强制使用 Git Worktree 隔离
- 执行结果是代码提交，不产出额外文档

---

## 二、三者交接的核心断层

```
BMAD 产出                    OpenSpec 需要                Superpowers 需要
────────────                ────────────                ──────────────
PRD.md（全局）               一个"变更提案"               一份"精确到文件路径和命令
architecture.md（全局）      （为什么改、改什么）           的原子任务计划"
epics/epic-1.md（宏观）      
epics/stories/（Story 级）   → proposal.md               → 2026-03-24-xxx.md
                            → design.md                    (plans/ 下的计划文件)
                            → tasks.md
                            → specs/
```

### 断层 1：BMAD → OpenSpec

| 问题 | 说明 |
|---|---|
| **粒度不匹配** | BMAD 产出的是 Epic/Story（"用户可以注册账号"），OpenSpec 需要的是 Change Proposal（"添加邮箱注册 API"）。一个 Story 可能对应多个 OpenSpec Change |
| **文件位置不同** | BMAD 输出到 `_bmad-output/`，OpenSpec 读 `openspec/`，两者不互通 |
| **缺少系统 Spec** | OpenSpec 需要 `openspec/specs/` 作为"当前系统状态"基线，BMAD 不生成这个 |
| **上下文传递** | BMAD 的上下文在会话中，OpenSpec 需要持久化文件作为输入 |

### 断层 2：OpenSpec → Superpowers

| 问题 | 说明 |
|---|---|
| **任务粒度不匹配** | OpenSpec 的 `tasks.md` 是"实施清单"（如"创建 auth 中间件"），Superpowers 的 plan 需要精确到文件路径、代码片段、测试命令 |
| **文件位置不同** | OpenSpec 输出到 `openspec/changes/xxx/tasks.md`，Superpowers 读 `docs/superpowers/plans/` |
| **TDD 步骤缺失** | OpenSpec 的 tasks 不包含 RED-GREEN-REFACTOR 步骤，Superpowers 强制要求 |
| **验证标准不同** | OpenSpec 有自己的 `/opsx:verify`，Superpowers 有 `verification-before-completion`，两者标准和流程不同 |

---

## 三、统一文档目录设计

### 设计原则

1. **尊重原版约定**：三个工具各自的文件路径不改——它们的 skill/workflow 硬编码了这些路径
2. **增加桥接层**：通过统一的 `docs/` 顶层目录做索引和路由
3. **不重复存储**：用引用（链接/指针）代替复制
4. **支持多工程**：每个子工程（Project）有自己的空间

### 统一目录结构

```
your-project/
│
├── docs/                               # ★ 统一文档入口 ★
│   ├── INDEX.md                        # 全局文档索引（自动生成/手动维护）
│   │
│   ├── global/                         # ═══ 全局文档（跨工程共享）═══
│   │   ├── PRD.md                      # → 来自 BMAD（symlink 或 copy from _bmad-output/）
│   │   ├── architecture.md             # → 来自 BMAD
│   │   ├── project-context.md          # → 来自 BMAD（项目"宪法"）
│   │   ├── glossary.md                 # 术语表（可选）
│   │   └── decisions/                  # 架构决策记录（ADR）
│   │       ├── 001-use-postgres.md
│   │       └── 002-use-rest-not-grpc.md
│   │
│   ├── projects/                       # ═══ 按工程/模块分区 ═══
│   │   ├── auth/
│   │   │   ├── README.md              # 模块概览
│   │   │   ├── epics/                 # → 来自 BMAD
│   │   │   │   └── epic-user-registration.md
│   │   │   └── stories/              # → 来自 BMAD
│   │   │       ├── story-email-register.md
│   │   │       └── story-oauth-login.md
│   │   ├── payments/
│   │   │   └── ...
│   │   └── ui/
│   │       └── ...
│   │
│   └── superpowers/                    # ═══ Superpowers 计划文件 ═══
│       └── plans/                      # → Superpowers 原版路径
│           ├── 2026-03-24-email-register-api.md
│           └── 2026-03-24-oauth-login.md
│
├── _bmad/                              # BMAD 框架配置（原版不动）
├── _bmad-output/                       # BMAD 产出（原版不动）
│   ├── planning-artifacts/
│   │   ├── PRD.md
│   │   ├── architecture.md
│   │   └── epics/
│   └── project-context.md
│
└── openspec/                           # OpenSpec 规范（原版不动）
    ├── specs/                          # 系统当前状态
    │   ├── auth/
    │   │   └── spec.md
    │   ├── payments/
    │   │   └── spec.md
    │   └── ui/
    │       └── spec.md
    ├── changes/                        # 活跃变更
    │   ├── add-email-register/
    │   │   ├── proposal.md
    │   │   ├── design.md
    │   │   ├── tasks.md
    │   │   └── specs/
    │   └── add-oauth-login/
    │       └── ...
    └── archive/                        # 已完成变更
```

### INDEX.md 的作用

`docs/INDEX.md` 是整个文档体系的"路由表"，任何 Agent（BMAD/OpenSpec/Superpowers）都可以通过读取它来快速定位需要的文件：

```markdown
# 项目文档索引

## 全局文档
- [PRD](./global/PRD.md) ← BMAD 产出
- [架构](./global/architecture.md) ← BMAD 产出
- [项目规则](./global/project-context.md) ← BMAD 产出，所有 Agent 共读

## 系统规范（Source of Truth）
- [Auth 规范](../openspec/specs/auth/spec.md) ← OpenSpec 维护
- [Payments 规范](../openspec/specs/payments/spec.md) ← OpenSpec 维护
- [UI 规范](../openspec/specs/ui/spec.md) ← OpenSpec 维护

## 活跃变更
- [添加邮箱注册](../openspec/changes/add-email-register/) ← OpenSpec 管理
  - 实施计划: [→ Superpowers Plan](./superpowers/plans/2026-03-24-email-register-api.md)

## 工程模块
- [Auth 模块](./projects/auth/README.md) — 2 Epics, 4 Stories
- [Payments 模块](./projects/payments/README.md) — 1 Epic, 3 Stories
```

---

## 四、交接机制：详细设计

### 交接 1：BMAD → OpenSpec

#### 触发时机

BMAD Phase 3（Solutioning）完成后，`bmad-check-implementation-readiness` 门控通过。

#### 交接流程

```
┌──────────────────────────────────────────────────────────────────────────┐
│ Step 1: BMAD 产出物归档到 docs/                                           │
│                                                                          │
│   _bmad-output/planning-artifacts/PRD.md                                 │
│       → 复制/链接到 docs/global/PRD.md                                    │
│   _bmad-output/planning-artifacts/architecture.md                        │
│       → 复制/链接到 docs/global/architecture.md                           │
│   _bmad-output/project-context.md                                        │
│       → 复制/链接到 docs/global/project-context.md                        │
│   _bmad-output/planning-artifacts/epics/                                 │
│       → 复制到 docs/projects/{module}/epics/                              │
│                                                                          │
│   ★ 这一步确保 BMAD 的产出物在文件系统中持久化，                              │
│     不再只存在于会话上下文中                                                │
└───────────────────────────────┬──────────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│ Step 2: 初始化 OpenSpec 的"系统基线"                                       │
│                                                                          │
│   根据 BMAD 的 architecture.md 和 PRD.md，                                │
│   为每个模块创建初始 openspec/specs/{module}/spec.md                       │
│                                                                          │
│   这是 OpenSpec 的前置条件——它需要一个"当前系统状态"基线                     │
│                                                                          │
│   ┌─── 新项目（Greenfield）───┐  ┌─── 已有项目（Brownfield）─────┐        │
│   │                            │  │                                │        │
│   │ 从 BMAD 的架构文档中       │  │ 运行 OpenSpec 的 /opsx:explore │        │
│   │ 提取各模块的行为规范，      │  │ 自动扫描代码库生成初始 spec    │        │
│   │ 生成初始 spec.md           │  │                                │        │
│   └────────────────────────────┘  └────────────────────────────────┘        │
│                                                                          │
│   示例：auth/spec.md                                                      │
│   ┌──────────────────────────────────────────┐                           │
│   │ # Auth Specification                      │                           │
│   │                                           │                           │
│   │ ## Purpose                                │                           │
│   │ 用户认证和会话管理。                         │                           │
│   │                                           │                           │
│   │ ## Requirements                           │                           │
│   │                                           │                           │
│   │ ### Requirement: Email Registration       │                           │
│   │ 系统 MUST 支持邮箱+密码注册。                │                           │
│   │                                           │                           │
│   │ #### Scenario: Valid Registration         │                           │
│   │ - GIVEN 用户输入有效邮箱和密码              │                           │
│   │ - WHEN 用户提交注册                        │                           │
│   │ - THEN 系统创建账号并返回认证令牌            │                           │
│   └──────────────────────────────────────────┘                           │
└───────────────────────────────┬──────────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│ Step 3: Story → OpenSpec Change 的"翻译"                                  │
│                                                                          │
│   BMAD Story 和 OpenSpec Change 是 多对多 关系：                           │
│                                                                          │
│   ┌─ Story: "用户可以注册" ─────────────────────────────────────────┐     │
│   │                                                                  │     │
│   │  拆分为：                                                         │     │
│   │                                                                  │     │
│   │  ┌─ OpenSpec Change: add-email-register ─┐                      │     │
│   │  │ /opsx:propose "添加邮箱注册 API"        │                      │     │
│   │  │   读取:                                │                      │     │
│   │  │     - docs/global/architecture.md      │                      │     │
│   │  │     - docs/global/project-context.md   │                      │     │
│   │  │     - docs/projects/auth/stories/...   │                      │     │
│   │  │     - openspec/specs/auth/spec.md      │                      │     │
│   │  │   产出:                                │                      │     │
│   │  │     - openspec/changes/add-email-register/ │                  │     │
│   │  │       ├── proposal.md                  │                      │     │
│   │  │       ├── design.md                    │                      │     │
│   │  │       ├── tasks.md                     │                      │     │
│   │  │       └── specs/auth/spec.md (Delta)   │                      │     │
│   │  └────────────────────────────────────────┘                      │     │
│   │                                                                  │     │
│   │  ┌─ OpenSpec Change: add-register-ui ────┐                      │     │
│   │  │ /opsx:propose "添加注册页面 UI"         │                      │     │
│   │  │   ...                                  │                      │     │
│   │  └────────────────────────────────────────┘                      │     │
│   └──────────────────────────────────────────────────────────────────┘     │
│                                                                          │
│   ★ 关键：每个 /opsx:propose 必须显式引用 BMAD 的相关文档作为输入            │
│     在 proposal.md 的头部加上：                                            │
│     > Source: docs/projects/auth/stories/story-email-register.md          │
│     > Architecture: docs/global/architecture.md                           │
│     > Context: docs/global/project-context.md                             │
└──────────────────────────────────────────────────────────────────────────┘
```

#### 交接检查清单

| # | 检查项 | 说明 |
|---|---|---|
| 1 | BMAD 产出物已持久化 | docs/global/ 和 docs/projects/ 下有对应文件 |
| 2 | OpenSpec specs/ 基线已建立 | 每个模块有初始 spec.md |
| 3 | Story → Change 映射已明确 | 每个 Story 知道对应哪些 OpenSpec Change |
| 4 | proposal.md 引用了 BMAD 文档 | 可追溯到原始需求 |
| 5 | project-context.md 已同步 | OpenSpec 能读到项目规则 |

---

### 交接 2：OpenSpec → Superpowers

#### 触发时机

OpenSpec 的 `tasks.md` 完成后，准备进入代码实现。

#### 交接流程

```
┌──────────────────────────────────────────────────────────────────────────┐
│ Step 1: 从 OpenSpec tasks.md 生成 Superpowers Plan                       │
│                                                                          │
│   OpenSpec 的 tasks.md：                                                  │
│   ┌──────────────────────────────────────────┐                           │
│   │ # Tasks: add-email-register              │                           │
│   │                                          │                           │
│   │ ## Task 1: Create user model             │                           │
│   │ - Create User entity with fields:        │                           │
│   │   email, password_hash, created_at       │                           │
│   │ - Add database migration                 │                           │
│   │                                          │                           │
│   │ ## Task 2: Implement registration API    │                           │
│   │ - POST /api/auth/register                │                           │
│   │ - Validate email format and uniqueness   │                           │
│   │ - Hash password with bcrypt              │                           │
│   │ - Return JWT token                       │                           │
│   │                                          │                           │
│   │ ## Task 3: Add input validation          │                           │
│   │ - Email format validation                │                           │
│   │ - Password strength requirements         │                           │
│   └──────────────────────────────────────────┘                           │
│                                                                          │
│                    ↓ Superpowers writing-plans skill 翻译 ↓               │
│                                                                          │
│   Superpowers Plan (docs/superpowers/plans/2026-03-24-email-register.md)  │
│   ┌──────────────────────────────────────────────────────────────────┐   │
│   │ # Email Registration API Implementation Plan                     │   │
│   │                                                                  │   │
│   │ > **Source**: openspec/changes/add-email-register/tasks.md       │   │
│   │ > **Spec**: openspec/specs/auth/spec.md                         │   │
│   │ > **Design**: openspec/changes/add-email-register/design.md     │   │
│   │                                                                  │   │
│   │ **Goal:** Implement email registration with JWT auth             │   │
│   │ **Architecture:** RESTful API with PostgreSQL + bcrypt           │   │
│   │ **Tech Stack:** Node.js, Express, Prisma, bcrypt, jsonwebtoken  │   │
│   │                                                                  │   │
│   │ ### Task 1: Create User Model                                    │   │
│   │ **Files:**                                                       │   │
│   │ - Create: `prisma/migrations/xxx/migration.sql`                 │   │
│   │ - Create: `src/models/user.ts`                                   │   │
│   │ - Test: `tests/models/user.test.ts`                              │   │
│   │                                                                  │   │
│   │ - [ ] Step 1: Write failing test                                 │   │
│   │   ```typescript                                                  │   │
│   │   describe('User model', () => {                                 │   │
│   │     it('should create user with valid email', async () => {      │   │
│   │       const user = await createUser({                            │   │
│   │         email: 'test@example.com', password: 'Str0ng!' });       │   │
│   │       expect(user.id).toBeDefined();                             │   │
│   │     });                                                          │   │
│   │   });                                                            │   │
│   │   ```                                                            │   │
│   │ - [ ] Step 2: Run test to verify FAIL                            │   │
│   │   Run: `npx vitest tests/models/user.test.ts`                    │   │
│   │   Expected: FAIL "createUser is not defined"                     │   │
│   │ - [ ] Step 3: Implement minimal code...                          │   │
│   │ - [ ] Step 4: Run test to verify PASS...                         │   │
│   │ - [ ] Step 5: Commit...                                          │   │
│   │                                                                  │   │
│   │ ### Task 2: Registration API Endpoint                            │   │
│   │ ...                                                              │   │
│   └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│   ★ 关键：Plan 文件头部必须引用 OpenSpec 的源文件                            │
│     这样 Superpowers 执行时可以回查规范                                     │
└───────────────────────────────┬──────────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│ Step 2: Superpowers 执行 + 回写验证                                        │
│                                                                          │
│   Superpowers 执行计划时：                                                 │
│                                                                          │
│   1. using-git-worktrees → 创建隔离工作空间                               │
│   2. 按 Plan 中的 Task 逐一执行：                                         │
│      - test-driven-development: RED → GREEN → REFACTOR                   │
│      - 每个 Task 完成后 commit                                            │
│   3. subagent-driven-development（如支持子代理）：                          │
│      - Implementer 写代码                                                 │
│      - Spec Reviewer 对照 openspec/specs/ 和 Delta Specs 检查             │
│      - Code Quality Reviewer 检查代码质量                                  │
│   4. verification-before-completion:                                      │
│      - 跑测试套件，贴证据                                                  │
│      - 对照 OpenSpec spec.md 中的 Scenario 验证行为                        │
│                                                                          │
│   ★ Spec Reviewer 的回查路径：                                             │
│     Plan 头部 → Source: openspec/changes/xxx/tasks.md                     │
│              → Spec: openspec/specs/auth/spec.md                         │
│              → Design: openspec/changes/xxx/design.md                    │
│     三个文件提供了完整的"验收标准"                                           │
└───────────────────────────────┬──────────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│ Step 3: 完成后回流到 OpenSpec                                              │
│                                                                          │
│   代码实现完成并通过所有验证后：                                             │
│                                                                          │
│   1. /opsx:verify                                                        │
│      → 检查实现是否符合 proposal + design + tasks + specs                  │
│      → 三维验证：完整性 + 正确性 + 连贯性                                   │
│                                                                          │
│   2. /opsx:archive                                                       │
│      → 将 Delta Specs 合并到 openspec/specs/ 主分支                       │
│      → 变更文件夹移到 openspec/changes/archive/                            │
│      → 系统 Spec 更新为最新状态                                            │
│                                                                          │
│   3. 更新 docs/INDEX.md                                                   │
│      → 活跃变更移出，归档变更归入历史                                       │
│                                                                          │
│   ★ 归档后 openspec/specs/ 反映系统最新状态，                               │
│     下一轮 BMAD 的 Story 可以基于最新 Spec 工作                             │
└──────────────────────────────────────────────────────────────────────────┘
```

#### 交接检查清单

| # | 检查项 | 说明 |
|---|---|---|
| 1 | Plan 文件已生成 | `docs/superpowers/plans/` 下有对应文件 |
| 2 | Plan 引用了 OpenSpec 源文件 | 头部有 Source/Spec/Design 引用 |
| 3 | Plan 包含 TDD 步骤 | 每个 Task 有 RED-GREEN-REFACTOR 步骤 |
| 4 | Plan 包含精确文件路径 | 不是"创建 auth 模块"，而是 `src/models/user.ts` |
| 5 | Plan 包含验证命令 | 有具体的测试命令和期望输出 |

---

## 五、完整数据流：从 BMAD 到归档

```
时间线 ──────────────────────────────────────────────────────────────────→

┌─────────┐     ┌───────────┐     ┌──────────────┐     ┌────────────┐
│  BMAD   │     │ 交接桥接    │     │   OpenSpec    │     │   交接桥接   │
│ Phase   │ ──→ │  BMAD →    │ ──→ │   Phase      │ ──→ │ OpenSpec → │
│  1-3    │     │  OpenSpec  │     │              │     │ Superpowers│
└─────────┘     └───────────┘     └──────────────┘     └────────────┘
    │                │                   │                    │
    ▼                ▼                   ▼                    ▼
                                                        ┌────────────┐
                                                        │Superpowers │
                                                        │  执行       │
                                                        └──────┬─────┘
                                                               │
文件系统变化：                                                    ▼
                                                        ┌────────────┐
(1) BMAD 写入:                                           │ /opsx:     │
  _bmad-output/PRD.md                                   │ verify +   │
  _bmad-output/architecture.md                          │ archive    │
  _bmad-output/epics/                                   └──────┬─────┘
                                                               │
(2) 桥接写入:                                                    ▼
  docs/global/PRD.md                                   openspec/specs/
  docs/global/architecture.md                          已更新为最新状态
  docs/projects/{module}/epics/
  docs/projects/{module}/stories/
  openspec/specs/{module}/spec.md (初始基线)
  
(3) OpenSpec 写入:
  openspec/changes/{change-name}/
    proposal.md + design.md + tasks.md + specs/

(4) 桥接写入:
  docs/superpowers/plans/{date}-{feature}.md

(5) Superpowers 写入:
  代码文件 + 测试文件 + Git 提交

(6) 回流:
  openspec/specs/ 更新
  openspec/changes/archive/ 归档
  docs/INDEX.md 更新
```

---

## 六、多工程场景下的文档组织

当项目拆分为多个 Project（如前端、后端、微服务）时：

### 方案 A：单仓多模块（Monorepo）

```
monorepo/
├── docs/                              # 统一文档入口
│   ├── INDEX.md
│   ├── global/                        # 全局文档
│   │   ├── PRD.md
│   │   ├── architecture.md
│   │   └── project-context.md
│   ├── projects/
│   │   ├── frontend/                  # 前端模块
│   │   │   ├── README.md
│   │   │   ├── epics/
│   │   │   └── stories/
│   │   ├── backend-api/               # 后端 API 模块
│   │   │   └── ...
│   │   └── shared-lib/                # 公共库
│   │       └── ...
│   └── superpowers/
│       └── plans/
│           ├── 2026-03-24-fe-login-page.md
│           └── 2026-03-24-be-auth-api.md
│
├── _bmad/
├── _bmad-output/
│
├── openspec/
│   ├── specs/
│   │   ├── frontend/
│   │   │   ├── auth-ui/
│   │   │   │   └── spec.md
│   │   │   └── dashboard/
│   │   │       └── spec.md
│   │   └── backend/
│   │       ├── auth-api/
│   │       │   └── spec.md
│   │       └── payment-api/
│   │           └── spec.md
│   └── changes/
│       ├── fe-login-redesign/
│       └── be-add-oauth/
│
├── packages/
│   ├── frontend/
│   └── backend/
└── ...
```

### 方案 B：多仓多工程

每个仓库独立管理自己的 docs/ + openspec/，但通过一个**元仓库**（meta-repo）维护全局文档：

```
meta-repo/                              # 元仓库
├── docs/
│   ├── INDEX.md                        # 全局索引
│   ├── global/
│   │   ├── PRD.md
│   │   ├── architecture.md
│   │   └── project-context.md
│   └── projects/
│       ├── frontend/
│       │   └── README.md              # 指向 frontend-repo 的文档
│       └── backend/
│           └── README.md              # 指向 backend-repo 的文档

frontend-repo/                          # 前端仓库
├── docs/
│   ├── local-context.md               # 前端特有的规则
│   └── superpowers/
│       └── plans/
├── openspec/
│   ├── specs/
│   └── changes/
└── src/

backend-repo/                           # 后端仓库
├── docs/
│   ├── local-context.md
│   └── superpowers/
│       └── plans/
├── openspec/
│   ├── specs/
│   └── changes/
└── src/
```

---

## 七、关键设计决策 FAQ

### Q1: 为什么不把 `_bmad-output/` 和 `openspec/` 都放到 `docs/` 下？

**不推荐**。原因：

1. **BMAD 和 OpenSpec 的 skill/workflow 硬编码了文件路径**——BMAD 的所有 skill 搜索 `_bmad-output/`，OpenSpec 搜索 `openspec/`。改路径意味着要 fork 并修改工具源码。
2. **职责不同**：`_bmad-output/` 是框架管理的产出物（BMAD 读写），`openspec/` 是规范管理的核心数据（OpenSpec 读写），`docs/` 是面向人类和跨工具的索引层。
3. **三个目录不是竞争关系而是协作关系**——各管各的，通过 `docs/INDEX.md` 做路由。

### Q2: `docs/global/PRD.md` 和 `_bmad-output/PRD.md` 是否重复？

两种策略：

| 策略 | 说明 | 适用场景 |
|---|---|---|
| **Symlink** | `docs/global/PRD.md` → `../_bmad-output/planning-artifacts/PRD.md` | 单机开发/Linux/macOS |
| **Copy + Version** | BMAD 产出后复制到 `docs/global/`，在文件头加 `> Synced from _bmad-output/ at 2026-03-24` | 跨平台/Windows/团队协作 |

推荐 **Copy + Version**——更稳定，Windows 对 symlink 支持不佳。

### Q3: OpenSpec 的 `openspec/specs/` 和 BMAD 的 `architecture.md` 什么关系？

| 文档 | 管理者 | 粒度 | 用途 |
|---|---|---|---|
| `architecture.md` | BMAD | **宏观**——技术选型、分层、部署拓扑 | 指导架构决策 |
| `openspec/specs/` | OpenSpec | **微观**——每个模块的行为契约（Given/When/Then） | 指导代码实现和验证 |

两者互补而非替代：`architecture.md` 告诉你"用 PostgreSQL + Express"，`specs/` 告诉你"注册 API 在邮箱已存在时 MUST 返回 409"。

### Q4: Superpowers 的 Plan 和 OpenSpec 的 tasks.md 什么关系？

| 文档 | 粒度 | 内容 |
|---|---|---|
| `tasks.md` | **逻辑任务**——"创建用户模型" | 不含代码、不含文件路径、不含测试步骤 |
| `plans/{date}-{name}.md` | **原子操作**——每步 2-5 分钟 | 精确到文件路径、代码片段、测试命令、预期输出 |

**关系**：Plan 是 tasks.md 的"细化展开"。tasks.md 中的一个 Task 可能展开为 Plan 中的 5-10 个 Steps。

### Q5: 谁负责维护 `docs/INDEX.md`？

理想状态是**自动化**——在每个阶段完成时由脚本或 Agent 自动更新。实际操作中：

1. BMAD 完成后 → Agent 更新 INDEX.md 的"全局文档"和"工程模块"部分
2. OpenSpec propose 后 → Agent 更新 INDEX.md 的"活跃变更"部分
3. OpenSpec archive 后 → Agent 将变更从"活跃"移到"历史"部分

---

## 八、总结：三层交接的关键原则

| 原则 | 说明 |
|---|---|
| **文件即接口** | 三个工具之间的交接通过文件系统实现，不依赖内存/会话 |
| **引用而非复制** | Plan 引用 OpenSpec 文件，OpenSpec 引用 BMAD 文件——保持单一信息源 |
| **显式溯源** | 每个产出文件头部必须标注来源——proposal 标注 Story，Plan 标注 tasks.md |
| **原版路径不动** | `_bmad-output/`、`openspec/`、`docs/superpowers/plans/` 各保原位 |
| **docs/ 是索引层** | docs/ 不是存储层，是路由层——帮助 Agent 和人类快速找到文件 |
| **Spec 是最终裁判** | 所有实现最终要对照 `openspec/specs/` 验收，不是对照 BMAD 的 Story |
