# oppy-marser

Personal static blog and portfolio site, live at
**<https://vphatfla.me/app/blog/>**.

Vue 3 + Vite. Content is written as markdown and compiled into Vue components
at build time, so the shipped site is pure static files with no runtime
markdown parsing.

## Layout

```
front-end/           the entire site
  docs/              markdown source — *.md pages, blog/*.md posts
  scripts/           build-docs.js, the markdown → Vue generator
  src/pages/generated/   GENERATED, never hand-edited
  src/generated-routes.js GENERATED, never hand-edited
claude-code/         design records from the original build-out
.github/workflows/   ci.yml — build verification only, never deploys
```

## Running it

```bash
cd front-end
npm install
npm run dev          # Vite dev server
npm run build        # production build to front-end/dist/
npm run preview      # preview that build
```

## Adding or changing content

Add a markdown file under `front-end/docs/` (or `front-end/docs/blog/` for a
post), with YAML frontmatter, then regenerate:

```bash
cd front-end/scripts && node build-docs.js
```

This step is **not** part of `npm run build` or `npm run dev`. It must run with
`scripts/` as the working directory, because it resolves paths relative to
itself. It wholesale deletes and rewrites `src/pages/generated/` and
`src/generated-routes.js`, so edits to either are lost — change the markdown
instead.

## Deployment

The site is **self-hosted** on a Docker/nginx server, with DNS on Cloudflare.
It is served under the path prefix `/app/blog/`.

Deploying is a script that runs **on the server**, which builds from this repo
there. GitHub Actions does not deploy: `.github/workflows/ci.yml` only checks
that `build-docs.js` and `npm run build` succeed on every push and pull
request. Merging to `main` does not put anything live by itself.

Note that this repo does not itself set the `/app/blog/` base — `vite.config.js`
sets no Vite `base` and `src/main.js` calls `createWebHistory()` with no base
argument, so a local `npm run build` emits root-relative asset URLs. The
server's deploy script supplies the base.
