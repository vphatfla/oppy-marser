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

const blogPostsData = [{"path":"/blog/BuildingModernStaticSites","componentName":"BuildingModernStaticSites","metadata":{"title":"Building Modern Static Sites with Vue.js","date":"2024-09-13","tags":["vue","static-sites","web-development","performance"],"excerpt":"Explore how to build lightning-fast static sites using Vue.js and modern build tools","author":"Developer"}},{"path":"/blog/OptimizingWebPerformance","componentName":"OptimizingWebPerformance","metadata":{"title":"Optimizing Web Performance in 2024","date":"2024-09-10","tags":["performance","web-vitals","optimization","javascript"],"excerpt":"Essential techniques for achieving lightning-fast web performance and excellent Core Web Vitals scores","author":"Developer","featured":true}}]
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
</style>