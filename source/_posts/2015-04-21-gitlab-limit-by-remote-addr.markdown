---
layout: post
title: "GitLabへのHTTPアクセスを特定IPアドレスからのみに限定する"
date: 2015-04-21 15:55:45 +0900
comments: true
categories: ['@g_maeda', 'gitlab', 'nginx']
---

Omnibus packageを使ってインストールしたGitLabへのHTTPアクセスを特定のIPアドレスのみ許可するための設定です。

GitLab Omnibus packageを使用している場合、webサーバ(Nginx)の設定ファイルは以下の二つです。

* `/var/opt/gitlab/nginx/conf/nginx.conf`
* `/var/opt/gitlab/nginx/conf/gitlab-http.conf`

これらのファイルは `gitlab-ctl reconfigure` を実行することで `/etc/gitlab/gitlab.rb` を元に自動生成されるので、直接編集して設定を追加することはできません(そのうち上書きされてしまいます)。

Nginxに設定を追加するには、gitlab.rb内の設定 `custom_gitlab_server_config` を使用します。


## `custom_gitlab_server_config` の有効化

`/etc/gitlab/gitlab.conf` に以下の記述を追加してください。

```
nginx['custom_gitlab_server_config'] = "include /etc/gitlab/custom_gitlab_server.conf
```
`custom_gitlab_server_config` に書かれたものはNginxの設定ファイル `/var/opt/gitlab/nginx/conf/gitlab-http.conf` の `server` ブロックの末尾に挿入されます。上記の記述により、ファイル `/etc/gitlab/custom_gitlab_server.conf` を読み込むための設定がNginxに追加されます。


## `/etc/gitlab/custom_gitlab_server.conf` の記述

`custom_gitlab_server.conf` にはNginxの設定ファイルが自由に書けます。HTTPアクセスを特定のIPアドレスに限定するには以下のように記述します。

```
allow 192.0.2.0/24;
allow 198.51.100.21;
allow 198.51.100.22;
deny all;
```

## 設定の反映

`gitlab.rb` からNginxの設定ファイルを生成:

```
sudo gitlab-ctl reconfigure
```

GitLabの再起動:


```
sudo gitlab-ctl restart
```
