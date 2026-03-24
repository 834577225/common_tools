# 多代码工程需求开发 Step-by-Step 指引

> **目标**：从零开始，使用 BMAD-Method（做什么）+ OpenSpec（怎么改）+ Superpowers（怎么做好）完成一个涉及多个代码工程的需求开发。
>
> **前置知识**：基于以下三份分析文档的结论整合而成：
> - [交接机制与统一文档目录设计](./handoff-and-docs-structure.md)
> - [文档工程与代码工程分离分析](./docs-code-separation-analysis.md)
> - [多代码工程文档策略](./multi-code-repo-docs-strategy.md)

---

## 目录

- [第一部分：目录规划](#第一部分目录规划)
- [第二部分：安装与配置](#第二部分安装与配置)
- [第三部分：开发流程 Step-by-Step](#第三部分开发流程-step-by-step)
- [附录：交接检查清单汇总](#附录交接检查清单汇总)

---

# 第一部分：目录规划

## 1.1 总体架构：Hub-Spoke 模式

采用**单一文档工程（Hub）+ 多个代码工程（Spoke）** 模式。文档工程是中央枢纽，承载所有需求、规范和变更管理；各代码工程只保留与代码强绑定的实施文件。

```
workspace/                              # 本地工作空间根目录
│
├── my-project.code-workspace           # VS Code / WorkBuddy 多文件夹工作空间
│
├── project-docs/                       # ★ 文档工程（Hub）★
│   │                                   #   独立 Git 仓库
│   ├── .git/
│   │
│   ├── _bmad/                          # BMAD 框架配置
│   │   └── bmm/                        #   └ BMad Method 模块
│   │       └── config.yaml             #     └ 模块配置
│   ├── _bmad-output/                   # BMAD 产出物
│   │   ├── planning-artifacts/
│   │   │   ├── PRD.md                  #   需求文档
│   │   │   ├── architecture.md         #   架构设计
│   │   │   └── epics/                  #   Epic 和 Story
│   │   │       ├── epic-xxx.md
│   │   │       └── ...
│   │   └── project-context.md          #   项目"宪法"（全局版）
│   │
│   ├── docs/                           # ═══ 统一文档入口 ═══
│   │   ├── INDEX.md                    #   全局路由表（全景追踪）
│   │   │
│   │   ├── global/                     #   全局文档（从 _bmad-output/ 复制）
│   │   │   ├── PRD.md
│   │   │   ├── architecture.md
│   │   │   └── project-context.md
│   │   │
│   │   └── projects/                   #   按【业务域】分区（不是按代码工程！）
│   │       ├── user-auth/
│   │       │   ├── README.md
│   │       │   ├── epics/
│   │       │   └── stories/
│   │       ├── payment/
│   │       │   └── ...
│   │       └── content-mgmt/
│   │           └── ...
│   │
│   └── openspec/                       # ═══ OpenSpec 规范 ═══
│       ├── specs/                      #   系统行为基线（按【行为域】分区）
│       │   ├── auth/
│       │   │   └── spec.md
│       │   ├── payment/
│       │   │   └── spec.md
│       │   └── membership/
│       │       └── spec.md
│       │
│       ├── changes/                    #   活跃变更
│       │   └── {change-name}/          #   每个变更一个文件夹
│       │       ├── proposal.md         #     为什么改、改什么
│       │       ├── design.md           #     技术方案（含跨工程接口契约）
│       │       ├── tasks.md            #     ★ 按代码工程分组的任务清单 ★
│       │       ├── .openspec.yaml      #     元数据
│       │       └── specs/              #     Delta Specs（增量规格）
│       │           └── {domain}/
│       │               └── spec.md
│       └── archive/                    #   已完成变更的归档
│           └── YYYY-MM-DD-{name}/
│
│
├── frontend/                           # ★ 代码工程 A（Spoke）★
│   ├── .git/                           #   独立 Git 仓库
│   ├── .project-context.md             #   局部项目规则（本工程特有）
│   ├── .project-context-global.md      #   全局规则只读副本（同步自文档工程）
│   ├── docs/
│   │   └── superpowers/
│   │       └── plans/                  #   本工程的 Superpowers 计划文件
│   │           └── YYYY-MM-DD-xxx.md
│   └── src/                            #   源代码
│
├── backend-api/                        # ★ 代码工程 B（Spoke）★
│   ├── .git/
│   ├── .project-context.md
│   ├── .project-context-global.md
│   ├── docs/
│   │   └── superpowers/
│   │       └── plans/
│   └── src/
│
├── payment-service/                    # ★ 代码工程 C（Spoke）★
│   └── ...（结构同上）
│
└── user-service/                       # ★ 代码工程 D（Spoke）★
    └── ...（结构同上）
```

## 1.2 核心设计原则

| 原则 | 说明 |
|---|---|
| **需求和规范是全局的，实施是局部的** | PRD/架构/Spec 放文档工程（全局），Plan/代码/测试放代码工程（局部） |
| **按业务域组织文档，按代码工程组织实施** | `docs/projects/` 按业务模块分，Plans 按代码工程分 |
| **tasks.md 是分发器** | 一份 tasks.md 按代码工程分组任务，含跨工程依赖和实施顺序 |
| **INDEX.md 是全景图** | 一个地方看到需求 → 设计 → 各工程实施状态 |
| **project-context 分层** | 全局版在文档工程（架构/服务拓扑），局部版在各代码工程（技术栈/代码规范/命令） |
| **Spec 是最终裁判** | 所有实现最终对照 `openspec/specs/` 验收 |

## 1.3 文件归属速查表

| 文件/目录 | 放在哪里 | 说明 |
|---|---|---|
| `_bmad/` (框架配置) | 文档工程 | BMAD 安装时生成 |
| `_bmad-output/` (产出物) | 文档工程 | PRD、架构、Epic、project-context |
| `openspec/` (规范) | 文档工程 | specs 基线 + changes 变更管理 |
| `docs/INDEX.md` (路由表) | 文档工程 | 全局文档索引和追踪 |
| `docs/superpowers/plans/` | **各代码工程** | Plan 引用的是代码路径，必须和代码在一起 |
| `.project-context.md` (局部规则) | 各代码工程 | 每个工程特有的技术栈/规范/命令 |
| `.project-context-global.md` (全局规则副本) | 各代码工程 | 从文档工程同步的只读副本 |
| 源代码、测试 | 各代码工程 | 显然 |

---

# 第二部分：安装与配置

## 2.0 前置条件

### Windows (PowerShell)

```powershell
# 检查 Node.js 版本（三个工具都需要 Node 20+）
node --version
# 如果低于 v20，请先升级 Node.js

# 检查 Git
git --version
```

### Linux (Bash/Zsh)

```bash
# 检查 Node.js 版本（三个工具都需要 Node 20+）
node --version
# 如果低于 v20，推荐用 nvm 安装：
#   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
#   source ~/.bashrc   # 或 source ~/.zshrc
#   nvm install 20
#   nvm use 20

# 检查 Git
git --version
# 如果未安装：
#   Ubuntu/Debian: sudo apt update && sudo apt install -y git nodejs npm
#   CentOS/RHEL:   sudo dnf install -y git nodejs npm
#   macOS:         brew install git node
```

## 2.1 Step 1：创建工作空间和仓库

### Windows (PowerShell)

```powershell
# 创建工作空间根目录
mkdir workspace
cd workspace

# 创建文档工程仓库
mkdir project-docs
cd project-docs
git init
cd ..

# 创建各代码工程仓库（根据你的实际项目调整）
mkdir frontend
cd frontend
git init
cd ..

mkdir backend-api
cd backend-api
git init
cd ..

mkdir payment-service
cd payment-service
git init
cd ..

mkdir user-service
cd user-service
git init
cd ..
```

### Linux (Bash/Zsh)

```bash
# 创建工作空间根目录
mkdir -p workspace && cd workspace

# 批量创建所有工程目录并初始化 Git
for repo in project-docs frontend backend-api payment-service user-service; do
  mkdir -p "$repo" && git -C "$repo" init
done

# 验证
ls -la
```

## 2.2 Step 2：安装 BMAD-Method（文档工程）

**BMAD 只需要安装在文档工程中**——它的分析阶段（Phase 1-3）完全在文档工程中完成。

### Windows (PowerShell)

```powershell
cd project-docs

# 运行 BMAD 交互式安装
npx bmad-method install
```

### Linux (Bash/Zsh)

```bash
cd project-docs

# 运行 BMAD 交互式安装（命令相同，npx 跨平台）
npx bmad-method install
```

安装向导中的选择：

| 提示 | 选择 | 说明 |
|---|---|---|
| 安装位置 | 当前目录 (`.`) | 安装到 project-docs/ 根目录 |
| AI 工具 | 根据你使用的 IDE 选择 | Claude Code / Cursor / 其他 |
| 模块 | **BMad Method (BMM)** | 核心软件开发模块 |

安装完成后验证：

### Windows (PowerShell)

```powershell
# 文档工程应该有以下目录
ls _bmad/            # BMAD 框架配置
ls _bmad-output/     # BMAD 产出目录（初始可能为空）
```

### Linux (Bash/Zsh)

```bash
# 文档工程应该有以下目录
ls -la _bmad/            # BMAD 框架配置
ls -la _bmad-output/     # BMAD 产出目录（初始可能为空）
```

> **⚠️ 注意**：BMAD 会根据你选择的 AI 工具在对应目录下生成 Skills 文件（如 `.claude/skills/` 或 `.cursor/skills/`）。这些 Skills 是 BMAD 的核心——Agent 通过它们执行工作流。

## 2.3 Step 3：安装 OpenSpec（文档工程）

**OpenSpec 的规范定义阶段（propose → design → tasks）在文档工程中完成。**

### Windows (PowerShell)

```powershell
# 确保在文档工程目录下
cd project-docs

# 全局安装 OpenSpec CLI
npm install -g @fission-ai/openspec@latest

# 验证安装
openspec --version

# 在文档工程中初始化 OpenSpec
openspec init
```

### Linux (Bash/Zsh)

```bash
# 确保在文档工程目录下
cd project-docs

# 全局安装 OpenSpec CLI
# 注意：如果没有 sudo 权限，先配置 npm 全局路径
#   mkdir -p ~/.npm-global
#   npm config set prefix '~/.npm-global'
#   echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
#   source ~/.bashrc
npm install -g @fission-ai/openspec@latest

# 验证安装
openspec --version

# 在文档工程中初始化 OpenSpec
openspec init
```

> **💡 Linux 权限提示**：在 Linux 上全局安装 npm 包时，**不建议用 `sudo npm install -g`**（会导致后续权限问题）。推荐上述配置 `~/.npm-global` 的方式，或使用 nvm 管理 Node.js（nvm 安装的 Node 天然不需要 sudo）。

初始化后生成的目录：

```
project-docs/
└── openspec/
    ├── specs/          # 系统行为基线（稍后填充）
    ├── changes/        # 活跃变更（稍后使用）
    └── ...             # OpenSpec 生成的引导文件和配置
```

> **⚠️ 注意**：OpenSpec 还会在 AI 工具的配置目录下生成 Slash Commands（如 `.claude/commands/` 或 `.cursor/commands/`），这些是 `/opsx:propose`、`/opsx:apply` 等命令的实现。

## 2.4 Step 4：安装 Superpowers（各代码工程）

**Superpowers 安装在每个代码工程中**——它的计划和执行完全在代码工程目录下运行。

安装方式取决于你的 AI 工具：

### Claude Code

```
# 在每个代码工程目录下执行
cd frontend
/plugin install superpowers@claude-plugins-official

cd ../backend-api
/plugin install superpowers@claude-plugins-official

cd ../payment-service
/plugin install superpowers@claude-plugins-official

cd ../user-service
/plugin install superpowers@claude-plugins-official
```

### Cursor

在每个代码工程中打开 Cursor Agent 聊天，输入：

```
/add-plugin superpowers
```

或在 Cursor 的插件市场中搜索 "superpowers" 安装。

### 手动安装（通用方式）

如果上述方式不可用，可以手动复制 Superpowers 的 Skills 文件到各代码工程：

#### Windows (PowerShell)

```powershell
# 克隆 Superpowers 仓库
git clone https://github.com/obra/superpowers.git _superpowers-source

# 对每个代码工程，复制所需的 skills
# 具体路径根据你的 AI 工具而定
```

#### Linux (Bash/Zsh)

```bash
# 克隆 Superpowers 仓库
git clone https://github.com/obra/superpowers.git _superpowers-source

# 对每个代码工程，复制所需的 skills
# 具体路径根据你的 AI 工具而定（如 .claude/skills/ 或 .cursor/skills/）
# 示例（以 Claude Code 为例）：
for repo in frontend backend-api payment-service user-service; do
  mkdir -p "$repo/.claude/skills"
  cp -r _superpowers-source/skills/* "$repo/.claude/skills/"
done
```

安装完成后，在各代码工程创建 Plans 目录：

#### Windows (PowerShell)

```powershell
# 对每个代码工程执行
cd frontend
mkdir -p docs/superpowers/plans
cd ..

cd backend-api
mkdir -p docs/superpowers/plans
cd ..

# ... 对其他代码工程重复
```

#### Linux (Bash/Zsh)

```bash
# 批量创建
for repo in frontend backend-api payment-service user-service; do
  mkdir -p "$repo/docs/superpowers/plans"
done
```

## 2.5 Step 5：创建多文件夹工作空间

```jsonc
// 文件：workspace/my-project.code-workspace
{
  "folders": [
    { "path": "./project-docs",     "name": "📄 文档工程" },
    { "path": "./frontend",         "name": "🖥️ frontend" },
    { "path": "./backend-api",      "name": "🔌 backend-api" },
    { "path": "./payment-service",  "name": "💳 payment-service" },
    { "path": "./user-service",     "name": "👤 user-service" }
  ],
  "settings": {}
}
```

用 VS Code / WorkBuddy 打开这个 `.code-workspace` 文件——Agent 可以同时访问所有工程的文件。

## 2.6 Step 6：创建统一文档目录（文档工程）

### Windows (PowerShell)

```powershell
cd project-docs

# 创建统一文档目录结构
mkdir -p docs/global
mkdir -p docs/projects

# INDEX.md 稍后在 BMAD 阶段完成时创建
```

### Linux (Bash/Zsh)

```bash
cd project-docs

# 创建统一文档目录结构
mkdir -p docs/{global,projects}

# INDEX.md 稍后在 BMAD 阶段完成时创建
```

## 2.7 Step 7：配置各代码工程

对每个代码工程执行以下操作：

### 创建局部 .project-context.md

每个代码工程需要一个描述本工程特有规则的 `.project-context.md`：

#### Windows (PowerShell)

```powershell
# 示例：frontend 工程
cd frontend
```

#### Linux (Bash/Zsh)

```bash
# 示例：frontend 工程
cd frontend
```

然后在该目录下创建 `.project-context.md`（内容跨平台通用）：

```markdown
# Project Context — frontend

> 全局规则见文档工程的 project-context.md
> 本文件仅描述 frontend 代码工程特有的规则

## 技术栈
- （填入你的前端技术栈，如 React 18 + TypeScript 5）

## 代码规则
- （填入你的代码规范）

## 目录约定
- src/components/ — 共享组件
- src/features/{feature}/ — 按功能模块组织

## 常用命令
- 开发: `npm run dev`
- 测试: `npx vitest`
- 构建: `npm run build`
```

### 配置 .gitignore

在各代码工程的 `.gitignore` 中添加：

```gitignore
# 从文档工程同步的镜像文件（不纳入代码仓库版本管理）
.project-context-global.md
.openspec-mirror/
```

## 2.8 Step 8：创建同步脚本（可选但推荐）

在工作空间根目录创建同步脚本，用于在关键节点将文档工程的文件同步到各代码工程：

### Windows (PowerShell)

```powershell
# 文件：workspace/sync-docs.ps1

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
    if (Test-Path "$DocsDir\_bmad-output\project-context.md") {
        Copy-Item "$DocsDir\_bmad-output\project-context.md" `
                  "$CodeDir\.project-context-global.md" -Force
        Write-Host "  ✅ project-context.md (global)"
    }

    # 2. 同步 OpenSpec specs（verify 阶段需要）
    $mirrorDir = "$CodeDir\.openspec-mirror"
    if (Test-Path $mirrorDir) { Remove-Item $mirrorDir -Recurse -Force }
    if (Test-Path "$DocsDir\openspec\specs") {
        Copy-Item "$DocsDir\openspec\specs" "$mirrorDir\specs" -Recurse
        Write-Host "  ✅ openspec/specs/"
    }

    # 3. 同步当前活跃变更（writing-plans 阶段需要）
    if (Test-Path "$DocsDir\openspec\changes") {
        Copy-Item "$DocsDir\openspec\changes" "$mirrorDir\changes" -Recurse
        Write-Host "  ✅ openspec/changes/"
    }

    Write-Host ""
}

Write-Host "🎉 全部同步完成"
```

### Linux (Bash/Zsh)

```bash
#!/usr/bin/env bash
# 文件：workspace/sync-docs.sh
# 用法：chmod +x sync-docs.sh && ./sync-docs.sh

set -euo pipefail

DOCS_DIR="${1:-./project-docs}"
CODE_DIRS=("./frontend" "./backend-api" "./payment-service" "./user-service")

for CODE_DIR in "${CODE_DIRS[@]}"; do
    REPO_NAME=$(basename "$CODE_DIR")
    echo "━━━ 同步到 $REPO_NAME ━━━"

    # 1. 同步全局 project-context.md
    SRC_CONTEXT="$DOCS_DIR/_bmad-output/project-context.md"
    if [[ -f "$SRC_CONTEXT" ]]; then
        cp -f "$SRC_CONTEXT" "$CODE_DIR/.project-context-global.md"
        echo "  ✅ project-context.md (global)"
    fi

    # 2. 同步 OpenSpec specs（verify 阶段需要）
    MIRROR_DIR="$CODE_DIR/.openspec-mirror"
    rm -rf "$MIRROR_DIR"
    if [[ -d "$DOCS_DIR/openspec/specs" ]]; then
        mkdir -p "$MIRROR_DIR"
        cp -r "$DOCS_DIR/openspec/specs" "$MIRROR_DIR/specs"
        echo "  ✅ openspec/specs/"
    fi

    # 3. 同步当前活跃变更（writing-plans 阶段需要）
    if [[ -d "$DOCS_DIR/openspec/changes" ]]; then
        mkdir -p "$MIRROR_DIR"
        cp -r "$DOCS_DIR/openspec/changes" "$MIRROR_DIR/changes"
        echo "  ✅ openspec/changes/"
    fi

    echo ""
done

echo "🎉 全部同步完成"
```

> **💡 Linux 使用提示**：创建后别忘了赋予执行权限：`chmod +x sync-docs.sh`。后续运行直接 `./sync-docs.sh` 即可。如果文档工程目录不是默认的 `./project-docs`，可以传参：`./sync-docs.sh /path/to/docs`。

---

# 第三部分：开发流程 Step-by-Step

## 全流程概览

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         文档工程中操作                                    │
│                                                                         │
│  Phase A: BMAD — "做什么"                                                │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐                           │
│  │ Discovery │ → │ Require  │ → │ Solution │ → PRD + 架构 + Epic/Story │
│  │ (发现)    │   │ (需求)   │   │ (方案)   │                           │
│  └──────────┘   └──────────┘   └──────────┘                           │
│        │                                                                │
│        ▼                                                                │
│  Phase B: 交接 — BMAD → OpenSpec                                        │
│  ┌──────────────────────────────────────────┐                          │
│  │ 持久化 docs/ + 初始化 specs/ + 同步 context │                          │
│  └──────────────────────────────────────────┘                          │
│        │                                                                │
│        ▼                                                                │
│  Phase C: OpenSpec — "怎么改"                                            │
│  ┌───────────┐   ┌──────────┐   ┌──────────┐                          │
│  │ /opsx:    │ → │ design   │ → │ tasks    │ → proposal + design +    │
│  │  propose  │   │ (设计)   │   │ (任务)   │   tasks（按代码工程分组） │
│  └───────────┘   └──────────┘   └──────────┘                          │
│                                                                         │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │
                                   ▼  tasks.md 按代码工程分发
                                   │
          ┌───────────────┬────────┴────────┬───────────────┐
          ▼               ▼                 ▼               ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ 代码工程 A   │  │ 代码工程 B   │  │ 代码工程 C   │  │ 代码工程 D   │
│             │  │             │  │             │  │             │
│ Phase D:    │  │ Phase D:    │  │ Phase D:    │  │ Phase D:    │
│ Superpowers │  │ Superpowers │  │ Superpowers │  │ Superpowers │
│ "怎么做好"   │  │ "怎么做好"   │  │ "怎么做好"   │  │ "怎么做好"   │
│             │  │             │  │             │  │             │
│ write-plan  │  │ write-plan  │  │ write-plan  │  │ write-plan  │
│     ↓       │  │     ↓       │  │     ↓       │  │     ↓       │
│ exec-plan   │  │ exec-plan   │  │ exec-plan   │  │ exec-plan   │
│ (TDD 循环)  │  │ (TDD 循环)  │  │ (TDD 循环)  │  │ (TDD 循环)  │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │                │
       └────────────────┴────────────────┴────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                          文档工程中操作                                    │
│                                                                          │
│  Phase E: 验证与归档                                                      │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐                │
│  │ /opsx:verify │ → │ /opsx:archive│ → │ 更新 INDEX.md │                │
│  │ (系统级验证) │   │ (归档变更)   │   │ (全景追踪)   │                │
│  └──────────────┘   └──────────────┘   └──────────────┘                │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Phase A：BMAD — "做什么"

> **活跃工程**：文档工程
> **目标**：产出 PRD、架构设计、Epic/Story
> **工具**：BMAD-Method 的 Agent（PO、Architect、SM）

### Step A1：启动 BMAD 流程

在文档工程目录下，用你的 AI IDE 打开项目，然后启动 BMAD 的工作流：

```
# 如果不确定从何开始，先问 bmad-help
bmad-help 我有一个新需求要分析，应该从哪里开始？
```

BMAD 的工作流通常是：

1. **Discovery（发现阶段）**：和 BMAD 的 Product Owner (PO) agent 对话，梳理业务需求
2. **Requirements（需求阶段）**：PO agent 产出结构化 PRD
3. **Solutioning（方案阶段）**：Architect agent 产出技术架构设计

### Step A2：确保架构文档明确多代码工程职责

**这一步至关重要。** 在 Architect 产出 `architecture.md` 时，确保它明确：

1. **各代码工程的职责边界**
2. **服务间通信方式**（REST/gRPC/消息队列等）
3. **共享组件和数据模型**

示例结构：

```markdown
## 系统架构

### 代码工程拓扑
| 工程 | 语言/框架 | 职责 |
|---|---|---|
| frontend | React + TypeScript | 用户界面 |
| backend-api | Node.js + Express | BFF 层，API 聚合 |
| payment-service | Go | 支付业务 |
| user-service | Go | 用户和会员业务 |

### 服务间通信
- frontend ↔ backend-api: REST over HTTPS
- backend-api ↔ payment-service: gRPC
- backend-api ↔ user-service: gRPC
```

### Step A3：产出 project-context.md（全局版）

BMAD 会在 `_bmad-output/project-context.md` 中生成"项目宪法"。在多代码工程场景下，确保它包含：

```markdown
# Project Context（全局版）

## 项目概述
（项目描述）

## 全局技术决策
- （全局技术选型）

## 代码工程拓扑
| 工程 | 语言 | 职责 |
|---|---|---|

## 全局编码规则
- API 命名遵循 RESTful 规范
- 所有时间字段使用 ISO 8601 格式
- 错误响应统一格式: { code, message, details }

## 各工程特有规则
→ 见各代码工程的 .project-context.md
```

### Step A4：通过 BMAD 质量门控

在 BMAD Phase 3 完成后，使用 BMAD 的实施准备检查：

```
bmad-check-implementation-readiness
```

确保 PRD、架构和 Epic/Story 都达到可实施标准。

---

## Phase B：交接 — BMAD → OpenSpec

> **活跃工程**：文档工程
> **目标**：将 BMAD 产出物持久化，初始化 OpenSpec 基线，准备进入规范驱动阶段
> **⚠️ 这是第一个关键交接点**

### Step B1：持久化 BMAD 产出物到 docs/

将 BMAD 的产出物从 `_bmad-output/` 复制到统一文档目录 `docs/`：

#### Windows (PowerShell)

```powershell
# 在文档工程目录下
cd project-docs

# 复制全局文档
Copy-Item "_bmad-output\planning-artifacts\PRD.md" "docs\global\PRD.md" -Force
Copy-Item "_bmad-output\planning-artifacts\architecture.md" "docs\global\architecture.md" -Force
Copy-Item "_bmad-output\project-context.md" "docs\global\project-context.md" -Force

# 按业务模块组织 Epic/Story
# （根据你的实际模块调整）
mkdir -p docs/projects/user-auth/epics
mkdir -p docs/projects/user-auth/stories
mkdir -p docs/projects/payment/epics
mkdir -p docs/projects/payment/stories

# 将 Epic/Story 文件移动到对应业务模块下
Copy-Item "_bmad-output\planning-artifacts\epics\epic-user-registration.md" `
           "docs\projects\user-auth\epics\" -Force
# ... 对其他 Epic/Story 重复
```

#### Linux (Bash/Zsh)

```bash
# 在文档工程目录下
cd project-docs

# 复制全局文档
cp -f _bmad-output/planning-artifacts/PRD.md docs/global/PRD.md
cp -f _bmad-output/planning-artifacts/architecture.md docs/global/architecture.md
cp -f _bmad-output/project-context.md docs/global/project-context.md

# 按业务模块组织 Epic/Story
mkdir -p docs/projects/{user-auth,payment}/{epics,stories}

# 将 Epic/Story 文件移动到对应业务模块下
cp -f _bmad-output/planning-artifacts/epics/epic-user-registration.md \
      docs/projects/user-auth/epics/
# ... 对其他 Epic/Story 重复
```

> **为什么要复制而不是只用 `_bmad-output/`？**
> - `_bmad-output/` 是 BMAD 框架管理的目录，格式固定
> - `docs/` 是面向人类和跨工具的索引层，组织更灵活
> - 复制后，即使后续 BMAD 更新了产出物，`docs/` 中有稳定的"快照"

### Step B2：初始化 OpenSpec 系统行为基线

OpenSpec 需要 `openspec/specs/` 作为"当前系统状态"的唯一事实来源。根据项目类型：

#### 新项目（Greenfield）

从 BMAD 的架构文档中提取各模块的行为规范，为每个行为域创建初始 spec：

```bash
# Windows / Linux 通用（mkdir -p 跨平台兼容）
mkdir -p openspec/specs/auth
mkdir -p openspec/specs/payment
mkdir -p openspec/specs/membership
```

创建初始 spec 示例（`openspec/specs/auth/spec.md`）：

```markdown
# Auth Specification

## Purpose
用户认证和会话管理。

## Requirements

### Requirement: Email Registration
系统 MUST 支持邮箱+密码注册。

#### Scenario: Valid Registration
- GIVEN 用户输入有效邮箱和密码
- WHEN 用户提交注册
- THEN 系统创建账号并返回认证令牌

#### Scenario: Duplicate Email
- GIVEN 邮箱已被注册
- WHEN 用户用同一邮箱注册
- THEN 系统返回 409 冲突错误
```

#### 已有项目（Brownfield）

使用 OpenSpec 的探索命令自动扫描代码库生成初始 spec：

```
/opsx:explore
```

> **⚠️ Brownfield 注意**：`/opsx:explore` 需要读代码——如果文档和代码分仓，需要在多文件夹工作空间中执行，或先切到代码工程目录扫描，再将结果整理到文档工程的 `openspec/specs/` 下。

### Step B3：同步 project-context.md 到各代码工程

#### Windows (PowerShell)

```powershell
# 方式 1：手动复制
Copy-Item "project-docs\_bmad-output\project-context.md" `
           "frontend\.project-context-global.md" -Force
Copy-Item "project-docs\_bmad-output\project-context.md" `
           "backend-api\.project-context-global.md" -Force
# ... 对其他代码工程重复

# 方式 2：使用同步脚本（推荐）
cd workspace
.\sync-docs.ps1
```

#### Linux (Bash/Zsh)

```bash
# 方式 1：手动复制
for repo in frontend backend-api payment-service user-service; do
  cp -f project-docs/_bmad-output/project-context.md \
       "$repo/.project-context-global.md"
done

# 方式 2：使用同步脚本（推荐）
cd workspace
./sync-docs.sh
```

### Step B4：创建 INDEX.md

在 `docs/INDEX.md` 中建立全局路由表：

```markdown
# 项目文档索引

## 全局文档
- [PRD](./global/PRD.md) ← BMAD 产出
- [架构](./global/architecture.md) ← BMAD 产出
- [项目规则](./global/project-context.md) ← BMAD 产出

## 系统规范（Source of Truth）
- [认证规范](../openspec/specs/auth/spec.md) ← OpenSpec 维护
- [支付规范](../openspec/specs/payment/spec.md) ← OpenSpec 维护
- [会员规范](../openspec/specs/membership/spec.md) ← OpenSpec 维护

## 活跃变更
（暂无——将在 Phase C 后更新）

## 代码工程清单
| 工程 | 技术栈 | context 版本 |
|---|---|---|
| frontend | React + TypeScript | v1 |
| backend-api | Node.js + Express | v1 |
| payment-service | Go | v1 |
| user-service | Go | v1 |
```

### ✅ BMAD → OpenSpec 交接检查清单

| # | 检查项 | 通过？ |
|---|---|---|
| 1 | `docs/global/` 下有 PRD.md、architecture.md、project-context.md | ☐ |
| 2 | `docs/projects/` 下按业务模块组织了 Epic/Story | ☐ |
| 3 | `openspec/specs/` 基线已建立，每个行为域有初始 spec.md | ☐ |
| 4 | 各代码工程有 `.project-context-global.md`（同步自文档工程） | ☐ |
| 5 | `docs/INDEX.md` 已创建，包含全局文档和系统规范链接 | ☐ |
| 6 | 各代码工程有自己的 `.project-context.md`（局部规则） | ☐ |

---

## Phase C：OpenSpec — "怎么改"

> **活跃工程**：文档工程
> **目标**：将 BMAD 的 Story 转化为结构化的变更提案（proposal → design → tasks）
> **工具**：OpenSpec 的 Slash Commands

### Step C1：Story → OpenSpec Change 的"翻译"

一个 BMAD Story 可能对应一个或多个 OpenSpec Change。关键是**按业务变更粒度拆分**，不是按代码工程拆分：

```
BMAD Story: "用户可以用微信支付购买会员"

拆分为 OpenSpec Changes:
├── add-wechat-pay          ← 一个变更，横跨多个代码工程 ✅
│
│   而不是：
├── add-wechat-pay-frontend ← 按代码工程拆 ❌
├── add-wechat-pay-backend  ← 信息碎片化 ❌
├── add-wechat-pay-service  ← 追溯链断裂 ❌
```

### Step C2：发起变更提案

```
/opsx:propose add-wechat-pay
```

OpenSpec 会引导你完成 proposal.md 的编写。**关键：在 proposal.md 头部标注 BMAD 来源**：

```markdown
# Proposal: add-wechat-pay

> **Source Story**: docs/projects/payment/stories/story-wechat-pay.md
> **Architecture**: docs/global/architecture.md
> **Context**: docs/global/project-context.md

## Summary
添加微信支付购买会员功能。

## Motivation
（从 BMAD Story 中提取的业务价值...）

## Scope
本变更涉及以下代码工程：
- frontend: 支付页面 UI
- backend-api: 订单接口和支付回调
- payment-service: 微信支付集成
- user-service: 会员状态更新
```

### Step C3：完成设计文档

OpenSpec 会引导你完成 `design.md`。**在多代码工程场景下，design.md 必须包含跨工程接口契约**：

```markdown
# Design: add-wechat-pay

## 技术方案概述
（整体方案描述...）

## 各代码工程的设计

### frontend
- 新增支付页面组件
- 使用 React Query 轮询订单状态

### backend-api
- POST /api/orders — 创建订单
- GET /api/orders/:id — 查询订单状态
- POST /api/webhooks/wechat-pay — 支付回调

### payment-service
- 对接微信支付统一下单 API
- 实现支付结果通知验签

### user-service
- 添加会员开通接口
- 实现会员到期自动降级

## 跨工程接口契约 ← ★ 这一节非常重要 ★

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

### Step C4：生成任务清单

OpenSpec 生成 `tasks.md`。**这是 Hub-Spoke 的核心接口——tasks.md 按代码工程分组任务**：

```markdown
# Tasks: add-wechat-pay

## 变更概述
添加微信支付购买会员功能。

## 代码工程任务分配

### 🔹 payment-service （代码工程 C）
- [ ] Task P1: 对接微信支付统一下单 API
- [ ] Task P2: 实现支付结果通知验签
- [ ] Task P3: 添加支付幂等性保障

### 🔹 user-service （代码工程 D）
- [ ] Task U1: 添加会员开通接口
- [ ] Task U2: 实现会员到期自动降级

### 🔹 backend-api （代码工程 B）
- [ ] Task B1: 创建订单接口 POST /api/orders
- [ ] Task B2: 微信支付回调接口 POST /api/webhooks/wechat-pay
- [ ] Task B3: 订单状态查询接口 GET /api/orders/:id

### 🔹 frontend （代码工程 A）
- [ ] Task F1: 创建支付页面组件
- [ ] Task F2: 添加支付结果轮询逻辑
- [ ] Task F3: 添加会员状态刷新

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

### Step C5：更新 INDEX.md

在 Phase C 完成后，更新 `docs/INDEX.md` 的"活跃变更"部分：

```markdown
## 活跃变更

### add-wechat-pay（添加微信支付）
- 提案: [proposal.md](../openspec/changes/add-wechat-pay/proposal.md)
- 设计: [design.md](../openspec/changes/add-wechat-pay/design.md)
- 任务: [tasks.md](../openspec/changes/add-wechat-pay/tasks.md)
- 实施计划:
  - `[payment-service]` ⚪ 待开始
  - `[user-service]` ⚪ 待开始
  - `[backend-api]` ⚪ 待开始
  - `[frontend]` ⚪ 待开始
```

---

## Phase D：Superpowers — "怎么做好"

> **活跃工程**：各代码工程（按实施顺序逐个切换）
> **目标**：将 OpenSpec 的 tasks 转化为精确的实施计划，并用 TDD 方式执行
> **工具**：Superpowers 的 Skills

### ⚠️ OpenSpec → Superpowers 交接注意事项

这是第二个关键交接点。需要注意：

| 注意项 | 说明 | 解决方式 |
|---|---|---|
| **Plan 必须在代码工程中生成** | Plan 引用的是代码工程的文件路径 | Superpowers writing-plans 在代码工程目录下执行 |
| **Plan 需要读文档工程的信息** | tasks.md、design.md、spec.md 都在文档工程 | 通过多文件夹工作空间跨工程读取，或先运行同步脚本 |
| **Plan 应该自包含** | Git worktree 中看不到文档工程 | Plan 头部内联验收标准和设计摘要 |
| **一个 tasks.md 拆成多个 Plan** | 各代码工程从 tasks.md 中"领取"自己的任务 | 每个代码工程独立生成自己的 Plan |

### Step D0：同步文档工程到各代码工程

在进入 Superpowers 之前，确保各代码工程能读到文档工程的最新信息：

#### Windows (PowerShell)

```powershell
# 运行同步脚本
cd workspace
.\sync-docs.ps1
```

#### Linux (Bash/Zsh)

```bash
# 运行同步脚本
cd workspace
./sync-docs.sh
```

### Step D1-D4：按实施顺序对各代码工程执行

以下以 **payment-service**（第一个无依赖的代码工程）为例，完整演示流程。其他代码工程重复相同步骤。

---

#### Step D1：切换到目标代码工程

```bash
# Windows / Linux 通用
cd workspace/payment-service
```

在 AI IDE 中将焦点切换到 `payment-service` 工程。

#### Step D2：Brainstorming（可选但推荐）

Superpowers 的 `brainstorming` skill 会在你描述需求时自动触发：

```
我需要为 payment-service 实现微信支付集成。
具体任务参考：../project-docs/openspec/changes/add-wechat-pay/tasks.md 中
payment-service 部分（Task P1, P2, P3）。
设计参考：../project-docs/openspec/changes/add-wechat-pay/design.md
```

Brainstorming 会和你讨论方案细节，最终产出一份设计文档。

#### Step D3：Writing Plan（生成实施计划）

Superpowers 的 `writing-plans` skill 会读取：
- 文档工程的 `tasks.md` 中属于本工程的任务
- 文档工程的 `design.md` 中本工程的设计
- 文档工程的 `spec.md` 中相关的行为规范
- **代码工程的现有代码**（确定精确的文件路径和依赖）

生成的 Plan 文件存放在 `docs/superpowers/plans/` 下：

```markdown
# Payment Service - WeChat Pay Integration Plan

> **Source Change**: ../project-docs/openspec/changes/add-wechat-pay/
> **Tasks**: P1, P2, P3 from tasks.md
>
> ## Acceptance Criteria (from spec) ← ★ 内联验收标准，自包含 ★
> - GIVEN 有效订单参数 WHEN 调用统一下单 API THEN 返回支付二维码 URL
> - GIVEN 收到微信回调 WHEN 签名验证通过 THEN 更新订单状态为已支付
> - GIVEN 相同订单号 WHEN 重复回调 THEN 幂等处理，不重复扣款
>
> ## Design Summary (from design.md) ← ★ 内联设计摘要 ★
> - 对接微信支付统一下单 API v3
> - HMAC-SHA256 签名验证
> - Redis 分布式锁实现幂等

**Goal:** Implement WeChat Pay integration for payment-service
**Tech Stack:** Go, gRPC, Redis

### Task 1: Implement Unified Order API Client (Task P1)
**Files:**
- Create: `internal/wechat/client.go`
- Create: `internal/wechat/client_test.go`
- Modify: `go.mod` (add wechat SDK dependency)

- [ ] Step 1: Write failing test for CreateOrder
  Run: `go test ./internal/wechat/... -run TestCreateOrder`
  Expected: FAIL "undefined: wechat.Client"
- [ ] Step 2: Implement minimal code
- [ ] Step 3: Run test to verify PASS
- [ ] Step 4: Commit

### Task 2: Implement Callback Signature Verification (Task P2)
...

### Task 3: Add Idempotency Guard (Task P3)
...
```

> **关键细节**：
> - Plan 头部**内联了验收标准和设计摘要**——这样在 git worktree 中执行时不需要跨仓读取
> - 每个 Task 有精确的文件路径、测试命令和预期输出
> - 遵循 TDD 的 RED-GREEN-REFACTOR 循环

#### Step D4：Executing Plan（执行计划）

Plan 批准后，Superpowers 自动进入执行流程：

1. **`using-git-worktrees`**：在代码仓库创建隔离的 worktree 和分支
2. **`executing-plans`**：逐个执行 Plan 中的 Task
3. **`test-driven-development`**：每个 Task 遵循 RED → GREEN → REFACTOR
4. **`verification-before-completion`**：每个 Task 完成后验证
5. **`finishing-a-development-branch`**：所有 Task 完成后，提供合并/PR 选项

```
执行流程：

git worktree (创建隔离分支)
    │
    ├── Task P1: 统一下单 API
    │   ├── 写测试 (RED)
    │   ├── 看测试失败 ✗
    │   ├── 写代码 (GREEN)
    │   ├── 看测试通过 ✓
    │   ├── 重构 (REFACTOR)
    │   └── Commit
    │
    ├── Task P2: 签名验证
    │   └── (同上 TDD 循环)
    │
    └── Task P3: 幂等保障
        └── (同上 TDD 循环)
    │
    ▼
验证所有测试通过
    │
    ▼
合并到主分支 / 创建 PR
```

#### Step D5：完成后更新 INDEX.md

当一个代码工程的 Plan 执行完成后，更新文档工程的 `INDEX.md`：

```markdown
- 实施计划:
  - `[payment-service]` 🟢 已完成  ← 更新
  - `[user-service]` ⚪ 待开始
  - `[backend-api]` ⚪ 待开始
  - `[frontend]` ⚪ 待开始
```

#### 重复 Step D1-D5 对其他代码工程

按照 tasks.md 中的建议实施顺序，对每个代码工程重复上述流程：

```
1. payment-service ✅ 已完成
2. user-service → 执行 Step D1-D5
3. backend-api → 执行 Step D1-D5（此时可以集成测试调用 payment + user）
4. frontend → 执行 Step D1-D5（此时可以端到端测试完整流程）
```

### ✅ OpenSpec → Superpowers 交接检查清单

| # | 检查项 | 通过？ |
|---|---|---|
| 1 | Plan 文件在**代码工程**的 `docs/superpowers/plans/` 下 | ☐ |
| 2 | Plan 头部引用了 OpenSpec 源文件（Source/Spec/Design） | ☐ |
| 3 | Plan 头部**内联了验收标准**（从 spec 提取的 GIVEN/WHEN/THEN） | ☐ |
| 4 | Plan 头部**内联了设计摘要**（从 design.md 提取的关键决策） | ☐ |
| 5 | Plan 每个 Task 有**精确的文件路径**（不是"创建 auth 模块"） | ☐ |
| 6 | Plan 每个 Task 有**TDD 步骤**（RED-GREEN-REFACTOR） | ☐ |
| 7 | Plan 每个 Task 有**验证命令和预期输出** | ☐ |

---

## Phase E：验证与归档

> **活跃工程**：文档工程（对照各代码工程）
> **目标**：验证所有代码工程的实现符合规范，归档变更，更新系统基线
> **工具**：OpenSpec 的 verify + archive

### Step E1：各代码工程内部验证（第一层）

这一层在 Phase D 中已经完成——Superpowers 的 `verification-before-completion` 确保了每个代码工程内部：
- 单元测试通过
- 验收标准满足
- 代码质量检查通过

### Step E2：跨工程系统级验证（第二层）

切回文档工程，运行 OpenSpec 的 verify：

```
/opsx:verify
```

这会对照 `openspec/specs/` 和 `openspec/changes/add-wechat-pay/specs/` 检查：

1. **完整性**：tasks.md 中的所有任务是否都已实现？
2. **正确性**：实现是否符合 spec 中的行为描述？（GIVEN/WHEN/THEN）
3. **一致性**：跨工程的接口契约是否一致？（如 backend-api 调 payment-service 的接口签名是否匹配）

> **⚠️ 跨仓验证注意**：verify 需要同时读 spec（文档工程）和代码（代码工程）。确保：
> - 在多文件夹工作空间中执行，Agent 可以跨工程读取
> - 或先运行 `.\sync-docs.ps1` 将 spec 镜像到各代码工程

### Step E3：归档变更

验证通过后，执行归档：

```
/opsx:archive
```

OpenSpec 会：
1. 将 Delta Specs 合并到 `openspec/specs/` 主分支——**系统基线更新为最新状态**
2. 将 `openspec/changes/add-wechat-pay/` 移到 `openspec/archive/YYYY-MM-DD-add-wechat-pay/`
3. 变更生命周期结束

### Step E4：最终更新 INDEX.md

```markdown
## 活跃变更
（无活跃变更）

## 已完成变更
### 2026-03-24-add-wechat-pay（添加微信支付）
- 提案: [proposal.md](../openspec/archive/2026-03-24-add-wechat-pay/proposal.md)
- 实施: payment-service ✅ | user-service ✅ | backend-api ✅ | frontend ✅
```

### Step E5：同步更新后的 spec 到各代码工程

归档后 `openspec/specs/` 已更新，运行同步脚本让各代码工程也获得最新的 spec 镜像：

#### Windows (PowerShell)

```powershell
cd workspace
.\sync-docs.ps1
```

#### Linux (Bash/Zsh)

```bash
cd workspace
./sync-docs.sh
```

---

# 附录：交接检查清单汇总

## A. BMAD → OpenSpec 交接

| # | 检查项 | 说明 |
|---|---|---|
| 1 | BMAD 产出物已持久化 | `docs/global/` 下有 PRD、architecture、project-context |
| 2 | Epic/Story 按业务域组织 | `docs/projects/{module}/` 下有对应文件 |
| 3 | OpenSpec specs/ 基线已建立 | 每个行为域有初始 spec.md |
| 4 | project-context 已同步 | 各代码工程有 `.project-context-global.md` |
| 5 | INDEX.md 已创建 | 包含全局文档、系统规范、代码工程清单 |
| 6 | Story → Change 映射已明确 | 知道哪个 Story 对应哪些 OpenSpec Changes |

## B. OpenSpec → Superpowers 交接

| # | 检查项 | 说明 |
|---|---|---|
| 1 | tasks.md 按代码工程分组 | 每个代码工程有明确的任务列表 |
| 2 | tasks.md 含跨工程依赖 | 依赖关系和建议实施顺序清晰 |
| 3 | design.md 含接口契约 | 跨工程的 API/gRPC/消息格式已定义 |
| 4 | Plan 在代码工程中生成 | `docs/superpowers/plans/` 在各代码工程 |
| 5 | Plan 自包含 | 头部内联验收标准和设计摘要 |
| 6 | Plan 引用了 OpenSpec 源 | 头部有 Source/Spec/Design 引用 |
| 7 | Plan 有 TDD 步骤 | RED-GREEN-REFACTOR |
| 8 | Plan 有精确文件路径和命令 | 不是模糊描述 |

## C. Superpowers → OpenSpec 回流

| # | 检查项 | 说明 |
|---|---|---|
| 1 | 各代码工程测试通过 | Superpowers verification-before-completion |
| 2 | 跨工程系统级验证通过 | OpenSpec /opsx:verify |
| 3 | Delta Specs 已合并 | openspec/specs/ 更新为最新 |
| 4 | 变更已归档 | openspec/archive/ 中有完整记录 |
| 5 | INDEX.md 已更新 | 活跃变更清空，归档变更记录在案 |
| 6 | spec 镜像已同步 | 各代码工程的 .openspec-mirror/ 是最新 |

---

# 附录：常见问题

## Q1：一个人操作要切来切去好麻烦，有简化方法吗？

**有。** 如果你是个人开发者，可以简化为：

1. **不用同步脚本**：直接用多文件夹工作空间，Agent 跨工程读取文件
2. **不用 git worktree**：如果你不需要隔离（个人开发风险低），可以告诉 Superpowers 跳过
3. **串行执行**：不需要考虑并行——按实施顺序逐个代码工程做完

## Q2：如果需求只涉及一个代码工程呢？

流程不变，只是 tasks.md 中只有一个代码工程的任务组。整体更简单：

```
文档工程: BMAD → 交接 → OpenSpec → tasks.md（只有一个工程）
    ↓
代码工程: Superpowers write-plan → exec-plan
    ↓
文档工程: verify → archive
```

## Q3：如果 BMAD 的 Story 很小，可以跳过 OpenSpec 吗？

**不建议跳过，但可以简化。** OpenSpec 的价值在于"做之前先对齐"——即使是小变更，用 `/opsx:propose` 快速写一个 proposal + tasks，也能避免做到一半发现方向不对。

如果真的是很小的改动（如改个文案、修个 bug），可以跳过 BMAD 直接从 OpenSpec propose 开始。

## Q4：BMAD/OpenSpec/Superpowers 版本更新了怎么办？

- **BMAD**：在文档工程中执行 `npx bmad-method install` 会检测并更新
- **OpenSpec**：`npm update -g @fission-ai/openspec`，然后在文档工程中执行 `openspec update`
- **Superpowers**：在各代码工程中用 AI IDE 的插件更新功能（如 `/plugin update superpowers`）

> **💡 Linux 注意**：如果 npm 全局包路径是 `~/.npm-global`，更新命令不需要 `sudo`。如果用 nvm 管理 Node.js，也不需要 `sudo`。

## Q5：多个需求同时进行怎么办？

OpenSpec 天然支持多个并行变更——`openspec/changes/` 下可以同时存在多个变更文件夹：

```
openspec/changes/
├── add-wechat-pay/        # 需求 A
├── improve-search/        # 需求 B
└── fix-auth-bug/          # 需求 C
```

每个变更独立管理，各自的 tasks.md 分别分发到各代码工程。INDEX.md 跟踪所有活跃变更的状态。

---

# 附录：Linux/macOS 专项注意事项

## 文件路径差异

| 项目 | Windows | Linux/macOS |
|---|---|---|
| 路径分隔符 | `\`（反斜杠） | `/`（正斜杠） |
| 同步脚本 | `.\sync-docs.ps1` | `./sync-docs.sh` |
| 隐藏文件 | 不自动隐藏 | `.` 开头的文件默认隐藏，`ls -a` 查看 |
| 文件权限 | 无执行权限概念 | 脚本需 `chmod +x` 才能运行 |

## Node.js 安装推荐

| 方式 | 适用场景 | 命令 |
|---|---|---|
| **nvm（强烈推荐）** | 个人开发机 | `nvm install 20 && nvm use 20` |
| 系统包管理器 | 服务器/CI | Ubuntu: `sudo apt install nodejs`，CentOS: `sudo dnf install nodejs` |
| Homebrew | macOS | `brew install node@20` |

> **为什么推荐 nvm？** 使用 nvm 安装的 Node.js 不需要 `sudo` 权限来安装全局 npm 包（如 OpenSpec CLI），避免了 Linux 上最常见的权限问题。

## npm 全局安装权限

如果**不使用 nvm**，全局安装 npm 包时可能遇到权限问题。推荐配置用户级全局路径：

```bash
# 一次性配置（写入 ~/.bashrc 或 ~/.zshrc）
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 之后全局安装不需要 sudo
npm install -g @fission-ai/openspec@latest  # 无需 sudo ✅
```

## Shell 脚本注意事项

1. **换行符**：确保 `.sh` 脚本使用 LF 换行符（Unix 格式），而非 CRLF（Windows 格式）。如果脚本在 Windows 编辑后复制到 Linux，运行 `dos2unix sync-docs.sh` 转换。
2. **执行权限**：新建的 `.sh` 文件需要 `chmod +x` 才能直接运行。
3. **文件编码**：确保所有脚本保存为 UTF-8 编码（尤其是包含中文注释的脚本）。

## AI IDE 在 Linux 上的差异

| IDE | Windows 安装 | Linux 安装 |
|---|---|---|
| VS Code / WorkBuddy | `.exe` 安装包 | `.deb`（Ubuntu）/ `.rpm`（Fedora）/ `snap` |
| Cursor | `.exe` 安装包 | `.AppImage` 或 `.deb` |
| Claude Code (CLI) | npm 安装 | npm 安装（相同） |

> **💡 提示**：Claude Code 是纯 CLI 工具，在 Linux 上体验和 Windows 完全一致。Superpowers 的安装命令也完全相同。

---

> **最后提醒**：这套流程看起来步骤很多，但核心只有五个阶段：**BMAD（做什么）→ 交接 → OpenSpec（怎么改）→ Superpowers（怎么做好）→ 验证归档**。每个阶段内部大部分工作都是由 AI Agent 自动完成的，你主要负责 review 和 approve。熟练之后会越来越快。
