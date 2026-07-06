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
- **Leaf 模板** — 基于 [Leaf](https://github.com/vapor/leaf) 渲染页面，支持 eject 后自定义 `index.leaf`
- **本地预览** — [Vapor](https://github.com/vapor/vapor) 开发服务器，一键浏览器预览
- **开箱即用** — 构建产物为静态文件，可直接部署 `.html/` 目录
- **GitHub Pages** — 一键部署到 `gh-pages` 分支

## 安装

需要 Swift 5.9+ 与 macOS 13+。

```bash
$ brew install jaywcjlove/tap/sgo
```

或者自己克隆编译：

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
linkly deploy        # 提交 .html/ 到本地 gh-pages
```

## 项目结构

```
my-links/
├── linkly.json          # 源配置（编辑此文件）
├── templates/           # 可选自定义 Leaf 模板
│   └── index.leaf
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
  "template": {
    "directory": "./templates"
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

### `template` 字段

| 字段 | 说明 |
|------|------|
| `directory` | Leaf 模板目录（默认 `./templates`） |

详见 [自定义模板](#自定义模板)。

## 命令

| 命令 | 说明 |
|------|------|
| `linkly init` | 初始化 `linkly.json` 并构建输出目录 |
| `linkly build` | 读取配置并生成输出目录 |
| `linkly deploy` | 将产物提交到本地 `gh-pages` 分支 |
| `linkly serve` | 构建并启动本地预览服务器（默认端口 `8080`） |
| `linkly preview` | 构建并在默认浏览器中打开 `index.html` |
| `linkly version` | 显示版本号 |
| `linkly add <label> <url> [<icon>]` | 快速添加链接到 `linkly.json` |
| `linkly template eject` | 导出内置 Leaf 模板到项目目录 |

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

# 部署到 GitHub Pages
linkly deploy
linkly deploy --build
linkly deploy -m "Update links"
```

## 部署

通过 `linkly deploy` 将构建产物提交到本地 `gh-pages` 分支，用于 [GitHub Pages](https://pages.github.com/) 发布：

```bash
linkly deploy
```

该命令会：

1. 指定 `--build` 时执行 `linkly build`
2. 切换到本地 `gh-pages` 分支（不存在则创建）
3. 用 `.html/` 产物替换分支内容，并添加 `.nojekyll` 文件
4. 在本地提交（不会推送到远程）

### 选项

| 选项 | 默认值 | 说明 |
|------|--------|------|
| `-o, --output` | `.html` | 要部署的输出目录 |
| `--branch` | `gh-pages` | 目标 git 分支 |
| `-m, --message` | `Deploy site` | 提交说明 |
| `--build` | — | 部署前先构建 HTML |

### 前置条件

- 项目目录必须是 git 仓库

### 示例

```bash
# 部署已有构建产物
linkly deploy

# 构建并部署
linkly deploy --build

# 自定义提交说明
linkly deploy --build -m "更新个人链接"

# 自定义分支
linkly deploy --branch gh-pages

# 手动推送到远程
git push origin gh-pages
```

推送完成后，在 GitHub 仓库 Settings → Pages 中，将发布源设置为 `gh-pages` 分支即可。

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

## 自定义模板

Linkly 使用 [Leaf](https://github.com/vapor/leaf) 模板引擎渲染页面。`linkly build` 和 `linkly serve` 共用同一套模板——`build` 生成静态 HTML，`serve` 通过 [Vapor](https://github.com/vapor/vapor) 动态渲染，便于本地预览。

### 导出模板

将默认模板导出到项目目录：

```bash
linkly template eject
```

会在 `./templates/index.leaf`（或 `linkly.json` 中配置的路径）生成模板文件。编辑后重新构建即可生效：

```bash
linkly build
# 或
linkly serve
```

覆盖已有模板：

```bash
linkly template eject --force
```

指定自定义模板目录：

```bash
linkly template eject --template-directory ./my-theme
```

### 模板解析规则

Linkly 按以下优先级选择模板目录：

1. **自定义模板** — 若 `./templates/index.leaf` 存在（路径由 `template.directory` 配置）
2. **内置模板** — Linkly 自带的默认模板

### 配置

```json
{
  "template": {
    "directory": "./templates"
  }
}
```

| 字段 | 说明 |
|------|------|
| `directory` | Leaf 模板目录路径（默认 `./templates`） |

### 模板变量

`index.leaf` 可使用以下变量（来自 `linkly.json` 及构建数据）：

| 变量 | 类型 | 说明 |
|------|------|------|
| `title` | `String` | 站点标题 |
| `bio` | `String` | 个人简介 |
| `theme` | `String` | 默认主题：`dark` 或 `light` |
| `primaryColor` | `String` | 主题色（如 `#00ff88`） |
| `avatarHTML` | `String` | 头像 HTML（需用 `#unsafeHTML` 输出） |
| `links` | `[Link]` | 链接列表 |

`links` 中每项包含：

| 字段 | 类型 | 说明 |
|------|------|------|
| `label` | `String` | 链接文字 |
| `url` | `String` | 跳转地址 |
| `iconHTML` | `String` | 图标 HTML（SVG 内联、`<img>` 或占位符） |

### Leaf 语法示例

```leaf
<html lang="zh-CN" data-theme="#(theme)">
  <title>#(title)</title>

  <style>
    :root {
      --primary: #(primaryColor);
    }
    /* CSS 十六进制颜色需用反斜杠转义 # */
    html[data-theme="dark"] {
      --bg: \#0f0f14;
    }
  </style>

  <body>
    #unsafeHTML(avatarHTML)
    <h1>#(title)</h1>
    <p>#(bio)</p>

    #for(link in links):
    <a href="#(link.url)">
      #unsafeHTML(link.iconHTML)
      <span>#(link.label)</span>
    </a>
    #endfor
  </body>
</html>
```

注意事项：

- `#(variable)` — 转义输出文本
- `#unsafeHTML(avatarHTML)` / `#unsafeHTML(link.iconHTML)` — 输出预渲染 HTML（头像、内联 SVG 图标）
- CSS 中十六进制颜色写作 `\#f5f7fa`，裸写 `#` 会被 Leaf 解析为模板语法
- `#for(link in links):` … `#endfor` — 遍历链接列表

### 推荐工作流

```bash
linkly init
linkly template eject      # 可选：导出自定义布局
# 编辑 templates/index.leaf
linkly build               # 生成 .html/index.html
linkly serve               # Vapor 本地预览
linkly deploy              # 发布到 GitHub Pages
```

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
swift run linkly deploy
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
