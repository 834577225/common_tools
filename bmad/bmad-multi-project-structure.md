# BMAD 多项目目录结构模板

> 适用于 A、B、C 多工程共享数据库、存在调用关系的场景
> 包含 BMAD + OpenSpec + SuperPowers 三件套的完整目录结构

---

## 整体项目布局

```
workspace/
├── project-a/                    # 工程 A
│   ├── .bmad/                    # BMAD 配置（项目级）
│   ├── .superpowers/             # SuperPowers 技能（项目级）
│   ├── openspec/                 # OpenSpec 规范（项目级）
│   └── src/                      # 源代码
│
├── project-b/                    # 工程 B
│   ├── .bmad/
│   ├── .superpowers/
│   ├── openspec/
│   └── src/
│
├── project-c/                    # 工程 C
│   ├── .bmad/
│   ├── .superpowers/
│   ├── openspec/
│   └── src/
│
└── shared-specs/                 # ⭐ 共享规范仓库（独立 Git 仓库）
    ├── openspec/
    │   ├── specs/
    │   │   ├── database/
    │   │   └── apis/
    │   └── changes/
    └── README.md
```

---

## 1. BMAD 目录结构（每个工程内）

```
project-x/.bmad/
├── bmad-core/                        # BMAD 核心框架
│   ├── agents/                       # 代理角色定义
│   │   ├── analyst.md                # 分析师
│   │   ├── pm.md                     # 产品经理
│   │   ├── architect.md              # 架构师
│   │   ├── scrum-master.md           # Scrum Master
│   │   ├── developer.md              # 开发者
│   │   └── qa.md                     # QA 测试架构师
│   │
│   ├── tasks/                        # 任务模板
│   │   ├── create-brief.md           # 创建项目简报
│   │   ├── create-prd.md             # 创建 PRD
│   │   ├── create-architecture.md    # 创建架构文档
│   │   ├── create-story.md           # 创建开发故事
│   │   └── review-checklist.md       # 审查检查清单
│   │
│   ├── templates/                    # 文档模板
│   │   ├── brief-template.md         # 项目简报模板
│   │   ├── prd-template.md           # PRD 模板
│   │   ├── architecture-template.md  # 架构文档模板
│   │   ├── story-template.md         # 开发故事模板
│   │   └── template-format.md        # 模板格式定义
│   │
│   ├── checklists/                   # 检查清单
│   │   ├── po-master-checklist.md    # PO 主检查清单
│   │   ├── architecture-checklist.md # 架构检查清单
│   │   └── story-checklist.md        # 故事检查清单
│   │
│   ├── data/                         # 持久化配置
│   │   ├── technical-preferences.md  # 技术偏好（影响所有代理行为）
│   │   └── project-context.md        # 项目上下文
│   │
│   └── personas/                     # 代理人格定义（可选）
│       ├── full-stack-team.md        # 全栈团队人格包
│       └── custom-personas/          # 自定义人格
│
├── docs/                             # BMAD 规划阶段产出物
│   ├── brief.md                      # 项目简报
│   ├── prd.md                        # 产品需求文档
│   ├── architecture.md               # 架构文档
│   ├── epics/                        # 史诗
│   │   ├── epic-01-xxx.md
│   │   └── epic-02-xxx.md
│   └── stories/                      # 开发故事
│       ├── story-01-xxx.md
│       ├── story-02-xxx.md
│       └── ...
│
└── .bmad-config.yaml                 # BMAD 项目配置文件
```

---

## 2. SuperPowers 目录结构（每个工程内）

```
project-x/.superpowers/
├── skills/                           # 技能目录
│   ├── using-superpowers/            # 元技能（必需）
│   │   └── SKILL.md
│   │
│   ├── test-driven-development/      # TDD 技能
│   │   └── SKILL.md
│   │
│   ├── brainstorming/                # 头脑风暴技能
│   │   └── SKILL.md
│   │
│   ├── writing-plans/                # 计划编写技能
│   │   └── SKILL.md
│   │
│   ├── subagent-driven-development/  # 子代理驱动开发
│   │   └── SKILL.md
│   │
│   ├── systematic-debugging/         # 系统化调试
│   │   └── SKILL.md
│   │
│   ├── using-git-worktrees/          # Git Worktree 管理
│   │   └── SKILL.md
│   │
│   └── custom/                       # ⭐ 项目自定义技能
│       ├── project-conventions/      # 项目编码规范
│       │   └── SKILL.md
│       └── shared-db-rules/          # 共享数据库操作规范
│           └── SKILL.md
│
├── commands/                         # Slash 命令定义
│   ├── brainstorm.md
│   ├── write-plan.md
│   └── execute-plan.md
│
├── knowledge/                        # 知识库（反模式、最佳实践）
│   ├── antipatterns.md
│   └── best-practices.md
│
└── .superpowers-config.yaml          # SuperPowers 配置
```

---

## 3. OpenSpec 目录结构（每个工程内）

```
project-x/openspec/
├── specs/                            # 规格文档
│   ├── feature-xxx.md                # 功能规格
│   └── ...
│
├── changes/                          # 变更记录
│   ├── active/                       # 进行中的变更
│   │   └── <变更名>/
│   │       ├── proposal.md           # 提案（理由、背景）
│   │       ├── specs/                # 验收场景
│   │       │   └── acceptance.md
│   │       ├── design.md             # 技术方案
│   │       └── tasks.md              # 任务清单
│   │
│   └── archive/                      # 已归档的变更
│       └── <已完成变更名>/
│           ├── proposal.md
│           ├── specs/
│           ├── design.md
│           └── tasks.md
│
├── schemas/                          # Schema 定义（可选）
│   └── ...
│
└── openspec.config.yaml              # OpenSpec 配置
```

---

## 4. ⭐ 共享规范仓库结构（独立 Git 仓库）

```
shared-specs/
├── openspec/
│   ├── specs/                        # 共享规格
│   │   ├── database/                 # 数据库 Schema Spec
│   │   │   ├── users-table.md        # users 表规格
│   │   │   ├── orders-table.md       # orders 表规格
│   │   │   ├── points-table.md       # 积分表规格
│   │   │   └── _schema-index.md      # Schema 索引
│   │   │
│   │   └── apis/                     # 接口契约 Spec
│   │       ├── a-calls-b/            # A → B 的接口
│   │       │   ├── get-user.md       # GET /api/user
│   │       │   └── create-order.md   # POST /api/order
│   │       ├── b-calls-c/            # B → C 的接口
│   │       │   └── send-notify.md    # POST /api/notify
│   │       └── _api-index.md         # API 索引
│   │
│   └── changes/                      # 跨工程变更记录
│       ├── active/                   # 进行中
│       │   └── add-user-points/      # 示例：新增积分系统
│       │       ├── proposal.md       # 跨工程提案
│       │       ├── specs/
│       │       │   ├── db-changes.md # DB 变更验收
│       │       │   ├── a-changes.md  # A 工程验收
│       │       │   ├── b-changes.md  # B 工程验收
│       │       │   └── c-changes.md  # C 工程验收
│       │       ├── design.md         # 跨工程技术方案
│       │       └── tasks.md          # 全局任务清单
│       │
│       └── archive/                  # 已归档
│
├── conventions/                      # 共享约定
│   ├── db-naming.md                  # 数据库命名规范
│   ├── api-versioning.md             # API 版本管理规范
│   ├── error-codes.md                # 统一错误码
│   └── data-types.md                 # 通用数据类型定义
│
└── README.md                         # 仓库说明
```

---

## 5. 各工程技术偏好配置模板

### `.bmad/bmad-core/data/technical-preferences.md`

```markdown
# 技术偏好配置

## 项目信息
- 项目名称：[Project-A / Project-B / Project-C]
- 所属工程组：[工程组名称]

## 共享基础设施
- 共享数据库：[PostgreSQL / MySQL] @ [host:port/dbname]
- 消息队列：[RabbitMQ / Kafka]（如有）
- 缓存：[Redis]（如有）

## 技术栈
- 语言：[Java / Go / Python / Node.js]
- 框架：[Spring Boot / Gin / FastAPI / NestJS]
- ORM：[MyBatis / GORM / SQLAlchemy / TypeORM]
- 测试框架：[JUnit / testing / pytest / Jest]

## 代码规范
- 缩进：[spaces/tabs] × [2/4]
- 命名风格：[camelCase / snake_case]
- Git 分支策略：[GitFlow / TrunkBased]
- Commit 规范：[Conventional Commits]

## 共享数据库操作规范
- DDL 变更必须通过迁移脚本（Migration）
- 先在 shared-specs 中提 proposal，三方确认后才能执行 DDL
- 禁止直接操作生产库
- 所有表变更需更新对应的 database spec

## 跨工程调用规范
- API 版本管理：URL 路径版本（/v1/, /v2/）
- 接口变更必须先更新 shared-specs/apis/ 中的契约
- 向后兼容期：至少保留 2 个版本
- 超时设置：默认 [3s]，可根据接口特性调整
```

---

## 6. 自定义 SuperPowers 技能模板

### `.superpowers/skills/custom/shared-db-rules/SKILL.md`

```markdown
---
name: shared-db-rules
description: 共享数据库操作规范技能
triggers:
  - database
  - migration
  - DDL
  - schema
  - table
---

# 共享数据库操作规范

## 核心规则

1. **Spec 先行**：任何 DB 变更必须先在 shared-specs/database/ 中有对应 spec
2. **迁移脚本**：所有 DDL 通过版本化迁移脚本执行，禁止手动 SQL
3. **三方确认**：涉及共享表的变更，A/B/C 三方必须在 spec 中签字确认
4. **向后兼容**：
   - 新增列：必须有默认值或允许 NULL
   - 删除列：先标记为 deprecated，下个版本再物理删除
   - 修改类型：禁止直接修改，应新增列 + 数据迁移 + 删旧列
5. **索引变更**：大表加索引必须在低峰期执行，并在 spec 中注明

## 测试要求

- 每个迁移脚本必须有对应的回滚脚本
- 迁移前后数据一致性验证
- 相关工程的集成测试必须全部通过

## 禁止操作

- ❌ 直接操作生产数据库
- ❌ 未经 spec 确认的 DDL
- ❌ 删除正在被其他工程使用的列/表
- ❌ 修改主键类型
```

---

## 快速初始化命令

### 初始化完整工程结构

```bash
# 1. 初始化 BMAD
cd project-x
npx bmad-method install

# 2. 初始化 SuperPowers（根据具体安装方式）
# 复制 .superpowers 目录到项目根目录

# 3. 初始化 OpenSpec
openspec init

# 4. 初始化共享 spec 仓库
cd shared-specs
openspec init
```

### 将自定义技能复制到新工程

```bash
# 复制共享 DB 操作规范技能
cp -r project-a/.superpowers/skills/custom/shared-db-rules/ project-b/.superpowers/skills/custom/shared-db-rules/

# 复制技术偏好配置（注意修改项目名称）
cp project-a/.bmad/bmad-core/data/technical-preferences.md project-b/.bmad/bmad-core/data/technical-preferences.md
```
