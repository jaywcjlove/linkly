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
- **Local preview** — built-in dev server and one-command browser preview
- **Deploy-ready output** — static files in `.html/` (or a custom directory)

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
```

## Project Layout

```
my-links/
├── linkly.json          # source config (edit this)
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

## Commands

| Command | Description |
|---------|-------------|
| `linkly init` | Create default `linkly.json` and build output |
| `linkly build` | Read config and generate output directory |
| `linkly serve` | Build and start local preview server (default port `8080`) |
| `linkly preview` | Build and open `index.html` in the default browser |
| `linkly version` | Print version number |
| `linkly add <label> <url> [<icon>]` | Append a link to `linkly.json` |

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
```

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