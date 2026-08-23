<template>
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

const blogPostsData = [{"path":"/blog/DatabaseConceptsWithTopDownApproach","componentName":"DatabaseConceptsWithTopDownApproach","metadata":{"title":"Database Concepts With A Top Down Appraoch","date":"2026-08-23","author":"vphatfla","featured":true}},{"path":"/blog/MakeTheExtraRun","componentName":"MakeTheExtraRun","metadata":{"title":"Make an Extra Run","date":"2025-12-28","author":"vphatfla","featured":true}},{"path":"/blog/YouHaveTime","componentName":"YouHaveTime","metadata":{"title":"You Have Time","date":"2024-09-14","author":"vphatfla","featured":true}}]
const blogPosts = computed(() => blogPostsData)
</script>

<style scoped>
.blog-posts {
  margin-top: 2rem;
}

.blog-post-item {
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid var(--color-border);
}

.blog-post-item:last-child {
  border-bottom: none;
}

.post-link {
  text-decoration: none;
  color: inherit;
}

.post-link:hover {
  color: var(--color-primary);
}

.post-meta {
  color: var(--color-text-secondary);
  font-size: 0.9rem;
  margin: 0.5rem 0;
}

.post-excerpt {
  color: var(--color-text-secondary);
  font-style: italic;
  margin-top: 0.5rem;
}
</style>