<template>
  <div class="home-view">
    <div class="container">
      <div class="content">
        <!-- Content will be generated at build time from src/md/home.md -->
        <h1>Welcome</h1>
        <p>This content will be replaced by the static site generator with content from src/md/home.md</p>
      </div>
    </div>
  </div>
</template>

<script setup>
// No runtime content loading - content will be pre-rendered during build
</script>

<style scoped>
.content {
  max-width: none;
}
</style>
