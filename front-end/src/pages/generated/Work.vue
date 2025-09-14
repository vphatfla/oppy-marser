<template>
  <div class="doc-content">
    <main class="container">
      <article class="markdown-content" v-html="htmlContent"></article>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const htmlContent = computed(() => "")
const metadata = {"title":"My Work & Projects","date":"2024-09-14","description":"Showcase of selected projects and professional work"}

</script>