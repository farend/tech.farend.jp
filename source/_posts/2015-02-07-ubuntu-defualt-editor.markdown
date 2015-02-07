---
layout: post
title: "Ubuntuのデフォルトのエディタをvimに変更する"
date: 2015-02-07 15:59:57 +0900
comments: true
categories: ['@g_maeda', 'ubuntu', 'vim']
---

```
update-alternatives --config editor
```

`--config` の後ろにはeditor以外にもさまざまなパラメータを指定できる。指定できるものは `/etc/alternatives` 以下にあるシンボリックリンクの名称。
