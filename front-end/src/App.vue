<template>
  <div class="app-layout">
    <AppHeader :site-title="siteTitle" />
    
    <main class="main-content">
      <!-- Static content will be injected here by the static site generator -->
      <div class="placeholder-content">
        <h1>Static Site Template</h1>
        <p>This is a clean template for static site generation.</p>
        <p>Content will be generated from markdown files during build time.</p>
      </div>
    </main>
    
    <AppFooter :author-name="authorName" />
  </div>
</template>

<script setup>
import AppHeader from './components/AppHeader.vue'
import AppFooter from './components/AppFooter.vue'

// These can be configured or moved to a config file
const siteTitle = ''
const authorName = ''
</script>