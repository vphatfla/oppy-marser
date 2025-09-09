<template>
  <footer class="app-footer">
    <div class="footer-content">
      Copyright © {{ currentYear }} {{ authorName || '[Name Placeholder]' }}. All rights reserved.
    </div>
  </footer>
</template>

<script setup>
import { computed, defineProps } from 'vue'

defineProps({
  authorName: {
    type: String,
    default: ''
  }
})

const currentYear = computed(() => new Date().getFullYear())
</script>