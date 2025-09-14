<template>
  <div class="doc-content">
    <main class="container">
      <article class="markdown-content" v-html="htmlContent"></article>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const htmlContent = computed(() => "<h1>Contact Me</h1>\n<p>Get in touch with me through any of the following channels. I’m always interested in discussing new opportunities, collaborations, or having conversations about technology and development.</p>\n<h2>Email</h2>\n<p><a href=\"mailto:email@example.com\">email@example.com</a></p>\n<h2>Professional Profiles</h2>\n<ul>\n<li><strong>LinkedIn</strong>: <a href=\"https://linkedin.com/in/username\">linkedin.com/in/username</a></li>\n<li><strong>GitHub</strong>: <a href=\"https://github.com/username\">github.com/username</a></li>\n<li><strong>Twitter</strong>: <a href=\"https://twitter.com/username\">@username</a></li>\n</ul>\n<h2>Location</h2>\n<p>Based in [Your Location]</p>\n<h2>What I’m Looking For</h2>\n<ul>\n<li><strong>Collaboration Opportunities</strong>: Open source projects, technical partnerships</li>\n<li><strong>Speaking Engagements</strong>: Tech conferences, workshops, meetups</li>\n<li><strong>Consulting Work</strong>: Web development, static site generation, Vue.js projects</li>\n<li><strong>Networking</strong>: Fellow developers and technology enthusiasts</li>\n</ul>\n<h2>Response Time</h2>\n<p>I typically respond to emails within 24-48 hours during business days. For urgent matters, please mention “URGENT” in your subject line.</p>\n<h2>Let’s Build Something Great Together</h2>\n<p>Whether you have a project idea, need technical consultation, or just want to chat about the latest in web development, I’d love to hear from you!</p>\n")
const metadata = {"title":"Contact Me","date":"2024-09-13","description":"Get in touch through various channels"}

</script>