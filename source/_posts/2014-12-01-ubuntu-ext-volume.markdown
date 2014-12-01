---
layout: post
title: "ubuntuでの外部ボリュームマウントについて"
date: 2014-12-01 18:25:44 +0900
comments: true
categories: ['@amidaku', 'ubuntu']
---

Linuxサーバで外部ボリュームを起動時に自動的にマウントさせるには`/etc/fstab`に記載をすることで可能になるが、ubuntu（debian系全般の模様であるが）では外部ボリュームが自動マウント出来ないと、ホストは起動するがsshログインが出来ないようになる。  
これを回避するため、`/etc/fstab`の記載で **nobootwait** のオプションを追記する。


```
/dev/xvdf1		/mnt	ext4	defaults,nobootwait	0 0
```

この追記で起動時に待ち（！？）が発生せず、sshdも通常通り起動しログイン可能となる模様。

**なお、AMAZON Linux（たぶんRedHat系全般と思われるが）では`nobootwait`の記載は無くてもホストはログイン可能の状態となった。**

<hr>

##### 情報ソース

[Amazon EBS ボリュームを使用できるようにする - Amazon Elastic Compute Cloud](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ebs-using-volumes.html)
