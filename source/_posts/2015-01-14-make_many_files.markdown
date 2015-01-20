---
layout: post
title: "ダミーファイルをいっぱい作る"
date: 2015-01-14 16:00:00 +0900
comments: true
categories: ['@amidaku', 'ruby', 'Operations']
---

ファイル関係のテスト用にダミーファイルがいっぱい必要な事ありますよね。

シェルスクリプトが面倒なのでRubyでつくりました。  
ただし、実際のファイル作成についてはddコマンドを実行しています。
ループとファイル名作成はRubyで、ファイルそのものはコマンドを使うという怠け者（ => オレ）です。


```
DIR = '/testvolume/'
0.upto(99) do |i|
  i = "%02d" % i
  TARGET_DIR = DIR + 'testdir' + i.to_s + '/'
  0.upto(99) do |j|
    j = "%02d" % j
    file_name = TARGET_DIR + "testfile#{j.to_s}"
    system("dd if=/dev/zero of=#{file_name} bs=1024 count=100")
  end
end
```

/testvolumeディレクトリの中に、さらにtestdir00〜testdir99というディレクトリを作成し、各ディレクトリにtestfile00〜testfile99という100KBのファイルを作成しています。  
ファイルサイズはsystemコマンド中のddコマンドでbsとcountを変更することで調節できます。  

* bs => ブロックサイズ（ `bs=1024` で1KByte）
* count => サイズ（ `count=100` で上記ブロックサイズx100）

[Man page of DD](http://linuxjm.sourceforge.jp/html/GNU_fileutils/man1/dd.1.html)
