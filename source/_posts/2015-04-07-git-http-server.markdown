---
layout: post
title: "ApacheでgitリポジトリをHTTPで公開するための設定"
date: 2015-04-07 22:29:08 +0900
comments: true
categories: ['@g_maeda', 'git', 'apache']
---

gitリポジトリをHTTP経由でcloneやpushできるよう設定する手順です。Ubuntu 14.04上でApacheを使って次のような環境を作ることをを想定しています。

* リポジトリの名前は project.git
* サーバ上のリポジトリのパスは /var/lib/git/project.git
* リポジトリのURLは http://HOSTNAME/git/project.git
* Basic認証を行う
* 認証用パスワードファイルは /etc/apache2/htpasswd


## ソフトウェアのインストール

### Apacheのインストール

Basic認証用パスワードファイルの生成に使う `htpasswd` を使用するために apache2-utils パッケージのインストールと、 git-http-backend を動作させるために必要な mod_cgi の有効化も行います。

```
sudo apt-get install apache2
sudo apt-get install apache2-utils
sudo a2enmod cgi
```

### gitのインストール

```
sudo apt-get install git
```


## 公開用リポジトリの作成

```
sudo mkdir -p /var/lib/git/project.git
cd /var/lib/git/project.git
sudo git init --bare --shared
sudo chown -R www-data:www-data /var/lib/git
```

## 認証用パスワードファイルの作成

```
sudo htpasswd -c /etc/apache2/htpasswd maeda
```

## Apacheの設定

以下の設定を `/etc/apache2/httpd.conf` に追記するなどします。

```
ScriptAlias /git/ /usr/lib/git-core/git-http-backend/
SetEnv GIT_PROJECT_ROOT /opt/git
SetEnv GIT_HTTP_EXPORT_ALL

<LocationMatch "^/git">
    AuthType Basic
    AuthName "git repository"
    Require valid-user
    AuthUserFile /etc/apache2/htpasswd
</LocationMatch>
```

## Apache再起動

```
sudo service apache2 restart
```


## cloneできることを確認

```
cd ~
git clone http://localhost/git/project.git
```



## 関連情報

* [git-http-backend - Server side implementation of Git over HTTP](http://git-scm.com/docs/git-http-backend)
* [gitをhttpで使いたかったけどWebDavさっさと止めてsmart-http使えば良かったって後悔した話](http://altarf.net/computer/server_tips/1446)

