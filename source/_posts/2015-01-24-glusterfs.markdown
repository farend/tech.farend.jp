---
layout: post
title: "GlusterFS構築手順"
date: 2015-01-24 11:00:00
comments: true
categories: ['@amidaku', 'GlusterFS']
---
Linuxにおいてファイル領域を冗長化したい場面は多いと思います。  
例えばファイルサーバやNFSサーバなどの共有領域は冗長構成にしておきたい場面は多いのでは無いでしょうか。  
オンプレなサーバであれば、媒体自体をハードウェアRAIDやソフトウェアRAIDでミラーリングしたり、DRBD等のツールでクラスタ化することが多いと思います。
クラウドを使った場合は、いろいろと仕様的な制限があったりで、使えない場合があります。  
今回は簡単に構築でき、マスターレスで動作する分散ファイルシステム **GlusterFS** の設定について書きます。


## ホストの用意

今回CentOS6、Amazon Linuxにて検証  
**※2台のVolume提供サーバをそれぞれ gfs_sv1・gfs_sv2、クライアントをgfs_clと仮定します。**

## 提供領域の確保(※Volume提供サーバの作業)

### 提供用の領域を準備する

クラウドやアーキテクチャに従い作業  
なお、提供領域が外部volumeで無い場合は、下記 `/etc/fstab` への追記までの作業は不要。  

### 増設領域のマウントポイントを作る

今回の例は`/var/glustervols`

```
# mkdir /var/glustervols
```

### 領域をマウント

下記はext4でマウントしている

```
# mount -t ext4 /dev/xxx /var/glustervols
```

### 再起動時に自動マウントするように、 `/etc/fstab` に追記する

```
/dev/xxx /var/glustervols ext4 defaults 0 0
```

### 領域のユーザをアプリケーションサーバと同じにし、パーミッションを変更する

**※UIDに注意**

今回の例では、apacheの領域として設定

```
# groupadd -g 600 apache
# useradd -g 600 -s /sbin/nologin -u 600 -d /var/glustervols apache
# chown -R apache:apache /var/glustervols
```

## すべての機器にGlusterFSを導入する

### Glusterよりリポジトリサイトを登録

```
# cd /etc/yum.repos.d/
# yum -y install wget
# wget http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/glusterfs-epel.repo
```

`/etc/yum.repos.d/glusterfs-epel.repo` の `enabled=1` を `enabled=0` に書き換え、指定時以外はyumリポジトリを参照しないようにする。   

```
# sed -i -e 's/enabled=1/enabled=0/g' /etc/yum.repos.d/glusterfs-epel.repo
```

### GlusterFSをインストールし、起動する

**※Amazon Linuxの場合$releaseverの値が取得できないので、yumの実行前に `/etc/yum.repo.d/glusterfs-epel.repo` の `$releasever` を _6など適切な物に_ 書き換える**

```
# yum --enablerepo=glusterfs-epel -y install glusterfs-server
# /etc/init.d/glusterd start
# chkconfig glusterd on
```

### DNSが使用できないときのために、 `/etc/hosts` に追記する

```
xxx.xxx.xxx.xxx gfs_sv1
xxx.xxx.xxx.yyy gfs_sv2
xxx.xxx.xxx.zzz gfs_cl
```

## Volume提供サーバ（の内、どちらか一方）にてVolumeを構成する。

例ではgfs_sv1において、replicaモードで2つの領域（ **gfs_sv1の `/var/glustervols`** と **gfs_sv2の `/var/glustervols`** ）を一つの `vol01` という仮想ボリュームとして構成している  

```
# gluster peer probe gfs_sv2
# gluster peer probe gfs_cl
# gluster volume create vol01 replica 2 transport tcp gfs_sv1:/var/glustervols gfs_sv2:/var/glustervols
# gluster volume start vol01
```

注意する点としては、 `gluster peer probe` コマンドで連携するホストを指定するが、 **Glusterクライアントの `gfs_cl` も含めている** ところ。

## クライアントにてlocalhostをマウントする

今回の例では、gfs_clでの作業

```
# mkdir /var/app01
# chown -R apache:apache /var/app01
# mount -t glusterfs localhost:/vol01 /var/app01
```

起動時に自動マウントする場合は `/etc/fstab` に下記を追記する。  

```
localhost:/vol01 /var/app01 glusterfs defaults,_netdev 0 0
```

これでクライアントであるgfs_clにおいて、 `/var/app01` にファイルやディレクトリを作成すると、両方のVolume提供サーバの `/var/glustervols` にファイルが作成され冗長構成が実現する。  
その後の編集なども同期され冗長化は維持される。  

## その他

クライアントがglusterfsファイルシステムを利用出来ない場合は、nfsでマウントすることも可能。  
この場合クライアントからはVolume提供サーバのどちらかを指定しマウントすることになる。  

GlusterFSは、マスターを持たないのでどちらを指定しても良い。  
ただし、Volume提供サーバの物理的な故障などで冗長化が壊れた場合、glusterfsマウントした場合は自動的に動作中のVolume提供サーバと通信し、サービス可動が維持できるが、 **NFSマウントした場合は指定したVolume提供サーバが落ちた場合は停止する** ことになる。  
