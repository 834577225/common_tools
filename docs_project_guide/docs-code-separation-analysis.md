# 文档工程与代码工程分离：可行性分析与方案设计

> 基于前一版 [交接机制与统一文档目录设计](./handoff-and-docs-structure.md) 方案，分析文档仓库与代码仓库分离的可行性、影响和规避方法。

---

## 一、结论先行

**合适，但有明确的前提条件和改造成本。**

文档工程与代码工程分离在软件工程中是成熟实践（monorepo vs polyrepo 中的 "docs repo" 模式），但 BMAD + OpenSpec + Superpowers 这套工具链对"文档与代码同仓"有**隐含假设**。分离可行，但需要在 Agent 配置和工作流交接上做针对性适配。

下面逐层拆解。

---

## 二、三个工具对"同仓"的依赖分析

### 2.1 BMAD：弱依赖 → 可分离

| 依赖项 | 说明 | 分离影响 |
|---|---|---|
| `_bmad/` 框架目录 | 存放 agents/skills/workflows 配置 | 可以放在文档工程中——BMAD 做需求分析时不需要跑代码 |
| `_bmad-output/` 产出目录 | PRD、架构、Epic/Story | 天然属于文档——可以放文档工程 |
| `project-context.md` | 项目"宪法"（技术栈、代码规则） | ⚠️ **需要双向可见**——BMAD 写它，Dev skill 在代码工程中读它 |
| `bmad-dev-story` skill | 直接操作代码文件 | ⚠️ **必须在代码工程目录下执行** |

**结论**：BMAD 的分析阶段（Phase 1-3：Discovery → Requirements → Solutioning）可以完全在文档工程中完成。但开发阶段（Phase 4：Implementation）的 Dev skill **必须运行在代码工程目录下**。

### 2.2 OpenSpec：强依赖 → 可分离但需改造

| 依赖项 | 说明 | 分离影响 |
|---|---|---|
| `openspec/specs/` | 系统行为基线（Source of Truth） | 描述的是代码的行为，但本质是文档——**可以放文档工程** |
| `openspec/changes/` | 活跃变更管理 | 同上，proposal/design/tasks 都是文档 |
| `/opsx:propose` | 基于代码库扫描生成提案 | ⚠️ **可能需要读代码**——特别是 brownfield 项目的 explore 阶段 |
| `/opsx:apply` | 根据 tasks.md 修改源代码 | ⚠️ **必须在代码工程目录下执行** |
| `/opsx:verify` | 验证实现是否符合 spec | ⚠️ **需要同时读 spec（文档工程）和代码（代码工程）** |

**结论**：OpenSpec 的**规范定义阶段**（propose → design → tasks）可以在文档工程中完成。但**应用阶段**（apply）和**验证阶段**（verify）需要同时访问两个工程。

### 2.3 Superpowers：强依赖 → 分离成本最高

| 依赖项 | 说明 | 分离影响 |
|---|---|---|
| `docs/superpowers/plans/` | 实施计划文件 | ⚠️ **writing-plans 需要读代码库**来生成精确文件路径 |
| `using-git-worktrees` | 创建隔离工作空间 | ⚠️ **基于代码仓库的 git worktree**——文档仓库用不上 |
| `executing-plans` | 执行计划、操作代码 | ⚠️ **必须在代码工程目录下执行** |
| TDD 步骤 | 运行测试命令 | ⚠️ **测试在代码工程中** |

**结论**：Superpowers 几乎完全是代码侧工具。Plan 文件虽然是 Markdown，但它**引用代码工程的文件路径**、**包含代码工程的测试命令**——放在文档工程中反而导致路径错位。

### 2.4 综合依赖矩阵

```
                      文档工程              代码工程
                    (docs-repo)          (code-repo)
                  ─────────────        ──────────────
BMAD Phase 1-3    ✅ 完全可以             ❌ 不需要
BMAD Phase 4      ❌ 不够（缺代码）        ✅ 必须在这里
                  ─────────────        ──────────────
OpenSpec propose  ✅ 可以（greenfield）    ⚠️ 需要（brownfield 需读码）
OpenSpec apply    ❌ 不够                 ✅ 必须在这里
OpenSpec verify   ⚠️ 需要（读 spec）       ✅ 必须在这里
                  ─────────────        ──────────────
Superpowers write ⚠️ 输入来自这里          ✅ 必须在这里（读码生成计划）
Superpowers exec  ❌ 不够                 ✅ 必须在这里
                  ─────────────        ──────────────
```

---

## 三、分离方案设计

### 3.1 工程拓扑

```
workspace/                              # 本地工作空间（或 CI 环境）
│
├── project-docs/                       # ★ 文档工程 ★ (独立 Git 仓库)
│   │
│   ├── .git/
│   ├── _bmad/                          # BMAD 框架配置
│   ├── _bmad-output/                   # BMAD 产出物
│   │   ├── planning-artifacts/
│   │   │   ├── PRD.md
│   │   │   ├── architecture.md
│   │   │   └── epics/
│   │   └── project-context.md          # ← 项目"宪法"（需同步到代码工程）
│   │
│   ├── docs/                           # 统一文档入口
│   │   ├── INDEX.md                    # 全局路由表
│   │   ├── global/                     # 全局文档
│   │   │   ├── PRD.md
│   │   │   ├── architecture.md
│   │   │   └── project-context.md
│   │   └── projects/                   # 按模块分区
│   │       ├── auth/
│   │       │   ├── epics/
│   │       │   └── stories/
│   │       └── payments/
│   │
│   └── openspec/                       # OpenSpec 规范
│       ├── specs/                      # 系统行为基线
│       │   ├── auth/spec.md
│       │   └── payments/spec.md
│       ├── changes/                    # 活跃变更
│       │   └── add-email-register/
│       │       ├── proposal.md
│       │       ├── design.md
│       │       ├── tasks.md
│       │       └── specs/
│       └── archive/                    # 已完成变更
│
└── project-code/                       # ★ 代码工程 ★ (独立 Git 仓库)
    │
    ├── .git/
    ├── .project-context.md             # ← 从文档工程同步的项目"宪法"（只读副本）
    │
    ├── docs/                           # 代码侧文档（仅存放代码相关的）
    │   └── superpowers/
    │       └── plans/                  # Superpowers 计划文件
    │           └── 2026-03-24-email-register.md
    │
    ├── src/                            # 源代码
    ├── tests/                          # 测试
    ├── package.json
    └── ...
```

### 3.2 核心设计决策

| 决策 | 选择 | 理由 |
|---|---|---|
| BMAD 配置和产出放哪 | **文档工程** | BMAD 的分析阶段不需要代码，产出物是文档 |
| OpenSpec 放哪 | **文档工程** | specs/ 是行为契约文档，不是代码 |
| Superpowers plans/ 放哪 | **代码工程** | Plan 引用的是代码工程的文件路径（如 `src/models/user.ts`） |
| project-context.md 放哪 | **文档工程为主，代码工程保留只读副本** | BMAD 写入在文档工程，代码工程的 dev/qa skill 需要读取 |
| `docs/INDEX.md` 放哪 | **文档工程** | 它是全局路由表，跨两个工程的索引 |

### 3.3 为什么 Superpowers plans/ 必须放代码工程

这是最关键的设计决策，值得展开说明：

```
Plan 文件内容示例：

  ### Task 1: Create User Model
  **Files:**
  - Create: `src/models/user.ts`        ← 代码工程的路径
  - Create: `prisma/migrations/xxx/`     ← 代码工程的路径
  - Test: `tests/models/user.test.ts`    ← 代码工程的路径

  - [ ] Step 1: Write failing test
    Run: `npx vitest tests/models/user.test.ts`  ← 代码工程的命令
    Expected: FAIL "createUser is not defined"
```

Plan 文件中的每一个路径、每一条命令都是**相对于代码工程根目录**的。如果 Plan 放在文档工程，Agent 执行计划时需要做路径转换——这不仅增加出错概率，还破坏了 Superpowers 的核心假设（"计划和代码在同一目录下"）。

此外，Superpowers 的 `using-git-worktrees` 会基于**代码仓库**创建 worktree，Plan 文件如果不在代码仓库中，worktree 里就没有它。

---

## 四、分离后的工作流变化

### 4.1 完整开发流程中的工程切换

```
阶段                    活跃工程              操作
─────────────────────  ──────────          ────────────────────────────
BMAD Phase 1-3          文档工程             产出 PRD/架构/Epic/Story
  Discovery
  Requirements
  Solutioning
                           │
                           ▼ 同步 project-context.md 到代码工程
                           │
BMAD→OpenSpec 交接          文档工程             持久化到 docs/，初始化 specs/
                           │
OpenSpec propose/design    文档工程             生成 proposal/design/tasks
                           │
                           ▼ Agent 切换到代码工程
                           │
OpenSpec apply 前准备       代码工程             读取文档工程的 tasks.md
                           │
Superpowers write-plan     代码工程             读代码库 + 读文档工程的 tasks.md/spec.md
                           │                    → 生成 plan 到 code-repo/docs/superpowers/plans/
                           │
Superpowers execute-plan   代码工程             在 git worktree 中执行
                           │
OpenSpec verify             代码工程            读文档工程的 spec.md，对照代码验证
                           │
                           ▼ Agent 切换回文档工程
                           │
OpenSpec archive            文档工程             归档变更，更新 specs/，更新 INDEX.md
```

### 4.2 关键观察

1. **有两次"跨工程"操作**：
   - Superpowers `writing-plans`：在代码工程中执行，但需要读文档工程的 `openspec/changes/xxx/tasks.md` + `design.md` + `spec.md`
   - OpenSpec `verify`：在代码工程中执行，但需要读文档工程的 `openspec/specs/`

2. **有两次"工程切换"**：
   - 从文档工程切到代码工程（进入实施阶段）
   - 从代码工程切回文档工程（归档阶段）

---

## 五、影响分析与规避方案

### 5.1 影响 ①：Agent 的工作目录上下文

**问题**：WorkBuddy（或其他 AI Agent）每次只能以一个目录作为"工作空间"。文档和代码分两个仓库后，Agent 不能同时"看到"两边的文件。

**规避方案**：

#### 方案 A：双目录打开（推荐）

WorkBuddy 支持多文件夹工作空间。在 VS Code / WorkBuddy 中同时打开两个文件夹：

```jsonc
// workspace.code-workspace
{
  "folders": [
    { "path": "./project-docs", "name": "📄 文档工程" },
    { "path": "./project-code", "name": "💻 代码工程" }
  ]
}
```

**优点**：Agent 可以同时访问两个工程的文件，路径通过 `project-docs/openspec/...` 和 `project-code/src/...` 区分。
**缺点**：路径前缀变长；三个工具的默认路径假设（从根目录开始）需要适配。

#### 方案 B：符号链接桥接

在代码工程中创建符号链接指向文档工程的关键目录：

```powershell
# Windows (需管理员权限)
mklink /D "C:\project-code\openspec" "C:\project-docs\openspec"
mklink /D "C:\project-code\_bmad-output" "C:\project-docs\_bmad-output"

# macOS/Linux
ln -s ../project-docs/openspec project-code/openspec
ln -s ../project-docs/_bmad-output project-code/_bmad-output
```

**优点**：对工具完全透明——OpenSpec 在代码工程目录下也能找到 `openspec/`。
**缺点**：Windows 符号链接需要管理员权限或开发者模式；Git 对符号链接支持有限（`.gitignore` 需排除）；CI/CD 环境需特殊处理。

#### 方案 C：构建时同步脚本

用一个简单脚本在关键节点将文档工程的文件同步到代码工程的临时目录：

```powershell
# sync-docs.ps1 — 从文档工程同步关键文件到代码工程
param(
    [string]$DocsDir = "..\project-docs",
    [string]$CodeDir = "."
)

# 同步 project-context.md（代码侧需要的核心文件）
Copy-Item "$DocsDir\_bmad-output\project-context.md" "$CodeDir\.project-context.md" -Force

# 同步 openspec specs（verify 阶段需要）
robocopy "$DocsDir\openspec\specs" "$CodeDir\.openspec-mirror\specs" /MIR /NJH /NJS

# 同步当前活跃变更（writing-plans 阶段需要）
robocopy "$DocsDir\openspec\changes" "$CodeDir\.openspec-mirror\changes" /MIR /NJH /NJS /XD archive
```

代码工程的 `.gitignore` 中排除这些镜像文件：

```gitignore
# 从文档工程同步的镜像文件（不纳入代码仓库版本管理）
.project-context.md
.openspec-mirror/
```

**优点**：不需要符号链接，跨平台；Git 干净。
**缺点**：需要记住在关键节点运行同步脚本（可自动化）。

**推荐**：小团队/个人用 **方案 A**（最简单），团队协作用 **方案 C**（最稳定）。

---

### 5.2 影响 ②：Superpowers Git Worktree 隔离

**问题**：Superpowers 的 `using-git-worktrees` 基于代码仓库创建 worktree。worktree 是代码仓库的"分身"，不包含文档仓库的文件。在 worktree 中执行计划时，Agent 无法直接访问文档工程的 openspec/ 目录。

**规避方案**：

在 Superpowers Plan 文件头部**内联**必要的验收标准（从 OpenSpec spec 中提取），而不是运行时去文档工程读取：

```markdown
# Email Registration API - Implementation Plan

> **Source Change**: openspec/changes/add-email-register/
> **Design**: (see below)
>
> ## Acceptance Criteria (from spec)
> - GIVEN valid email and password WHEN register THEN return JWT + 201
> - GIVEN duplicate email WHEN register THEN return 409
> - GIVEN invalid email format WHEN register THEN return 400
>
> ## Design Summary (from design.md)
> - POST /api/auth/register
> - bcrypt for password hashing
> - JWT for token generation
```

这样 Plan 文件是**自包含的**——在 worktree 中执行时不需要跨仓读取。

---

### 5.3 影响 ③：OpenSpec `/opsx:verify` 跨仓验证

**问题**：verify 需要同时读 spec（文档工程）和代码（代码工程），分仓后 Agent 在代码工程中跑 verify 时看不到 spec。

**规避方案**：

有三种策略（按推荐顺序）：

| 策略 | 操作 | 适用场景 |
|---|---|---|
| **内联验收标准** | Plan 头部已包含 spec 摘要，verify 用它即可 | 小变更，spec 简单 |
| **同步脚本** | verify 前运行 `sync-docs.ps1`，将 spec 镜像到代码工程 | 大变更，需要完整 spec |
| **双工程打开** | Agent 通过 workspace 同时访问两个工程 | 交互式开发 |

---

### 5.4 影响 ④：OpenSpec `/opsx:apply` 的代码操作

**问题**：`/opsx:apply` 需要在代码工程中执行（它会修改源代码），但 `openspec/changes/xxx/tasks.md` 在文档工程中。

**规避方案**：

这其实不是问题——因为在我们的交接方案中，`/opsx:apply` 已经被 Superpowers 替代了：

```
原版 OpenSpec 流程：  propose → design → tasks → /opsx:apply（直接改代码）
我们的流程：         propose → design → tasks → Superpowers write-plan → execute-plan
```

`/opsx:apply` 被 Superpowers 的计划执行替代，Agent 在代码工程中读取 Plan 文件（已在代码工程的 `docs/superpowers/plans/` 下），不需要跨仓。

---

### 5.5 影响 ⑤：project-context.md 的同步

**问题**：`project-context.md` 是 BMAD 在文档工程中生成的"项目宪法"，但代码工程中的 Dev skill、QA skill、Code Review skill 都需要读取它来了解技术栈和代码规则。

**规避方案**：

在代码工程根目录保留一个**只读副本**，通过以下方式保持同步：

```
文档工程                               代码工程
_bmad-output/project-context.md  ──→  .project-context.md（只读副本）
                                      或
                                      docs/project-context.md（只读副本）
```

同步时机和方式：

| 方式 | 说明 | 推荐场景 |
|---|---|---|
| **手动复制** | BMAD 阶段完成后手动 copy | 个人项目 |
| **同步脚本** | `sync-docs.ps1` 中包含 | 团队协作 |
| **Git submodule** | 代码仓库把文档仓库作为 submodule | 企业级项目 |
| **CI/CD 管道** | PR 合并时自动同步 | 自动化要求高的项目 |

BMAD 的 Dev skill 默认搜索 `**/project-context.md`，所以只要代码工程中有这个文件（任何位置），它就能找到。

---

### 5.6 影响 ⑥：`docs/INDEX.md` 的跨仓引用

**问题**：`docs/INDEX.md` 在文档工程中，需要引用代码工程中的 Superpowers Plan 文件——但两者不在同一仓库。

**规避方案**：

`INDEX.md` 中对 Superpowers Plan 的引用改为**标注性引用**（不是文件链接，而是信息说明）：

```markdown
## 活跃变更

### add-email-register
- 提案: [proposal.md](./openspec/changes/add-email-register/proposal.md)
- 设计: [design.md](./openspec/changes/add-email-register/design.md)
- 任务: [tasks.md](./openspec/changes/add-email-register/tasks.md)
- 实施计划: `[代码工程] docs/superpowers/plans/2026-03-24-email-register.md`
  └─ 状态: 执行中 | 分支: feature/email-register
```

用 `[代码工程]` 前缀标注，告诉读者这个文件在另一个仓库中。这比死链接更有用。

---

## 六、两个工程的设置影响

### 6.1 文档工程的设置

```yaml
# 文档工程需要的设置

Git 配置:
  - 正常的 Git 仓库，无特殊要求
  - 不需要 .gitignore 排除代码文件（因为没有代码）

WorkBuddy/Agent 配置:
  - 工作目录指向文档工程根目录
  - BMAD 的 _bmad/ 和 _bmad-output/ 在此
  - OpenSpec 的 openspec/ 在此

BMAD 配置:
  - 无变化——_bmad/ 和 _bmad-output/ 原版路径不动
  - bmad-init 在文档工程中执行

OpenSpec 配置:
  - 无变化——openspec/ 原版路径不动
  - openspec init 在文档工程中执行
  - /opsx:propose 和 /opsx:archive 在此执行

Superpowers 配置:
  - ❌ 不在文档工程中安装/使用 Superpowers
  - Superpowers 完全在代码工程中运行
```

### 6.2 代码工程的设置

```yaml
# 代码工程需要的设置

Git 配置:
  - 正常的 Git 仓库
  - .gitignore 中排除同步文件:
    .project-context.md
    .openspec-mirror/

WorkBuddy/Agent 配置:
  - 工作目录指向代码工程根目录
  - Superpowers 在此运行

BMAD 配置（部分）:
  - ❌ 不需要 _bmad/ 框架目录
  - ❌ 不需要 _bmad-output/ 产出目录
  - ✅ 需要 .project-context.md（只读副本）
  - ✅ 如果使用 BMAD 的 Dev/QA skill，它们在此运行

OpenSpec 配置（部分）:
  - ❌ 不需要完整的 openspec/ 目录
  - ✅ 如使用方案 C（同步脚本），需要 .openspec-mirror/（只读副本）
  - ✅ /opsx:verify 可在此执行（读 mirror 或内联的验收标准）

Superpowers 配置:
  - ✅ docs/superpowers/plans/ 在此（原版路径不动）
  - ✅ using-git-worktrees 基于此仓库创建 worktree
  - ✅ writing-plans 和 executing-plans 在此运行
```

### 6.3 设置对比汇总

```
                          文档工程              代码工程
                        ─────────            ──────────
BMAD 框架 (_bmad/)        ✅ 主仓               ❌ 不需要
BMAD 产出                 ✅ 主仓               ⚡ 只读副本 (.project-context.md)
OpenSpec                  ✅ 主仓               ⚡ 只读镜像 (可选)
Superpowers               ❌ 不需要              ✅ 主仓
docs/INDEX.md             ✅ 主仓               ❌ 不需要
源代码                     ❌ 不需要              ✅ 主仓
测试                       ❌ 不需要              ✅ 主仓
```

---

## 七、如果不分离会怎样（对比参考）

为了公平起见，列出不分离的优劣：

### 优点（不分离）

| 优点 | 说明 |
|---|---|
| **零适配成本** | 三个工具的原版路径全部生效，不需要同步脚本 |
| **Agent 无需切换** | 工作目录始终是项目根目录 |
| **Git worktree 天然包含文档** | Plan 和 Spec 和代码在同一个 worktree 中 |
| **引用路径简单** | INDEX.md 可以直接链接到所有文件 |

### 缺点（不分离）

| 缺点 | 说明 |
|---|---|
| **仓库臃肿** | 代码仓库中混入大量文档文件，Git 历史混杂 |
| **权限不独立** | 文档和代码使用同一 Git 权限——可能不适合需求分析人员只看文档的场景 |
| **CI/CD 互相干扰** | 文档变更触发代码 CI，代码变更触发文档构建 |
| **文档版本节奏不同** | 文档可能需要独立的版本号、发布周期 |

---

## 八、分离 vs 不分离：决策矩阵

| 场景特征 | 推荐方案 | 理由 |
|---|---|---|
| 个人项目 / 小团队 | **不分离** | 简单即正义，三个工具开箱即用 |
| 团队 > 5人，有专职 PM/BA | **分离** | PM 只需访问文档工程，开发人员只需代码工程 |
| 多个代码仓库共享同一份 PRD/架构 | **分离** | 文档工程是共享的"元仓库"，多个代码仓库引用它 |
| 文档需要独立审批/版本管理 | **分离** | 文档和代码的 review 流程、发布节奏不同 |
| 代码仓库已存在且较大 | **分离** | 避免往已有仓库中塞入 BMAD/OpenSpec 目录 |
| 新项目从零开始 | **不分离** | 先在一个仓库中跑通全流程，后续按需分离 |

---

## 九、分离操作清单（如果决定分离）

### Step 1: 初始化文档工程

```powershell
mkdir project-docs
cd project-docs
git init

# BMAD 初始化
# （假设 BMAD 已安装为 skill）
# 运行 bmad-init，产出物写入 _bmad-output/

# OpenSpec 初始化
# openspec init

# 创建统一文档目录
mkdir -p docs/global docs/projects
```

### Step 2: 配置代码工程

```powershell
cd project-code

# 创建 Superpowers plans 目录
mkdir -p docs/superpowers/plans

# 排除同步文件
echo ".project-context.md" >> .gitignore
echo ".openspec-mirror/" >> .gitignore

# 首次同步 project-context.md
copy ..\project-docs\_bmad-output\project-context.md .project-context.md
```

### Step 3: 创建工作空间文件

```jsonc
// project.code-workspace
{
  "folders": [
    { "path": "./project-docs", "name": "📄 Docs" },
    { "path": "./project-code", "name": "💻 Code" }
  ],
  "settings": {}
}
```

### Step 4: 创建同步脚本（可选）

在工作空间根目录创建 `sync-docs-to-code.ps1`：

```powershell
# sync-docs-to-code.ps1
# 将文档工程的关键文件同步到代码工程

$DocsDir = ".\project-docs"
$CodeDir = ".\project-code"

Write-Host "同步 project-context.md ..."
Copy-Item "$DocsDir\_bmad-output\project-context.md" "$CodeDir\.project-context.md" -Force

Write-Host "同步 OpenSpec specs ..."
if (Test-Path "$CodeDir\.openspec-mirror") { Remove-Item "$CodeDir\.openspec-mirror" -Recurse -Force }
Copy-Item "$DocsDir\openspec" "$CodeDir\.openspec-mirror" -Recurse

Write-Host "✅ 同步完成"
```

### Step 5: 配置 Agent 提示

在代码工程中创建 `.workbuddy/IDENTITY.md` 或类似配置，告知 Agent 文档工程的位置：

```markdown
## 工程拓扑

本项目采用文档工程/代码工程分离模式：

- 文档工程: ../project-docs/
  - BMAD 配置和产出: _bmad/, _bmad-output/
  - OpenSpec 规范: openspec/
  - 统一文档: docs/

- 代码工程: ./ (当前目录)
  - 源代码: src/
  - 测试: tests/
  - Superpowers 计划: docs/superpowers/plans/
  - 项目规则副本: .project-context.md (只读，同步自文档工程)

当需要读取 OpenSpec spec 或 BMAD 产出时，请从 ../project-docs/ 读取。
```

---

## 十、总结

### 一句话答案

**文档工程与代码工程分离是合适的**，但不是"分了就完事"——需要在**三个工具的路径假设**上做适配，核心是解决"跨仓读取"问题。

### 影响与规避速查表

| 影响点 | 严重程度 | 规避方案 | 成本 |
|---|---|---|---|
| Agent 工作目录上下文 | 🟡 中 | 多文件夹工作空间 / 同步脚本 | 低 |
| Git Worktree 隔离 | 🟡 中 | Plan 文件内联验收标准 | 低 |
| OpenSpec verify 跨仓 | 🟡 中 | 同步脚本 / 内联标准 | 低 |
| project-context.md 同步 | 🟢 低 | 只读副本 + 手动/脚本同步 | 极低 |
| INDEX.md 跨仓引用 | 🟢 低 | 标注性引用（`[代码工程]` 前缀） | 极低 |
| OpenSpec apply 跨仓 | ⚪ 无 | 已被 Superpowers 替代 | 无 |

### 建议

1. **新项目**：先不分离，在一个仓库中跑通 BMAD→OpenSpec→Superpowers 全流程。等流程熟练后再按需分离。
2. **已有项目**：如果代码仓库已经很大、或者有专职的需求/架构角色，直接分离。用多文件夹工作空间 + 同步脚本解决跨仓问题。
3. **不管分不分离**：确保 `project-context.md` 在代码侧可访问——这是三个工具都需要的"公共契约"。
