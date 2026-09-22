---
name: code-to-prd
description: >-
  从项目源代码反向整理业务需求文档（PRD），含 Mermaid 流程图/时序图与字段表格。
  Use when the user asks to generate requirements/PRD from code, 代码转需求,
  需求文档, 业务模块梳理, 反推需求, or mentions code-to-prd.
---

# 代码 → 业务需求文档

`<skills-root>` 指本 skill 目录（安装后通常为项目内的 `code-to-prd/` 或其绝对路径）。

## 使用时机

- 用户要求从代码整理/反推需求文档、PRD、业务需求
- 用户要求梳理项目涉及哪些业务模块
- 用户指定模块名，需要从代码生成含流程图的需求说明

## 核心原则

1. **业务视角**：产出面向产品/业务人员的文档，非技术设计文档
2. **有据可依**：所有需求点须能从代码中找到依据；无法推断的写入「开放问题」，**禁止编造**
3. **仅扫描当前工作区**：不依赖 git history 或 diff
4. **图表必备**：每个模块 PRD 至少包含 1 个 Mermaid 流程图 + 1 个时序图

## 输出约定

| 场景 | 输出 |
|------|------|
| 单模块 | `output/{模块slug}-需求文档-{YYYYMMDD}.md` |
| 多模块 | 每个模块单独一个 `.md` 文件 |
| 用户指定路径 | 优先采用用户路径 |

默认输出到**当前工作区**的 `output/` 目录；目录不存在则创建。

文档结构见 `<skills-root>/templates/prd-template.md`，写作规范见 `<skills-root>/references/prd-writing-rules.md`。

## 工作流程

复制并跟踪进度：

```
- [ ] Step 1: 判断是否已指定模块
- [ ] Step 2a: 未指定 → 模块发现 → 用户多选
- [ ] Step 2b: 已指定 → 定位代码范围
- [ ] Step 3: 读取 references 与 template
- [ ] Step 4: 按 checklist 分析代码（业务视角）
- [ ] Step 5: 撰写 PRD（含 Mermaid + 表格）
- [ ] Step 6: 写入 output/*.md
- [ ] Step 7: 输出摘要 + 开放问题清单
```

### Step 1: 判断是否已指定模块

**已指定**（满足任一）：
- 用户明确模块名（如「用户登录」「订单管理」）
- 用户指定了代码路径或目录（如 `src/views/order/`）

**未指定**：
- 用户说「整理需求文档」「梳理业务模块」但未点名模块
- 用户要求「整个项目的需求」

### Step 2a: 模块发现（未指定时）

读取 `<skills-root>/references/module-discovery.md`，扫描当前工作区：

1. 按技术栈识别入口（路由、目录、Controller、菜单等）
2. 合并去重，生成模块清单表格：

| 序号 | 模块名 | 说明 | 主要代码路径 | 页面/接口数 |
|------|--------|------|--------------|-------------|

3. **无模块时**：明确告知「未发现可识别业务模块」，列出已扫描的路径与原因，停止流程
4. **有模块时**：调用 `AskQuestion`，`allow_multiple: true`，让用户选择要整理的模块
5. 若用户已在对话中明确选择了模块，跳过 AskQuestion

### Step 2b: 定位代码（已指定时）

按模块名匹配相关代码：

- 前端：路由 `meta.title`、目录名、菜单名、组件名
- 后端：Controller 包名、`@RequestMapping` 前缀、Service 目录
- 全栈：前后端路径一并纳入「来源代码路径」

无法定位时，向用户确认范围后再继续。

### Step 3: 读取参考文档

按需读取：

- `<skills-root>/references/code-analysis-checklist.md` — 分析检查清单
- `<skills-root>/references/prd-writing-rules.md` — 写作与 Mermaid 规范
- `<skills-root>/templates/prd-template.md` — 输出模板

若项目含 Vue/React，可参考 sibling skill 的 pages/enums 提取思路（路由 title、Form label、枚举 Options），但**输出为业务 PRD，非测试用例**。

### Step 4: 分析代码

对每个选定模块，按 checklist 提取：

- 功能清单与优先级
- 角色与权限
- 页面/表单/列表字段
- 枚举值与状态流转
- 按钮动作、跳转、提交逻辑
- 校验规则与错误提示
- 异常与边界场景

内部可维护 pages/enums 对照表辅助撰写，**不写入 PRD 正文**。

### Step 5: 撰写 PRD

按 `<skills-root>/templates/prd-template.md` 结构撰写，须包含：

1. 文档信息表
2. 模块概述（1–2 段，无技术栈）
3. 角色与权限表
4. 功能清单表（REQ-001 递增）
5. **Mermaid flowchart** — 主业务流程
6. **Mermaid sequenceDiagram** — 至少 1 个核心交互
7. 页面/功能说明（操作步骤 + 预期结果）
8. 字段说明表
9. 业务规则与状态（可选 stateDiagram-v2）
10. 异常与边界
11. 开放问题

写作约束详见 `<skills-root>/references/prd-writing-rules.md`。

### Step 6: 写入文件

```bash
# 确保输出目录存在
mkdir -p output
```

逐模块写入 `output/{模块slug}-需求文档-{YYYYMMDD}.md`。

### Step 7: 输出摘要

向用户汇报：

- 已生成文件路径列表
- 每个模块的功能点数、REQ 数量
- **开放问题汇总**（需产品确认项）
- 若某模块代码覆盖不完整，说明缺口

## 模块 slug 命名

- 优先英文 kebab-case：`user-login`、`order-management`
- 中文模块可用拼音：`dingdan-guanli`
- 与模块名一一对应，文件名保持稳定

## 示例

详见 `<skills-root>/examples/README.md`。
