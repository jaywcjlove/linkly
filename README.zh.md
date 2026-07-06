Linkly
===

[![Buy me a coffee](https://img.shields.io/badge/Buy_Me_a_Coffee-ffdd00?logo=buy-me-a-coffee&logoColor=black)](https://jaywcjlove.github.io/#/sponsor)
[![Follow On X](https://img.shields.io/badge/Follow%20on%20X-333333?logo=x&logoColor=white)](https://x.com/jaywcjlove)
[![English](https://jaywcjlove.github.io/sb/lang/english.svg)](README.md)

使用 Swift 开发的命令行工具，通过 `linkly.json` 配置文件生成美观、响应式的链接聚合单页（类似 Linktree）。

## 特性

- **单文件配置** — 在 `linkly.json` 中管理个人资料与链接
- **响应式 HTML** — 移动端适配，支持暗黑/亮色主题与页面内切换
- **智能图标** — 内置 SVG Logo，按 URL 域名自动匹配，无需填写 `icon`
- **资源优化** — SVG 内联到 HTML；PNG/JPG 输出到 `assets/` 目录
- **本地预览** — 内置开发服务器，一键浏览器预览
- **开箱即用** — 构建产物为静态文件，可直接部署 `.html/` 目录

## 安装

需要 Swift 5.9+ 与 macOS 13+。

```bash
git clone https://github.com/jaywcjlove/Linkly.git
cd Linkly
swift build -c release
cp .build/release/linkly /usr/local/bin/
```

或不安装，直接运行：

```bash
swift run linkly --help
```

## 快速开始

```bash
mkdir my-links && cd my-links

linkly init          # 生成 linkly.json 并构建 .html/
linkly preview       # 重新构建并在浏览器中打开
linkly serve         # 重新构建并启动 http://localhost:8080
```

## 项目结构

```
my-links/
├── linkly.json          # 源配置（编辑此文件）
├── avatar.jpg           # 可选头像
├── logo.png             # 可选自定义栅格图标
└── .html/               # 构建产物（部署此目录）
    ├── index.html
    └── assets/
        ├── avatar.jpg
        └── logo.png
```

## 配置文件

在项目目录中创建或编辑 `linkly.json`：

```json
{
  "site": {
    "title": "小弟调调",
    "bio": "macOS/iOS 开发者 | Open Source Maintainer",
    "avatar": "./avatar.jpg",
    "theme": "dark",
    "primary_color": "#00ff88"
  },
  "links": [
    {
      "label": "GitHub",
      "url": "https://github.com/jaywcjlove"
    },
    {
      "label": "Custom",
      "url": "https://example.com",
      "icon": "./logo.png"
    }
  ]
}
```

### `site` 字段

| 字段 | 说明 |
|------|------|
| `title` | 页面标题与个人名称 |
| `bio` | 简介，显示在标题下方 |
| `avatar` | 头像本地路径（如 `./avatar.jpg`） |
| `theme` | 默认主题：`dark` 或 `light` |
| `primary_color` | 主题色，十六进制（如 `#00ff88`） |

### `links` 字段

| 字段 | 必填 | 说明 |
|------|------|------|
| `label` | 是 | 链接按钮文字 |
| `url` | 是 | 跳转地址 |
| `icon` | 否 | 自定义图标路径；省略则按 URL 域名自动匹配 |

`icon` 为可选字段。省略时，Linkly 会根据链接 URL 的域名，在内置图标库中查找对应 SVG（例如 `github.com` → `github.svg`）。

## 命令

| 命令 | 说明 |
|------|------|
| `linkly init` | 初始化 `linkly.json` 并构建输出目录 |
| `linkly build` | 读取配置并生成输出目录 |
| `linkly serve` | 构建并启动本地预览服务器（默认端口 `8080`） |
| `linkly preview` | 构建并在默认浏览器中打开 `index.html` |
| `linkly version` | 显示版本号 |
| `linkly add <label> <url> [<icon>]` | 快速添加链接到 `linkly.json` |

### 通用选项

多数命令支持：

- `-d, --directory <path>` — 包含 `linkly.json` 的项目目录（默认当前目录）
- `-o, --output <path>` — 输出目录（默认 `.html`）

### 示例

```bash
# 在当前目录初始化
linkly init

# 构建到自定义输出目录
linkly build -o dist

# 添加链接（icon 可省略）
linkly add Twitter https://twitter.com/you
linkly add Blog https://example.com ./logo.png --build

# 指定端口启动，跳过构建
linkly serve -p 3000 --no-build
```

## 图标

### 自动识别

未设置 `icon` 时，Linkly 从 URL 提取域名，在 `Resources/Icons/` 内置资源中查找：

1. 完整域名 — `threads.com` → `threads.svg`
2. 域名分段 — `github.com` → `github.svg`
3. `mailto:` 链接 — `email.svg`
4. 兜底 — `website.svg`

### 自定义图标

| 格式 | 处理方式 |
|------|----------|
| **SVG**（`./icon.svg`） | 内联写入 `index.html` |
| **PNG / JPG**（`./logo.png`） | 复制到 `assets/` 并在 HTML 中引用 |
| **远程 URL**（`https://...`） | 直接在 HTML 中引用 |

### 内置图标

已内置：`github`、`x`、`twitter`、`instagram`、`linkedin`、`youtube`、`telegram`、`discord`、`facebook`、`reddit`、`medium`、`tiktok`、`twitch`、`bilibili`、`wechat`、`weibo`、`threads`、`bsky`、`mastodon`、`substack`、`docker`、`npmjs`、`email`、`website` 等。

添加新图标：将 SVG 放入 `Sources/linkly/Resources/Icons/`，文件名与域名或品牌对应（如 `mysite.com.svg` 或 `mysite.svg`），重新编译 Linkly 即可。

## 开发

### 构建

```bash
swift build -c release
# 可执行文件：.build/release/linkly
```

### 本地试用

```bash
swift run linkly --help
swift run linkly init
swift run linkly build
swift run linkly serve
swift run linkly preview
swift run linkly version
swift run linkly add GitHub https://github.com/you
```

### 发布

```bash
swift build -c release --arch arm64 --arch x86_64
tar -czf ./linkly.tar.gz -C ./.build/release linkly

brew tap jaywcjlove/tap
cd "$(brew --repository jaywcjlove/tap)"
```

## 许可证

基于 [MIT License](LICENSE) 授权。