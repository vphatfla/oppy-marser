---
title: "Database Concepts With A Top Down Approach"
date: "2026-08-23"
author: "vphatfla"
featured: true
---

## Why I wrote this

I graduate with a Computer Science degree at a not-so-high ranked school in the US and has been working full-time as a software engineer at a Big-tech-ish for more than a year.
I think it's common nowadays for most students to skim through the CS fundamental concepts and spend more time grinding Leetcode and/or light system design for interviews. I did the same thing, I got good internships and full time offers; but fundamentally, I feel like I don't understand the computer enough! Which might be very normal, because this field is so broad.

The mentor in one of my internship impressed me deeply about how he understand the computer. He changed my mind about what is it I should spend more time learning. Personally, it was never what is trendy at the momment, but rather the fundamentals.

There are around 4 computer fundamental that I set out to tackle and understand deeper: Operating System, Networking, Programming Langauge, and Database System.

This blog is written based on my knowledge after taking the Database System cour CMU-445 from Carnegie Mellon. The course uses a bottom up approach, and I will use the top down approach here to make the concepts easier to digest in a short reading sessions.

1. Essential components of a database:

- Database, or Database Management System (DBMS), is a *software* that manage your application data.
- There are two most popular type of DBMS: relational and non-relational (or more commonly refered to as *no-SQL*). This blog will be about a typical relational database (like Postgres).
