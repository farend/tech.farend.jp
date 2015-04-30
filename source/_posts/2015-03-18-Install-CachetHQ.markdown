---
layout: post
title: "CachetHQインストール手順"
date: 2015-03-18 11:10:00 +0900
comments: true
categories: ['@y_fujie', 'CachetHQ', 'ubuntu']
---
**本手順で作成される環境**

本手順で作成される環境は以下のとおりです。

| CachetHQ    | CachetHQ 1.0.0 |
|:-----------|:--------------|
|OS          |Ubuntu 14.04     |
|データベース  |MySQL 14.14   |
|webサーバ    |Nginx 1.4.6|
|PHP        | 5.6.4-1|




##Ubuntuの設定
SSLで通信を行うため443番のポートを開けておきます。

```
sudo ufw enable
sudo ufw allow 443/tcp
```
リポジトリやパッケージを最新の状態にしておきます。

*/etc/apt/sources.list*に以下を追加


```
deb http://packages.dotdeb.org wheezy all
deb http://packages.dotdeb.org wheezy-php56 all
```
以下のコマンドでgpg鍵をダウンロード・リポジトリの追加を行います。

```
sudo apt-get -y install wget
wget -qO - http://www.dotdeb.org/dotdeb.gpg | sudo apt-key add -
sudo apt-get update && sudo apt-get upgrade
```

##必要なパッケージのインストール
CachetHQを導入するにあたり、必要なパッケージのインストールを行います。

```
sudo apt-get install -y python-software-properties git curl openssl build-essential nginx mysql-server
```
##MySQLの設定
**デフォルトキャラクタセットをutf8に設定**

エディタで `/etc/mysql/my.cnf` を開き、 

*[mysqld]* セクションに

```
character-set-server=utf8
```

*[mysql]* セクションに 

```
default-character-set=utf8
```

を追加してください。


**MySQLの初期設定**

```
sudo mysql_secure_installation
```

**CachetHQ用のデータベース、ユーザーの作成**

```
mysql -p -uroot
create database db_cachet default character set utf8;
grant all privileges on db_cachet.* to 'user_cachet'@'localhost' identified by 'password';
flush privileges;
exit;
```



##PHPの設定

**phpモジュールのインストール**

```
sudo apt-get -y install php5-fpm php5-cli php5-mcrypt php5-apcu php5-mysql
```
**composerを配置**

```
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```
**bower、gulpを使用するためにnodejsをインストール**

```
curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get install -y nodejs
sudo npm install -g bower
sudo npm install -g gulp
```

##CachetHQの設定
**gitからリポジトリをクローン**

```
mkdir -p ~/cachet.example.com
git clone -b master https://github.com/cachethq/Cachet.git ~/cachet.example.com
cd cachet.example.com
```
※cachet.example.com:サイト名

**エディタで.env.phpを作成**

```
<?php

return [
	'DB_DRIVER'   => 'mysql',
	'DB_HOST'     => 'localhost',
	'DB_DATABASE' => 'db_cachet',
	'DB_USERNAME' => 'user_cachet',
	'DB_PASSWORD'  => 'password',
];
```
※db_cachet，user_cachet，passwordの部分はデータベースの設定に合わせ適宜変更してください。

**db_cachetに必要なテーブルを登録**

```
export ENV=production
composer install --no-dev -o
php artisan migrate
```
**CachetHQを動かすにあたり必要なものを自動収集**

```
sudo npm isntall
bower install 
sudo gulp
```
**エディタで/etc/php5/fpm/pool.d/cachet.confを作成**

```
[ユーザー名]
user = ユーザー名  
group = ユーザー名  
listen = /var/run/php5-fpm-ユーザー名.sock  
listen.owner = ユーザー名
listen.group = ユーザー名  
listen.mode = 0666  
pm = ondemand  
pm.max_children = 5  
pm.process_idle_timeout = 10s;  
pm.max_requests = 200  
chdir = /  
```
※ユーザー名の部分は適宜置き換えてください

**php5-fpmの再起動**

```
sudo service php5-fpm restart
```

**SSLの自己証明書を発行**

```
sudo mkdir -p /etc/nginx/ssl
cd /etc/nginx/ssl
sudo openssl genrsa -des3 -passout pass:x -out cachet.pass.key 2048
sudo openssl rsa -passin pass:x -in cachet.pass.key -out cachet.key
sudo rm cachet.pass.key
sudo openssl req -new -key cachet.key -out cachet.csr
sudo openssl x509 -req -days 365 -in cachet.csr -signkey cachet.key -out cachet.crt
```

**エディタで/etc/nginx/sites-available/cachet.confを以下の内容で作成**

```
server {
    listen      443 default;
    server_name cachet.example.com;

    ssl on;
    ssl_certificate     /etc/nginx/ssl/cachet.crt;
    ssl_certificate_key /etc/nginx/ssl/cachet.key;
    ssl_session_timeout 5m;

    ssl_ciphers               'AES128+EECDH:AES128+EDH:!aNULL';
    ssl_protocols              TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;

    root /home/ユーザー名/cachet.example.com/public;

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log  /var/log/nginx/cachet.access.log;
    error_log   /var/log/nginx/cachet.error.log;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm-ユーザー名.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_param ENV "production";
    }

    location ~ /\.ht {
        deny all;
    }
}

server {
    listen      80;
    server_name cachet.example.com;

    add_header Strict-Transport-Security max-age=2592000;
    rewrite ^ https://$server_name$request_uri? permanent;
}
```
**シンボリックリンクを張り、Nginxを再起動**

```
sudo a2ensite cachet.conf
sudo service nginx restart
```