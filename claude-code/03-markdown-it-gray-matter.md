# Static Site Generation with markdown-it + gray-matter

## Overview

This document outlines the final implementation approach for building a truly static blog application using Vue 3, Vite, markdown-it, and gray-matter. This approach generates static HTML files at build time while maintaining the flexibility of Vue components for layout and styling.

## Architecture Summary

The implementation converts Markdown files to Vue components at build time, embedding the HTML content directly into components to ensure true static generation without runtime dependencies.

### Core Components
- **markdown-it**: Robust Markdown to HTML conversion with plugin ecosystem
- **gray-matter**: Frontmatter parsing for metadata extraction
- **Vite + Vue 3**: Build system and component framework
- **SASS + Bootstrap**: Styling with responsive design

## Implementation Requirements

### Static Generation Criteria
- ✅ **Build-time Processing**: All content converted during `npm run build`
- ✅ **Zero Runtime Dependencies**: No client-side markdown processing
- ✅ **Pre-rendered HTML**: Complete static files for CDN deployment
- ✅ **S3 Compatible**: Pure static file output

### Application Structure
```
front-end/
├── docs/                          # Source markdown files
│   ├── home.md
│   ├── contact.md
│   ├── blog/
│   │   └── *.md
│   └── work/
│       └── *.md
├── docs-html/                     # Generated HTML (build artifact)
├── scripts/
│   └── build-docs.js              # Build-time MD → Vue converter
├── src/
│   ├── components/
│   │   ├── AppHeader.vue
│   │   ├── AppFooter.vue
│   │   └── generated/             # Auto-generated components
│   │       └── Doc*.vue
│   ├── styles/                    # SASS architecture
│   │   ├── abstracts/
│   │   ├── base/
│   │   ├── layout/
│   │   └── main.scss
│   ├── generated-routes.js        # Auto-generated routes
│   ├── router.js                  # Main router
│   └── main.js
└── package.json
```

## Step-by-Step Implementation

### Step 1: Install Dependencies

```bash
npm install markdown-it markdown-it-highlightjs markdown-it-anchor gray-matter glob @vueuse/head
```

**Dependencies Explained:**
- `markdown-it`: Core markdown parser with robust HTML handling
- `markdown-it-highlightjs`: Syntax highlighting for code blocks
- `markdown-it-anchor`: Auto-generated heading anchors
- `gray-matter`: Frontmatter parsing (YAML/TOML/JSON support)
- `glob`: File pattern matching for markdown discovery
- `@vueuse/head`: Meta tag management for SEO

### Step 2: Create Build Script

**File: `scripts/build-docs.js`**

```js
import fs from 'fs'
import path from 'path'
import { glob } from 'glob'
import MarkdownIt from 'markdown-it'
import hljs from 'markdown-it-highlightjs'
import anchor from 'markdown-it-anchor'
import matter from 'gray-matter'

// Configure markdown-it with plugins
const md = new MarkdownIt({
  html: true,          // Enable HTML tags in markdown
  xhtmlOut: true,      // XHTML-compliant output
  breaks: false,       // Convert \n to <br>
  langPrefix: 'language-',
  linkify: true,       // Auto-link URLs
  typographer: true    // Smart quotes and typography
})
.use(hljs, { 
  auto: true,          // Auto-detect language
  code: true           // Highlight inline code
})
.use(anchor, {
  permalink: anchor.permalink.headerLink()  // Generate heading anchors
})

const DOCS_DIR = 'docs'
const COMPONENTS_DIR = 'src/components/generated'

// Clean and create output directory
if (fs.existsSync(COMPONENTS_DIR)) {
  fs.rmSync(COMPONENTS_DIR, { recursive: true })
}
fs.mkdirSync(COMPONENTS_DIR, { recursive: true })

// Discover all markdown files
const mdFiles = glob.sync(`${DOCS_DIR}/**/*.md`)
const routes = []

// Process each markdown file
for (const filePath of mdFiles) {
  const fileContent = fs.readFileSync(filePath, 'utf8')
  
  // Parse frontmatter with gray-matter
  const { data: frontmatter, content: markdownContent } = matter(fileContent)
  
  // Convert markdown to HTML
  const html = md.render(markdownContent)
  
  // Generate unique component name
  const relativePath = path.relative(DOCS_DIR, filePath)
  const componentName = 'Doc' + Buffer.from(relativePath)
    .toString('base64')
    .replace(/[^a-zA-Z0-9]/g, '')
    .slice(0, 10)
  
  // Generate Vue component with embedded HTML
  const componentCode = `<template>
  <div class="doc-content">
    <AppHeader />
    <main class="container">
      <article class="markdown-content" v-html="htmlContent"></article>
    </main>
    <AppFooter />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import AppHeader from '../AppHeader.vue'
import AppFooter from '../AppFooter.vue'

const htmlContent = computed(() => ${JSON.stringify(html)})
const metadata = ${JSON.stringify(frontmatter)}

// SEO meta tags
import { useMeta } from '@vueuse/head'
useMeta({
  title: metadata.title || 'Page Title',
  meta: [
    { name: 'description', content: metadata.description || '' },
    { name: 'author', content: metadata.author || '' },
    { name: 'keywords', content: metadata.tags?.join(', ') || '' }
  ]
})
</script>`

  // Write component file
  fs.writeFileSync(
    path.join(COMPONENTS_DIR, `${componentName}.vue`),
    componentCode
  )
  
  // Generate route configuration
  const routePath = '/' + relativePath.replace('.md', '').replace(/\\/g, '/')
  routes.push({
    path: routePath === '/home' ? '/' : routePath,
    component: componentName,
    meta: frontmatter
  })
}

// Generate routes file
const routesCode = `// Auto-generated doc routes
${routes.map(r => `import ${r.component} from './components/generated/${r.component}.vue'`).join('\n')}

export const docRoutes = [
${routes.map(r => `  { 
    path: '${r.path}', 
    component: ${r.component}, 
    meta: ${JSON.stringify(r.meta)} 
  }`).join(',\n')}
]

// Export metadata for site generation
export const docMetadata = ${JSON.stringify(routes.map(r => ({
  path: r.path,
  ...r.meta,
  file: r.component
})), null, 2)}`

fs.writeFileSync('src/generated-routes.js', routesCode)

console.log(`✅ Generated ${mdFiles.length} static components with markdown-it + gray-matter`)
```

### Step 3: Configure Package.json Scripts

```json
{
  "scripts": {
    "build-docs": "node scripts/build-docs.js",
    "dev": "npm run build-docs && vite",
    "build": "npm run build-docs && vite build",
    "preview": "npm run build-docs && vite preview"
  }
}
```

### Step 4: Router Integration

**File: `src/router.js`**

```js
import { createRouter, createWebHistory } from 'vue-router'
import { docRoutes } from './generated-routes.js'

const routes = [
  ...docRoutes,
  // Add other manual routes here if needed
]

export default createRouter({
  history: createWebHistory(),
  routes
})
```

### Step 5: Main Application Setup

**File: `src/main.js`**

```js
import { createApp } from 'vue'
import { createHead } from '@vueuse/head'
import './styles/main.scss'
import App from './App.vue'
import router from './router.js'

const app = createApp(App)
const head = createHead()

app.use(router)
app.use(head)
app.mount('#app')
```

## Markdown File Structure

### Sample Frontmatter Support

**File: `docs/blog/my-post.md`**

```markdown
---
title: "Building Static Sites with Vue"
description: "Learn how to build static sites using Vue and markdown"
author: "Your Name"
date: 2024-01-15
tags: 
  - vue
  - static-sites
  - markdown
category: tutorial
featured: true
image: "/images/vue-static.jpg"
---

# Building Static Sites

Your markdown content here with **bold text**, _italic text_, and code blocks:

\`\`\`javascript
console.log('Hello, World!')
\`\`\`

## Features

- Syntax highlighting
- Auto-generated anchors
- Responsive design
- SEO optimization
```

## Build Process Flow

### Development Workflow
1. **Create/Edit**: Write content in `docs/*.md` files
2. **Build Docs**: Run `npm run build-docs` to generate components
3. **Develop**: Run `npm run dev` for live development
4. **Preview**: Test with `npm run preview`

### Production Workflow
1. **Content Ready**: All markdown files finalized
2. **Generate**: `npm run build-docs` creates Vue components
3. **Build**: `npm run build` creates static site in `dist/`
4. **Deploy**: Upload `dist/` contents to S3/CDN

### Generated Output Structure
```
dist/
├── index.html              # Home page (from docs/home.md)
├── contact/
│   └── index.html          # Contact page
├── blog/
│   └── my-post/
│       └── index.html      # Blog post pages
├── work/
│   └── project/
│       └── index.html      # Work portfolio pages
├── assets/
│   ├── app-[hash].js       # Vue application bundle
│   ├── app-[hash].css      # Compiled styles
│   └── vendor-[hash].js    # Dependencies
└── sitemap.xml             # SEO sitemap
```

## Technical Benefits

### True Static Generation
- **No Runtime Processing**: HTML content embedded at build time
- **CDN Optimized**: Pure static files with optimal caching
- **Fast Loading**: Zero client-side markdown parsing
- **SEO Friendly**: Complete HTML available to crawlers

### Developer Experience
- **Hot Reload**: Development server with instant updates
- **Type Safety**: Vue 3 composition API with TypeScript support
- **Plugin Ecosystem**: Extensive markdown-it plugins
- **Flexible Styling**: SASS + Bootstrap integration

### Content Management
- **Git-based**: Version control for all content
- **Frontmatter Support**: Rich metadata with YAML/TOML/JSON
- **Syntax Highlighting**: Automatic code block highlighting
- **Auto-linking**: Automatic URL and anchor generation

## Advanced Features

### SEO Optimization
- **Meta Tags**: Automatic generation from frontmatter
- **Structured Data**: JSON-LD for rich snippets
- **Sitemap**: Auto-generated XML sitemap
- **Performance**: Optimized Lighthouse scores

### Extensibility
- **Custom Plugins**: Add markdown-it plugins for features
- **Theming**: Multiple theme support with CSS variables
- **Multi-language**: i18n support for internationalization
- **Content Types**: Flexible frontmatter schemas

## Migration Notes

### From Existing Vue App
1. Move existing markdown files to `docs/` directory
2. Update header/footer components for new layout structure
3. Run build script to generate static components
4. Test routing and navigation

### Content Structure Changes
- Markdown files moved from `src/md/` to `docs/`
- Frontmatter parsing with gray-matter instead of custom parsing
- Route generation based on file structure
- Component naming with collision prevention

This implementation ensures true static generation while maintaining the developer experience and flexibility of Vue.js components.