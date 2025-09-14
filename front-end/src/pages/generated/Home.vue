<template>
  <div class="doc-content">
    <main class="container">
      <article class="markdown-content" v-html="htmlContent"></article>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const htmlContent = computed(() => "<h1>Welcome to My Blog</h1>\n<p>This is the home page content rendered from markdown with proper frontmatter support.</p>\n<h2>About This Site</h2>\n<p>This is a static blog application built with modern web technologies. The content is written in Markdown format and automatically converted to HTML using gray-matter for frontmatter parsing and markdown-it for HTML conversion.</p>\n<h2>Features</h2>\n<ul>\n<li>Clean, responsive design</li>\n<li>Fast loading times with static generation</li>\n<li>SEO optimized with proper metadata</li>\n<li>Easy content management through markdown</li>\n<li>Syntax highlighting for code blocks</li>\n<li>Frontmatter support for metadata</li>\n</ul>\n<h2>Technology Stack</h2>\n<ul>\n<li><strong>Vue.js 3</strong>: Progressive JavaScript framework</li>\n<li><strong>Vite</strong>: Fast build tool and development server</li>\n<li><strong>SASS</strong>: Enhanced CSS preprocessing</li>\n<li><strong>Markdown-it</strong>: Markdown parser with extensibility</li>\n<li><strong>Gray-matter</strong>: Frontmatter processor</li>\n<li><strong>Highlight.js</strong>: Syntax highlighting</li>\n</ul>\n<h2>Get Started</h2>\n<p>Navigate through the site using the menu above to explore blog posts, view my work, or get in touch. All content is dynamically generated from markdown files with proper frontmatter metadata parsing.</p>\n")
const metadata = {"title":"Welcome to My Blog","date":"2024-09-13","description":"A modern static blog built with Vue.js and markdown"}

</script>