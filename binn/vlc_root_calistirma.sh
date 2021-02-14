#!/bin/sh

cp /usr/bin/vlc /usr/bin/vlc-backup 

sed -i 's/geteuid/getppid/' /usr/bin/vlc
