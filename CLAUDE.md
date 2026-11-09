# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

This repo hosts a personal static blog/portfolio site (`vphatfla`). All of it lives in one place:

- `front-end/` — the Vue 3 + Vite site (all application code lives here)

There is no infrastructure code here any more. The site is served by a self-hosted Docker/nginx server, which also builds and publishes it — see § Deployment.

`claude-code/*.md` contains design docs (tech specs, implementation notes) written during the original build-out — useful background, but not always in sync with the current code. Two of them still describe the output as "S3 + CloudFront compatible"; that is historical. The point it was making — the build is pure static files with no runtime markdown parsing — is still true.

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

This must be run with `scripts/` as the working directory (it uses paths relative to itself, e.g. `../docs`). It fully deletes and regenerates `front-end/src/pages/generated/` and `front-end/src/generated-routes.js` from `front-end/docs/**/*.md`, so any change to a markdown file (or to the generator script itself, e.g. its inline `<style>` for `BlogIndex.vue`) is invisible until this is re-run. CI (`.github/workflows/ci.yml`) runs it before `npm run build`, so a build that depends on a missing regeneration fails there rather than silently shipping stale pages.

There is no test suite, linter, or type checker configured for `front-end/`.

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

The site is **self-hosted**: a Docker/nginx server serves it at
`https://vphatfla.me/app/blog/`, with DNS on Cloudflare. Nothing in AWS serves
this site any more, and this repo holds no infrastructure code and no cloud
credentials.

**GitHub does not deploy.** `.github/workflows/ci.yml` only verifies that
`build-docs.js` + `npm run build` succeed, on every push and pull request.
Publishing is a deploy script that runs **on the server**, which builds from
this repo there.

Two consequences worth knowing:

- **The path prefix is `/app/blog/`, and this repo does not set it.**
  `front-end/vite.config.js` sets no Vite `base`, and `src/main.js` calls
  `createWebHistory()` with no base argument, so a plain `npm run build` here
  emits root-relative asset URLs (`/assets/…`) while the live site serves
  `/app/blog/assets/…`. The server's deploy script supplies the base. That
  means CI verifies *a* build, not byte-for-byte the deployed one — worth
  reconciling if it ever bites.
- Because the server builds and publishes, a merge to `main` does not put
  anything live by itself.
