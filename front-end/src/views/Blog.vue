<template>
  <div class="blog-view">
    <div class="container">
      <div class="content">
        <h1>Blog</h1>
        <div class="blog-posts">
          <!-- Blog posts will be generated at build time from src/md/blog/*.md -->
          <article class="blog-post-preview">
            <h2>Sample Blog Post</h2>
            <div class="post-meta">
              <time>January 15, 2024</time>
              <span class="tags">javascript, vue</span>
            </div>
            <p>This is a placeholder for blog posts that will be generated at build time.</p>
          </article>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// No runtime content loading - blog posts will be pre-rendered during build
// Date formatting utility can be moved to build-time processing
</script>

<style scoped>
.blog-post-preview {
  margin-bottom: 3rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid var(--color-border);
}

.blog-post-preview:last-child {
  border-bottom: none;
}

.post-meta {
  color: var(--color-text-secondary);
  font-size: 0.9rem;
  margin-bottom: 1rem;
}

.post-meta time {
  margin-right: 1rem;
}

.tags {
  font-style: italic;
}

.content {
  max-width: none;
}
</style>