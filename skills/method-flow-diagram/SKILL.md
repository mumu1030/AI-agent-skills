---
name: method-flow-diagram
description: 根据用户指定的方法或接口分析代码逻辑，用测试人员能看懂的自然语言画出一张流程图或时序图。已安装 draw.io 则导出 .drawio/PNG，否则输出 Mermaid。Use when the user asks to 画流程图, 时序图, 方法调用流程, 接口逻辑图, visualize a method/interface, or understand code control flow.
---

# 方法/接口逻辑图

根据用户指定的方法或接口，只读代码、画出一张逻辑图（流程图或时序图）。读者是**测试人员**：图上用场景语言写清系统在做什么、用户会看到什么。不改业务代码、不提交。

## 必填输入

缺则先问，不问其它：

| 项目 | 说明 |
|------|------|
| 目标 | 方法名、接口名、`文件路径:符号`，或编辑器选中的代码 |

可选：输出路径。未指定时写到当前工作目录。`{symbol}` 取方法/接口名，非法路径字符换成 `-`：

- 有 draw.io：`{symbol}-flow.drawio` 与 `{symbol}-flow.drawio.png`
- 无 draw.io：`{symbol}-flow.md`

## 工作流程

```
- [ ] Step 1: 定位代码
- [ ] Step 2: 选择图类型
- [ ] Step 3: 探测 draw.io
- [ ] Step 4: 出图
- [ ] Step 5: 向用户展示
```

### 1. 定位代码

在仓库内找到定义与实现。接口则读声明及主要实现类。

沿调用链向下跟 **2–3 层**（对本方法理解必要的协作对象：存储、下游接口、其它模块）。禁止展开成全系统图。

只依据代码下结论，不臆造调用。内部分析可用方法名，**画到图上必须翻译成场景语言**。节点宜 **12–20** 个（含开始/结束）。

要画全测试能感知的分支，不要只画成功主干。按本方法实际存在的路径取舍，不要硬套：

- 入参/权限等校验失败
- 依赖不可用（查不到数据、下游失败、外部服务超时）
- 需要用户确认或补充信息
- 中途取消、超时；成功与失败时页面分别会看到什么

仍合并：日志、纯转发、内部重试、用户看不到的实现细节。用户看到不同结果的路径不要合成一个节点。

图上标签规则：

- 节点 / 参与者 / 消息用中文表述系统当前行为及用户可见结果
- 判断框写成测试能理解的问题（如「必填参数是否齐全？」「是否需要用户确认？」）
- 时序图参与者用业务角色，按本次代码实际出现的协作方命名（常见：用户、页面、本功能、存储、外部服务；不要写类名）
- 流程图只保留 **一个**「结束」节点，错误/确认/取消等出口都汇到它
- **不要**写方法名、类名、接口路径，以及协议/序列化等实现词（如 SSE、JSON、RPC）

| 不要写 | 改成（按代码语义翻译） |
|--------|------------------------|
| `loadOrderById` | 根据编号查订单 |
| `validateRequest` | 检查必填项是否齐全 |
| `saveAndNotify` / 推送完成事件 | 保存结果并通知页面 |

### 2. 选择图类型

读取 [references/diagram-choice.md](references/diagram-choice.md)，按规则选一张图：

- **时序图**：多个角色按时间交互（用户、页面、接口、存储等）
- **流程图**：单方法内部怎么走（分支、循环、提前结束）
- 两者都明显时以主路径为准，只出一张图
- 用户点名图类型则服从

### 3. 探测 draw.io

在本 skill 根目录（即本 SKILL.md 所在目录）执行，路径以 skill 实际安装位置为准：

```bash
bash "<本skill根目录>/scripts/check-drawio.sh"
```

- 退出码 0：stdout 为 CLI 绝对路径，走 draw.io
- 退出码非 0：stdout 为 `NOT_FOUND`，走 Mermaid

不要在本文件重复探测逻辑。

### 4. 出图

**有 CLI：** 读取 [references/drawio-core.md](references/drawio-core.md)，写入 `.drawio` XML，用探测到的 CLI 导出 PNG：

```bash
"$DRAWIO" -x -f png -e -s 2 -b 10 -o "{symbol}-flow.drawio.png" "{symbol}-flow.drawio"
```

导出后读 PNG 自检（重叠、截断、断线、越界），最多修复 2 轮。

**无 CLI：** 按 [references/diagram-choice.md](references/diagram-choice.md) 的 Mermaid 模板写入 `{symbol}-flow.md`，聊天里直接展示代码块。不要改走 diagrams.net URL。

### 5. 向用户展示

1. 报告文件路径
2. 展示图预览（PNG 或 Mermaid）
3. 有 draw.io 时可提示用桌面端打开 `.drawio` 微调：`open "{symbol}-flow.drawio"`
