---
layout: post
title: "SHIRASAGIをインストールする手順(3)"
date: 2015-01-27 09:27:22 +0900
comments: true
categories: ['@ishihara', 'shirasagi']
---

[SHIRASAGIをインストールする手順(2)](http://tech.farend.jp/blog/2015/01/20/shirasagi-install-2/)の続きです。  

ここからはSHIRASAGI公式サイトの[インストール手順](http://www.ss-proj.org/download/install.html)に従って進めます。  

## Packages  

```
# yum -y install ImageMagick ImageMagick-devel  
```


## MongoDB  

ここでMongoDBをインストールします  
※先にインストールすると既にあるものとぶつかり合ってしまいます  

```
# vi /etc/yum.repos.d/CentOS-Base.repo  
```

以下を一番最後に追記する  

```
[10gen]  
name=10gen Repository  
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/  
gpgcheck=0  
enabled=0  
```


```
# yum -y --enablerepo=10gen install mongo-10gen mongo-10gen-server  
```

（バージョン確認してみるとインストールできたことが分かります）  

```
# mongo -version  
MongoDB shell version: 2.6.7  
```


```
# /sbin/service mongod start  
Starting mongod:                                           [  OK  ]  
# /sbin/chkconfig mongod on  
```


## Ruby (RVM)  

```
# \curl -sSL https://get.rvm.io | sudo bash -s stable  
```

警告が出ました  

示してある通りにする  

```
sudo gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3  
```

再度行う  

```
# \curl -sSL https://get.rvm.io | sudo bash -s stable  

# source /etc/profile  

# rvm install 2.1.2  
```

（rvmのバージョンを確認したい場合は）  

```
# rvm -v  
rvm 1.26.9 (latest) by Wayne E. Seguin <wayneeseguin@gmail.com>, Michal Papis <mpapis@gmail.com> [https://rvm.io/]  
```


## SHIRASAGI  

```
# git clone -b stable --depth 1 https://github.com/shirasagi/shirasagi /var/www/shirasagi  
-bash: git: コマンドが見つかりません  
```

gitがないと言われたのでインストールします  
参考：[Gitのインストール](http://git-scm.com/book/ja/v1/%E4%BD%BF%E3%81%84%E5%A7%8B%E3%82%81%E3%82%8B-Git%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB)  

```
# yum install git  
```

最後に「完了しました!」と表示されたらOK  

再度行う  

```
# git clone -b stable --depth 1 https://github.com/shirasagi/shirasagi /var/www/shirasagi  
# cd /var/www/shirasagi  
# cp config/samples/* config/  
# bundle install  
# rake unicorn:start  
bundle exec unicorn_rails -c /var/www/shirasagi/config/unicorn.rb -E production -D  
```

「 http://localhost:3000/.mypage にアクセスしてください」と書いてある([インストール手順](http://www.ss-proj.org/download/install.html))  

でも、今はVirtualBox上の仮想マシンなので  
いつも通りブラウザではアクセスしても表示されません。  

（ちなみに http://192.168.56.101:3000/.mypage/ にもアクセスできない）  

ターミナル上でアクセスする  

```
# curl http://localhost:3000/.mypage  
<html><body>You are being <a href="http://localhost:3000/.mypage/login">redirected</a>.</body></html>  
```

言われた通りに http://localhost:3000/.mypage/login へアクセスする  

```
# curl http://localhost:3000/.mypage/login  
<!doctype html>  
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja">  
<head>  
.
.
.
</body>  
</html>  
```

ターミナルにhtmlが表示され、アクセスできた  

こちらにもアクセスできます  

```
# curl http://192.168.56.101:3000/.mypage/login  
```

ブラウザでアクセスできるようにします  

```  
# service iptables stop  
```

ブラウザを起動してアクセスする  
http://192.168.56.101:3000/.mypage/login  

画面が表示されました！  


## ふりがな機能  

```
# cd /usr/local/src  
# wget http://mecab.googlecode.com/files/mecab-0.996.tar.gz \  
       http://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz \  
       http://mecab.googlecode.com/files/mecab-ruby-0.996.tar.gz  

# cd /usr/local/src  
# tar xvzf mecab-0.996.tar.gz && cd mecab-0.996  
# ./configure --enable-utf8-only && make && make install  

# cd /usr/local/src  
# tar xvzf mecab-ipadic-2.7.0-20070801.tar.gz && cd mecab-ipadic-2.7.0-20070801  
# ./configure --with-charset=utf8 && make && make install  

# cd /usr/local/src  
# tar xvzf mecab-ruby-0.996.tar.gz && cd mecab-ruby-0.996  
# ruby extconf.rb && make && make install  

# echo "/usr/local/lib" >> /etc/ld.so.conf  
# ldconfig  
```

問題なくできました。  



## データベース操作  

###インデックスの作成  

```
# cd /var/www/shirasagi  
# rake db:create_indexes  
```


### 管理者ユーザーの作成  

```
# rake ss:create_user data='{ name: "システム管理者", email: "sys@example.jp", password: "pass" }'  
```

### サイトの作成  

```
# rake ss:create_site data='{ name: "サイト名", host: "www", domains: "localhost:3000" }'  
```

## サンプルデータ  

### ユーザー、グループデータの登録  

```
# rake db:seed name=users site=www  
```


### サイトデータの登録  

```
# rake db:seed name=demo site=www  
```


ブラウザのログイン画面で入力してみる  
Email：`sys@example.jp`  
Password：`pass`  


ログインできました！  
これでSHIRASAGIのインストールは完了です。おつかれさまでした。  

