#!/bin/bash

if [ -z $MPS_PATH ];then
	MPS_PATH="/usr/milis/mps"
fi

if [ ! -z $1 ];then
	MPS_PATH="$1"
fi

if [ ! -d $MPS_PATH ];then
	echo "$MPS_PATH dizini mevcut değil!"
	exit 1
fi

cd $MPS_PATH/src

# lua kütüphanelerinin derlenip-yüklenmesi

# 0 temizlik 

[ -d $MPS_PATH/lua/ext ] && mv $MPS_PATH/lua/ext $MPS_PATH/lua/ext.old
mkdir -p $MPS_PATH/lua/ext

# 1- luafilesystem
cd luafilesystem && make clean && make && cp -rf src/*.so $MPS_PATH/lua/ext/ && make clean
cd -

# 2- luasocket
cd luasocket && make clean && MYCFLAGS=$CFLAGS MYLDFLAGS=$LDFLAGS make LUAV=5.3 linux
mkdir /tmp/pkg.socket
make DESTDIR=/tmp/pkg.socket LUAV=5.3 prefix=/usr install-unix
cp -rf  /tmp/pkg.socket/usr/lib/lua/5.3/*  $MPS_PATH/lua/ext/
cp -rf  /tmp/pkg.socket/usr/share/lua/5.3/*  $MPS_PATH/lua/ext/
rm -rf /tmp/pkg.socket
make clean
cd -

# 3- lua-sec ssl support
cd luasec && make clean && make linux DEFS="-DWITH_LUASOCKET -DOPENSSL_NO_SSL3"
mkdir /tmp/pkg.sec
make LUACPATH="/tmp/pkg.sec/usr/lib/lua/5.3" LUAPATH="/tmp/pkg.sec/usr/share/lua/5.3" install
cp -rf  /tmp/pkg.sec/usr/lib/lua/5.3/*  $MPS_PATH/lua/ext/
cp -rf  /tmp/pkg.sec/usr/share/lua/5.3/*  $MPS_PATH/lua/ext/
rm -rf /tmp/pkg.sec
make clean
cd -


# 4 temizlik
rm -rf $MPS_PATH/lua/ext.old

# exe
chmod +x $MPS_PATH/bin/mps*.lua
