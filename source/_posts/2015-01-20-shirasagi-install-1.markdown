---
layout: post
title: "SHIRASAGIをインストールする手順(1)"
date: 2015-01-20 11:55:34 +0900
comments: true
categories: ['@ishihara', 'shirasagi']
---


[SHIRASAGI公式サイト](http://www.ss-proj.org/)の[ダウンロード](http://www.ss-proj.org/download/)ページにアクセスします。
[インストール手順](http://www.ss-proj.org/download/install.html)がありますが、前提として[動作環境](http://www.ss-proj.org/about/requirement.html)に記載された状態にする必要があります。

[動作環境](http://www.ss-proj.org/about/requirement.html)に記載されている通り、
OSは以下のどちらかにする必要があります。
* CentOS 6.5 64bit
* ubuntu Server 14.04LTS

今回は*CentOS 6.5 64bit*をインストールします。



## VirtualBoxに新規の仮想マシンを作成し、CentOS6.5をインストールする
（※ はじめにVirtualBoxをインストールする必要があります。）

この手順は詳しく書きませんが、以下のページを参考にしたらできました。
* [VirtualBoxのネットワーク設定とCentOS6.5のインストール](https://blog.apar.jp/linux/402/)
* [macにVirtualBoxをインストールしてCentOSを起動してホストとssh接続、最後に共有ディレクトリの設定まで](http://djangoapplab.com/mac%E3%81%ABvirtualbox%E3%82%92%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E3%81%97%E3%81%A6centos%E3%82%92%E8%B5%B7%E5%8B%95%E3%81%97%E3%81%A6%E3%83%9B%E3%82%B9%E3%83%88%E3%81%A8ssh/)

＜気をつけたこと＞
・容量不足になるといけないのでファイルサイズを20GBにした
・言語設定では日本語を選択するが、キーボードではアメリカ合衆国（U.S）を選択する


これでOSの準備ができました！

起動後、ログインします。
```
localhost login: root
Password: パスワードを入力する
```
ログインできました！



----- 以下はしなくてもいいけど、やっておくと便利なこと -----



## ターミナルからssh接続する

VirtualBoxのCentOS上の画面での操作は慣れないと不便な点
（スクロールできない、コピー&ペーストできない等）があるので
ターミナルからssh接続できるようにしました。

参考：[macにVirtualBoxをインストールしてCentOSを起動してホストとssh接続、最後に共有ディレクトリの設定まで](http://djangoapplab.com/mac%E3%81%ABvirtualbox%E3%82%92%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E3%81%97%E3%81%A6centos%E3%82%92%E8%B5%B7%E5%8B%95%E3%81%97%E3%81%A6%E3%83%9B%E3%82%B9%E3%83%88%E3%81%A8ssh/)

手順は次のようになります。
1. ホストオンリーネットワークを作成
2. 仮想マシンでホストオンリーアダプタを設定
3. 2つのファイルを編集


以下は補足として*3. 2つのファイルを編集*するときの操作を詳しく書きました。

```
# vi /etc/sysconfig/network-scripts/ifcfg-eth0
```
「esc」キーを押して、「i」キーを押す
（下に「--　INSERT　--」と出れば入力モードになる）

下記のように書き換える
```
DEVICE=eth0
HWADDR=08:00:27:xx:xx:xx
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=dhcp
```

＜気をつけたこと＞
* カーソルを見失った場合は「command」キーを押して切り替え
* スクロールはできないので、キー操作で移動する

編集し終わったら...
「esc」キーを押す
「:wq」と入力する（上書き保存して終了）


同じように下記も書き換える

```
# vi /etc/sysconfig/network-scripts/ifcfg-eth1
```

「esc」キーを押して、「i」キーを押す

```
DEVICE=eth1
HWADDR=08:00:27:xx:xx:xx
TYPE=Ethernet
UUID=xxxxxx-xxxx-xxxxx-xxxxx-xxxx
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=192.168.56.101
NETMASK=255.255.255.0
NETWORK=192.168.56.0
```
「esc」キーを押して、「:wq」と入力する

2つの編集が終われば、ネットワークの再起動をする

```
# /etc/init.d/network restart
```

ターミナル(Macの場合)を起動して接続します
（Finder >  アプリケーション > ユーティリティ > ターミナル）

```
$ ssh root@192.168.56.101
root@192.168.56.101’s password: パスワードを入力する
```

これでターミナルからssh接続できるようになりました！
