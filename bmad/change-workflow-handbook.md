# 三级变更流程操作手册

> 根据变更影响范围，选择对应流程，避免过度工程化或协调不足

---

## 变更等级判断规则

问自己：**"这个改动，其他工程需要知道吗？"**

| 等级 | 判断条件 | 流程 | 预计耗时 |
|------|---------|------|---------|
| 🔴 **大变更** | 涉及共享数据库变更 / 跨工程接口变更 | OpenSpec → BMAD → SuperPowers | 数小时到数天 |
| 🟡 **中变更** | 单工程新功能，不影响其他工程 | OpenSpec → SuperPowers | 1-3 小时 |
| 🟢 **小变更** | Bug 修复 / 微调 / 小优化 | 仅 SuperPowers | 15-60 分钟 |

> ⚠️ **升级规则**：中变更执行中途发现需要改共享接口？**立即停下来**，重新走大变更流程。

---

## 🔴 大变更：跨工程 / 共享数据库变更

> **完整流程：OpenSpec → BMAD → SuperPowers**
> 
> 示例：新增用户积分系统，需改共享数据库表结构，A/B/C 三个工程都要适配

### 第一阶段：OpenSpec — 规范对齐（在共享 spec 仓库操作）

| 步骤 | 操作 | 命令 / 动作 | 说明 |
|------|------|------------|------|
| 1 | 初始化 OpenSpec（首次） | `openspec init` | 在共享 spec 仓库中初始化 |
| 2 | 发起跨工程提案 | `/opsx:propose "新增用户积分系统，涉及共享DB表变更及A/B/C工程适配"` | AI 生成 proposal.md、specs/、design.md、tasks.md |
| 3 | 人工审查提案 | 审阅 `openspec/changes/<变更名>/proposal.md` | **重点**：影响范围是否覆盖了所有工程 |
| 4 | 审查技术方案 | 审阅 `openspec/changes/<变更名>/design.md` | **重点**：数据库 DDL、接口契约定义、各工程改动点 |
| 5 | 审查验收场景 | 审阅 `openspec/changes/<变更名>/specs/` | 确认每个工程的验收标准是否完整 |
| 6 | 确认任务清单 | 审阅 `openspec/changes/<变更名>/tasks.md` | 按工程拆分：DB变更 → A适配 → B适配 → C适配 |
| 7 | （可选）同步 spec | `/opsx:sync` | 确保 spec 与代码库状态一致 |

### 第二阶段：BMAD — 角色协作规划（每个工程各跑一轮）

| 步骤 | 操作 | 命令 / 动作 | 说明 |
|------|------|------------|------|
| 8 | 调用架构师代理 | Web UI 中输入 `*architect` | 基于 OpenSpec 的 design.md，补充本工程的架构细节 |
| 9 | 架构师审查 | 架构师审查 OpenSpec 产出的接口契约 | 确认 API 版本兼容性、数据库迁移方案 |
| 10 | 调用 Scrum Master | Web UI 中输入 `*sm` | SM 基于 OpenSpec tasks.md 生成**超详细开发故事** |
| 11 | 文档对齐检查 | PO 运行主检查清单 | 确保 PRD、架构文档、OpenSpec spec 三者一致 |
| 12 | 切换到 IDE | 将规划产物同步到 IDE 工作区 | 准备进入开发阶段 |

### 第三阶段：SuperPowers — 执行开发（每个工程的 IDE 中）

| 步骤 | 操作 | 命令 / 动作 | 说明 |
|------|------|------------|------|
| 13 | 头脑风暴（可选） | `/superpowers:brainstorm` | 实现方案仍有不确定性时使用 |
| 14 | 编写实现计划 | `/superpowers:write-plan` | 基于 BMAD 开发故事，生成分批次执行计划 |
| 15 | 人工审查计划 | 审阅生成的 plan | 确认批次划分合理，DB 变更在最前 |
| 16 | 执行计划（TDD循环） | `/superpowers:execute-plan` | 按批次：**Red**（写失败测试）→ **Green**（写最小代码）→ **Refactor** |
| 17 | 架构师检查点 | 每批任务完成后暂停，人工审查 | SuperPowers 自动暂停等待确认 |
| 18 | 子代理审查 | 自动触发 | 规格审查者 + 代码质量审查者，两级通过才标记完成 |
| 19 | 完成分支 | Git worktree 合并或 PR | `using-git-worktrees` 技能管理 |

### 第四阶段：收尾

| 步骤 | 操作 | 命令 / 动作 | 说明 |
|------|------|------------|------|
| 20 | 跨工程集成测试 | 人工 / CI 执行 | 验证 A/B/C 在新 DB 结构下的协作 |
| 21 | 归档变更 | `/opsx:archive` | 将 OpenSpec 变更归档到 archive/ |
| 22 | 更新共享 spec | 提交共享 spec 仓库 | 确保 DB schema spec、接口契约 spec 最新 |

---

## 🟡 中变更：单工程新功能

> **流程：OpenSpec → SuperPowers（跳过 BMAD）**
> 
> 示例：A 工程新增数据导出功能，不影响 B/C

| 步骤 | 操作 | 命令 / 动作 | 说明 |
|------|------|------------|------|
| 1 | 发起提案 | `/opsx:propose "A工程新增数据导出功能"` | AI 生成 proposal + design + tasks |
| 2 | 审查提案和设计 | 审阅 `proposal.md`、`design.md` | **确认不影响共享部分**，否则升级为大变更 |
| 3 | 确认任务清单 | 审阅 `tasks.md` | 确认范围合理 |
| 4 | 头脑风暴（可选） | `/superpowers:brainstorm` | 复杂功能才需要 |
| 5 | 编写实现计划 | `/superpowers:write-plan` | 将 OpenSpec tasks 细化为分批执行计划 |
| 6 | 审查计划 | 人工审阅 | 确认 OK |
| 7 | TDD 执行 | `/superpowers:execute-plan` | Red → Green → Refactor 循环 |
| 8 | 代码审查 | 自动子代理审查 | 规格审查 + 代码质量审查 |
| 9 | 验证（可选） | `/opsx:verify` | 验证代码是否符合 spec |
| 10 | 归档 | `/opsx:archive` | 归档变更 |

---

## 🟢 小变更：Bug 修复 / 微调

> **流程：仅 SuperPowers（跳过 OpenSpec 和 BMAD）**
> 
> 示例：修复 B 工程的日期格式显示 Bug

| 步骤 | 操作 | 命令 / 动作 | 说明 |
|------|------|------------|------|
| 1 | 系统化调试（如是Bug） | `systematic-debugging` 技能自动介入 | 4阶段：观察 → 假设 → 验证 → 修复 |
| 2 | 写失败测试 | TDD **Red** 阶段 | 先写一个能复现 Bug 的测试 |
| 3 | 最小修复 | TDD **Green** 阶段 | 写最少代码让测试通过 |
| 4 | 重构（如需要） | TDD **Refactor** 阶段 | 优化代码结构 |
| 5 | 代码审查 | 自动子代理审查 | 快速审查 |
| 6 | 提交 | 正常 Git 流程 | 直接提交或 PR |

---

## 流程对比一览

```
大变更（跨工程）:
  OpenSpec ──────────────────→ BMAD ──────────→ SuperPowers ────→ 归档
  propose → 审查 → confirm     architect → SM    brainstorm → plan
                                                  → TDD → review → merge
  ≈ 22 步

中变更（单工程新功能）:
  OpenSpec ──────────────────→ SuperPowers ────────────────────→ 归档
  propose → 审查 → confirm     brainstorm → plan → TDD → review
  ≈ 10 步

小变更（Bug/微调）:
  SuperPowers ──────────────→ 完成
  debug → TDD(Red→Green→Refactor) → review → commit
  ≈ 6 步
```

---

## 实操贴士

### 1. 大变更时共享 DB 的操作顺序铁律

```
先改 spec → 三方对齐确认 → 再改 DB schema → 最后改各工程代码
```

**绝对不能**先改代码再补 spec。

### 2. 中变更想升级为大变更时

执行 OpenSpec 中途发现需要改共享接口？**立即停下来**，重新走大变更流程，补充跨工程影响面分析。

### 3. SuperPowers TDD 的铁律

- 没有失败的测试，就不能编写生产代码
- Red → Green → Refactor，不能跳步
- 每批任务完成后必须暂停等待人工确认

### 4. BMAD 开发故事的质量标准

开发代理打开故事文件时，应能完全理解：
- **构建什么**（What）
- **如何构建**（How）
- **为什么这样构建**（Why）

如果故事文件缺少以上任一要素，退回 Scrum Master 补充。
