# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

This repo hosts a personal static blog/portfolio site (`vphatfla`), plus the AWS infrastructure that serves it. It has two independent parts:

- `front-end/` — the Vue 3 + Vite site (all application code lives here)
- `terraform/` — AWS infra-as-code (S3 + CloudFront + ACM) that hosts the built site

`claude-code/*.md` contains design docs (tech specs, implementation notes, deployment guide) written during the original build-out — useful background, but not always in sync with the current code (e.g. it still frames the deploy script suggestions as "recommended," not yet wired in).

## Commands

All frontend commands run from `front-end/`:

```bash
npm run dev       # start Vite dev server
npm run build     # production build to front-end/dist/
npm run preview   # preview the production build locally
```

**Content changes require a manual regeneration step first** — it is *not* part of `npm run build`/`dev`:

```bash
cd front-end/scripts && node build-docs.js
```

This must be run with `scripts/` as the working directory (it uses paths relative to itself, e.g. `../docs`). It fully deletes and regenerates `front-end/src/pages/generated/` and `front-end/src/generated-routes.js` from `front-end/docs/**/*.md`, so any change to a markdown file (or to the generator script itself, e.g. its inline `<style>` for `BlogIndex.vue`) is invisible until this is re-run. The CI deploy workflow (`.github/workflows/frontend-deploy.yml`) runs it before `npm run build`.

There is no test suite, linter, or type checker configured for `front-end/`.

Terraform commands run from `terraform/`: `terraform init`, `terraform plan`, `terraform apply` (also automated for `main` via `.github/workflows/terraform-deploy.yml`, plan-only on PRs).

## Architecture

### Content pipeline (the key thing to understand)

The site is a Vue 3 SPA, but its content pages are **statically generated at build time**, not fetched/rendered at runtime:

1. Markdown source lives in `front-end/docs/*.md` (pages) and `front-end/docs/blog/*.md` (posts), with YAML frontmatter (`title`, `date`, `excerpt`, `tags`, etc. — used by generated templates).
2. `front-end/scripts/build-docs.js` (run manually or by CI, see above) parses frontmatter with `gray-matter`, renders markdown to HTML with `markdown-it` (+ `highlight.js` for code blocks; external links get `target="_blank"` injected), and writes one generated `.vue` SFC per markdown file into `front-end/src/pages/generated/` (mirroring the `docs/` folder structure), embedding the rendered HTML as a string constant — no runtime markdown parsing.
3. It also assembles `BlogIndex.vue` (a listing of everything under `docs/blog/`) and overwrites `front-end/src/generated-routes.js` with the full `vue-router` route table.
4. **Never hand-edit anything under `src/pages/generated/` or `src/generated-routes.js`** — both are wholesale overwritten on every `build-docs.js` run. Add a new page/post by adding a markdown file instead.
5. `front-end/src/main.js` boots Vue, imports `./styles/main.scss` globally, wires up the router from `generated-routes.js`, and mounts to `#app` in `front-end/index.html` (the sole HTML entry point).
6. `App.vue` is just `AppHeader` + `<router-view>` + `AppFooter` (`front-end/src/components/`) — hand-written, not generated.

### Styling

Plain SCSS (no Tailwind/CSS-in-JS/Bootstrap despite what `claude-code/01-tech-specs.md` mentions as a possibility), 7-1-lite partial structure under `front-end/src/styles/`, aggregated by `main.scss` in a fixed import order: `abstracts` (variables/mixins) → `base` (reset/typography/global/markdown) → `layout` (header/footer) → `components`. Colors are CSS custom properties defined on `:root` in `abstracts/_variables.scss` and consumed everywhere via `var(--color-*)` — keep new colors on that system rather than hardcoding hex, including inside generator template strings in `build-docs.js` (those bypass the SCSS pipeline entirely since they're raw `<style scoped>` text).

Theming: `[data-theme="dark"]` on `<html>` overrides the same custom-property names for dark mode. An inline script in `index.html`'s `<head>` sets `data-theme` synchronously before Vue mounts (localStorage → OS `prefers-color-scheme` → light) to avoid a flash of the wrong theme; `front-end/src/composables/useTheme.js` reads that already-applied value (rather than re-deciding it) and exposes `toggleTheme`/`isDark` to `ThemeToggle.vue`, mounted in `AppHeader.vue`.

### Deployment

`front-end/` builds to static files (`dist/`) deployed to a private S3 bucket fronted by CloudFront (OAC, ACM cert, HTTPS-only) — see `claude-code/04-aws-deployment.md` for the full rationale. `terraform/` provisions that infra; `.github/workflows/frontend-deploy.yml` builds and syncs `dist/` to S3 on push to `main` (or manual dispatch) when `front-end/**` changes; `.github/workflows/terraform-deploy.yml` plans on PRs and applies on push to `main` when `terraform/**` changes.
