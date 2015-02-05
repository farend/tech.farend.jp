---
layout: post
title: "Octopressでサイト内検索が行えるよう修正する"
date: 2015-02-05 22:59:39 +0900
comments: true
categories: ['@g_maeda', 'octpress']
---

Octopressのclassicテーマの検索ボックスは、実際に使ってみるとサイト内検索ではなく単なるGoogle検索として動作している。

サイト内検索ができるようにするためには下記のパッチを適用する。

https://github.com/imathis/octopress/commit/514ed5eb9f6bb91a6f3288febf3c2ba892a9b693
