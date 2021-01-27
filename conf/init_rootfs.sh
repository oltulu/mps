if [ -z $1 ];then
	echo "kokdizin parametresi eksik!"
	exit 1
else
	ROOTDIR=$1
fi

[ ! -d $ROOTDIR ] && mkdir -pv $ROOTDIR

mkdir -pv $ROOTDIR/{boot,etc/{opt,sysconfig},home,mnt,opt}
mkdir -pv $ROOTDIR/{media/{floppy,cdrom},srv,var}
install -dv -m 0750 $ROOTDIR/root
install -dv -m 1777 $ROOTDIR/tmp $ROOTDIR/var/tmp
mkdir -pv $ROOTDIR/usr/{,local/}{bin,include,lib,lib/firmware,src}
mkdir -pv $ROOTDIR/usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv  $ROOTDIR/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv $ROOTDIR/usr/{,local/}share/man/man{1..8}
ln -sf /usr/bin $ROOTDIR/bin
ln -sf /usr/bin $ROOTDIR/usr/sbin
ln -sf /usr/bin $ROOTDIR/sbin

ln -sf /usr/lib $ROOTDIR/lib
ln -sf /usr/lib $ROOTDIR/lib64
ln -sf /usr/lib $ROOTDIR/usr/lib64


mkdir -pv $ROOTDIR/var/{log,mail,spool}
ln -sv /run $ROOTDIR/var/run
ln -sv /run/lock $ROOTDIR/var/lock
mkdir -pv $ROOTDIR/var/{opt,cache,lib/{color,misc,locate},local}

install -vdm755 $ROOTDIR/usr/lib/pkgconfig



ln -sv /proc/self/mounts $ROOTDIR/etc/mtab

cat > $ROOTDIR/etc/fstab << "EOF"
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
EOF

cat > $ROOTDIR/etc/issue << "EOF"
Milis Linux \r (\l)
EOF

cat > $ROOTDIR/etc/lsb-release << "EOF"
DISTRIB_ID="Milis Linux"
DISTRIB_RELEASE="2.0"
DISTRIB_CODENAME="HAN"
DISTRIB_DESCRIPTION="Milis Linux Operating System"
EOF

cat > $ROOTDIR/etc/os-release << "EOF"
DISTRIB_ID="Milis Linux"
DISTRIB_RELEASE="2.0"
DISTRIB_CODENAME="HAN"
DISTRIB_DESCRIPTION="Milis Linux Operating System"
EOF

cat > $ROOTDIR/etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

cat > $ROOTDIR/etc/shadow << "EOF"
root:JINC7Qk9605P2:17405:0:99999:7:::
bin:x:17367:0:99999:7:::
daemon:x:17367:0:99999:7:::
messagebus:x:17367:0:99999:7:::
nobody:x:17367:0:99999:7:::
EOF

cat > $ROOTDIR/etc/gshadow << "EOF"
root:x::
bin:x::
sys:x::
kmem:x::
tape:x::
tty:x::
daemon:x::
floppy:x::
disk:x::
lp:x::
dialout:x::
audio:x::
video:x::
utmp:x::
usb:x::
cdrom:x::
adm:x::
messagebus:x::
input:x::
mail:x::
kvm:x::
wheel:x::
nogroup:x::
users:x::
EOF

chmod 400 $ROOTDIR/etc/shadow
chmod 400 $ROOTDIR/etc/gshadow

cat > $ROOTDIR/etc/group << "EOF"
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

# profil ayarları
cat > $ROOTDIR/etc/profile << "EOF"
# Begin /etc/profile
# Written for Beyond Linux From Scratch forked for Milis Linux 2.0 2019

# System wide environment variables and startup programs.

# System wide aliases and functions should go in /etc/bashrc.  Personal
# environment variables and startup programs should go into
# ~/.bash_profile.  Personal aliases and functions should go into
# ~/.bashrc.

# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}

export -f pathremove pathprepend pathappend

# Set the initial path
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/milis/bin:/usr/milis/mps/bin:/usr/local/bin


# Setup some environment variables.
export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"

# Set some defaults for graphical systems
#export XDG_DATA_DIRS=${XDG_DATA_DIRS:-/usr/share/}
#export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg/}
#export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/xdg-$USER}

# Setup a red prompt for root and a green one for users.
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
else
  PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
fi

for script in /etc/profile.d/*.sh ; do
        if [ -r $script ] ; then
                . $script
        fi
done

unset script RED GREEN NORMAL

# End /etc/profile
EOF


mkdir -p $ROOTDIR/etc/profile.d

cat > $ROOTDIR/etc/profile.d/bash_completion.sh << "EOF"
# Begin /etc/profile.d/bash_completion.sh
# Import bash completion scripts

# If the bash-completion package is installed, use its configuration instead
if [ -f /usr/share/bash-completion/bash_completion ]; then

  # Check for interactive bash and that we haven't already been sourced.
  if [ -n "${BASH_VERSION-}" -a -n "${PS1-}" -a -z "${BASH_COMPLETION_VERSINFO-}" ]; then

    # Check for recent enough version of bash.
    if [ ${BASH_VERSINFO[0]} -gt 4 ] || \
       [ ${BASH_VERSINFO[0]} -eq 4 -a ${BASH_VERSINFO[1]} -ge 1 ]; then
       [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion" ] && \
            . "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion"
       if shopt -q progcomp && [ -r /usr/share/bash-completion/bash_completion ]; then
          # Source completion code.
          . /usr/share/bash-completion/bash_completion
       fi
    fi
  fi

else

  # bash-completions are not installed, use only bash completion directory
  if shopt -q progcomp; then
    for script in /etc/bash_completion.d/* ; do
      if [ -r $script ] ; then
        . $script
      fi
    done
  fi
fi

# End /etc/profile.d/bash_completion.sh

EOF

cat > $ROOTDIR/etc/profile.d/dircolors.sh << "EOF"
# Setup for /bin/ls and /bin/grep to support color, the alias is in /etc/bashrc.
if [ -f "/etc/dircolors" ] ; then
        eval $(dircolors -b /etc/dircolors)
fi

if [ -f "$HOME/.dircolors" ] ; then
        eval $(dircolors -b $HOME/.dircolors)
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
EOF

cat > $ROOTDIR/etc/profile.d/readline.sh << "EOF"
# Setup the INPUTRC environment variable.
if [ -z "$INPUTRC" -a ! -f "$HOME/.inputrc" ] ; then
        INPUTRC=/etc/inputrc
fi
export INPUTRC
EOF

cat > $ROOTDIR/etc/profile.d/umask.sh << "EOF"
# By default, the umask should be set.
if [ "$(id -gn)" = "$(id -un)" -a $EUID -gt 99 ] ; then
  umask 002
else
  umask 022
fi
EOF

cat > $ROOTDIR/etc/profile.d/i18n.sh << "EOF"
# Set up i18n variables
export LANG=tr_TR.UTF-8
EOF

# saat ayarları
cat > $ROOTDIR/etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=2

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF

# mouse ayarları
cat > $ROOTDIR/etc/sysconfig/mouse << "EOF"
MDEVICE="/dev/input/mice"
PROTOCOL="imps2"
EOF

# ağ ayarları
cat > $ROOTDIR/etc/sysconfig/template.ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.2
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
EOF

cat > $ROOTDIR/etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

domain <Your Domain Name>
nameserver <IP address of your primary nameserver>
nameserver <IP address of your secondary nameserver>

# End /etc/resolv.conf
EOF

cat > $ROOTDIR/etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF

cat > $ROOTDIR/etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF


echo "milis" > $ROOTDIR/etc/hostname

touch $ROOTDIR/var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp $ROOTDIR/var/log/lastlog
chmod -v 664  $ROOTDIR/var/log/lastlog
chmod -v 600  $ROOTDIR/var/log/btmp

# talimatname yolu 
mkdir -p $ROOTDIR/usr/milis/talimatname

# mps
#mkdir -p $ROOTDIR/var/lib/mps/db
#mkdir -p $ROOTDIR/var/log/mps/kur
#mkdir -p $ROOTDIR/var/log/mps/sil
