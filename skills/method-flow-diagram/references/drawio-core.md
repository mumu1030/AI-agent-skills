# draw.io 核心规范（流程图 / 时序图）

本文件从 drawio-skill 精简而来，仅覆盖本 skill 会生成的两类图。CLI 探测由 `scripts/check-drawio.sh` 完成；此处假定变量 `DRAWIO` 已是可用的 CLI 绝对路径。

## XML 骨架

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="drawio" version="26.0.0">
  <diagram name="Page-1">
    <mxGraphModel>
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <!-- user shapes start at id="2" -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

规则：

- `id="0"` 与 `id="1"` 必须存在
- 用户形状从 `id="2"` 递增
- 普通形状 `parent="1"`；容器内子节点 `parent="容器id"`，坐标相对容器
- 文本 style 必须含 `html=1`
- XML 注释内禁止 `--`
- 属性转义：`&amp;` `&lt;` `&gt;` `&quot;`
- 多行标签用 `&#xa;`，禁止字面 `\n`

## 配色（fillColor / strokeColor）

| 用途 | fillColor | strokeColor |
|------|-----------|-------------|
| 处理 / 服务 | `#dae8fc` | `#6c8ebf` |
| 开始结束 / 成功 | `#d5e8d4` | `#82b366` |
| 判断 / 队列 | `#fff2cc` | `#d6b656` |
| I/O / 网关 | `#ffe6cc` | `#d79b00` |
| 错误 | `#f8cecc` | `#b85450` |
| 外部 / 中性 | `#f5f5f5` | `#666666` |
| 安全 / 子流程 | `#e1d5e7` | `#9673a6` |

## 流程图形状

开始/结束：

```xml
<mxCell id="2" value="开始" style="ellipse;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
  <mxGeometry x="240" y="40" width="120" height="60" as="geometry" />
</mxCell>
```

处理（矩形）：

```xml
<mxCell id="3" value="查询用户" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
  <mxGeometry x="200" y="160" width="200" height="60" as="geometry" />
</mxCell>
```

判断（菱形）：

```xml
<mxCell id="4" value="参数填全了吗?" style="rhombus;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;" vertex="1" parent="1">
  <mxGeometry x="200" y="280" width="200" height="80" as="geometry" />
</mxCell>
```

I/O（平行四边形）：

```xml
<mxCell id="5" value="读取请求" style="shape=parallelogram;perimeter=parallelogramPerimeter;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;" vertex="1" parent="1">
  <mxGeometry x="200" y="420" width="200" height="60" as="geometry" />
</mxCell>
```

布局：TB，相邻形状空隙约 30–40px（垂直间距约 90px），避免连线过长。判断分支必须在边上标注 `是` / `否`。判断向左右分叉，再汇回中线。

## 时序图形状

Lifeline（参与者）：

```xml
<mxCell id="2" value="用户" style="shape=umlLifeline;perimeter=lifelinePerimeter;whiteSpace=wrap;html=1;container=1;collapsible=0;recursiveResize=0;outlineConnect=0;portConstraint=eastwest;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
  <mxGeometry x="80" y="40" width="100" height="400" as="geometry" />
</mxCell>
```

消息（边上必须有 `<mxGeometry>`，禁止自闭合）：

```xml
<!-- 同步调用 -->
<mxCell id="10" value="提交登录" style="html=1;verticalAlign=bottom;endArrow=block;exitX=1;exitY=0.2;exitDx=0;exitDy=0;entryX=0;entryY=0.2;entryDx=0;entryDy=0;" edge="1" parent="1" source="2" target="3">
  <mxGeometry relative="1" as="geometry" />
</mxCell>

<!-- 异步 -->
<mxCell id="11" value="发出通知" style="html=1;verticalAlign=bottom;endArrow=open;dashed=1;exitX=1;exitY=0.4;exitDx=0;exitDy=0;entryX=0;entryY=0.4;entryDx=0;entryDy=0;" edge="1" parent="1" source="3" target="4">
  <mxGeometry relative="1" as="geometry" />
</mxCell>

<!-- 返回 -->
<mxCell id="12" value="返回结果" style="html=1;verticalAlign=bottom;endArrow=open;dashed=1;strokeColor=#999999;exitX=0;exitY=0.3;exitDx=0;exitDy=0;entryX=1;entryY=0.3;entryDx=0;entryDy=0;" edge="1" parent="1" source="3" target="2">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

布局：LR，lifeline 间距约 200px。时间自上而下。`exitY` / `entryY` 随消息顺序递增，避免叠线。

## 连线（流程图）

每条边必须包含子元素 `<mxGeometry relative="1" as="geometry" />`。自闭合 `<mxCell ... edge="1" />` 不会渲染。

```xml
<mxCell id="20" value="" style="edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;" edge="1" parent="1" source="2" target="3">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

- 始终带 `rounded=1;orthogonalLoop=1;jettySize=auto`
- 同一形状有 2+ 连线时，分散 `exitX/exitY/entryX/entryY`（一边 3 条 → 0.25 / 0.5 / 0.75）
- 绕开中间形状时用 waypoints：

```xml
<mxGeometry relative="1" as="geometry">
  <Array as="points">
    <mxPoint x="500" y="50" />
  </Array>
</mxGeometry>
```

- 箭头落到目标前的最后一段直线 ≥ 20px，否则箭头叠在弯折上

## 间距与网格

- `x` `y` `width` `height` 均为 10 的倍数
- 简单图（≤8 节点）：水平 200px、垂直 90px
- 详细图（12–20）：水平 240px、垂直 90px
- 行/列之间留约 50px 走线走廊，不要把形状放在边必经的缝里
- 子节点相对父节点居中，避免斜线

## 导出

```bash
"$DRAWIO" -x -f png -e -s 2 -b 10 -o "{symbol}-flow.drawio.png" "{symbol}-flow.drawio"
```

| 参数 | 含义 |
|------|------|
| `-x` | 导出模式 |
| `-f png` | 格式 |
| `-e` | 把 diagram XML 嵌进 PNG，可用 draw.io 再打开 |
| `-s 2` | 缩放 |
| `-b 10` | 边距 |

macOS 若 PATH 里没有 `draw.io`，脚本会给出 `/Applications/draw.io.app/Contents/MacOS/draw.io`。

## PNG 自检（最多 2 轮）

导出后用视觉读 PNG，发现问题则改 XML 再导出：

| 检查 | 处理 |
|------|------|
| 形状重叠 | 拉开 ≥ 200px |
| 文字被裁切 | 加大 width/height |
| 箭头未接到形状 | 核对 edge 的 `source`/`target` 与现有 id |
| 形状在负坐标或远离主群 | 移到正坐标、靠近主群 |
| 边穿过无关形状 | 加 waypoints 或加大间距 |
| 多条边叠在同一路径 | 分散 entry/exit |

2 轮后仍有问题也先给用户看，不要无限修。

## 常见错误

| 错误 | 修法 |
|------|------|
| 缺少 `id="0"` / `id="1"` | 骨架里必须有 |
| 边不显示 | `source`/`target` 必须对应已有形状 id；边必须有 `<mxGeometry>` |
| macOS 找不到命令 | 用脚本给出的绝对路径 |
| 特殊字符 | `value` 里用 XML 实体 |
| 箭头弯折处叠箭头 | 加大间距或加 waypoints |
| 标签写成 `\n` | 改用 `&#xa;` |
