---
layout: post
title: "AWS AMIの公開（Amazon Linux）"
date: 2015-03-18 23:00:00 +0900
comments: true
categories: ['@amidaku', 'AWS']
---
## AMIの元になるインスタンスを構築

普通にインスタンスを作成しアプリケーションほか構築

## サービス停止

自動起動の設定等はそのまま、起動しているデーモン等（特にログを出力するもの）の停止をおこなう。

サンプル

```
[ec2-user@xxx ]$ sudo service mysqld stop
[ec2-user@xxx ]$ sudo service postfix stop
```

## 重要情報削除

削除対象

* ログ
* 操作履歴
* 個人操作履歴


### ec2-user履歴削除

```
[ec2-user@xxx ]$ export HISTSIZE=0
[ec2-user@xxx ]$ history -c
[ec2-user@xxx ]$ sudo su -
```


### 削除用スクリプト作成

下記内容の `delete.sh` ファイルを `/root` に作成する。  
下記シェルスクリプトでは、 *root* および *ec2-user* でのMySQLに関するログも削除している。
またログファイルに関してはhttpdのログなど、公開したくないログがあればサンプルを参考に内容を消去するスクリプトを追記すること。

```
#!/bin/sh

service rsyslog stop
cp /dev/null /root/.ssh/authorized_keys
cp /dev/null /root/.bash_history
cp /dev/null /root/.mysql_history
cp /dev/null /home/ec2-user/.ssh/authorized_keys
cp /dev/null /home/ec2-user/.bash_history
cp /dev/null /home/ec2-user/.mysql_history
cp /dev/null /var/log/boot.log
cp /dev/null /var/log/btmp
cp /dev/null /var/log/cron
cp /dev/null /var/log/dmesg
cp /dev/null /var/log/dmesg.old
cp /dev/null /var/log/lastlog
cp /dev/null /var/log/maillog
cp /dev/null /var/log/messages
cp /dev/null /var/log/secure
cp /dev/null /var/log/spooler
cp /dev/null /var/log/tallylog
cp /dev/null /var/log/wtmp
cp /dev/null /var/log/yum.log
cp /dev/null /var/log/audit/audit.log
cp /dev/null /var/log/cloud-init.log
cp /dev/null /var/log/cloud-init-output.log
cp /dev/null /var/log/dracut.log
cp /dev/null /var/log/mail/statistics

```

### 処理実行

```
[root@xxx ]# sh delete.sh
```

delete.shを削除する。

```
[root@xxx ]# rm delete.sh
```

rootの履歴を削除する。

```
[root@xxx ]# export HISTSIZE=0
[root@xxx ]# history -c
```

## AMIを作成する。

AWS管理コンソールで、対象のインスタンスを指定し、
*[Actions]* をクリックして *[Image]* を選択し、*[Create Image]* でしばらくすると、My AMIsに追加される。  
*Discription* や *Name* は、作成時のみ指定可能であとから変更することができないので、あらかじめ記入内容を決めておき、コピペでしていする用が良い。  
作成元のインスタンスはログイン用公開鍵を削除しているので、もうログインできない。  
インスタンスは使えないので、 *STOPもしくはTerminate* する。