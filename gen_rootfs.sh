#!/bin/sh
export MPS_PATH=/opt/mps
export MILIS_PATH=/tmp/sys/usr/milis
git clone https://notabug.org/milislinux/mps $MPS_PATH
cd $MPS_PATH
bash derle.sh $MPS_PATH
cd bin
./mps -v && ./mps -v
nano ../conf/conf.lua
./mps --initfs --kok=/tmp/sys
./mps --ilk --kok=/tmp/sys
./mps -G --kok=/tmp/sys
./mps -GG --kok=/tmp/sys
./mps -BG --kok=/tmp/sys
./mps kur --dosya=/tmp/sys/usr/milis/talimatname/1/order --kurkos=0 --koskur=0 --kok=/tmp/sys
cp -r $MPS_PATH /tmp/sys/usr/milis/mps
# alttaki komutlar chroot içinde
chmod +x enter-chroot
./enter-chroot /tmp/sys
dracut -N --force --xz --add 'dmsquash-live pollcdrom' --omit systemd /boot/initrd_live `ls /usr/lib/modules`
cd /usr/milis/mps
bash derle.sh
# gerekli servislerin kurulması
cd /usr/milis/ayarlar/servisler
make kur-random
rm -rf /var/cache/mps/depo/*
rm -f /root/.bash_history
exit
# iso yapma
cd /opt
git clone https://notabug.org/milislinux/imaj-uretici-2
cd /opt/imaj-uretici-2.0 
bash iso_olustur.sh /tmp/sys
