# 业务模块发现规则

扫描**当前工作区**代码，识别业务模块。不依赖 git，仅基于目录结构与配置文件。

## 通用流程

1. 识别项目类型（前端 / 后端 / 全栈）
2. 按下方信号源提取候选模块
3. 合并去重（同一路由前缀、同一菜单分组视为同一模块）
4. 生成模块清单，等待用户选择

## 信号源与优先级

| 信号来源 | 识别方式 | 模块名优先级 |
|----------|----------|--------------|
| 前端路由 | `routes` / `<Route>` / `meta.title` | meta.title > 目录名 |
| 页面目录 | `views/`、`pages/`、`features/` 子目录 | 目录名 → 中文化 |
| 菜单配置 | Layout 菜单、`menuName`、侧边栏配置 | 菜单文案 |
| 后端 API | Controller 包、`@RequestMapping` 前缀 | 包名/注释/路径段 |
| 领域层 | `domain/`、`modules/`、`services/` | 文件夹名 |

## 前端项目（Vue / React）

### 扫描入口

| 技术栈 | 路由文件 | 页面目录 |
|--------|----------|----------|
| Vue | `src/router/index.ts`、`routes.ts`、`router/index.js` | `src/views/`、`src/pages/` |
| React | `src/router/`、`src/routes/`、`App.tsx` 内 Route | `src/pages/`、`src/views/`、`src/features/` |

### 提取步骤

1. **读路由配置**：提取 `path`、`meta.title`（Vue）或路由注释/title（React）
2. **读菜单配置**：Layout 组件、侧边栏 `menuItems`、`menuName`
3. **扫页面目录**：一级子目录名作为模块候选（如 `views/order/` →「订单管理」）
4. **合并规则**：
   - 同一路由前缀（如 `/order/*`）合并为「订单管理」
   - 列表页 + 详情页 + 编辑页归属同一模块
   - 独立弹窗/子组件不单独成模块

### 模块名中文化

| 英文目录/组件 | 建议中文名 |
|---------------|------------|
| login / Login | 用户登录 |
| user / UserManagement | 用户管理 |
| order / Order | 订单管理 |
| tenant / TenantLease | 租住登记 |
| dashboard / Home | 工作台 |

优先使用 `meta.title` 或菜单文案；无中文时按上表或组件名推断，并在「说明」列标注「名称来自目录推断」。

## 后端项目（Java Spring / Node）

### Java Spring

| 扫描位置 | 提取内容 |
|----------|----------|
| `*Controller.java` | `@RequestMapping` 前缀、类注释、`@Tag` |
| `controller/` 包结构 | 子包名（如 `controller.order` → 订单） |
| `service/`、`domain/` | 业务域文件夹名 |

### Node / NestJS

| 扫描位置 | 提取内容 |
|----------|----------|
| `modules/`、`routes/` | 模块文件夹名 |
| `*.controller.ts` | 路由前缀、装饰器注释 |
| `*.module.ts` | 模块注册名 |

### 合并规则

- 同一 Controller 前缀下的 CRUD 接口归属同一模块
- `UserController` + `UserService` →「用户管理」

## 全栈项目

1. 以前端路由/菜单为主轴划分模块
2. 后端 Controller 路径用于补充「接口数」与交叉验证
3. 前后端模块名不一致时，优先采用前端展示名，备注后端包名

## 模块清单输出格式

```markdown
| 序号 | 模块名 | 说明 | 主要代码路径 | 页面/接口数 |
|------|--------|------|--------------|-------------|
| 1 | 用户登录 | 账号密码/验证码登录 | src/views/login/ | 1 页 |
| 2 | 订单管理 | 订单列表、详情、创建 | src/views/order/, OrderController | 3 页 / 8 接口 |
```

## 去重与边界

- **排除**：`utils/`、`components/`（通用组件）、`assets/`、测试目录、`node_modules/`
- **排除**：纯配置、构建脚本、CI 文件
- **子模块**：若用户需要细粒度，可在说明中列出子功能，不默认拆成多个顶级模块
- **未发现模块**：返回已扫描路径列表，建议用户指定目录或模块名

## slug 生成

- 中文模块「用户登录」→ `user-login`
- 中文模块「订单管理」→ `order-management`
- 多词英文目录 `TenantLease` → `tenant-lease`

用于输出文件名：`{slug}-需求文档-{YYYYMMDD}.md`
