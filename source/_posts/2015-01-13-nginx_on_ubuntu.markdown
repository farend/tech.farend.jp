---
layout: post
title: "Nginx簡単インストール on ubuntu"
date: 2015-01-13 17:30:00 +0900
comments: true
categories: ['@amidaku', 'ubuntu', 'nginx']
---

ubuntuのリポジトリのnginxは古いので新しいものをnginx本家からインストールできる様にする。

# Nginx本家よりubuntu用Keyをダウンロード

```
cd /tmp
curl -L -O http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
```

# /etc/apt/sources.listに下記（ubuntu14.04設定）を追記

```
deb http://nginx.org/packages/ubuntu/ trusty nginx
deb-src http://nginx.org/packages/ubuntu/ trusty nginx
```

# aptの情報を更新しインストール

```
apt-get update
apt-get -y install nginx
```
