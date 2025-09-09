<template>
  <div class="work-view">
    <div class="container">
      <div class="content">
        <h1>Work</h1>
        <div class="work-items">
          <!-- Work items will be generated at build time from src/md/work/*.md -->
          <article class="work-item-preview">
            <h2>Sample Project</h2>
            <div class="project-meta">
              <time>January 10, 2024</time>
              <span class="technologies">Technologies: Vue.js, SASS</span>
              <span class="status">Status: Completed</span>
            </div>
            <p>This is a placeholder for work items that will be generated at build time.</p>
          </article>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// No runtime content loading - work items will be pre-rendered during build
</script>

<style scoped>
.loading, .error {
  text-align: center;
  padding: 2rem;
}

.error {
  color: #e74c3c;
}

.work-item-preview {
  margin-bottom: 3rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid var(--color-border);
}

.work-item-preview:last-child {
  border-bottom: none;
}

.project-meta {
  color: var(--color-text-secondary);
  font-size: 0.9rem;
  margin-bottom: 1rem;
}

.project-meta time {
  display: block;
  margin-bottom: 0.5rem;
}

.technologies, .status {
  display: block;
  margin-bottom: 0.25rem;
}

.technologies {
  font-style: italic;
}

.status {
  font-weight: 500;
}

.markdown-content {
  max-width: none;
}
</style>