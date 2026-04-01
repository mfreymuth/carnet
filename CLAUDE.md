# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Carnet is a personal digital garden built with [Quartz v4](https://quartz.jzhao.xyz/) (static site generator). Content is written in Obsidian-flavored Markdown and published via Cloudflare Pages.

## Commands

```bash
# Local development (serves on http://localhost:8080 with hot reload)
./scripts/serve.sh

# Production build (outputs to ./public)
./scripts/build.sh
```

Both scripts install npm dependencies, copy `config/` and `content/` into the `quartz/` submodule, then run the Quartz CLI.

## Architecture

- **`content/`** — Markdown notes and articles (Obsidian vault; `.obsidian/` and templates are gitignored)
- **`config/`** — Quartz configuration: `quartz.config.ts` (plugins, theme, analytics) and `quartz.layout.ts` (page component layout)
- **`scripts/`** — `build.sh` and `serve.sh` shell scripts that orchestrate the build pipeline
- **`quartz/`** — Git submodule pinned to Quartz v4.5.2 (`jackyzha0/quartz`). Do not edit files here directly; update via `git submodule update --remote`
- **`wrangler.jsonc`** — Cloudflare Pages deployment config

## Key Details

- **Node.js v22+** required (see `.node-version`)
- Deployment is git-push triggered — push to `main` and Cloudflare Pages rebuilds automatically
- Content supports: OFM links, GFM, LaTeX/KaTeX, syntax highlighting, draft filtering (`RemoveDrafts` plugin)
- SPA mode is enabled with popovers, full-text search, graph visualization, backlinks, and RSS
