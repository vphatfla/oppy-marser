<template>
  <div class="doc-content">
    <main class="container">
      <article class="markdown-content" v-html="htmlContent"></article>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const htmlContent = computed(() => "<h1>Hello. I’m vphatfla</h1>\n<h2>I write code and thoughts, I run, and I play soccer</h2>\n<p>I am a software engineer, orignally from Florida (<code>fla</code>), currently working in New York City.</p>\n<p>I build software and write short blogs in my free time.</p>\n")
const metadata = {"title":"vphatfla","date":"2024-09-14","description":""}

</script>