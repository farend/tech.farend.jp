---
layout: post
title: "Octopressでの記事の書き方"
date: 2014-11-27 17:38:31 +0900
comments: true
categories: ['@g_maeda', 'octopress']
---

## 記事のひな形の作成

コマンドラインで以下を実行すると記事のひな形が生成されます。生成されるひな形のファイル名は `source/_posts/YYYY-MM-DD-title.markdown` です。

```
bundle exec rake new_post["title"]
```

rakeタスクを実行するときの `title` 部分がそのままファイル名となり、またURLの一部となるので、日本語ではなく英語またはローマ字としてください。


## 記事の編集

`source/_posts` ディレクトリ内に生成されたひな形をエディタで開いて記事を編集します。


### front matter の編集

ひな形の冒頭には「front matter」と呼ばれる記述があり、記事のタイトルや作成日、カテゴリなどが指定できるようになっています。このうち、`title`と`categories`を適宜書き換えてください。


```
---
layout: post
title: "Octopressでの記事の書き方"
date: 2014-11-27 17:38:31 +0900
comments: true
categories: ['@g_maeda', 'octpress']
---
```

#### `title`

記事のタイトルです。ここに記述したタイトルがページに表示されます。

#### `categories`

記事を分類するカテゴリです。複数指定できます。tech.farend.jpでは次の規則に従って付与します。

* 半角英数文字のみ使用
* アルファベットは小文字のみ使用
* 記事の1個目のカテゴリはその記事の著者名を `@username` の形式で記述する
* カテゴリを増やしすぎない。なるべく既存のカテゴリを使用


### 本文の記述

front matterの後にMarkdownで記述します。


## 記事の見た目の確認

コマンドラインで以下を実行すると、サイトの生成が行われるとともにwebサーバが起動します。 http://localhost:4000 にアクセスするとサイトをプレビューできます。


```
bundle exec rake preview
```


なお、`bundle exec rake preview` によってwebサーバが起動している間は、記事を保存するとファイルが書き換えられたのが検知され、サイトの再生製が即時行われます。記事執筆中はwebサーバを立ち上げっぱなしにして、 ①少し書いて保存 ②自動で再生成 ③生成されたサイトをブラウザで確認 — のサイクルを繰り返すと作業しやすいと思います。
