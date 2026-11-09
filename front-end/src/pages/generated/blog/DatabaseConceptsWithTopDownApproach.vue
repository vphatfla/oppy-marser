<template>
  <div class="doc-content">
    <main class="container">
      <article class="markdown-content" v-html="htmlContent"></article>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const htmlContent = computed(() => "<h2>Why I wrote this</h2>\n<p>I graduate with a Computer Science degree at a not-so-high ranked school in the US and has been working full-time as a software engineer at a Big-tech-ish for more than a year.<br />\nI think it’s common nowadays for most students to skim through the CS fundamental concepts and spend more time grinding Leetcode and/or light system design for interviews. I did the same thing, I got good internships and full time offers; but fundamentally, I feel like I don’t understand the computer enough! Which might be very normal, because this field is so broad.</p>\n<p>The mentor in one of my internship impressed me deeply about how he understand the computer. He changed my mind about what is it I should spend more time learning. Personally, it was never what is trendy at the momment, but rather the fundamentals.</p>\n<p>There are around 4 computer fundamental that I set out to tackle and understand deeper: Operating System, Networking, Programming Langauge, and Database System.</p>\n<p>This blog is written based on my knowledge after taking the Database System cour CMU-445 from Carnegie Mellon. The course uses a bottom up approach, and I will use the top down approach here to make the concepts easier to digest in a short reading sessions.</p>\n<ol>\n<li>Essential components of a database:</li>\n</ol>\n<ul>\n<li>Database, or Database Management System (DBMS), is a <em>software</em> that manage your application data.</li>\n<li>There are two most popular type of DBMS: relational and non-relational (or more commonly refered to as <em>no-SQL</em>). This blog will be about a typical relational database (like Postgres).</li>\n</ul>\n")
const metadata = {"title":"Database Concepts With A Top Down Approach","date":"2026-08-23","author":"vphatfla","featured":true}

</script>