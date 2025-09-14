# Static Site Generation with markdown-it + gray-matter

## Overview

This document outlines the **actual current implementation** for building a truly static blog application using Vue 3, Vite, markdown-it, and gray-matter. This approach generates static HTML files at build time while maintaining the flexibility of Vue components for layout and styling.

## Architecture Summary

The implementation converts Markdown files to Vue components at build time, embedding the HTML content directly into components to ensure true static generation without runtime dependencies.

### Core Components
- **markdown-it**: Robust Markdown to HTML conversion with built-in highlight.js integration
- **gray-matter**: Frontmatter parsing for metadata extraction
- **highlight.js**: Standalone syntax highlighting library
- **Vite + Vue 3**: Build system and component framework
- **SASS**: Styling with modular architecture

## Current Implementation Details

### Static Generation Criteria
- ✅ **Build-time Processing**: All content converted during build script execution
- ✅ **Zero Runtime Dependencies**: No client-side markdown processing
- ✅ **Pre-rendered HTML**: Complete static files for CDN deployment
- ✅ **S3 Compatible**: Pure static file output

### Application Structure
```
front-end/
├── docs/                          # Source markdown files
│   ├── Home.md                    # Homepage content
│   ├── Contact.md                 # Contact page
│   ├── Work.md                    # Work page
│   └── blog/                      # Blog posts
│       └── YouHaveTime.md         # Individual blog posts
├── scripts/
│   └── build-docs.js              # Build script (MD → Vue converter)
├── src/
│   ├── components/
│   │   ├── AppHeader.vue          # Header component (with "vphatfla" branding)
│   │   ├── AppFooter.vue          # Footer component
│   │   └── App.vue                # Main app layout
│   ├── pages/generated/           # Auto-generated components
│   │   ├── Contact.vue
│   │   ├── Home.vue
│   │   ├── Work.vue
│   │   ├── BlogIndex.vue          # Auto-generated blog listing
│   │   └── blog/
│   │       └── YouHaveTime.vue
│   ├── styles/                    # SASS modular architecture
│   │   ├── abstracts/
│   │   ├── base/
│   │   ├── layout/
│   │   └── main.scss
│   ├── generated-routes.js        # Auto-generated routes
│   ├── main.js                    # Main application entry
│   └── App.vue
├── package.json                   # Dependencies and scripts
└── vite.config.js                 # Vite configuration with @ alias
```

## Current Dependencies

**From package.json:**
```json
{
  "dependencies": {
    "gray-matter": "^4.0.3",
    "highlight.js": "^11.11.1",
    "markdown-it": "^14.1.0",
    "vue": "^3.5.18",
    "vue-router": "^4.5.1"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^6.0.1",
    "sass": "^1.92.1",
    "vite": "^7.1.2"
  }
}
```

## Build Script Implementation

**File: `scripts/build-docs.js`**

```js
import MarkdownIt from "markdown-it";
import matter from "gray-matter";
import hljs from "highlight.js";
import * as fs from "node:fs";
import { promisify } from "node:util";
import path from "node:path";

const INPUT_MD_DIR = '../docs';
const OUTPUT_HTML_DIR = '../src/pages/generated';
const OUTPUT_ROUTE_JS = '../src/generated-routes.js';

// Configure markdown-it with highlight.js integration
const md = new MarkdownIt({
    html: true,
    xhtmlOut: true,
    breaks: false,
    langPrefix: 'language-',
    linkify: true,
    typographer: true,

    highlight: function (str, lang) {
        if (lang && hljs.getLanguage(lang)) {
            try {
                return hljs.highlight(str, {language: lang}).value;
            } catch (err) {
                console.log(err)
            }
        }

        return '';
    }
});

// Configure external links to open in new tabs
var defaultRender = md.renderer.rules.link_open || function (tokens, idx, options, env, self) {
  return self.renderToken(tokens, idx, options);
};

md.renderer.rules.link_open = function (tokens, idx, options, env, self) {
  tokens[idx].attrSet('target', '_blank');
  return defaultRender(tokens, idx, options, env, self);
};

// Helper function to generate Vue components
const generateVueComponent = (html, data) => {
    return `<template>
  <div class="doc-content">
    <main class="container">
      <article class="markdown-content" v-html="htmlContent"></article>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const htmlContent = computed(() => ${JSON.stringify(html)})
const metadata = ${JSON.stringify(data)}

</script>`
}

// Clean and recreate output directory
if (fs.existsSync(OUTPUT_HTML_DIR)) {
    fs.rmSync(OUTPUT_HTML_DIR, { recursive: true, force: true })
}

const mkdirRes = fs.mkdirSync(OUTPUT_HTML_DIR, {recursive: true});

if (!mkdirRes) {
    throw new Error("ERROR mkdir ", OUTPUT_HTML_DIR, " --> ", mkdirRes)
}

if (!fs.existsSync(INPUT_MD_DIR)) {
    throw new Error("ERROR dir, input not found " + INPUT_MD_DIR)
}

// Discover all markdown files
const asyncGlob = promisify(fs.glob);
var mdFiles = await asyncGlob(`${INPUT_MD_DIR}/**/*.md`);
console.log('Input md files = ',mdFiles);

const routes = [];

// Process each markdown file
for (const filePath of mdFiles) {
    const mdContent = fs.readFileSync(filePath, {encoding: 'utf8'});
    const { data, content } =  matter(mdContent);
    const html = md.render(content);
    const vueComponent = generateVueComponent(html, data);

    const componentName = path.basename(filePath, '.md');
    const routePath = path.relative(INPUT_MD_DIR, filePath).replace('.md', '');
    const outFilePath = path.join(OUTPUT_HTML_DIR, routePath) + '.vue';

    fs.mkdirSync(path.dirname(outFilePath), { recursive: true} )
    fs.writeFileSync(
        outFilePath,
        vueComponent
    )

    routes.push({
        path: '/' + routePath,
        componentName: componentName,
        metadata: data
    })

    console.log("Successfully generated vue component at ", outFilePath);
}

// Collect blog posts for blog index
const blogPosts = routes.filter(r => r.path.startsWith('/blog/'));

// Generate blog index component
const generateBlogIndex = (blogPosts) => {
    return `<template>
  <div class="doc-content">
    <main class="container">
      <article class="markdown-content">
        <h1>Blog Posts</h1>
        <p>Welcome to my blog! Here are my latest posts:</p>

        <div class="blog-posts">
          <div v-for="post in blogPosts" :key="post.path" class="blog-post-item">
            <h2>
              <router-link :to="post.path" class="post-link">
                {{ post.metadata.title }}
              </router-link>
            </h2>
            <div class="post-meta">
              <span class="post-date">{{ post.metadata.date }}</span>
              <span v-if="post.metadata.tags" class="post-tags">
                | Tags: {{ post.metadata.tags.join(', ') }}
              </span>
            </div>
            <p v-if="post.metadata.excerpt" class="post-excerpt">
              {{ post.metadata.excerpt }}
            </p>
          </div>
        </div>
      </article>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const blogPostsData = ${JSON.stringify(blogPosts)}
const blogPosts = computed(() => blogPostsData)
</script>

<style scoped>
.blog-posts {
  margin-top: 2rem;
}

.blog-post-item {
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid #eee;
}

.blog-post-item:last-child {
  border-bottom: none;
}

.post-link {
  text-decoration: none;
  color: inherit;
}

.post-link:hover {
  color: #007acc;
}

.post-meta {
  color: #666;
  font-size: 0.9rem;
  margin: 0.5rem 0;
}

.post-excerpt {
  color: #444;
  font-style: italic;
  margin-top: 0.5rem;
}
</style>`
}

// Write blog index component
const blogIndexPath = path.join(OUTPUT_HTML_DIR, 'BlogIndex.vue');
fs.writeFileSync(blogIndexPath, generateBlogIndex(blogPosts));
console.log("Successfully generated blog index at ", blogIndexPath);

// Generate routes file
const routeCodes = `//Generated by build-docs.js
${routes.map(r => `import ${r.componentName} from '@/pages/generated${r.path}.vue'` ).join('\n')}
import BlogIndex from '@/pages/generated/BlogIndex.vue'

export const routes = [
{
    path: '/',
    component: ${routes.find(r => r.componentName === 'Home')?.componentName || 'Home'},
},
{
    path: '/blog',
    component: BlogIndex,
},
${routes.map(r => `{
    path: '${r.path.toLowerCase()}',
    component: ${r.componentName},
}`).join(',\n')}
]`;

fs.writeFileSync(OUTPUT_ROUTE_JS, routeCodes);

console.log('Generated successfully route scripting ', OUTPUT_ROUTE_JS);
```

## Current Package.json Scripts

**Currently Missing Build Integration:**
```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  }
}
```

**Recommended Integration:**
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

## Application Structure

### Main Application Setup

**File: `src/main.js`**
```js
import { createApp } from 'vue'
import './styles/main.scss'
import App from './App.vue'
import { createWebHistory, createRouter } from 'vue-router'
import { routes } from './generated-routes'

const router = createRouter({
    history: createWebHistory(),
    routes
})

const app = createApp(App)
app.use(router)
app.mount('#app')
```

**File: `src/App.vue`**
```vue
<template>
  <div class="app-layout">
    <AppHeader />
    <main class="main-content">
      <router-view />
    </main>
    <AppFooter />
  </div>
</template>

<script setup>
import AppHeader from '@/components/AppHeader.vue'
import AppFooter from '@/components/AppFooter.vue'
</script>
```

### Header Implementation

**File: `src/components/AppHeader.vue`**
```vue
<template>
  <header class="app-header">
    <div class="header-container">
      <div class="site-title">
        vphatfla
      </div>
      <nav class="nav-links">
        <router-link to="/" class="nav-link">Home</router-link>
        <router-link to="/blog" class="nav-link">Blog</router-link>
        <router-link to="/work" class="nav-link">Work</router-link>
        <router-link to="/contact" class="nav-link">Contact</router-link>
      </nav>
    </div>
  </header>
</template>

<script setup>
import { defineProps } from 'vue'
</script>
```

## Content Structure and Frontmatter

### Current Markdown Files
```
docs/
├── Home.md              # Homepage content
├── Contact.md           # Contact page
├── Work.md              # Work page
└── blog/                # Blog posts
    └── YouHaveTime.md   # Individual blog post
```

### Frontmatter Example
**File: `docs/blog/YouHaveTime.md`**
```markdown
---
title: "You Have Time"
date: "2024-09-14"
author: "vphatfla"
featured: true
---

## The usual

During my very last semester at UCF, spring 2025, I went to pick up a few groceries...
```

## Generated Output

### Route Generation
**File: `src/generated-routes.js`** (auto-generated)
```js
//Generated by build-docs.js
import Contact from '@/pages/generated/Contact.vue'
import Home from '@/pages/generated/Home.vue'
import Work from '@/pages/generated/Work.vue'
import YouHaveTime from '@/pages/generated/blog/YouHaveTime.vue'
import BlogIndex from '@/pages/generated/BlogIndex.vue'

export const routes = [
{
    path: '/',
    component: Home,
},
{
    path: '/blog',
    component: BlogIndex,
},
{
    path: '/contact',
    component: Contact,
},
{
    path: '/home',
    component: Home,
},
{
    path: '/work',
    component: Work,
},
{
    path: '/blog/youhavetime',
    component: YouHaveTime,
}
]
```

### Generated Component Structure
```
src/pages/generated/
├── Contact.vue          # Generated from docs/Contact.md
├── Home.vue             # Generated from docs/Home.md
├── Work.vue             # Generated from docs/Work.md
├── BlogIndex.vue        # Auto-generated blog listing page
└── blog/
    └── YouHaveTime.vue  # Generated from docs/blog/YouHaveTime.md
```

## Styling Architecture

### SASS Structure (Current)
```
src/styles/
├── abstracts/
│   ├── _variables.scss
│   └── _mixins.scss
├── base/
│   ├── _reset.scss
│   ├── _typography.scss
│   ├── _global.scss
│   └── _markdown.scss
├── layout/
│   ├── _header.scss
│   └── _footer.scss
└── main.scss           # Main import file
```

## Build Process

### Development Workflow
1. **Manual Build**: Run `node scripts/build-docs.js` to generate components
2. **Develop**: Run `npm run dev` for development server
3. **Content Changes**: Re-run build script when markdown changes

### Production Workflow
1. **Generate**: `node scripts/build-docs.js` creates Vue components
2. **Build**: `npm run build` creates static site in `dist/`
3. **Deploy**: Upload `dist/` contents to S3/CDN

### Technical Benefits

#### True Static Generation
- **No Runtime Processing**: HTML content embedded at build time
- **CDN Optimized**: Pure static files with optimal caching
- **Fast Loading**: Zero client-side markdown parsing
- **SEO Friendly**: Complete HTML available to crawlers

#### Developer Experience
- **Hot Reload**: Development server with instant updates (requires manual build script re-run for content changes)
- **Vue 3 Composition API**: Modern component development
- **SASS Integration**: Modular styling architecture
- **Automatic Routing**: Route generation from file structure

## Key Differences from Original Specs

1. **No @vueuse/head**: SEO meta tag management not currently implemented
2. **No Bootstrap**: Custom SASS architecture instead of Bootstrap integration
3. **Manual Build Process**: Build script not integrated into package.json scripts
4. **Simplified Component Generation**: Direct Vue component creation without complex naming schemes
5. **Blog Index Generation**: Auto-generated blog listing page with styling
6. **External Link Handling**: Links automatically open in new tabs
7. **Path-based Routing**: Simple path mapping based on file structure

This implementation successfully achieves true static generation while maintaining Vue.js development experience and producing deployment-ready static files.