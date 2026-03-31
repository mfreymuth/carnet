# carnet

My digital garden: notes, ideas, and things I'm learning.

Built with [Quartz](https://quartz.jzhao.xyz/) and hosted on [Cloudflare Pages](https://pages.cloudflare.com/).

## Structure

```text
content/     # notes and articles
config/      # quartz configuration
scripts/     # build and serve scripts
quartz/      # quartz submodule
```

## Usage

### Serve locally

```bash
./scripts/serve.sh
# → http://localhost:8080
```

### Deploy

```bash
git add -A && git commit -m "note: ..." && git push
# → Cloudflare rebuilds automatically
```

### Update Quartz

```bash
git submodule update --remote
git add quartz && git commit -m "chore: update quartz"
```
