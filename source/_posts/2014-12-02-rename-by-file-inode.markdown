---
layout: post
title: "ファイル名が文字化けして指定出来ない場合の対応"
date: 2013-12-02 13:19:06 +0900
comments: true
categories: ["@amidaku", "Linux"]
---

# ファイル名が文字化けして指定出来ない場合の対応

なんらかの事情でファイル名が文字化けし、指定ができなくなる場合がある（というかそういう場面に遭遇した）。  
Linuxでは下記の様に表示されるが、Windowsなどでftpツールでログインするとindex.htmlが３つ、report.htmlが３つという訳のわからない状態に見える。  
ちなみにLinuxでは表示できるが、 **ファイル名を指定することができない** ため何の対応も出来ない。  
（そもそも同一のフォルダに同じ名前のファイルとか...）

```
[root@xxxx xxxxx]# ls -la
合計 244
-rw-r--r--.  1 hogehoge hogehoge 16959  2月 29 12:25 2012 ??report.html
-rw-rw-r--.  1 hogehoge hogehoge 16959  2月 24 14:41 2012 ??report.html
-rw-r--r--.  1 hogehoge hogehoge  8516  2月 29 12:25 2012 ??index.html
-rw-rw-r--.  1 hogehoge hogehoge  8516  2月 24 14:41 2012 ??index.html
drwxr-xr-x. 12 hogehoge hogehoge  4096  7月 11 11:51 2013 .
drwx--x--x.  3 hogehoge    500  4096  7月  1 15:03 2000 ..
drwxr-xr-x.  6 hogehoge hogehoge  4096  4月  2 20:08 2013 event
-rw-r--r--.  1 hogehoge hogehoge 12247  4月 29 21:56 2013 event.html
drwxr-xr-x.  5 hogehoge hogehoge  4096  1月 22 16:16 2013 report
-rw-r--r--   1 hogehoge hogehoge 16235  7月 11 11:51 2013 report.html
drwxrwxr-x.  5 hogehoge hogehoge  4096  4月 28 20:02 2013 img
-rw-r--r--   1 hogehoge hogehoge  9979  7月 11 11:51 2013 index.html
```

## ファイルinode番号の確認

この場合はLinuxのファイルinode番号で処理をする。  
`ls` コマンドの `i` オプションをつけると各ファイルのinode番号が表示される。  
（最初の列がinode番号）


```
[root@xxxx xxxxx]# ls -li
合計 236
785288 -rw-r--r--. 1 hogehoge hogehoge 16959  2月 29 12:25 2012 ??report.html
785214 -rw-rw-r--. 1 hogehoge hogehoge 16959  2月 24 14:41 2012 ??report.html
785213 -rw-r--r--. 1 hogehoge hogehoge  8516  2月 29 12:25 2012 ??index.html
785212 -rw-rw-r--. 1 hogehoge hogehoge  8516  2月 24 14:41 2012 ??index.html
785289 drwxr-xr-x. 6 hogehoge hogehoge  4096  4月  2 20:08 2013 event
785071 -rw-r--r--. 1 hogehoge hogehoge 12247  4月 29 21:56 2013 event.html
785016 drwxr-xr-x. 5 hogehoge hogehoge  4096  1月 22 16:16 2013 report
784916 -rw-r--r--  1 hogehoge hogehoge 16235  7月 11 11:51 2013 report.html
785072 drwxrwxr-x. 5 hogehoge hogehoge  4096  4月 28 20:02 2013 img
784915 -rw-r--r--  1 hogehoge hogehoge  9979  7月 11 11:51 2013 index.html
```

## inode番号でファイル指定しリネーム

inode番号で指定するには `find` コマンドが使いやすい。

```
[root@xxxx xxxxx]# find . -inum 785214
./??report.html
```

`find` コマンドに `exec` オプションをつける事で引数を受け渡してコマンド実行が可能

```
[root@xxxx xxxxx]# find . -inum 785214 -exec mv {} report._html1 \;
```

これで指定出来なかった **??report.html** の一つが **report._html1** にリネームされる。

```
[root@xxxx xxxxx]# ls -la
合計 244
-rw-r--r--.  1 hogehoge hogehoge 16959  2月 29 12:25 2012 ??report.html
-rw-r--r--.  1 hogehoge hogehoge  8516  2月 29 12:25 2012 ??index.html
-rw-rw-r--.  1 hogehoge hogehoge  8516  2月 24 14:41 2012 ??index.html
drwxr-xr-x. 12 hogehoge hogehoge  4096  7月 11 12:31 2013 .
drwx--x--x.  3 hogehoge    500  4096  7月  1 15:03 2000 ..
drwxr-xr-x.  6 hogehoge hogehoge  4096  4月  2 20:08 2013 event
-rw-r--r--.  1 hogehoge hogehoge 12247  4月 29 21:56 2013 event.html
drwxr-xr-x.  5 hogehoge hogehoge  4096  1月 22 16:16 2013 report
-rw-rw-r--.  1 hogehoge hogehoge 16959  2月 24 14:41 2012 report._html1
-rw-r--r--   1 hogehoge hogehoge 16235  7月 11 11:51 2013 report.html
drwxrwxr-x.  5 hogehoge hogehoge  4096  4月 28 20:02 2013 img
-rw-r--r--   1 hogehoge hogehoge  9979  7月 11 11:51 2013 index.html
```

これで普通にファイル名でアクセスできる様になるので、その後の処理をすることになる。

### 一気に削除するなら
一気に削除するなら下記のコマンドとなる。
ただし `-i` オプションは削除実行の前に確認をするためコワイので、普通はリネームしてから処理することが多いと思われる。

```
[root@xxxx xxxxx]# find . -inum 785214 -exec rm -i {} \;
```

