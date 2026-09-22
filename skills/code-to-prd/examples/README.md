# 使用示例

## 触发方式

在 Cursor 中 @ 引用本 skill（`code-to-prd`），或使用下列自然语言触发。

## 示例 1：未指定模块 — 先发现再选择

**用户输入**：

> 帮我把这个项目的需求文档整理一下

**Agent 行为**：

1. 扫描当前工作区代码
2. 输出模块清单表格，例如：

| 序号 | 模块名 | 说明 | 主要代码路径 | 页面/接口数 |
|------|--------|------|--------------|-------------|
| 1 | 用户登录 | 账号密码登录 | src/views/login/ | 1 页 |
| 2 | 订单管理 | 订单 CRUD | src/views/order/ | 3 页 |
| 3 | 用户管理 | 用户列表与权限 | src/views/system/user/ | 2 页 |

3. 调用 AskQuestion 让用户多选模块
4. 为所选模块分别生成 `output/{slug}-需求文档-{YYYYMMDD}.md`

## 示例 2：指定模块 — 直接生成

**用户输入**：

> 整理用户登录模块的需求文档

**Agent 行为**：

1. 定位 `src/views/login/` 及相关路由
2. 按 checklist 分析代码
3. 生成 `output/user-login-需求文档-20260703.md`
4. 汇报摘要与开放问题

## 示例 3：指定代码路径

**用户输入**：

> 根据 src/views/order/ 目录整理订单模块 PRD，输出到 docs/requirements/

**Agent 行为**：

1. 以指定目录为分析范围
2. 写入用户指定路径：`docs/requirements/order-management-需求文档-20260703.md`

## 示例 4：多模块批量

**用户输入**：

> 整理登录和订单两个模块的需求

**Agent 行为**：

1. 跳过模块发现（用户已指定）
2. 生成两个文件：
   - `output/user-login-需求文档-20260703.md`
   - `output/order-management-需求文档-20260703.md`

## 输出物检查

生成的 PRD 应包含：

- [ ] 文档信息表（含来源代码路径）
- [ ] 模块概述（无技术术语）
- [ ] Mermaid 流程图（flowchart）
- [ ] Mermaid 时序图（sequenceDiagram）
- [ ] 字段说明表格
- [ ] 开放问题节

## 空项目或无模块

**用户输入**：

> 整理需求文档

**工作区为空或无 recognizable 结构时**：

Agent 应明确回复「未发现可识别业务模块」，并说明已扫描的路径，建议用户指定模块名或代码目录。

## 安装说明

将本 skill 目录复制到目标项目，或通过 Cursor skills 配置引用 `<skills-root>` 路径。Agent 执行时仅扫描**当前打开的工作区**，不依赖 git。
