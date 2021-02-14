if [ -z $1 ];then
	echo "kokdizin parametresi eksik!"
	exit 1
else
	PKG=$1
fi

[ ! -d $PKG ] && mkdir -pv $PKG

mkdir -pv $PKG/{boot,etc/{opt,sysconfig},home,mnt,opt}
mkdir -pv $PKG/{media/{floppy,cdrom},srv,var}
install -dv -m 0750 $PKG/root
install -dv -m 1777 $PKG/tmp $PKG/var/tmp
mkdir -pv $PKG/usr/{,local/}{bin,include,lib,lib/firmware,src}
mkdir -pv $PKG/usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -v  $PKG/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv $PKG/usr/{,local/}share/man/man{1..8}
ln -sf /usr/bin $PKG/bin
ln -sf /usr/bin $PKG/usr/sbin
ln -sf /usr/bin $PKG/sbin

ln -sf /usr/lib $PKG/lib
ln -sf /usr/lib $PKG/lib64
ln -sf /usr/lib $PKG/usr/lib64


mkdir -v $PKG/var/{log,mail,spool}
ln -sv $PKG/run $PKG/var/run
ln -sv $PKG/run/lock $PKG/var/lock
mkdir -pv $PKG/var/{opt,cache,lib/{color,misc,locate},local}

install -vdm755 $PKG/usr/lib/pkgconfig



ln -sv /proc/self/mounts $PKG/etc/mtab

cat > $PKG/etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

cat > $PKG/etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
wheel:x:97:
nogroup:x:99:
users:x:999:
EOF

touch $PKG/var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp $PKG/var/log/lastlog
chmod -v 664  $PKG/var/log/lastlog
chmod -v 600  $PKG/var/log/btmp

# talimatname yolu 
mkdir -p $PKG/usr/milis/talimatname

# mps
#mkdir -p $PKG/var/lib/mps/db
#mkdir -p $PKG/var/log/mps/kur
#mkdir -p $PKG/var/log/mps/sil
