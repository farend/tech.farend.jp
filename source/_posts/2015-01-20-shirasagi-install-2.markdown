---
layout: post
title: "SHIRASAGIをインストールする手順(2)"
date: 2015-01-20 11:55:34 +0900
comments: true
categories: ['@ishihara', 'shirasagi']
---

[SHIRASAGIをインストールする手順(1)](http://tech.farend.jp/blog/2015/01/20/shirasagi-install-1/)の続きです。

ここからの手順は、前提としてVirtualBoxにCentOS6.5 64bitがインストールされた状態です。

SHIRASAGI公式サイトの[動作環境](http://www.ss-proj.org/about/requirement.html)に記載されているものをインストールしていきます

* CentOS 6.5 64bit ←済
* nginx または Apache ←ここではApacheをインストールします
* Unicorn
* MongoDB ←まだインストールしない
* Ruby 2.1.2
* Ruby on Rails 4.1.6



## 1.Apacheのインストール

```
# yum -y install httpd
```
最後に「完了しました!」と表示されたらOK

バージョンの確認

```
# apachectl -v
Server version: Apache/2.2.15 (Unix)
Server built:   Oct 16 2014 14:48:21
```
インストールされたことが確認できました。




## 2.Rubyのインストール

参考：[Rubyのインストール](https://www.ruby-lang.org/ja/documentation/installation/#building-from-source)
以下のコマンドでインストールすると、現時点(2015年1月)では古いバージョン(1.8.7)がインストールされるのでしないように気をつける。

```
# yum install ruby
```

今回は「Ruby2.1.2」という指定があるので、次の方法でインストールします。
参考：[Ruby2.0をソースからインストールする手順 (CentOS/RedHat)](http://weblabo.oscasierra.net/install-ruby20-to-redhat-1/)

ダウンロードします

```
# cd /usr/local/src
# wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz
-bash: wget: コマンドが見つかりません
```

wgetがないと言われたのでインストールします

```
# yum install wget
```

最後に「完了しました!」と表示されたらOK

再度ダウンロードします

```
# wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz
```

最後に「完了しました!」と表示されたらOK

展開します

```
# tar zxvf ruby-2.1.2.tar.gz
```

コンパイル・インストールします

```
# cd /usr/local/src/ruby-2.1.2
# ./configure
# make
make: *** ターゲットが指定されておらず, makefile も見つかりません.  中止.
```

このエラーを解決するためにはgccのインストールが必要らしい

```
# yum -y install gcc
```

最後に「完了しました!」と表示されたらOK

再度

```
# make
# make install
```

バージョンを確認します

```
# ruby -v
ruby 2.1.2p95 (2014-05-08 revision 45877) [x86_64-linux]
```

インストールされていることが確認できました！

次の作業のためにディレクトリを移動します

```
# cd /root/
```




## 3.Unicornのインストール

参考：[Unicorn: Rack HTTP server for fast clients and Unix](http://unicorn.bogomips.org/)

インストールします

```
# gem install unicorn
ERROR:  Loading command: install (LoadError)
	cannot load such file -- zlib
ERROR:  While executing gem ... (NoMethodError)
    undefined method `invoke_with_build_args' for nil:NilClass
```

zlibがないらしいので入れます

```
# yum install zlib-devel
```

最後に「完了しました!」と表示されたらOK

改めてインストール

```
# gem install unicorn
ERROR:  Loading command: install (LoadError)
	cannot load such file -- zlib
ERROR:  While executing gem ... (NoMethodError)
    undefined method `invoke_with_build_args' for nil:NilClass
```

さっきと同じエラーが出たので入ってないらしい

参考：[centOS6.4にrail4をいれる](http://blog.katashiyo515.com/entry/2014/03/16/233012)

zlibというディレクトリに移動して実行

```
# cd /usr/local/src/ruby-2.1.2/ext/zlib/

# ruby extconf.rb
checking for deflateReset() in -lz... yes
checking for zlib.h... yes
checking for crc32_combine() in zlib.h... yes
checking for adler32_combine() in zlib.h... yes
checking for z_crc_t in zlib.h... no
creating Makefile

# make install
compiling zlib.c
linking shared-object zlib.so
/usr/bin/install -c -m 0755 zlib.so /usr/local/lib/ruby/site_ruby/2.1.0/x86_64-linux
installing default zlib libraries
```

改めてインストール

```
# gem install unicorn
ERROR:  While executing gem ... (Gem::Exception)
    Unable to require openssl, install OpenSSL and rebuild ruby (preferred) or use non-HTTPS sources
```

さっきのエラーはなくなったけど別のエラーが発生しました...

opensslをインストールしないといけないらしいのでインストールします

opensslというディレクトリに移動して実行

```
# cd /usr/local/src/ruby-2.1.2/ext/openssl

# ruby extconf.rb
checking for t_open() in -lnsl... no
checking for socket() in -lsocket... no
checking for assert.h... yes
checking for openssl/ssl.h... no

# make
make: *** `ossl.o' に必要なターゲット `/thread_native.h' を make  するルールがありません.  中止.
```

エラーが発生しました

参考：[rubyのインストール](http://ameblo.jp/nikatabushi/entry-11783310218.html)

```
# find / -name thread_native.h
*/usr/local/src/ruby-2.1.2/*thread_native.h

# vi Makefile
topdir = /usr/local/include/ruby-2.1.0
top_srcdir =　*/usr/local/src/ruby-2.1.2/*　←追記

# make
linking shared-object openssl.so

# sudo make install
/usr/bin/install -c -m 0755 openssl.so /usr/local/lib/ruby/site_ruby/2.1.0/x86_64-linux
installing default openssl libraries
```

改めてインストールします

```
# gem install unicorn
```

バージョンを確認します

```
# unicorn -v
unicorn v4.8.3
```

無事にインストールされたことが確認できました！




## 4.Ruby on Rails 4.1.6のインストール

参考：[Ruby on Rails: Download](http://rubyonrails.org/download/)
　　　[第1章 ゼロからデプロイまで](http://railstutorial.jp/chapters/beginning?version=4.0#sec-install_rails)

今回は4.1.6をインストールしたいのでバージョン指定します

```
# gem install rails --version 4.1.6
```

バージョンを確認します

```
# rails -v
Rails 4.1.6
```

インストールされたことが確認できました！



これで環境が整いました。
MongoDBをまだインストールしていませんが、あとで行います。
（このときにインストールすると手間がかかるため）
