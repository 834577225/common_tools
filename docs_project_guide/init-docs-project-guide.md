# 文档工程初始化实操指引

> **场景**：你已经有多个代码工程和一些现有文档（PRD、架构设计、会议纪要、需求说明等），需要从零搭建文档工程（Hub），然后立即开始首个需求开发。
>
> **前置知识**：本指引是 [多代码工程需求开发 Step-by-Step 指引](./multi-repo-dev-guide.md) 的"冷启动"专用版。完成本指引后，直接进入那份指引的 Phase C（OpenSpec）开始需求开发。

---

## 目录

- [总览：你要做什么](#总览你要做什么)
- [Step 0：盘点现有资产](#step-0盘点现有资产)
- [Step 1：创建文档工程仓库](#step-1创建文档工程仓库)
- [Step 2：安装 BMAD-Method](#step-2安装-bmad-method)
- [Step 3：安装 OpenSpec](#step-3安装-openspec)
- [Step 4：导入现有文档到 BMAD 框架](#step-4导入现有文档到-bmad-框架)
- [Step 5：用 BMAD Agent 补齐缺失文档](#step-5用-bmad-agent-补齐缺失文档)
- [Step 6：持久化到 docs/ 统一目录](#step-6持久化到-docs-统一目录)
- [Step 7：初始化 OpenSpec 系统行为基线](#step-7初始化-openspec-系统行为基线)
- [Step 8：配置各代码工程](#step-8配置各代码工程)
- [Step 9：创建 INDEX.md 和同步脚本](#step-9创建-indexmd-和同步脚本)
- [Step 10：安装 Superpowers 到各代码工程](#step-10安装-superpowers-到各代码工程)
- [Step 11：创建多文件夹工作空间](#step-11创建多文件夹工作空间)
- [验收：文档工程初始化检查清单](#验收文档工程初始化检查清单)
- [接下来：开始首个需求开发](#接下来开始首个需求开发)

---

## 总览：你要做什么

```
你现在的状态                          你要达到的状态
─────────────────                    ─────────────────
✅ 多个代码工程（已有代码）             ✅ 同前
✅ 一些散落的文档（PRD/架构/需求等）    ✅ 文档工程（Hub）搭建完成
❌ 没有文档工程                        ✅ BMAD 框架就位，核心文档补齐
❌ 没有 OpenSpec 基线                  ✅ OpenSpec specs/ 基线反映当前系统真实状态
❌ 代码工程没有 Superpowers            ✅ 各代码工程安装 Superpowers，准备接受任务
❌ 没有统一的文档索引                   ✅ INDEX.md + project-context.md 全局贯通
```

**核心原则：不是重新写文档，而是把现有文档"安装"进框架，然后补齐缺失的部分。**

整个过程预计 2-4 小时（取决于现有文档的完整度）。其中大部分工作由 AI Agent 自动完成，你主要负责 review 和确认。

---

## Step 0：盘点现有资产

> **目标**：搞清楚你有什么、缺什么，避免重复造轮子。

### 0.1 列出所有代码工程

制作一张表格：

```markdown
| 工程名称 | 语言/框架 | Git 仓库地址 | 职责描述 | 本地路径 |
|---|---|---|---|---|
| frontend | React + TypeScript | git@... | 用户界面 | ~/workspace/frontend |
| backend-api | Node.js + Express | git@... | BFF 层 | ~/workspace/backend-api |
| payment-service | Go | git@... | 支付业务 | ~/workspace/payment-service |
| user-service | Go | git@... | 用户会员 | ~/workspace/user-service |
```

### 0.2 列出现有文档

把你手头的所有文档归类到以下四个桶：

| 桶 | 对应 BMAD 产出 | 你有吗？ | 示例 |
|---|---|---|---|
| **产品需求** | PRD.md | ？ | 需求文档、PRD、MRD、用户故事、会议纪要中的需求部分 |
| **技术架构** | architecture.md | ？ | 架构设计文档、系统设计、技术选型说明、API 设计 |
| **项目规则** | project-context.md | ？ | 编码规范、分支策略、部署流程、技术栈约定 |
| **需求分解** | Epic/Story | ？ | 拆分好的 Epic/Story、Jira 导出、任务列表 |

### 0.3 确定"缺什么"

对每个桶打分：

- ✅ **有且完整**：内容足够 AI Agent 理解系统全貌
- ⚠️ **有但不完整**：有文档但信息零散或过时
- ❌ **没有**：需要 BMAD Agent 帮你补齐

> **💡 常见情况**：大多数团队有 PRD 和部分架构文档，但缺 project-context.md（全局技术规则）和结构化的 Epic/Story。这完全没问题——Step 5 会用 BMAD Agent 补齐。

---

## Step 1：创建文档工程仓库

### Windows (PowerShell)

```powershell
# 进入你的工作空间目录（存放所有代码工程的上级目录）
cd C:\your\workspace

# 创建文档工程
mkdir project-docs
cd project-docs
git init

# 创建基础目录结构
mkdir -p docs/global
mkdir -p docs/projects
```

### Linux (Bash/Zsh)

```bash
# 进入你的工作空间目录
cd ~/workspace

# 创建文档工程
mkdir -p project-docs && cd project-docs
git init

# 创建基础目录结构
mkdir -p docs/{global,projects}
```

> **⚠️ 注意**：文档工程和各代码工程应在同一个父目录下，方便后续创建多文件夹工作空间。

---

## Step 2：安装 BMAD-Method

```bash
# 在文档工程目录下（Windows / Linux 通用）
cd project-docs
npx bmad-method install
```

安装向导选择：
- 安装位置：当前目录（`.`）
- AI 工具：根据你使用的 IDE（WorkBuddy / Cursor / Claude Code）
- 模块：**BMad Method (BMM)**

验证安装：

```bash
ls _bmad/            # BMAD 框架配置
ls _bmad-output/     # BMAD 产出目录（初始为空）
```

---

## Step 3：安装 OpenSpec

### Windows (PowerShell)

```powershell
cd project-docs
npm install -g @fission-ai/openspec@latest
openspec --version
openspec init
```

### Linux (Bash/Zsh)

```bash
cd project-docs

# 如果用 nvm 管理 Node.js，直接安装即可
# 如果不是，参考下方权限配置
npm install -g @fission-ai/openspec@latest

openspec --version
openspec init
```

> **Linux 权限提示**：如果 `npm install -g` 报权限错误，配置用户级全局路径：
> ```bash
> mkdir -p ~/.npm-global && npm config set prefix '~/.npm-global'
> echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc && source ~/.bashrc
> ```
> 或者直接用 nvm 管理 Node.js（推荐）。

---

## Step 4：导入现有文档到 BMAD 框架

> **目标**：把你现有的文档"安装"进 BMAD 的标准目录结构，让 AI Agent 能识别和使用。

这一步的核心动作是**复制 + 重命名**，把现有文档放到 BMAD 期望的位置。

### 4.1 导入产品需求文档

把你的 PRD / 需求文档复制到 `_bmad-output/planning-artifacts/`：

#### Windows (PowerShell)

```powershell
cd project-docs
mkdir -p _bmad-output/planning-artifacts

# 情况 A：你有一份完整的 PRD
Copy-Item "C:\path\to\your\existing-PRD.md" `
          "_bmad-output\planning-artifacts\PRD.md" -Force

# 情况 B：你有多个需求文档，先全部复制进来，稍后让 BMAD 整合
Copy-Item "C:\path\to\docs\需求说明-v1.docx" "_bmad-output\planning-artifacts\" -Force
Copy-Item "C:\path\to\docs\需求补充.md" "_bmad-output\planning-artifacts\" -Force
# ... 后续 Step 5 让 BMAD Agent 整合成标准 PRD.md
```

#### Linux (Bash/Zsh)

```bash
cd project-docs
mkdir -p _bmad-output/planning-artifacts

# 情况 A：你有一份完整的 PRD
cp ~/docs/existing-PRD.md _bmad-output/planning-artifacts/PRD.md

# 情况 B：多个需求文档先全部放进来
cp ~/docs/需求说明-v1.md ~/docs/需求补充.md \
   _bmad-output/planning-artifacts/
```

### 4.2 导入架构文档

```bash
# Windows / Linux 通用思路
# 如果你有架构设计文档，复制为 architecture.md
cp /path/to/your/architecture-doc.md \
   _bmad-output/planning-artifacts/architecture.md
```

### 4.3 导入 Epic/Story（如果有）

```bash
mkdir -p _bmad-output/planning-artifacts/epics

# 如果你有已拆分的 Epic/Story 文件
cp /path/to/epics/*.md _bmad-output/planning-artifacts/epics/
```

### 4.4 没有 Markdown 格式怎么办？

| 情况 | 处理方式 |
|---|---|
| 文档是 `.docx` / `.pdf` | 先转为 Markdown（可用 pandoc：`pandoc input.docx -o output.md`），再导入 |
| 文档在 Confluence / 飞书 | 导出为 Markdown，或直接复制文本粘贴到 `.md` 文件 |
| 文档在 Jira / TAPD | 导出 Epic/Story 为 CSV/Markdown |
| 只有口头约定没有文档 | 跳过导入，Step 5 用 BMAD Agent 从零生成 |
| 只有代码没有文档 | 跳过导入，Step 7 用 OpenSpec explore 从代码反向生成 |

---

## Step 5：用 BMAD Agent 补齐缺失文档

> **目标**：让 BMAD Agent 基于你导入的现有文档 + 对现有代码工程的理解，补齐框架要求的标准文档。

### 5.1 启动 BMAD 工作流

在文档工程目录下，用 AI IDE 打开项目，和 BMAD Agent 对话：

**如果你有较完整的现有文档（✅ 或 ⚠️ 状态）：**

```
我已经把现有文档导入到了 _bmad-output/planning-artifacts/ 目录下。
这是一个已有的项目，有以下代码工程：
- frontend (React + TypeScript)：用户界面
- backend-api (Node.js + Express)：BFF 层
- payment-service (Go)：支付业务
- user-service (Go)：用户会员

请帮我：
1. 审查 _bmad-output/planning-artifacts/ 中的现有文档
2. 将它们整理成 BMAD 标准格式（PRD.md、architecture.md）
3. 识别缺失的部分并帮我补齐
4. 生成 project-context.md（全局版，包含多代码工程拓扑）
```

**如果你的文档很少或几乎没有（❌ 状态）：**

```
这是一个已有的项目，但文档不完善。代码工程如下：
- frontend (React + TypeScript)：用户界面
- backend-api (Node.js + Express)：BFF 层
- payment-service (Go)：支付业务
- user-service (Go)：用户会员

请帮我从头梳理：
1. 通过对话了解项目背景和业务逻辑
2. 生成 PRD.md（至少覆盖核心功能）
3. 生成 architecture.md（基于现有代码工程的职责分工）
4. 生成 project-context.md（全局技术规则）

先从项目概述开始问我。
```

### 5.2 确保 architecture.md 包含多代码工程信息

> **⚠️ 这一步至关重要。**

无论你的架构文档是已有的还是 BMAD 新生成的，确保它包含：

```markdown
## 代码工程拓扑

| 工程 | 语言/框架 | 职责 | Git 仓库 |
|---|---|---|---|
| frontend | React 18 + TypeScript 5 | 用户界面、SPA | git@xxx/frontend.git |
| backend-api | Node.js 20 + Express | API 网关、BFF 层 | git@xxx/backend-api.git |
| payment-service | Go 1.22 | 支付业务逻辑 | git@xxx/payment-service.git |
| user-service | Go 1.22 | 用户认证和会员管理 | git@xxx/user-service.git |

## 服务间通信

- frontend ↔ backend-api: REST over HTTPS
- backend-api ↔ payment-service: gRPC
- backend-api ↔ user-service: gRPC

## 公共基础设施

- 数据库: PostgreSQL 16（每个服务独立 schema）
- 缓存: Redis 7
- 消息队列: RabbitMQ / Kafka（如有）
- CI/CD: GitHub Actions / Jenkins / ...
```

### 5.3 确保 project-context.md 包含全局规则

```markdown
# Project Context（全局版）

## 项目概述
（一句话描述项目是什么）

## 代码工程拓扑
（同 architecture.md 中的表格）

## 全局技术决策
- API 风格: RESTful（外部）/ gRPC（内部）
- 认证方式: JWT
- 时间格式: ISO 8601
- 错误响应格式: { code, message, details }

## 全局编码规则
- Git 分支策略: trunk-based / Git Flow
- commit 规范: Conventional Commits
- PR 审核: 至少 1 人 approve

## 各工程特有规则
→ 见各代码工程的 .project-context.md
```

### 5.4 通过 BMAD 质量门控

```
bmad-check-implementation-readiness
```

确保 PRD、架构、project-context 三份核心文档都通过检查。

> **💡 实际操作建议**：如果你不需要 Epic/Story 的拆分（因为你已经知道第一个需求是什么），可以跳过 BMAD 的 Epic/Story 生成。直接确保 PRD + architecture + project-context 三份文档就位即可。Epic/Story 可以后续按需补充。

---

## Step 6：持久化到 docs/ 统一目录

把 BMAD 产出物复制到 `docs/` 统一入口：

### Windows (PowerShell)

```powershell
cd project-docs

# 复制全局文档
Copy-Item "_bmad-output\planning-artifacts\PRD.md" "docs\global\PRD.md" -Force
Copy-Item "_bmad-output\planning-artifacts\architecture.md" "docs\global\architecture.md" -Force
Copy-Item "_bmad-output\project-context.md" "docs\global\project-context.md" -Force

# 如果有 Epic/Story，按业务域组织
# mkdir -p docs/projects/{业务域名}/epics
# mkdir -p docs/projects/{业务域名}/stories
# Copy-Item "_bmad-output\planning-artifacts\epics\*.md" "docs\projects\{业务域名}\epics\" -Force
```

### Linux (Bash/Zsh)

```bash
cd project-docs

# 复制全局文档
cp -f _bmad-output/planning-artifacts/PRD.md docs/global/PRD.md
cp -f _bmad-output/planning-artifacts/architecture.md docs/global/architecture.md
cp -f _bmad-output/project-context.md docs/global/project-context.md

# 如果有 Epic/Story，按业务域组织
# mkdir -p docs/projects/{业务域名}/{epics,stories}
# cp -f _bmad-output/planning-artifacts/epics/*.md docs/projects/{业务域名}/epics/
```

---

## Step 7：初始化 OpenSpec 系统行为基线

> **目标**：让 OpenSpec 的 `specs/` 反映当前系统的**真实状态**——不是"理想状态"，不是"将来要做的"，而是"现在代码里实际跑着什么"。

这是初始化中**最重要也最容易犯错**的一步。

### 7.1 确定行为域

行为域 ≠ 代码工程。行为域是**按业务能力划分**的：

```
代码工程拓扑                          行为域划分
─────────────                        ─────────
frontend                      ┌──→  auth（认证）
backend-api            ───────┤
payment-service        ───────┼──→  payment（支付）
user-service           ───────┤
                              └──→  membership（会员）
                              └──→  content（内容管理）
```

一个行为域可能横跨多个代码工程，一个代码工程可能涉及多个行为域。

### 7.2 方式 A：从现有代码自动生成（推荐）

如果你的代码工程已有功能在运行，用 OpenSpec 的 explore 命令扫描代码自动生成 spec：

```
# 在多文件夹工作空间中，或依次切到各代码工程执行
/opsx:explore
```

`/opsx:explore` 会分析代码中的 API 端点、数据模型、业务逻辑，自动生成行为描述。

生成后 **务必 review**——自动生成的 spec 可能不够精确，你需要：
- 删掉不需要的细节
- 补充业务逻辑（代码不一定能反映"为什么这么做"）
- 纠正错误理解

### 7.3 方式 B：手动编写最小基线（快速启动）

如果你急着开始开发，可以先写最小基线——只描述各行为域的核心能力，后续逐步完善：

```bash
# 创建行为域目录（根据你的实际业务调整）
mkdir -p openspec/specs/auth
mkdir -p openspec/specs/payment
mkdir -p openspec/specs/membership
```

为每个行为域创建 `spec.md`，示例（`openspec/specs/auth/spec.md`）：

```markdown
# Auth Specification

## Purpose
用户认证、授权和会话管理。

## Current Capabilities

### Requirement: Email/Password Login
系统 MUST 支持邮箱+密码登录。

#### Scenario: Successful Login
- GIVEN 用户提供正确的邮箱和密码
- WHEN 用户提交登录请求
- THEN 系统返回 JWT access token 和 refresh token

#### Scenario: Invalid Credentials
- GIVEN 用户提供错误的密码
- WHEN 用户提交登录请求
- THEN 系统返回 401 Unauthorized

### Requirement: Token Refresh
系统 MUST 支持 JWT token 刷新。

（继续列出当前已实现的核心能力...）
```

> **⚠️ 关键原则**：
> - **只写当前已实现的能力**，不写"计划做但还没做的"
> - **不需要完美**——后续每次变更都会自动完善 spec
> - **宁可少写不要错写**——错误的 spec 比没有 spec 更有害

### 7.4 方式 C：混合方式（最实用）

1. 先用 `/opsx:explore` 自动扫描生成初稿
2. 再手动 review 和修正
3. 对于代码不完善的行为域，手动补写最小 spec

---

## Step 8：配置各代码工程

对每个代码工程做两件事：

### 8.1 创建局部 .project-context.md

在每个代码工程根目录创建 `.project-context.md`，描述**本工程特有的规则**：

```markdown
# Project Context — {工程名}

> 全局规则见文档工程的 project-context.md
> 本文件仅描述 {工程名} 特有的规则

## 技术栈
- 语言: （如 TypeScript 5.4）
- 框架: （如 React 18, Vite 5）
- 测试: （如 Vitest + React Testing Library）
- 包管理: （如 pnpm 9）

## 目录约定
- src/components/ — 共享组件
- src/features/{feature}/ — 按功能模块组织
- src/lib/ — 工具函数

## 代码规则
- 组件使用函数式写法 + Hooks
- 状态管理用 Zustand
- API 请求统一用 @tanstack/react-query

## 常用命令
- 开发: `pnpm dev`
- 测试: `pnpm test`
- 构建: `pnpm build`
- Lint: `pnpm lint`
```

### 8.2 配置 .gitignore

在各代码工程的 `.gitignore` 中添加：

```gitignore
# 从文档工程同步的镜像文件（不纳入版本管理）
.project-context-global.md
.openspec-mirror/
```

---

## Step 9：创建 INDEX.md 和同步脚本

### 9.1 创建 INDEX.md

在文档工程的 `docs/INDEX.md`：

```markdown
# 项目文档索引

> 最后更新: YYYY-MM-DD

## 全局文档
- [PRD](./global/PRD.md) — 产品需求文档
- [架构设计](./global/architecture.md) — 系统架构和代码工程拓扑
- [项目规则](./global/project-context.md) — 全局技术规则和编码规范

## 系统行为规范（Source of Truth）
- [认证规范](../openspec/specs/auth/spec.md)
- [支付规范](../openspec/specs/payment/spec.md)
- [会员规范](../openspec/specs/membership/spec.md)
（根据你的实际行为域调整）

## 活跃变更
（暂无 —— 首个需求在 Step "接下来" 中发起）

## 已完成变更
（暂无）

## 代码工程清单
| 工程 | 技术栈 | 职责 | .project-context |
|---|---|---|---|
| frontend | React + TypeScript | 用户界面 | ✅ |
| backend-api | Node.js + Express | BFF/API 网关 | ✅ |
| payment-service | Go | 支付业务 | ✅ |
| user-service | Go | 用户会员 | ✅ |
```

### 9.2 创建同步脚本

在工作空间根目录创建同步脚本。

#### Windows (PowerShell) — `sync-docs.ps1`

```powershell
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

    # 2. 同步 OpenSpec specs
    $mirrorDir = "$CodeDir\.openspec-mirror"
    if (Test-Path $mirrorDir) { Remove-Item $mirrorDir -Recurse -Force }
    if (Test-Path "$DocsDir\openspec\specs") {
        Copy-Item "$DocsDir\openspec\specs" "$mirrorDir\specs" -Recurse
        Write-Host "  ✅ openspec/specs/"
    }

    # 3. 同步活跃变更
    if (Test-Path "$DocsDir\openspec\changes") {
        Copy-Item "$DocsDir\openspec\changes" "$mirrorDir\changes" -Recurse
        Write-Host "  ✅ openspec/changes/"
    }

    Write-Host ""
}

Write-Host "🎉 全部同步完成"
```

#### Linux (Bash/Zsh) — `sync-docs.sh`

```bash
#!/usr/bin/env bash
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

    # 2. 同步 OpenSpec specs
    MIRROR_DIR="$CODE_DIR/.openspec-mirror"
    rm -rf "$MIRROR_DIR"
    if [[ -d "$DOCS_DIR/openspec/specs" ]]; then
        mkdir -p "$MIRROR_DIR"
        cp -r "$DOCS_DIR/openspec/specs" "$MIRROR_DIR/specs"
        echo "  ✅ openspec/specs/"
    fi

    # 3. 同步活跃变更
    if [[ -d "$DOCS_DIR/openspec/changes" ]]; then
        mkdir -p "$MIRROR_DIR"
        cp -r "$DOCS_DIR/openspec/changes" "$MIRROR_DIR/changes"
        echo "  ✅ openspec/changes/"
    fi

    echo ""
done

echo "🎉 全部同步完成"
```

```bash
# Linux 下别忘了赋权
chmod +x sync-docs.sh
```

### 9.3 运行首次同步

```powershell
# Windows
.\sync-docs.ps1

# Linux
./sync-docs.sh
```

---

## Step 10：安装 Superpowers 到各代码工程

Superpowers 安装在**每个代码工程**中：

### Claude Code

```
# 在每个代码工程目录下
cd frontend && /plugin install superpowers@claude-plugins-official
cd ../backend-api && /plugin install superpowers@claude-plugins-official
cd ../payment-service && /plugin install superpowers@claude-plugins-official
cd ../user-service && /plugin install superpowers@claude-plugins-official
```

### Cursor

在每个代码工程中打开 Agent 聊天，输入 `/add-plugin superpowers`。

### 手动安装

```bash
git clone https://github.com/obra/superpowers.git _superpowers-source

# 批量复制 skills 并创建 plans 目录
for repo in frontend backend-api payment-service user-service; do
  # 复制 skills（路径根据你的 AI 工具调整）
  mkdir -p "$repo/.claude/skills"
  cp -r _superpowers-source/skills/* "$repo/.claude/skills/"
  # 创建 Plans 目录
  mkdir -p "$repo/docs/superpowers/plans"
done
```

---

## Step 11：创建多文件夹工作空间

在工作空间根目录创建 `.code-workspace` 文件：

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

用 VS Code / WorkBuddy 打开这个文件——现在 Agent 可以同时看到文档工程和所有代码工程。

---

## 验收：文档工程初始化检查清单

| # | 检查项 | 状态 |
|---|---|---|
| **文档工程基础** | | |
| 1 | `project-docs/` 目录存在且已 `git init` | ☐ |
| 2 | `_bmad/` 目录存在（BMAD 已安装） | ☐ |
| 3 | `openspec/` 目录存在（OpenSpec 已初始化） | ☐ |
| **核心文档** | | |
| 4 | `_bmad-output/planning-artifacts/PRD.md` 存在且内容合理 | ☐ |
| 5 | `_bmad-output/planning-artifacts/architecture.md` 存在，包含代码工程拓扑和通信方式 | ☐ |
| 6 | `_bmad-output/project-context.md` 存在，包含全局技术规则 | ☐ |
| **统一文档目录** | | |
| 7 | `docs/global/` 下有 PRD.md、architecture.md、project-context.md | ☐ |
| 8 | `docs/INDEX.md` 已创建，包含全局文档、系统规范、代码工程清单 | ☐ |
| **OpenSpec 基线** | | |
| 9 | `openspec/specs/` 下每个行为域有 `spec.md` | ☐ |
| 10 | spec 内容反映的是当前系统的**真实状态**（不是理想状态） | ☐ |
| **代码工程配置** | | |
| 11 | 每个代码工程有 `.project-context.md`（局部规则） | ☐ |
| 12 | 每个代码工程有 `.project-context-global.md`（同步自文档工程） | ☐ |
| 13 | 每个代码工程的 `.gitignore` 已排除同步文件 | ☐ |
| 14 | 每个代码工程已安装 Superpowers | ☐ |
| 15 | 每个代码工程有 `docs/superpowers/plans/` 目录 | ☐ |
| **工具链** | | |
| 16 | 同步脚本（`sync-docs.ps1` / `sync-docs.sh`）存在且可运行 | ☐ |
| 17 | 多文件夹工作空间 `.code-workspace` 文件已创建 | ☐ |

---

## 接下来：开始首个需求开发

文档工程初始化完成后，你已经跳过了 [多代码工程需求开发指引](./multi-repo-dev-guide.md) 中的 Phase A（BMAD）和 Phase B（交接），可以**直接从 Phase C（OpenSpec）开始**你的首个需求开发。

### 快速开始路径

```
                            ┌─── 你在这里 ───┐
                            ▼                 │
1. 在文档工程中发起变更提案                    │  Phase C
   /opsx:propose {你的需求名称}               │  (OpenSpec)
                                              │
2. 完成 design.md（含跨工程接口契约）          │
                                              │
3. 生成 tasks.md（按代码工程分组）             │
                            ┌─────────────────┘
                            ▼
4. 运行同步脚本              │  交接
   ./sync-docs.sh           │
                            ▼
5. 切到各代码工程             │  Phase D
   Superpowers write-plan   │  (Superpowers)
   → exec-plan (TDD)        │
                            ▼
6. 回到文档工程              │  Phase E
   /opsx:verify             │  (验证归档)
   /opsx:archive            │
```

### 示例：发起你的第一个需求

```
# 在文档工程中
/opsx:propose add-wechat-pay
```

OpenSpec 会引导你完成 proposal → design → tasks 的全流程。在 proposal 头部标注文档来源：

```markdown
# Proposal: add-wechat-pay

> **PRD Reference**: docs/global/PRD.md (Section 3.2)
> **Architecture**: docs/global/architecture.md
> **Context**: docs/global/project-context.md
```

然后按照 [多代码工程需求开发指引](./multi-repo-dev-guide.md) 的 Phase C → D → E 走完整个开发流程。

---

> **最后提醒**：文档工程的初始化是一次性的重活，但做好之后的日常开发就很顺畅了——每次新需求只需要 `propose → design → tasks → write-plan → exec-plan → verify → archive` 这条流水线。文档工程会随着每次变更自动沉淀和完善。
