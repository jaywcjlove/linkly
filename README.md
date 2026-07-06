Linkly
===

[![Buy me a coffee](https://img.shields.io/badge/Buy_Me_a_Coffee-ffdd00?logo=buy-me-a-coffee&logoColor=black)](https://jaywcjlove.github.io/#/sponsor)
[![Follow On X](https://img.shields.io/badge/Follow%20on%20X-333333?logo=x&logoColor=white)](https://x.com/jaywcjlove)
[![中文](https://jaywcjlove.github.io/sb/lang/chinese.svg)](README.zh.md)

A Swift command-line tool that generates beautiful, responsive link aggregation pages (like Linktree) from a single `linkly.json` config file.

## Features

- **Single-file config** — manage your profile and links in `linkly.json`
- **Responsive HTML** — mobile-friendly, dark/light theme with in-page toggle
- **Smart icons** — built-in SVG logos auto-matched by URL domain; no `icon` field required
- **Optimized assets** — SVG icons inlined into HTML; PNG/JPG copied to `assets/`
- **Leaf templates** — pages rendered with [Leaf](https://github.com/vapor/leaf); eject and customize `index.leaf`
- **Local preview** — [Vapor](https://github.com/vapor/vapor)-powered dev server and one-command browser preview
- **Deploy-ready output** — static files in `.html/` (or a custom directory)
- **GitHub Pages** — one-command deploy to the `gh-pages` branch

## Installation

Requires Swift 5.9+ and macOS 13+.

```bash
git clone https://github.com/jaywcjlove/Linkly.git
cd Linkly
swift build -c release
cp .build/release/linkly /usr/local/bin/
```

Or run without installing:

```bash
swift run linkly --help
```

## Quick Start

```bash
mkdir my-links && cd my-links

linkly init          # create linkly.json and build .html/
linkly preview       # rebuild and open in browser
linkly serve         # rebuild and serve at http://localhost:8080
linkly deploy        # commit .html/ to local gh-pages
```

## Project Layout

```
my-links/
├── linkly.json          # source config (edit this)
├── templates/           # optional custom Leaf templates
│   └── index.leaf
├── avatar.jpg           # optional profile image
├── logo.png             # optional custom raster icon
└── .html/               # build output (deploy this)
    ├── index.html
    └── assets/
        ├── avatar.jpg
        └── logo.png
```

## Configuration

Create or edit `linkly.json` in your project directory:

```json
{
  "site": {
    "title": "小弟调调",
    "bio": "macOS/iOS Developer | Open Source Maintainer",
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

### `site` fields

| Field | Description |
|-------|-------------|
| `title` | Page title and profile heading |
| `bio` | Short bio shown under the title |
| `avatar` | Local path to profile image (`./avatar.jpg`) |
| `theme` | Default theme: `dark` or `light` |
| `primary_color` | Accent color as hex (e.g. `#00ff88`) |

### `links` fields

| Field | Required | Description |
|-------|----------|-------------|
| `label` | Yes | Link button text |
| `url` | Yes | Destination URL |
| `icon` | No | Custom icon path; omit to auto-detect from URL domain |

The `icon` field is optional. When omitted, Linkly looks up a matching SVG in its bundled icon library based on the link URL's domain (e.g. `github.com` → `github.svg`).

### `template` fields

| Field | Description |
|-------|-------------|
| `directory` | Leaf template directory (default: `./templates`) |

See [Custom Templates](#custom-templates) for details.

## Commands

| Command | Description |
|---------|-------------|
| `linkly init` | Create default `linkly.json` and build output |
| `linkly build` | Read config and generate output directory |
| `linkly deploy` | Commit output to the local `gh-pages` branch |
| `linkly serve` | Build and start local preview server (default port `8080`) |
| `linkly preview` | Build and open `index.html` in the default browser |
| `linkly version` | Print version number |
| `linkly add <label> <url> [<icon>]` | Append a link to `linkly.json` |
| `linkly template eject` | Copy bundled Leaf templates to your project |

### Common options

Most commands accept:

- `-d, --directory <path>` — project directory containing `linkly.json` (default: current directory)
- `-o, --output <path>` — output directory (default: `.html`)

### Examples

```bash
# Initialize in current directory
linkly init

# Build to a custom output folder
linkly build -o dist

# Add links (icon is optional)
linkly add Twitter https://twitter.com/you
linkly add Blog https://example.com ./logo.png --build

# Serve on a custom port without rebuilding
linkly serve -p 3000 --no-build

# Deploy to GitHub Pages
linkly deploy
linkly deploy --build
linkly deploy -m "Update links"
```

## Deploy

Prepare your site for [GitHub Pages](https://pages.github.com/) by committing the build output to the local `gh-pages` branch:

```bash
linkly deploy
```

This command will:

1. Run `linkly build` when `--build` is specified
2. Check out the local `gh-pages` branch (create it if missing)
3. Replace branch contents with `.html/` output and add a `.nojekyll` file
4. Commit locally (does not push to remote)

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `-o, --output` | `.html` | Output directory to deploy |
| `--branch` | `gh-pages` | Target git branch |
| `-m, --message` | `Deploy site` | Commit message |
| `--build` | — | Build HTML before deploy |

### Prerequisites

- The project directory must be a git repository

### Examples

```bash
# Deploy existing build output
linkly deploy

# Build and deploy
linkly deploy --build

# Custom commit message
linkly deploy --build -m "Update profile links"

# Custom branch
linkly deploy --branch gh-pages

# Push to remote manually
git push origin gh-pages
```

After pushing, enable GitHub Pages in your repository settings and set the source to the `gh-pages` branch.

## Icons

### Auto-detection

When `icon` is not set, Linkly extracts the domain from the URL and searches bundled icons in `Resources/Icons/`:

1. Full hostname — `threads.com` → `threads.svg`
2. Domain segment — `github.com` → `github.svg`
3. `mailto:` links — `email.svg`
4. Fallback — `website.svg`

### Custom icons

| Format | Behavior |
|--------|----------|
| **SVG** (`./icon.svg`) | Inlined directly into `index.html` |
| **PNG / JPG** (`./logo.png`) | Copied to `assets/` and referenced in HTML |
| **Remote URL** (`https://...`) | Referenced as-is in HTML |

### Bundled icons

Shipped logos include: `github`, `x`, `twitter`, `instagram`, `linkedin`, `youtube`, `telegram`, `discord`, `facebook`, `reddit`, `medium`, `tiktok`, `twitch`, `bilibili`, `wechat`, `weibo`, `threads`, `bsky`, `mastodon`, `substack`, `docker`, `npmjs`, `email`, `website`, and more.

To add a new icon, drop an SVG into `Sources/linkly/Resources/Icons/` named after the domain or brand (e.g. `mysite.com.svg` or `mysite.svg`), then rebuild Linkly.

## Custom Templates

Linkly renders pages with [Leaf](https://github.com/vapor/leaf). Both `linkly build` and `linkly serve` use the same template engine — `build` writes static HTML, `serve` renders dynamically via [Vapor](https://github.com/vapor/vapor) for local preview.

### Eject templates

Export the default template into your project:

```bash
linkly template eject
```

This creates `./templates/index.leaf` (or the path set in `linkly.json`). Edit the file, then rebuild:

```bash
linkly build
# or
linkly serve
```

Overwrite an existing template:

```bash
linkly template eject --force
```

Use a custom template directory:

```bash
linkly template eject --template-directory ./my-theme
```

### Template resolution

Linkly picks a template directory in this order:

1. **Custom** — if `./templates/index.leaf` exists (path from `template.directory` in config)
2. **Bundled** — built-in default template shipped with Linkly

### Configuration

```json
{
  "template": {
    "directory": "./templates"
  }
}
```

| Field | Description |
|-------|-------------|
| `directory` | Path to your Leaf templates (default: `./templates`) |

### Template variables

`index.leaf` receives these variables from `linkly.json`:

| Variable | Type | Description |
|----------|------|-------------|
| `title` | `String` | Site title |
| `bio` | `String` | Bio text |
| `theme` | `String` | Default theme: `dark` or `light` |
| `primaryColor` | `String` | Accent color (e.g. `#00ff88`) |
| `avatarHTML` | `String` | Pre-rendered avatar HTML (use `#unsafeHTML`) |
| `links` | `[Link]` | Link list |

Each item in `links`:

| Field | Type | Description |
|-------|------|-------------|
| `label` | `String` | Link label |
| `url` | `String` | Link URL |
| `iconHTML` | `String` | Pre-rendered icon HTML (SVG inline, `<img>`, or placeholder) |

### Leaf syntax examples

```leaf
<html lang="zh-CN" data-theme="#(theme)">
  <title>#(title)</title>

  <style>
    :root {
      --primary: #(primaryColor);
    }
    /* Escape # in CSS hex colors with backslash */
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

Notes:

- Use `#(variable)` for escaped text output
- Use `#unsafeHTML(avatarHTML)` / `#unsafeHTML(link.iconHTML)` for pre-rendered HTML (avatars, inline SVG icons)
- In CSS, escape hex colors as `\#f5f7fa` — a bare `#` is parsed as Leaf syntax
- Use `#for(link in links):` … `#endfor` to iterate links

### Workflow

```bash
linkly init
linkly template eject      # optional: customize layout
# edit templates/index.leaf
linkly build               # generate .html/index.html
linkly serve               # live preview with Vapor
linkly deploy              # publish to GitHub Pages
```

## Development

### Build

```bash
swift build -c release
# Binary: .build/release/linkly
```

### Try commands locally

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

### Release

```bash
swift build -c release --arch arm64 --arch x86_64
tar -czf ./linkly.tar.gz -C ./.build/release linkly

brew tap jaywcjlove/tap
cd "$(brew --repository jaywcjlove/tap)"
```

## License

Licensed under the [MIT License](LICENSE).