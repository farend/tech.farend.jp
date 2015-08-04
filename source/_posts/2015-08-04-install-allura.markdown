---
layout: post
title: "Alluraのインストール手順"
date: 2015-08-04 13:13:00 +0900
comments: true
categories: ['@y_fujie', 'allura']
---

SubversionやGitなどのリポジトリをブラウザ上で一元管理する「Allura」のインストール手順です。

##環境設定
Alluraの構築に必要なパッケージをインストールします。

```
sudo apt-get install git-core default-jre-headless python-dev libssl-dev libldap2-dev libsasl2-dev libjpeg8-dev zlib1g-dev subversion python-svn
```
##MongoDBインストール
MongoDBのインストール手順です。

```
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo service mongod start
```
##Pythonインストール
pipをインストールし、さらに必要なパッケージをインストールします。

```
sudo apt-get -y install python-pip
sudo pip install virtualenv
virtualenv env-allura
. env-allura/bin/activate
```
##Allura環境準備
Alluraのログを格納する環境準備です。

```
sudo mkdir -p /var/log/allura
sudo chown $(whoami) /var/log/allura
```
##Alluraインストール
Allura本体をgitからクローニングし、必要なパッケージをインストールします。

```
mkdir src
cd src
git clone https://git-wip-us.apache.org/repos/asf/allura.git allura
cd allura
pip install -r requirements.txt
ln -s /usr/lib/python2.7/dist-packages/pysvn ~/env-allura/lib/python2.7/site-packages/
```
###全部インストール
プラグインツールを全てインストールします。

```
./rebuild-all.bash # ALL build
```
###部分インストール
必要なプラグインのみインストールします。
src/allura以下ににツールのディレクトリがあります。以下の２つは必須ツールです。

```
cd Allura
python setup.py develop
cd ../ForgeWiki
python setup.py develop
```
同様に

```
cd ツール名
python setup.py develop
```
で追加ツールをインストールできます。
##Solrインストール
Apache Solrのインストールを行います。

```
cd ~/src
wget http://archive.apache.org/dist/lucene/solr/4.2.1/solr-4.2.1.tgz
tar xf solr-4.2.1.tgz && rm -f solr-4.2.1.tgz
cp -f allura/solr_config/schema.xml solr-4.2.1/example/solr/collection1/conf
cd solr-4.2.1/example/
nohup java -jar start.jar > /var/log/allura/solr.log &
```

##リポジトリ領域作成
各種リポジトリを保存する領域を作成します。

```
sudo mkdir /srv/{git,svn,hg}
sudo chown $USER /srv/{git,svn,hg}
sudo chmod 775 /srv/{git,svn,hg}
```
##Allura起動
Alluraを起動します。

```
cd ~/src/allura/Allura
nohup paster taskd development.ini > /var/log/allura/taskd.log 2>&1 &
ALLURA_TEST_DATA=False paster setup-app development.ini
nohup paster serve --reload development.ini > /var/log/allura/allura.log 2>&1 &
```

##自動起動設定
/etc/init.dにalluraの起動スクリプトを配置し、serviceコマンドで扱えるようにします。
###事前準備

```
sudo apt-get -y install sysv-rc-conf
```
###起動スクリプト
ALLURADIRと SOLRDIRは適宜変更してください。
以下は"user_allura"というユーザーのホームディレクトリにAlluraがインストールされている場合です。


```sudo vim /etc/init.d/allura```

```
#!/bin/bash
ALLURADIR=/home/user_allura/src/allura/Allura
SOLRDIR=/home/user_allura/src/solr/example

start(){
echo "Starting Allura"
. /home/user_allura/env-allura/bin/activate
cd $SOLRDIR
nohup java -jar start.jar > /var/log/allura/solr.log &
cd $ALLURADIR
nohup paster taskd development.ini > /var/log/allura/taskd.log 2>&1 &
nohup paster serve --reload development.ini > /var/log/allura/allura.log 2>&1 &
if [ $? -eq 0 ]; then
        echo "OK. Allura is running."
        return 0
else
        echo "Some ERROR occurred."
        return 1
fi
}
stop(){
echo "Stopping Allura"
pkill -f "paster serve --reload development.ini"
if [ $? -eq 0 ]; then
        echo "OK. Allura is stopped"
        return 0
else
        echo "Some ERROR occurred."
        return 1
fi
}
case "$1" in
        start)   start ;;
        stop)    stop ;;
        restart) echo "Restarting Allura"
                 stop
                 start ;;
esac
```

このスクリプトを作成した後、以下を実行すると```sudo service allura start```で起動できるようになります。

```
sudo sysv-rc-conf allura on
```

以上です。