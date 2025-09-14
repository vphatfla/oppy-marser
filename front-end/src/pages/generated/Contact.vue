<template>
  <div class="doc-content">
    <main class="container">
      <article class="markdown-content" v-html="htmlContent"></article>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const htmlContent = computed(() => "<h1>Say Hello!</h1>\n<h2>Email</h2>\n<p><a href=\"mailto:pvphat25@gmail.com\" target=\"_blank\">pvphat25@gmail.com</a></p>\n<h2>Or</h2>\n<ul>\n<li><strong>GitHub</strong>: <a href=\"https://github.com/vphatfla\" target=\"_blank\">github.com/vphatfla</a></li>\n<li><strong>LinkedIn</strong>: <a href=\"https://linkedin.com/in/vphatfla\" target=\"_blank\">linkedin.com/in/vphatfla</a></li>\n</ul>\n")
const metadata = {"title":"Contact Me","date":"2024-09-13","description":"Get in touch through various channels"}

</script>