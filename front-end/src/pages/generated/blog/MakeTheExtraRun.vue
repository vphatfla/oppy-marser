<template>
  <div class="doc-content">
    <main class="container">
      <article class="markdown-content" v-html="htmlContent"></article>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const htmlContent = computed(() => "<h2>The Extra Run in Soccer</h2>\n<p>The Extra Run often means covering your teammate’s position. It might or might not change the outcome of the game.<br />\nI’m a soccer fan and player. I like to believe that the way I play the game affects the way I live, and vice versa.</p>\n<p>I don’t like losing a game.<br />\nI hate knowing that if I had made that extra run, we might have won.<br />\nI don’t beat myself up if I tried my absolute best and lost.</p>\n<h2>Bruno Fernandes | 8</h2>\n<p>Bruno is my favorite player in modern soccer. Apart from elite skill and intelligence, the man carries an unmatched energy with him every time he steps on the pitch.<br />\nManchester United has been losing games embarrassingly on and off, yet Bruno still runs, still plays through pain to contribute his best for the club.<br />\nHe’s undoubtedly a United legend, and he won a million hearts with those extra runs.</p>\n<p>The rare inspiration I find.</p>\n")
const metadata = {"title":"Make an Extra Run","date":"2025-12-28","author":"vphatfla","featured":true}

</script>