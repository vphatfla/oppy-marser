<template>
  <div class="doc-content">
    <main class="container">
      <article class="markdown-content" v-html="htmlContent"></article>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const htmlContent = computed(() => "<h2>The usual</h2>\n<p>During my very last semester at UCF, spring 2025, I went to pick up a few groceries from a market in Orlando and was about to hit the road to Fort Myers.</p>\n<p>I drove back home often. Even though the trip would be 4 hours with I-4’s famous traffic, I somewhat enjoyed it. The drives calmed me down. I turned on the music, cruised toward the west, and watched the sun come down over the horizon.</p>\n<h2>The random</h2>\n<p>As I was pushing the cart after loading the trunk, an elderly Asian man got out of his car with his wife. He was standing still and looking at me.</p>\n<p>I didn’t pay attention (as usual), but I noticed him eventually. He smiled and said, in a very calm tone: “You have time.”</p>\n<p>I didn’t respond; I didn’t know how to. I smiled back.</p>\n<h2>The post-processing</h2>\n<p>I thought about that moment till today. I don’t know who he was, we never met. But for some reason, he read me, whether it’s from my face expression, my behavior, or something else.</p>\n<p>It was random, it was special. I have rushed so much, have never been satisfied and have been pushing myself hard. And I still do so today.</p>\n<p>Now, I think about those three words with a deep breath when I struggle.</p>\n")
const metadata = {"title":"You Have Time","date":"2024-09-14","author":"vphatfla","featured":true}

</script>