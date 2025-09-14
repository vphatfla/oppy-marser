<template>
  <footer class="app-footer">
    <div class="footer-content">
      Copyright © {{ currentYear }} vphatfla. All rights reserved.
    </div>
  </footer>
</template>

<script setup>
import { computed, defineProps } from 'vue'
const currentYear = computed(() => new Date().getFullYear())
</script>
