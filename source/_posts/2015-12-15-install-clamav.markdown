---
layout: post
title: "Clam Antivirusの導入方法"
date: 2015-12-15 11:10:00 +0900
comments: true
categories: ['@y_fujie', 'CalmAV', 'ubuntu']
---


##インストール

```
sudo apt-get install clamav clamav-daemon
```

##初期設定

###ログファイルの設定

```
sudo touch /var/log/clamav/freshscan.log /var/log/clamav/clamscan.log /var/log/clamav/clamdscan.log
sudo chmod 600 -R /var/log/clamav/
sudo chown -R clamav /var/log/clamav/
```

###ウイルス定義データベースの更新

```
sudo freshclam
```

##使用例

ClamAVにはウイルススキャンを行う `clamscan` と、
デーモンとして常駐させておきウイルススキャンする `clamdscan` があります。
`clamscan` では実行の度に定義データベースの読み込みを行いますが、 `clamdscan` ではデーモンの起動時にのみ定義データベースの読み込みを行います。

ClamAVにはローカルでウイルススキャンを行うclamscanと、
デーモンとして常駐させておき特定のIPを持つ端末をウイルススキャンするclamdscanがあります。

###clamscanによるフルスキャンの実行

```
sudo clamscan -r / -l /var/log/clamscan.log --exclude-dir=/sys/ -i --quiet
```

###clamdscanによるスキャンの実行

```
sudo clamd  //デーモンの起動
sudo clamdscan / -l /var/log/clamdscan.log -i --quiet
```

**clamdscan実行時に権限エラーが出る場合**

`/etc/clamav/clamd.conf` の `User clamav` を `User root` 等に書き換えてください。

###clamscanで定期的にスキャンさせる

`freshclam` を毎日実行するようデーモンとして常駐させます。

```
freshclam -d
```

`clamscan.sh` を作成します。

```
#!/bin/sh
clamscan -r / -l /var/log/clamav/clamscan.log --exclude-dir=/sys/ -i --quiet
```

作成したスクリプトを配置します。

```
chmod +x clamscan.sh
mv clamscan.sh /etc/cron.daily/
```
