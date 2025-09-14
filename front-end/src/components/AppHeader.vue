<template>
  <header class="app-header">
    <div class="header-container">
      <div class="site-title">
        {{ siteTitle || 'My Blog' }}
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

defineProps({
  siteTitle: {
    type: String,
    default: 'My Blog'
  }
})
</script>
