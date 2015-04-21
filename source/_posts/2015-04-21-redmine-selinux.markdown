---
layout: post
title: "RedmineをSELinux(enforcing)下で使う方法"
date: 2015-04-21 17:30:00 +0900
comments: true
categories: ['@y_fujie', 'redmine', 'selinux']
---

Redmine.jpの[最新版インストールガイド](http://blog.redmine.jp/articles/3_0/installation_centos/) と併読してください。

##インストール

“SELinuxを無効にする”の項は無視し、SELinuxをPermissiveモード(監視はするがアクセス制御はしない)にします。

```
setenforce 0
```

以降、[最新版インストールガイド](http://blog.redmine.jp/articles/3_0/installation_centos/) に従い、Redmineを構築します。

##SELinuxの有効化と権限の付与

Redmineを構築し終えたら、以下のコマンドを実行します。

```
chcon -R -t httpd_sys_content_t /var/lib/redmine/
setsebool -P httpd_unified on
```
Redmineのルートフォルダに対して「httpd_tというラベル付けがされたファイルから読み出される権限」を適用し、httpdによるファイルへの書き込み許可を設定しています。

最後に、SELinuxをEnforcingモードに戻します。

```
setenforce 1
```
以上です。