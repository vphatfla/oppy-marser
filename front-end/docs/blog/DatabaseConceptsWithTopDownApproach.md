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

### Essential components of a database:

- Database, or Database Management System (DBMS), is a *software* that manage your application data.
- There are two most popular type of DBMS: relational and non-relational (or more commonly refered to as *no-SQL*). This blog will be about a typical relational database (like Postgres).
- DBMS stores its meta-data in a *catalog*. This is properly the most topdown approach concept you will have to know. *Catalog* store the metadata about the tables, their schemas, the indexes, and more. These are all the information to answer the question: how does this software knows about the data that it storing and where.
- Tuples/Records are stored within a *page*. A *page* in DMBS is different from a page concept in OS or Hardware. The OS page is typically 4KB in size, where a DBMS page size can be vary from 4 up to 36KB (and more). A page is a smallest unit controlled by *buffer poll management* (another important component that will be discussed in later chapter).

## Top Down Approach

Since we are looking at DBMS from top to bottom, this blog flows will be as if there is a query received and processed by the DBMS. To *overly simplify* the process, we will look at the topics in order:

1. query planning: this include how the sql query is *parsed*, *binded*, then *optimized*
2. query executor: the sql query will the be translated into a **tree** of multiple *executor*. executor is a component that is used to retrieve tuples. executors can have parent and child relationship with other executor. this can be drawn our as a tree graph.
3. access method: provide the **mechanism** and report the query capabilities on a table: sequential heap scan, B+ tree index scan, etc. This layer abstracts and translate the view from table to actual page_id.
4. buffer poll manager: at this level, components no longer know or care about the query, it deals with the dbms *page*. bpm provides methods to get the read or write privilege on a particular page given the page_id.
5. disk manager: handle the physically read/write the raw bytes of a page from disk to memory, and vice versa.
