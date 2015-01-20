---
layout: post
title: "VPC内のサーバ用にProxyを立てる"
date: 2015-01-13 17:30:00 +0900
comments: true
categories: ['@amidaku', 'aws', 'proxy']
---

EIPやパブリックIPがアタッチされていないインスタンスは外部との接続ができない。  
このため、yumやwgetなどができないが、それ以外にインターネットとの通信が不要の場合はproxyを経由するのが簡単。  
インターネットとつながっているインスタンスにProxyを立てて、これを経由させる。

今回はCentOS6およびAmazon Linuxが対象

# squidのインストールと設定

## squidインストール

```
yum -y install squid
```

## squidの設定

`/etc/squid.conf` を編集（主な設定のみ記載。例では経由するサーバは172.16.0.0/16にあるものとする）  

```
acl localhost src 127.0.0.1/32 ::1
acl localnet src 172.16.0.0/16

acl Safe_ports port 80        # http
acl Safe_ports port 21        # ftp
acl Safe_ports port 443        # https
acl CONNECT method CONNECT
http_access allow localnet
http_access allow localhost

http_access deny all

http_port 3128
```

## squid起動

```
/etc/init.d/squid start
chkconfig squid on
```

# Proxyを経由するサーバの設定

（上記Proxyサーバを172.16.1.100と想定）

## yum

`/etc/yum.conf` の最終行に下記を追記

```
#proxy settings
proxy=http://172.16.1.100:3128
```

## apt-get

`/etc/apt/apt.conf.d/80proxy` を作成（ファイル名は何でも良いです。）

```
Acquire::ftp::proxy "ftp://172.16.1.100:3128";
Acquire::http::proxy "http://172.16.1.100:3128";
Acquire::https::proxy "https://172.16.1.100:3128";
```

## wget

`/etc/wgetrc` 中の内容を下記の様に修正

```
https_proxy = http://172.16.1.100:3128/
http_proxy = http://172.16.1.100:3128/
ftp_proxy = http://172.16.1.100:3128/
```

## curl

ホームディレクトリに `.curlrc` を作成

```
proxy = "http://172.16.1.100:3128"
```
