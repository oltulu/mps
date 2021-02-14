#!/bin/sh
# todo!!! yeni bir ikon seti yüklendiğinde mps tarafından kontrol edilecek.
if [ -z $1 ];then
	echo "simge seti dizini parametresi yok!"
	exit 0
else
	if [ -d /usr/share/icons/$1 ];then
		gtk-update-icon-cache -f /usr/share/icons/$1
		gtk-update-icon-cache -t /usr/share/icons
	else
		echo "simge seti dizini yok! /usr/share/icons/$1"
		exit 0
	fi
fi 
