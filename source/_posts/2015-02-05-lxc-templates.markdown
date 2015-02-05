---
layout: post
title: "lxc-createの -t オプションで指定できるテンプレートの一覧"
date: 2015-02-05 23:12:19 +0900
comments: true
categories: ['@g_maeda', 'lxc']
---

lxc-createコマンドで新しいLXCコンテナを作成するとき、 `-t` オプションによってどのテンプレートを使うか(どのディストリビューションのコンテナを作成するか)指定する。

指定できるテンプレート名を確認するには `/usr/share/lxc/templates` ディレクトリを参照すればよい。テンプレートのファイル名から `lxc-` を除いたものが指定できる。

具体的には下記の通り。

* alpine
* altlinux
* archlinux
* busybox
* centos
* cirros
* debian
* fedora
* gentoo
* openmandriva
* opensuse
* oracle
* plamo
* sshd
* ubuntu
* ubuntu-cloud

