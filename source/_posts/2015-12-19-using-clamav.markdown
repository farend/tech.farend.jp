---
layout: post
title: "clamscanとclamdscanの使用方法"
date: 2015-12-28 11:00:00 +0900
comments: true
categories: ['@y_fujie', 'ClamAV', 'ubuntu']
---

参考：[公式ドキュメント](https://github.com/vrtadmin/clamav-faq/tree/master/manual)

## clamscan

```
(0) 特定のファイルをスキャン:

       clamscan [ファイルパス]

(1) カレントディレクトリをスキャン:

       clamscan

(2) 特定のディレクトリを再帰的にスキャン:

       clamscan -r [ディレクトリパス]

(3) 特定のファイルからデータベースを読み込んでスキャン:

       clamscan -d /tmp/newclamdb -r /tmp

(4) パイプを利用してファイル内をスキャン:

       cat testfile | clamscan -
       
(5) homeディレクトリを再起的にスキャンし、感染しているファイルのみ出力し、指定ディレクトリに隔離:

       clamscan -i -r /home --move=[ディレクトリパス]
       
(6) ログファイルを指定して、/sysを除外してフルスキャン、冗長なメッセージを出力させない:

       clamscan -r / -l /var/log/clamscan.log --exclude-dir=/sys/ -i --quiet
```              
## clamdscan

```
(0) 特定のファイルをスキャン:

       clamdscan [ファイルパス]

(1) カレントディレクトリをスキャン:

       clamdscan

(2) 特定のディレクトリ内をスキャン:

       clamdscan [ディレクトリパス]

(3)他のユーザが実行しているclamdデーモンでスキャン :

       clamdscan --fdpass [ディレクトリパス]

(4) 標準入力からスキャン:

       clamdscan - <  [パス]

       cat [パス] | clamdscan -
```

###clamdscanで再起的なスキャンを実行する

```
sudo ls -R [ディレクトリパス] | grep / | tr -d : | xargs clamdscan
```