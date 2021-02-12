SHELL=/bin/bash
ETCDIR=${DESTDIR}/etc
MODE=754
DIRMODE=755
CONFMODE=644

all: links

install: all

create-dirs:
	install -d -m ${DIRMODE}  ${ETCDIR}/rc.d/rc0.d
	install -d -m ${DIRMODE}  ${ETCDIR}/rc.d/rc1.d
	install -d -m ${DIRMODE}  ${ETCDIR}/rc.d/rc2.d
	install -d -m ${DIRMODE}  ${ETCDIR}/rc.d/rc3.d
	install -d -m ${DIRMODE}  ${ETCDIR}/rc.d/rc4.d
	install -d -m ${DIRMODE}  ${ETCDIR}/rc.d/rc5.d
	install -d -m ${DIRMODE}  ${ETCDIR}/rc.d/rc6.d
	install -d -m ${DIRMODE}  ${ETCDIR}/rc.d/rcS.d
	install -d -m ${DIRMODE}  ${ETCDIR}/rc.d/init.d
	install -d -m ${DIRMODE}  ${ETCDIR}/sysconfig

create-links:
	ln -sfn       rc.d/init.d ${ETCDIR}/init.d

files: create-dirs create-links
	install -m ${MODE} ./init.d/initbase      ${ETCDIR}/rc.d/init.d/
	install -m ${MODE} ./init.d/halt          ${ETCDIR}/rc.d/init.d/
	install -m ${MODE} ./init.d/network       ${ETCDIR}/rc.d/init.d/
	install -m ${MODE} ./init.d/rc            ${ETCDIR}/rc.d/init.d/
	install -m ${MODE} ./init.d/reboot        ${ETCDIR}/rc.d/init.d/
	install -m ${MODE} ./init.d/sendsignals   ${ETCDIR}/rc.d/init.d/
	install -m ${MODE} ./init.d/setclock      ${ETCDIR}/rc.d/init.d/
	install -m ${MODE} ./init.d/sysklogd      ${ETCDIR}/rc.d/init.d/
	install -m ${MODE} ./init.d/template      ${ETCDIR}/rc.d/init.d/

	install -m ${CONFMODE} ./functions        ${ETCDIR}/rc.d

	if [ ! -f ${ETCDIR}/sysconfig/createfiles ]; then \
	  install -m ${CONFMODE} ./sysconfig/createfiles ${ETCDIR}/sysconfig/ ;\
	fi
	if [ ! -f ${ETCDIR}/sysconfig/modules     ]; then \
	  install -m ${CONFMODE} ./sysconfig/modules     ${ETCDIR}/sysconfig/ ;\
	fi
	if [ ! -f ${ETCDIR}/sysconfig/udev_retry  ]; then \
	  install -m ${CONFMODE} ./sysconfig/udev_retry  ${ETCDIR}/sysconfig/ ;\
	fi
	if [ ! -f ${ETCDIR}/sysconfig/rc.site     ]; then \
	  install -m ${CONFMODE} ./sysconfig/rc.site     ${ETCDIR}/sysconfig/ ;\
	fi

links: rcS rc0 rc1 rc2 rc3 rc4 rc5 rc6

rcS: files
	ln -sf ../init.d/initbase    ${ETCDIR}/rc.d/rcS.d/S00initbase

rc0: files
	ln -sf ../init.d/network     ${ETCDIR}/rc.d/rc0.d/K80network
	ln -sf ../init.d/sysklogd    ${ETCDIR}/rc.d/rc0.d/K90sysklogd
	ln -sf ../init.d/sendsignals ${ETCDIR}/rc.d/rc0.d/K60sendsignals
	ln -sf ../init.d/initbase    ${ETCDIR}/rc.d/rc0.d/K98initbase
	ln -sf ../init.d/halt        ${ETCDIR}/rc.d/rc0.d/S99halt

rc1: files
	ln -sf ../init.d/network     ${ETCDIR}/rc.d/rc1.d/K80network
	ln -sf ../init.d/sysklogd    ${ETCDIR}/rc.d/rc1.d/K90sysklogd

rc2: files
	ln -sf ../init.d/network     ${ETCDIR}/rc.d/rc2.d/K80network
	ln -sf ../init.d/sysklogd    ${ETCDIR}/rc.d/rc2.d/K90sysklogd

rc3: files
	ln -sf ../init.d/sysklogd    ${ETCDIR}/rc.d/rc3.d/S10sysklogd
	ln -sf ../init.d/network     ${ETCDIR}/rc.d/rc3.d/S20network

rc4: files
	ln -sf ../init.d/sysklogd    ${ETCDIR}/rc.d/rc4.d/S10sysklogd
	ln -sf ../init.d/network     ${ETCDIR}/rc.d/rc4.d/S20network

rc5: files
	ln -sf ../init.d/sysklogd    ${ETCDIR}/rc.d/rc5.d/S10sysklogd
	ln -sf ../init.d/network     ${ETCDIR}/rc.d/rc5.d/S20network

rc6: files
	ln -sf ../init.d/network     ${ETCDIR}/rc.d/rc6.d/K80network
	ln -sf ../init.d/sysklogd    ${ETCDIR}/rc.d/rc6.d/K90sysklogd
	ln -sf ../init.d/sendsignals ${ETCDIR}/rc.d/rc6.d/K60sendsignals
	ln -sf ../init.d/initbase    ${ETCDIR}/rc.d/rc6.d/K98initbase
	ln -sf ../init.d/reboot      ${ETCDIR}/rc.d/rc6.d/S99reboot

uninstall:
	rm -rf ${ETCDIR}/rc.d ${ETCDIR}/init.d
	

kur-acpid: create-dirs
	install -m ${MODE} ./init.d/acpid       ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/acpid ${ETCDIR}/rc.d/rc0.d/K32acpid
	ln -sf  ../init.d/acpid ${ETCDIR}/rc.d/rc1.d/K32acpid
	ln -sf  ../init.d/acpid ${ETCDIR}/rc.d/rc2.d/S18acpid
	ln -sf  ../init.d/acpid ${ETCDIR}/rc.d/rc3.d/S18acpid
	ln -sf  ../init.d/acpid ${ETCDIR}/rc.d/rc4.d/S18acpid
	ln -sf  ../init.d/acpid ${ETCDIR}/rc.d/rc5.d/S18acpid
	ln -sf  ../init.d/acpid ${ETCDIR}/rc.d/rc6.d/K32acpid

kur-alsa: create-dirs
	install -m ${MODE} ./init.d/alsa       ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/alsa ${ETCDIR}/rc.d/rc0.d/K35alsa
	ln -sf  ../init.d/alsa ${ETCDIR}/rc.d/rc1.d/K35alsa
	ln -sf  ../init.d/alsa ${ETCDIR}/rc.d/rc6.d/K35alsa
	ln -sf  ../init.d/alsa ${ETCDIR}/rc.d/rcS.d/S60alsa

kur-httpd: create-dirs
	install -m ${MODE} ./init.d/httpd     ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/httpd ${ETCDIR}/rc.d/rc0.d/K28httpd
	ln -sf  ../init.d/httpd ${ETCDIR}/rc.d/rc1.d/K28httpd
	ln -sf  ../init.d/httpd ${ETCDIR}/rc.d/rc2.d/K28httpd
	ln -sf  ../init.d/httpd ${ETCDIR}/rc.d/rc3.d/S32httpd
	ln -sf  ../init.d/httpd ${ETCDIR}/rc.d/rc4.d/S32httpd
	ln -sf  ../init.d/httpd ${ETCDIR}/rc.d/rc5.d/S32httpd
	ln -sf  ../init.d/httpd ${ETCDIR}/rc.d/rc6.d/K28httpd

kur-hiawatha: create-dirs
	install -m ${MODE} ./init.d/hiawatha     ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/hiawatha ${ETCDIR}/rc.d/rc0.d/K28hiawatha
	ln -sf  ../init.d/hiawatha ${ETCDIR}/rc.d/rc1.d/K28hiawatha
	ln -sf  ../init.d/hiawatha ${ETCDIR}/rc.d/rc2.d/K28hiawatha
	ln -sf  ../init.d/hiawatha ${ETCDIR}/rc.d/rc3.d/S32hiawatha
	ln -sf  ../init.d/hiawatha ${ETCDIR}/rc.d/rc4.d/S32hiawatha
	ln -sf  ../init.d/hiawatha ${ETCDIR}/rc.d/rc5.d/S32hiawatha
	ln -sf  ../init.d/hiawatha ${ETCDIR}/rc.d/rc6.d/K28hiawatha

kur-lighttpd: create-dirs
	install -m ${MODE} ./init.d/lighttpd     ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/lighttpd ${ETCDIR}/rc.d/rc0.d/K28lighttpd
	ln -sf  ../init.d/lighttpd ${ETCDIR}/rc.d/rc1.d/K28lighttpd
	ln -sf  ../init.d/lighttpd ${ETCDIR}/rc.d/rc2.d/K28lighttpd
	ln -sf  ../init.d/lighttpd ${ETCDIR}/rc.d/rc3.d/S32lighttpd
	ln -sf  ../init.d/lighttpd ${ETCDIR}/rc.d/rc4.d/S32lighttpd
	ln -sf  ../init.d/lighttpd ${ETCDIR}/rc.d/rc5.d/S32lighttpd
	ln -sf  ../init.d/lighttpd ${ETCDIR}/rc.d/rc6.d/K28lighttpd
	
kur-nginx: create-dirs
	install -m ${MODE} ./init.d/nginx     ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/nginx ${ETCDIR}/rc.d/rc0.d/K28nginx
	ln -sf  ../init.d/nginx ${ETCDIR}/rc.d/rc1.d/K28nginx
	ln -sf  ../init.d/nginx ${ETCDIR}/rc.d/rc2.d/K28nginx
	ln -sf  ../init.d/nginx ${ETCDIR}/rc.d/rc3.d/S32nginx
	ln -sf  ../init.d/nginx ${ETCDIR}/rc.d/rc4.d/S32nginx
	ln -sf  ../init.d/nginx ${ETCDIR}/rc.d/rc5.d/S32nginx
	ln -sf  ../init.d/nginx ${ETCDIR}/rc.d/rc6.d/K28nginx

kur-openresty: create-dirs
	install -m ${MODE} ./init.d/openresty    ${ETCDIR}/rc.d/init.d/

kur-php-fpm: create-dirs
	install -m ${MODE} ./init.d/php-fpm     ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/php-fpm ${ETCDIR}/rc.d/rc0.d/K28php-fpm
	ln -sf  ../init.d/php-fpm ${ETCDIR}/rc.d/rc1.d/K28php-fpm
	ln -sf  ../init.d/php-fpm ${ETCDIR}/rc.d/rc2.d/K28php-fpm
	ln -sf  ../init.d/php-fpm ${ETCDIR}/rc.d/rc3.d/S32php-fpm
	ln -sf  ../init.d/php-fpm ${ETCDIR}/rc.d/rc4.d/S32php-fpm
	ln -sf  ../init.d/php-fpm ${ETCDIR}/rc.d/rc5.d/S32php-fpm
	ln -sf  ../init.d/php-fpm ${ETCDIR}/rc.d/rc6.d/K28php-fpm

kur-autofs: create-dirs
	install -m $(MODE) ./init.d/autofs    $(EXTDIR)/rc.d/init.d/
	install -m $(CONFMODE) ./sysconfig/autofs.conf $(EXTDIR)/sysconfig/
	ln -sf  ../init.d/autofs $(EXTDIR)/rc.d/rcS.d/S52autofs

kur-atd: create-dirs
	install -m ${MODE} ./init.d/atd       ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/atd ${ETCDIR}/rc.d/rc0.d/K29atd
	ln -sf  ../init.d/atd ${ETCDIR}/rc.d/rc1.d/K29atd
	ln -sf  ../init.d/atd ${ETCDIR}/rc.d/rc2.d/S68atd
	ln -sf  ../init.d/atd ${ETCDIR}/rc.d/rc3.d/S68atd
	ln -sf  ../init.d/atd ${ETCDIR}/rc.d/rc4.d/S68atd
	ln -sf  ../init.d/atd ${ETCDIR}/rc.d/rc5.d/S68atd
	ln -sf  ../init.d/atd ${ETCDIR}/rc.d/rc6.d/K29atd

kur-avahi: create-dirs
	install -m ${MODE} ./init.d/avahi     ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/avahi ${ETCDIR}/rc.d/rc0.d/K28avahi
	ln -sf  ../init.d/avahi ${ETCDIR}/rc.d/rc1.d/K28avahi
	ln -sf  ../init.d/avahi ${ETCDIR}/rc.d/rc2.d/S34avahi
	ln -sf  ../init.d/avahi ${ETCDIR}/rc.d/rc3.d/S34avahi
	ln -sf  ../init.d/avahi ${ETCDIR}/rc.d/rc4.d/S34avahi
	ln -sf  ../init.d/avahi ${ETCDIR}/rc.d/rc5.d/S34avahi
	ln -sf  ../init.d/avahi ${ETCDIR}/rc.d/rc6.d/K28avahi

kur-bind: create-dirs
	install -m ${MODE} ./init.d/bind       ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/bind ${ETCDIR}/rc.d/rc0.d/K49bind
	ln -sf  ../init.d/bind ${ETCDIR}/rc.d/rc1.d/K49bind
	ln -sf  ../init.d/bind ${ETCDIR}/rc.d/rc2.d/K49bind
	ln -sf  ../init.d/bind ${ETCDIR}/rc.d/rc3.d/S22bind
	ln -sf  ../init.d/bind ${ETCDIR}/rc.d/rc4.d/S22bind
	ln -sf  ../init.d/bind ${ETCDIR}/rc.d/rc5.d/S22bind
	ln -sf  ../init.d/bind ${ETCDIR}/rc.d/rc6.d/K49bind

kur-bluetooth: create-dirs
	install -m ${MODE} ./init.d/bluetooth ${ETCDIR}/rc.d/init.d/bluetooth
	install -m ${CONFMODE} ./sysconfig/bluetooth ${ETCDIR}/sysconfig/bluetooth 
	ln -sf  ../init.d/bluetooth ${ETCDIR}/rc.d/rc0.d/K27bluetooth
	ln -sf  ../init.d/bluetooth ${ETCDIR}/rc.d/rc1.d/K27bluetooth
	ln -sf  ../init.d/bluetooth ${ETCDIR}/rc.d/rc2.d/S35bluetooth
	ln -sf  ../init.d/bluetooth ${ETCDIR}/rc.d/rc3.d/S35bluetooth
	ln -sf  ../init.d/bluetooth ${ETCDIR}/rc.d/rc4.d/S35bluetooth
	ln -sf  ../init.d/bluetooth ${ETCDIR}/rc.d/rc5.d/S35bluetooth
	ln -sf  ../init.d/bluetooth ${ETCDIR}/rc.d/rc6.d/K27bluetooth

kur-cups: create-dirs
	install -m ${MODE} ./init.d/cups       ${ETCDIR}/rc.d/init.d/
	rm -f ${ETCDIR}/rc.d/rc0.d/K36cups
	rm -f ${ETCDIR}/rc.d/rc2.d/K36cups
	rm -f ${ETCDIR}/rc.d/rc3.d/K36cups
	rm -f ${ETCDIR}/rc.d/rc5.d/K36cups
	rm -f ${ETCDIR}/rc.d/rc2.d/S81cups
	rm -f ${ETCDIR}/rc.d/rc3.d/S81cups
	rm -f ${ETCDIR}/rc.d/rc5.d/S81cups
	ln -sf  ../init.d/cups ${ETCDIR}/rc.d/rc0.d/K00cups
	ln -sf  ../init.d/cups ${ETCDIR}/rc.d/rc1.d/K00cups
	ln -sf  ../init.d/cups ${ETCDIR}/rc.d/rc2.d/S25cups
	ln -sf  ../init.d/cups ${ETCDIR}/rc.d/rc3.d/S25cups
	ln -sf  ../init.d/cups ${ETCDIR}/rc.d/rc4.d/S25cups
	ln -sf  ../init.d/cups ${ETCDIR}/rc.d/rc5.d/S25cups
	ln -sf  ../init.d/cups ${ETCDIR}/rc.d/rc6.d/K00cups

kur-saslauthd: create-dirs
	install -m ${MODE} ./init.d/saslauthd ${ETCDIR}/rc.d/init.d/saslauthd
	install -m ${CONFMODE} ./sysconfig/saslauthd ${ETCDIR}/sysconfig/saslauthd
	ln -sf  ../init.d/saslauthd ${ETCDIR}/rc.d/rc0.d/K49saslauthd
	ln -sf  ../init.d/saslauthd ${ETCDIR}/rc.d/rc1.d/K49saslauthd
	ln -sf  ../init.d/saslauthd ${ETCDIR}/rc.d/rc2.d/S24saslauthd
	ln -sf  ../init.d/saslauthd ${ETCDIR}/rc.d/rc3.d/S24saslauthd
	ln -sf  ../init.d/saslauthd ${ETCDIR}/rc.d/rc4.d/S24saslauthd
	ln -sf  ../init.d/saslauthd ${ETCDIR}/rc.d/rc5.d/S24saslauthd
	ln -sf  ../init.d/saslauthd ${ETCDIR}/rc.d/rc6.d/K49saslauthd

kur-dbus: create-dirs
	install -m ${MODE} ./init.d/dbus ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/dbus ${ETCDIR}/rc.d/rc0.d/K30dbus
	ln -sf  ../init.d/dbus ${ETCDIR}/rc.d/rc1.d/K30dbus
	ln -sf  ../init.d/dbus ${ETCDIR}/rc.d/rc2.d/S29dbus
	ln -sf  ../init.d/dbus ${ETCDIR}/rc.d/rc3.d/S29dbus
	ln -sf  ../init.d/dbus ${ETCDIR}/rc.d/rc4.d/S29dbus
	ln -sf  ../init.d/dbus ${ETCDIR}/rc.d/rc5.d/S29dbus
	ln -sf  ../init.d/dbus ${ETCDIR}/rc.d/rc6.d/K30dbus

kur-dovecot: create-dirs
	install -m ${MODE} ./init.d/dovecot       ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/dovecot ${ETCDIR}/rc.d/rc0.d/K78dovecot
	ln -sf  ../init.d/dovecot ${ETCDIR}/rc.d/rc1.d/K78dovecot
	ln -sf  ../init.d/dovecot ${ETCDIR}/rc.d/rc2.d/K78dovecot
	ln -sf  ../init.d/dovecot ${ETCDIR}/rc.d/rc3.d/S27dovecot
	ln -sf  ../init.d/dovecot ${ETCDIR}/rc.d/rc4.d/S27dovecot
	ln -sf  ../init.d/dovecot ${ETCDIR}/rc.d/rc5.d/S27dovecot
	ln -sf  ../init.d/dovecot ${ETCDIR}/rc.d/rc6.d/K78dovecot

kur-wicd: create-dirs
	install -m ${MODE} ./init.d/wicd ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/wicd ${ETCDIR}/rc.d/rc0.d/K20wicd
	ln -sf  ../init.d/wicd ${ETCDIR}/rc.d/rc1.d/K20wicd
	ln -sf  ../init.d/wicd ${ETCDIR}/rc.d/rc2.d/S30wicd
	ln -sf  ../init.d/wicd ${ETCDIR}/rc.d/rc3.d/S30wicd
	ln -sf  ../init.d/wicd ${ETCDIR}/rc.d/rc4.d/S30wicd
	ln -sf  ../init.d/wicd ${ETCDIR}/rc.d/rc5.d/S30wicd
	ln -sf  ../init.d/wicd ${ETCDIR}/rc.d/rc6.d/K20wicd

kur-dhcpd: create-dirs
	install -m ${MODE} ./init.d/dhcpd       ${ETCDIR}/rc.d/init.d/dhcpd
	install -m ${CONFMODE} ./sysconfig/dhcpd ${ETCDIR}/sysconfig/dhcpd
	ln -sf  ../init.d/dhcpd ${ETCDIR}/rc.d/rc0.d/K30dhcpd
	ln -sf  ../init.d/dhcpd ${ETCDIR}/rc.d/rc1.d/K30dhcpd
	ln -sf  ../init.d/dhcpd ${ETCDIR}/rc.d/rc2.d/K30dhcpd
	ln -sf  ../init.d/dhcpd ${ETCDIR}/rc.d/rc3.d/S30dhcpd
	ln -sf  ../init.d/dhcpd ${ETCDIR}/rc.d/rc4.d/S30dhcpd
	ln -sf  ../init.d/dhcpd ${ETCDIR}/rc.d/rc5.d/S30dhcpd
	ln -sf  ../init.d/dhcpd ${ETCDIR}/rc.d/rc6.d/K30dhcpd

kur-exim: create-dirs
	install -m ${MODE} ./init.d/exim       ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/exim ${ETCDIR}/rc.d/rc0.d/K25exim
	ln -sf  ../init.d/exim ${ETCDIR}/rc.d/rc1.d/K25exim
	ln -sf  ../init.d/exim ${ETCDIR}/rc.d/rc2.d/K25exim
	ln -sf  ../init.d/exim ${ETCDIR}/rc.d/rc3.d/S35exim
	ln -sf  ../init.d/exim ${ETCDIR}/rc.d/rc4.d/S35exim
	ln -sf  ../init.d/exim ${ETCDIR}/rc.d/rc5.d/S35exim
	ln -sf  ../init.d/exim ${ETCDIR}/rc.d/rc6.d/K25exim

kur-fcron: create-dirs
	install -m ${MODE} ./init.d/fcron      ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/fcron ${ETCDIR}/rc.d/rc0.d/K08fcron
	ln -sf  ../init.d/fcron ${ETCDIR}/rc.d/rc1.d/K08fcron
	ln -sf  ../init.d/fcron ${ETCDIR}/rc.d/rc2.d/S40fcron
	ln -sf  ../init.d/fcron ${ETCDIR}/rc.d/rc3.d/S40fcron
	ln -sf  ../init.d/fcron ${ETCDIR}/rc.d/rc4.d/S40fcron
	ln -sf  ../init.d/fcron ${ETCDIR}/rc.d/rc5.d/S40fcron
	ln -sf  ../init.d/fcron ${ETCDIR}/rc.d/rc6.d/K08fcron

kur-gdm: create-dirs
	install -m ${MODE} ./init.d/gdm        ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/gdm ${ETCDIR}/rc.d/rc0.d/K05gdm
	ln -sf  ../init.d/gdm ${ETCDIR}/rc.d/rc1.d/K05gdm
	ln -sf  ../init.d/gdm ${ETCDIR}/rc.d/rc2.d/K05gdm
	ln -sf  ../init.d/gdm ${ETCDIR}/rc.d/rc3.d/K05gdm
	ln -sf  ../init.d/gdm ${ETCDIR}/rc.d/rc4.d/K05gdm
	ln -sf  ../init.d/gdm ${ETCDIR}/rc.d/rc5.d/S95gdm
	ln -sf  ../init.d/gdm ${ETCDIR}/rc.d/rc6.d/K05gdm

kur-gpm: create-dirs
	install -m ${MODE} ./init.d/gpm        ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/gpm ${ETCDIR}/rc.d/rc0.d/K10gpm
	ln -sf  ../init.d/gpm ${ETCDIR}/rc.d/rc1.d/K10gpm
	ln -sf  ../init.d/gpm ${ETCDIR}/rc.d/rc2.d/S70gpm
	ln -sf  ../init.d/gpm ${ETCDIR}/rc.d/rc3.d/S70gpm
	ln -sf  ../init.d/gpm ${ETCDIR}/rc.d/rc4.d/S70gpm
	ln -sf  ../init.d/gpm ${ETCDIR}/rc.d/rc5.d/S70gpm
	ln -sf  ../init.d/gpm ${ETCDIR}/rc.d/rc6.d/K10gpm

kur-haveged: create-dirs
	install -m ${MODE} ./init.d/haveged        ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/haveged ${ETCDIR}/rc.d/rc0.d/K90haveged
	ln -sf  ../init.d/haveged ${ETCDIR}/rc.d/rc1.d/K90haveged
	ln -sf  ../init.d/haveged ${ETCDIR}/rc.d/rc2.d/K90haveged
	ln -sf  ../init.d/haveged ${ETCDIR}/rc.d/rc3.d/S21haveged
	ln -sf  ../init.d/haveged ${ETCDIR}/rc.d/rc4.d/S21haveged
	ln -sf  ../init.d/haveged ${ETCDIR}/rc.d/rc5.d/S21haveged
	ln -sf  ../init.d/haveged ${ETCDIR}/rc.d/rc6.d/K90haveged

kur-crond: create-dirs
	install -m ${MODE} ./init.d/crond        ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/crond ${ETCDIR}/rc.d/rc0.d/K90crond
	ln -sf  ../init.d/crond ${ETCDIR}/rc.d/rc1.d/K90crond
	ln -sf  ../init.d/crond ${ETCDIR}/rc.d/rc2.d/S21crond
	ln -sf  ../init.d/crond ${ETCDIR}/rc.d/rc3.d/S21crond
	ln -sf  ../init.d/crond ${ETCDIR}/rc.d/rc4.d/S21crond
	ln -sf  ../init.d/crond ${ETCDIR}/rc.d/rc5.d/S21crond
	ln -sf  ../init.d/crond ${ETCDIR}/rc.d/rc6.d/K90crond

kur-heimdal: create-dirs
	install -m ${MODE} ./init.d/heimdal        ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/heimdal ${ETCDIR}/rc.d/rc0.d/K42heimdal
	ln -sf  ../init.d/heimdal ${ETCDIR}/rc.d/rc1.d/K42heimdal
	ln -sf  ../init.d/heimdal ${ETCDIR}/rc.d/rc2.d/K42heimdal
	ln -sf  ../init.d/heimdal ${ETCDIR}/rc.d/rc3.d/S28heimdal
	ln -sf  ../init.d/heimdal ${ETCDIR}/rc.d/rc4.d/S28heimdal
	ln -sf  ../init.d/heimdal ${ETCDIR}/rc.d/rc5.d/S28heimdal
	ln -sf  ../init.d/heimdal ${ETCDIR}/rc.d/rc6.d/K42heimdal

kur-pcscd: create-dirs
	install -m ${MODE} ./init.d/pcscd        ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/pcscd ${ETCDIR}/rc.d/rc0.d/K31pcscd
	ln -sf  ../init.d/pcscd ${ETCDIR}/rc.d/rc1.d/K31pcscd
	ln -sf  ../init.d/pcscd ${ETCDIR}/rc.d/rc2.d/K31pcscd
	ln -sf  ../init.d/pcscd ${ETCDIR}/rc.d/rc3.d/S31pcscd
	ln -sf  ../init.d/pcscd ${ETCDIR}/rc.d/rc4.d/S31pcscd
	ln -sf  ../init.d/pcscd ${ETCDIR}/rc.d/rc5.d/S31pcscd
	ln -sf  ../init.d/pcscd ${ETCDIR}/rc.d/rc6.d/K31pcscd

kur-iptables: create-dirs
	install -m ${MODE} ./init.d/iptables  ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/iptables ${ETCDIR}/rc.d/rc3.d/S19iptables
	ln -sf  ../init.d/iptables ${ETCDIR}/rc.d/rc4.d/S19iptables
	ln -sf  ../init.d/iptables ${ETCDIR}/rc.d/rc5.d/S19iptables

kur-sysklogd: create-dirs
	install -m ${MODE} ./init.d/sysklogd  ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/sysklogd ${ETCDIR}/rc.d/rc0.d/K90sysklogd
	ln -sf  ../init.d/sysklogd ${ETCDIR}/rc.d/rc1.d/K90sysklogd
	ln -sf  ../init.d/sysklogd ${ETCDIR}/rc.d/rc2.d/K90sysklogd
	ln -sf  ../init.d/sysklogd ${ETCDIR}/rc.d/rc3.d/S10sysklogd
	ln -sf  ../init.d/sysklogd ${ETCDIR}/rc.d/rc4.d/S10sysklogd
	ln -sf  ../init.d/sysklogd ${ETCDIR}/rc.d/rc5.d/S10sysklogd
	ln -sf  ../init.d/sysklogd ${ETCDIR}/rc.d/rc6.d/K90sysklogd

kur-krb5: create-dirs
	install -m ${MODE} ./init.d/krb5 ${ETCDIR}/rc.d/init.d/
	ln -sf ../init.d/krb5 ${ETCDIR}/rc.d/rc0.d/K42krb5
	ln -sf ../init.d/krb5 ${ETCDIR}/rc.d/rc1.d/K42krb5
	ln -sf ../init.d/krb5 ${ETCDIR}/rc.d/rc2.d/K42krb5
	ln -sf ../init.d/krb5 ${ETCDIR}/rc.d/rc3.d/S28krb5
	ln -sf ../init.d/krb5 ${ETCDIR}/rc.d/rc4.d/S28krb5
	ln -sf ../init.d/krb5 ${ETCDIR}/rc.d/rc5.d/S28krb5
	ln -sf ../init.d/krb5 ${ETCDIR}/rc.d/rc6.d/K42krb5

kur-lprng: create-dirs
	install -m ${MODE} ./init.d/lprng      ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/lprng ${ETCDIR}/rc.d/rc0.d/K00lprng
	ln -sf  ../init.d/lprng ${ETCDIR}/rc.d/rc1.d/K00lprng
	ln -sf  ../init.d/lprng ${ETCDIR}/rc.d/rc2.d/S99lprng
	ln -sf  ../init.d/lprng ${ETCDIR}/rc.d/rc3.d/S99lprng
	ln -sf  ../init.d/lprng ${ETCDIR}/rc.d/rc4.d/S99lprng
	ln -sf  ../init.d/lprng ${ETCDIR}/rc.d/rc5.d/S99lprng
	ln -sf  ../init.d/lprng ${ETCDIR}/rc.d/rc6.d/K00lprng

kur-lxdm: create-dirs
	install -m ${MODE} ./init.d/lxdm        ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/lxdm ${ETCDIR}/rc.d/rc0.d/K05lxdm
	ln -sf  ../init.d/lxdm ${ETCDIR}/rc.d/rc1.d/K05lxdm
	ln -sf  ../init.d/lxdm ${ETCDIR}/rc.d/rc2.d/K05lxdm
	ln -sf  ../init.d/lxdm ${ETCDIR}/rc.d/rc3.d/K05lxdm
	ln -sf  ../init.d/lxdm ${ETCDIR}/rc.d/rc4.d/K05lxdm
	ln -sf  ../init.d/lxdm ${ETCDIR}/rc.d/rc5.d/S95lxdm
	ln -sf  ../init.d/lxdm ${ETCDIR}/rc.d/rc6.d/K05lxdm
	
kur-lightdm: create-dirs
	install -m ${MODE} ./init.d/lightdm        ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/lightdm ${ETCDIR}/rc.d/rc0.d/K05lightdm
	ln -sf  ../init.d/lightdm ${ETCDIR}/rc.d/rc1.d/K05lightdm
	ln -sf  ../init.d/lightdm ${ETCDIR}/rc.d/rc2.d/K05lightdm
	ln -sf  ../init.d/lightdm ${ETCDIR}/rc.d/rc3.d/K05lightdm
	ln -sf  ../init.d/lightdm ${ETCDIR}/rc.d/rc4.d/K05lightdm
	ln -sf  ../init.d/lightdm ${ETCDIR}/rc.d/rc5.d/S95lightdm
	ln -sf  ../init.d/lightdm ${ETCDIR}/rc.d/rc6.d/K05lightdm

kur-mdm: create-dirs
	install -m ${MODE} ./init.d/mdm        ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/mdm ${ETCDIR}/rc.d/rc0.d/K05mdm
	ln -sf  ../init.d/mdm ${ETCDIR}/rc.d/rc1.d/K05mdm
	ln -sf  ../init.d/mdm ${ETCDIR}/rc.d/rc2.d/K05mdm
	ln -sf  ../init.d/mdm ${ETCDIR}/rc.d/rc3.d/K05mdm
	ln -sf  ../init.d/mdm ${ETCDIR}/rc.d/rc4.d/K05mdm
	ln -sf  ../init.d/mdm ${ETCDIR}/rc.d/rc5.d/S95mdm
	ln -sf  ../init.d/mdm ${ETCDIR}/rc.d/rc6.d/K05mdm

kur-mysql: create-dirs
	install -m ${MODE} ./init.d/mysql      ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/mysql ${ETCDIR}/rc.d/rc0.d/K26mysql
	ln -sf  ../init.d/mysql ${ETCDIR}/rc.d/rc1.d/K26mysql
	ln -sf  ../init.d/mysql ${ETCDIR}/rc.d/rc2.d/K26mysql
	ln -sf  ../init.d/mysql ${ETCDIR}/rc.d/rc3.d/S34mysql
	ln -sf  ../init.d/mysql ${ETCDIR}/rc.d/rc4.d/S34mysql
	ln -sf  ../init.d/mysql ${ETCDIR}/rc.d/rc5.d/S34mysql
	ln -sf  ../init.d/mysql ${ETCDIR}/rc.d/rc6.d/K26mysql

kur-netfs: create-dirs
	install -m ${MODE} ./init.d/netfs      ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/netfs ${ETCDIR}/rc.d/rc0.d/K47netfs
	ln -sf  ../init.d/netfs ${ETCDIR}/rc.d/rc1.d/K47netfs
	ln -sf  ../init.d/netfs ${ETCDIR}/rc.d/rc2.d/K47netfs
	ln -sf  ../init.d/netfs ${ETCDIR}/rc.d/rc3.d/S28netfs
	ln -sf  ../init.d/netfs ${ETCDIR}/rc.d/rc4.d/S28netfs
	ln -sf  ../init.d/netfs ${ETCDIR}/rc.d/rc5.d/S28netfs
	ln -sf  ../init.d/netfs ${ETCDIR}/rc.d/rc6.d/K47netfs

kur-networkmanager: create-dirs
	install -m ${MODE} ./init.d/networkmanager ${ETCDIR}/rc.d/init.d/networkmanager
	ln -sf  ../init.d/networkmanager ${ETCDIR}/rc.d/rc0.d/K28networkmanager
	ln -sf  ../init.d/networkmanager ${ETCDIR}/rc.d/rc1.d/K28networkmanager
	ln -sf  ../init.d/networkmanager ${ETCDIR}/rc.d/rc2.d/S33networkmanager
	ln -sf  ../init.d/networkmanager ${ETCDIR}/rc.d/rc3.d/S33networkmanager
	ln -sf  ../init.d/networkmanager ${ETCDIR}/rc.d/rc4.d/S33networkmanager
	ln -sf  ../init.d/networkmanager ${ETCDIR}/rc.d/rc5.d/S33networkmanager
	ln -sf  ../init.d/networkmanager ${ETCDIR}/rc.d/rc6.d/K28networkmanager
	
kur-connmand: create-dirs
	install -m ${MODE} ./init.d/connmand ${ETCDIR}/rc.d/init.d/connmand
	ln -sf  ../init.d/connmand ${ETCDIR}/rc.d/rc0.d/K28connmand
	ln -sf  ../init.d/connmand ${ETCDIR}/rc.d/rc1.d/K28connmand
	ln -sf  ../init.d/connmand ${ETCDIR}/rc.d/rc2.d/S33connmand
	ln -sf  ../init.d/connmand ${ETCDIR}/rc.d/rc3.d/S33connmand
	ln -sf  ../init.d/connmand ${ETCDIR}/rc.d/rc4.d/S33connmand
	ln -sf  ../init.d/connmand ${ETCDIR}/rc.d/rc5.d/S33connmand
	ln -sf  ../init.d/connmand ${ETCDIR}/rc.d/rc6.d/K28connmand

kur-nfs-client: create-dirs
	install -m ${MODE} ./init.d/nfs-client ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/nfs-client ${ETCDIR}/rc.d/rc0.d/K48nfs-client
	ln -sf  ../init.d/nfs-client ${ETCDIR}/rc.d/rc1.d/K48nfs-client
	ln -sf  ../init.d/nfs-client ${ETCDIR}/rc.d/rc2.d/K48nfs-client
	ln -sf  ../init.d/nfs-client ${ETCDIR}/rc.d/rc3.d/S24nfs-client
	ln -sf  ../init.d/nfs-client ${ETCDIR}/rc.d/rc4.d/S24nfs-client
	ln -sf  ../init.d/nfs-client ${ETCDIR}/rc.d/rc5.d/S24nfs-client
	ln -sf  ../init.d/nfs-client ${ETCDIR}/rc.d/rc6.d/K48nfs-client

kur-nfs-server: create-dirs
	install -m ${MODE} ./init.d/nfs-server ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/nfs-server ${ETCDIR}/rc.d/rc0.d/K48nfs-server
	ln -sf  ../init.d/nfs-server ${ETCDIR}/rc.d/rc1.d/K48nfs-server
	ln -sf  ../init.d/nfs-server ${ETCDIR}/rc.d/rc2.d/K48nfs-server
	ln -sf  ../init.d/nfs-server ${ETCDIR}/rc.d/rc3.d/S24nfs-server
	ln -sf  ../init.d/nfs-server ${ETCDIR}/rc.d/rc4.d/S24nfs-server
	ln -sf  ../init.d/nfs-server ${ETCDIR}/rc.d/rc5.d/S24nfs-server
	ln -sf  ../init.d/nfs-server ${ETCDIR}/rc.d/rc6.d/K48nfs-server

kur-ntpd: create-dirs
	install -m ${MODE} ./init.d/ntpd       ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/ntpd ${ETCDIR}/rc.d/rc0.d/K46ntpd
	ln -sf  ../init.d/ntpd ${ETCDIR}/rc.d/rc1.d/K46ntpd
	ln -sf  ../init.d/ntpd ${ETCDIR}/rc.d/rc2.d/K46ntpd
	ln -sf  ../init.d/ntpd ${ETCDIR}/rc.d/rc3.d/S46ntpd
	ln -sf  ../init.d/ntpd ${ETCDIR}/rc.d/rc4.d/S46ntpd
	ln -sf  ../init.d/ntpd ${ETCDIR}/rc.d/rc5.d/S46ntpd
	ln -sf  ../init.d/ntpd ${ETCDIR}/rc.d/rc6.d/K46ntpd

kur-slapd: create-dirs
	install -m ${MODE} ./init.d/slapd ${ETCDIR}/rc.d/init.d/slapd
	install -m ${CONFMODE} ./sysconfig/slapd ${ETCDIR}/sysconfig/slapd
	ln -sf  ../init.d/slapd ${ETCDIR}/rc.d/rc0.d/K46slapd
	ln -sf  ../init.d/slapd ${ETCDIR}/rc.d/rc1.d/K46slapd
	ln -sf  ../init.d/slapd ${ETCDIR}/rc.d/rc2.d/S25slapd
	ln -sf  ../init.d/slapd ${ETCDIR}/rc.d/rc3.d/S25slapd
	ln -sf  ../init.d/slapd ${ETCDIR}/rc.d/rc4.d/S25slapd
	ln -sf  ../init.d/slapd ${ETCDIR}/rc.d/rc5.d/S25slapd
	ln -sf  ../init.d/slapd ${ETCDIR}/rc.d/rc6.d/K46slapd

kur-postfix: create-dirs
	install -m ${MODE} ./init.d/postfix    ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/postfix ${ETCDIR}/rc.d/rc0.d/K25postfix
	ln -sf  ../init.d/postfix ${ETCDIR}/rc.d/rc1.d/K25postfix
	ln -sf  ../init.d/postfix ${ETCDIR}/rc.d/rc2.d/K25postfix
	ln -sf  ../init.d/postfix ${ETCDIR}/rc.d/rc3.d/S35postfix
	ln -sf  ../init.d/postfix ${ETCDIR}/rc.d/rc4.d/S35postfix
	ln -sf  ../init.d/postfix ${ETCDIR}/rc.d/rc5.d/S35postfix
	ln -sf  ../init.d/postfix ${ETCDIR}/rc.d/rc6.d/K25postfix

kur-dnsmasq: create-dirs
	install -m ${MODE} ./init.d/dnsmasq    ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/dnsmasq ${ETCDIR}/rc.d/rc0.d/K33dnsmasq
	ln -sf  ../init.d/dnsmasq ${ETCDIR}/rc.d/rc1.d/K33dnsmasq
	ln -sf  ../init.d/dnsmasq ${ETCDIR}/rc.d/rc2.d/K33dnsmasq
	ln -sf  ../init.d/dnsmasq ${ETCDIR}/rc.d/rc3.d/S36dnsmasq
	ln -sf  ../init.d/dnsmasq ${ETCDIR}/rc.d/rc4.d/S36dnsmasq
	ln -sf  ../init.d/dnsmasq ${ETCDIR}/rc.d/rc5.d/S36dnsmasq
	ln -sf  ../init.d/dnsmasq ${ETCDIR}/rc.d/rc6.d/K33dnsmasq

kur-postgresql: create-dirs
	install -m ${MODE} ./init.d/postgresql ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/postgresql ${ETCDIR}/rc.d/rc0.d/K26postgresql
	ln -sf  ../init.d/postgresql ${ETCDIR}/rc.d/rc1.d/K26postgresql
	ln -sf  ../init.d/postgresql ${ETCDIR}/rc.d/rc2.d/K26postgresql
	ln -sf  ../init.d/postgresql ${ETCDIR}/rc.d/rc3.d/S34postgresql
	ln -sf  ../init.d/postgresql ${ETCDIR}/rc.d/rc4.d/S34postgresql
	ln -sf  ../init.d/postgresql ${ETCDIR}/rc.d/rc5.d/S34postgresql
	ln -sf  ../init.d/postgresql ${ETCDIR}/rc.d/rc6.d/K26postgresql

kur-proftpd: create-dirs
	install -m ${MODE} ./init.d/proftpd    ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/proftpd ${ETCDIR}/rc.d/rc0.d/K28proftpd
	ln -sf  ../init.d/proftpd ${ETCDIR}/rc.d/rc1.d/K28proftpd
	ln -sf  ../init.d/proftpd ${ETCDIR}/rc.d/rc2.d/K28proftpd
	ln -sf  ../init.d/proftpd ${ETCDIR}/rc.d/rc3.d/S32proftpd
	ln -sf  ../init.d/proftpd ${ETCDIR}/rc.d/rc4.d/S32proftpd
	ln -sf  ../init.d/proftpd ${ETCDIR}/rc.d/rc5.d/S32proftpd
	ln -sf  ../init.d/proftpd ${ETCDIR}/rc.d/rc6.d/K28proftpd

kur-qpopper: create-dirs
	install -m ${MODE} ./init.d/qpopper   ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/qpopper ${ETCDIR}/rc.d/rc0.d/K23qpopper
	ln -sf  ../init.d/qpopper ${ETCDIR}/rc.d/rc1.d/K23qpopper
	ln -sf  ../init.d/qpopper ${ETCDIR}/rc.d/rc2.d/K23qpopper
	ln -sf  ../init.d/qpopper ${ETCDIR}/rc.d/rc3.d/S37qpopper
	ln -sf  ../init.d/qpopper ${ETCDIR}/rc.d/rc4.d/S37qpopper
	ln -sf  ../init.d/qpopper ${ETCDIR}/rc.d/rc5.d/S37qpopper
	ln -sf  ../init.d/qpopper ${ETCDIR}/rc.d/rc6.d/K23qpopper

kur-random: create-dirs
	install -m ${MODE} ./init.d/random     ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/random ${ETCDIR}/rc.d/rc0.d/K45random
	ln -sf  ../init.d/random ${ETCDIR}/rc.d/rc1.d/S25random
	ln -sf  ../init.d/random ${ETCDIR}/rc.d/rc2.d/S25random
	ln -sf  ../init.d/random ${ETCDIR}/rc.d/rc3.d/S25random
	ln -sf  ../init.d/random ${ETCDIR}/rc.d/rc4.d/S25random
	ln -sf  ../init.d/random ${ETCDIR}/rc.d/rc5.d/S25random
	ln -sf  ../init.d/random ${ETCDIR}/rc.d/rc6.d/K45random

kur-rpcbind: create-dirs
	install -m ${MODE} ./init.d/rpcbind    ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/rpcbind ${ETCDIR}/rc.d/rc0.d/K49rpcbind
	ln -sf  ../init.d/rpcbind ${ETCDIR}/rc.d/rc1.d/K49rpcbind
	ln -sf  ../init.d/rpcbind ${ETCDIR}/rc.d/rc2.d/K49rpcbind
	ln -sf  ../init.d/rpcbind ${ETCDIR}/rc.d/rc3.d/S22rpcbind
	ln -sf  ../init.d/rpcbind ${ETCDIR}/rc.d/rc4.d/S22rpcbind
	ln -sf  ../init.d/rpcbind ${ETCDIR}/rc.d/rc5.d/S22rpcbind
	ln -sf  ../init.d/rpcbind ${ETCDIR}/rc.d/rc6.d/K49rpcbind

kur-rsyncd: create-dirs
	install -m ${MODE} ./init.d/rsyncd     ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/rsyncd ${ETCDIR}/rc.d/rc0.d/K30rsyncd
	ln -sf  ../init.d/rsyncd ${ETCDIR}/rc.d/rc1.d/K30rsyncd
	ln -sf  ../init.d/rsyncd ${ETCDIR}/rc.d/rc2.d/K30rsyncd
	ln -sf  ../init.d/rsyncd ${ETCDIR}/rc.d/rc3.d/S30rsyncd
	ln -sf  ../init.d/rsyncd ${ETCDIR}/rc.d/rc4.d/S30rsyncd
	ln -sf  ../init.d/rsyncd ${ETCDIR}/rc.d/rc5.d/S30rsyncd
	ln -sf  ../init.d/rsyncd ${ETCDIR}/rc.d/rc6.d/K30rsyncd

kur-samba: create-dirs
	install -m ${MODE} ./init.d/samba      ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/samba ${ETCDIR}/rc.d/rc0.d/K48samba
	ln -sf  ../init.d/samba ${ETCDIR}/rc.d/rc1.d/K48samba
	ln -sf  ../init.d/samba ${ETCDIR}/rc.d/rc2.d/K48samba
	ln -sf  ../init.d/samba ${ETCDIR}/rc.d/rc3.d/S45samba
	ln -sf  ../init.d/samba ${ETCDIR}/rc.d/rc4.d/S45samba
	ln -sf  ../init.d/samba ${ETCDIR}/rc.d/rc5.d/S45samba
	ln -sf  ../init.d/samba ${ETCDIR}/rc.d/rc6.d/K48samba

kur-pulseaudio: create-dirs
	install -m ${MODE} ./init.d/pulseaudio      ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/pulseaudio ${ETCDIR}/rc.d/rc0.d/K55pulseaudio
	ln -sf  ../init.d/pulseaudio ${ETCDIR}/rc.d/rc1.d/K55pulseaudio
	ln -sf  ../init.d/pulseaudio ${ETCDIR}/rc.d/rc2.d/K55pulseaudio
	ln -sf  ../init.d/pulseaudio ${ETCDIR}/rc.d/rc3.d/S55pulseaudio
	ln -sf  ../init.d/pulseaudio ${ETCDIR}/rc.d/rc4.d/S55pulseaudio
	ln -sf  ../init.d/pulseaudio ${ETCDIR}/rc.d/rc5.d/S55pulseaudio
	ln -sf  ../init.d/pulseaudio ${ETCDIR}/rc.d/rc6.d/K55pulseaudio

kur-sddm: create-dirs
	install -m ${MODE} ./init.d/sddm        ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/sddm ${ETCDIR}/rc.d/rc0.d/K05sddm
	ln -sf  ../init.d/sddm ${ETCDIR}/rc.d/rc1.d/K05sddm
	ln -sf  ../init.d/sddm ${ETCDIR}/rc.d/rc2.d/K05sddm
	ln -sf  ../init.d/sddm ${ETCDIR}/rc.d/rc3.d/K05sddm
	ln -sf  ../init.d/sddm ${ETCDIR}/rc.d/rc4.d/K05sddm
	ln -sf  ../init.d/sddm ${ETCDIR}/rc.d/rc5.d/S95sddm
	ln -sf  ../init.d/sddm ${ETCDIR}/rc.d/rc6.d/K05sddm

kur-plymouth: create-dirs
	install -m ${MODE} ./init.d/plymouth ${ETCDIR}/rc.d/init.d/
	ln -sf ../init.d/plymouth ${ETCDIR}/rc.d/rc0.d/K20plymouth
	ln -sf ../init.d/plymouth ${ETCDIR}/rc.d/rc1.d/K20plymouth
	ln -sf ../init.d/plymouth ${ETCDIR}/rc.d/rc2.d/S20plymouth
	ln -sf ../init.d/plymouth ${ETCDIR}/rc.d/rc3.d/S20plymouth
	ln -sf ../init.d/plymouth ${ETCDIR}/rc.d/rc4.d/S20plymouth
	ln -sf ../init.d/plymouth ${ETCDIR}/rc.d/rc5.d/S20plymouth
	ln -sf ../init.d/plymouth ${ETCDIR}/rc.d/rc6.d/K20plymouth

kur-sendmail: create-dirs
	install -m ${MODE} ./init.d/sendmail   ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/sendmail ${ETCDIR}/rc.d/rc0.d/K25sendmail
	ln -sf  ../init.d/sendmail ${ETCDIR}/rc.d/rc1.d/K25sendmail
	ln -sf  ../init.d/sendmail ${ETCDIR}/rc.d/rc2.d/K25sendmail
	ln -sf  ../init.d/sendmail ${ETCDIR}/rc.d/rc3.d/S35sendmail
	ln -sf  ../init.d/sendmail ${ETCDIR}/rc.d/rc4.d/S35sendmail
	ln -sf  ../init.d/sendmail ${ETCDIR}/rc.d/rc5.d/S35sendmail
	ln -sf  ../init.d/sendmail ${ETCDIR}/rc.d/rc6.d/K25sendmail

kur-smartd: create-dirs
	install -m ${MODE} ./init.d/smartd    ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/smartd ${ETCDIR}/rc.d/rc0.d/K70smartd
	ln -sf  ../init.d/smartd ${ETCDIR}/rc.d/rc1.d/K70smartd
	ln -sf  ../init.d/smartd ${ETCDIR}/rc.d/rc2.d/K70smartd
	ln -sf  ../init.d/smartd ${ETCDIR}/rc.d/rc3.d/S21smartd
	ln -sf  ../init.d/smartd ${ETCDIR}/rc.d/rc4.d/S21smartd
	ln -sf  ../init.d/smartd ${ETCDIR}/rc.d/rc5.d/S21smartd
	ln -sf  ../init.d/smartd ${ETCDIR}/rc.d/rc6.d/K70smartd

kur-slim: create-dirs
	install -m ${MODE} ./init.d/slim  ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/slim ${ETCDIR}/rc.d/rc0.d/K05slim
	ln -sf  ../init.d/slim ${ETCDIR}/rc.d/rc1.d/K05slim
	ln -sf  ../init.d/slim ${ETCDIR}/rc.d/rc2.d/K05slim
	ln -sf  ../init.d/slim ${ETCDIR}/rc.d/rc3.d/K05slim
	ln -sf  ../init.d/slim ${ETCDIR}/rc.d/rc4.d/K05slim
	ln -sf  ../init.d/slim ${ETCDIR}/rc.d/rc5.d/S95slim
	ln -sf  ../init.d/slim ${ETCDIR}/rc.d/rc6.d/K05slim

kur-soprano: create-dirs
	install -m ${MODE} ./init.d/soprano    ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/soprano ${ETCDIR}/rc.d/rc0.d/K35soprano
	ln -sf  ../init.d/soprano ${ETCDIR}/rc.d/rc1.d/K35soprano
	ln -sf  ../init.d/soprano ${ETCDIR}/rc.d/rc2.d/K35soprano
	ln -sf  ../init.d/soprano ${ETCDIR}/rc.d/rc3.d/S48soprano
	ln -sf  ../init.d/soprano ${ETCDIR}/rc.d/rc4.d/S48soprano
	ln -sf  ../init.d/soprano ${ETCDIR}/rc.d/rc5.d/S48soprano
	ln -sf  ../init.d/soprano ${ETCDIR}/rc.d/rc6.d/K35soprano

kur-swat: create-dirs
	install -m ${MODE} ./init.d/swat      ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/swat ${ETCDIR}/rc.d/rc0.d/K47swat
	ln -sf  ../init.d/swat ${ETCDIR}/rc.d/rc1.d/K47swat
	ln -sf  ../init.d/swat ${ETCDIR}/rc.d/rc2.d/K47swat
	ln -sf  ../init.d/swat ${ETCDIR}/rc.d/rc3.d/S46swat
	ln -sf  ../init.d/swat ${ETCDIR}/rc.d/rc4.d/S46swat
	ln -sf  ../init.d/swat ${ETCDIR}/rc.d/rc5.d/S46swat
	ln -sf  ../init.d/swat ${ETCDIR}/rc.d/rc6.d/K47swat

kur-sshd: create-dirs
	install -m ${MODE} ./init.d/sshd       ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/sshd ${ETCDIR}/rc.d/rc0.d/K30sshd
	ln -sf  ../init.d/sshd ${ETCDIR}/rc.d/rc1.d/K30sshd
	ln -sf  ../init.d/sshd ${ETCDIR}/rc.d/rc2.d/K30sshd
	ln -sf  ../init.d/sshd ${ETCDIR}/rc.d/rc3.d/S30sshd
	ln -sf  ../init.d/sshd ${ETCDIR}/rc.d/rc4.d/S30sshd
	ln -sf  ../init.d/sshd ${ETCDIR}/rc.d/rc5.d/S30sshd
	ln -sf  ../init.d/sshd ${ETCDIR}/rc.d/rc6.d/K30sshd

kur-stunnel: create-dirs
	install -m ${MODE} ./init.d/stunnel    ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/stunnel ${ETCDIR}/rc.d/rc0.d/K47stunnel
	ln -sf  ../init.d/stunnel ${ETCDIR}/rc.d/rc1.d/K47stunnel
	ln -sf  ../init.d/stunnel ${ETCDIR}/rc.d/rc2.d/K47stunnel
	ln -sf  ../init.d/stunnel ${ETCDIR}/rc.d/rc3.d/S55stunnel
	ln -sf  ../init.d/stunnel ${ETCDIR}/rc.d/rc4.d/S55stunnel
	ln -sf  ../init.d/stunnel ${ETCDIR}/rc.d/rc5.d/S55stunnel
	ln -sf  ../init.d/stunnel ${ETCDIR}/rc.d/rc6.d/K47stunnel

kur-svn: create-dirs
	install -m ${MODE} ./init.d/svn        ${ETCDIR}/rc.d/init.d/
	ln -sf ../init.d/svn ${ETCDIR}/rc.d/rc0.d/K27svn
	ln -sf ../init.d/svn ${ETCDIR}/rc.d/rc1.d/K27svn
	ln -sf ../init.d/svn ${ETCDIR}/rc.d/rc2.d/K27svn
	ln -sf ../init.d/svn ${ETCDIR}/rc.d/rc3.d/S33svn
	ln -sf ../init.d/svn ${ETCDIR}/rc.d/rc4.d/S33svn
	ln -sf ../init.d/svn ${ETCDIR}/rc.d/rc5.d/S33svn
	ln -sf ../init.d/svn ${ETCDIR}/rc.d/rc6.d/K27svn

kur-sysstat: create-dirs
	install -m ${MODE} ./init.d/sysstat    ${ETCDIR}/rc.d/init.d/
	ln -sf ../init.d/sysstat ${ETCDIR}/rc.d/rcS.d/S85sysstat

kur-unbound: create-dirs
	install -m ${MODE} ./init.d/unbound       ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/unbound ${ETCDIR}/rc.d/rc0.d/K79unbound
	ln -sf  ../init.d/unbound ${ETCDIR}/rc.d/rc1.d/K79unbound
	ln -sf  ../init.d/unbound ${ETCDIR}/rc.d/rc2.d/K79unbound
	ln -sf  ../init.d/unbound ${ETCDIR}/rc.d/rc3.d/S21unbound
	ln -sf  ../init.d/unbound ${ETCDIR}/rc.d/rc4.d/S21unbound
	ln -sf  ../init.d/unbound ${ETCDIR}/rc.d/rc5.d/S21unbound
	ln -sf  ../init.d/unbound ${ETCDIR}/rc.d/rc6.d/K79unbound

kur-virtuoso: create-dirs
	install -m ${MODE} ./init.d/virtuoso   ${ETCDIR}/rc.d/init.d/
	ln -sf ../init.d/virtuoso ${ETCDIR}/rc.d/rc0.d/K40virtuoso
	ln -sf ../init.d/virtuoso ${ETCDIR}/rc.d/rc1.d/K40virtuoso
	ln -sf ../init.d/virtuoso ${ETCDIR}/rc.d/rc2.d/K40virtuoso
	ln -sf ../init.d/virtuoso ${ETCDIR}/rc.d/rc3.d/S47virtuoso
	ln -sf ../init.d/virtuoso ${ETCDIR}/rc.d/rc4.d/S47virtuoso
	ln -sf ../init.d/virtuoso ${ETCDIR}/rc.d/rc5.d/S47virtuoso
	ln -sf ../init.d/virtuoso ${ETCDIR}/rc.d/rc6.d/K40virtuoso

kur-vsftpd: create-dirs
	install -m ${MODE} ./init.d/vsftpd     ${ETCDIR}/rc.d/init.d/
	ln -sf ../init.d/vsftpd ${ETCDIR}/rc.d/rc0.d/K28vsftpd
	ln -sf ../init.d/vsftpd ${ETCDIR}/rc.d/rc1.d/K28vsftpd
	ln -sf ../init.d/vsftpd ${ETCDIR}/rc.d/rc2.d/K28vsftpd
	ln -sf ../init.d/vsftpd ${ETCDIR}/rc.d/rc3.d/S32vsftpd
	ln -sf ../init.d/vsftpd ${ETCDIR}/rc.d/rc4.d/S32vsftpd
	ln -sf ../init.d/vsftpd ${ETCDIR}/rc.d/rc5.d/S32vsftpd
	ln -sf ../init.d/vsftpd ${ETCDIR}/rc.d/rc6.d/K28vsftpd

kur-winbindd: create-dirs
	install -m ${MODE} ./init.d/winbindd      ${ETCDIR}/rc.d/init.d/
	ln -sf  ../init.d/winbindd ${ETCDIR}/rc.d/rc0.d/K49winbindd
	ln -sf  ../init.d/winbindd ${ETCDIR}/rc.d/rc1.d/K49winbindd
	ln -sf  ../init.d/winbindd ${ETCDIR}/rc.d/rc2.d/K49winbindd
	ln -sf  ../init.d/winbindd ${ETCDIR}/rc.d/rc3.d/S50winbindd
	ln -sf  ../init.d/winbindd ${ETCDIR}/rc.d/rc4.d/S50winbindd
	ln -sf  ../init.d/winbindd ${ETCDIR}/rc.d/rc5.d/S50winbindd
	ln -sf  ../init.d/winbindd ${ETCDIR}/rc.d/rc6.d/K49winbindd

kur-xinetd: create-dirs
	install -m ${MODE} ./init.d/xinetd     ${ETCDIR}/rc.d/init.d/
	ln -sf ../init.d/xinetd ${ETCDIR}/rc.d/rc0.d/K49xinetd
	ln -sf ../init.d/xinetd ${ETCDIR}/rc.d/rc1.d/K49xinetd
	ln -sf ../init.d/xinetd ${ETCDIR}/rc.d/rc2.d/K49xinetd
	ln -sf ../init.d/xinetd ${ETCDIR}/rc.d/rc3.d/S23xinetd
	ln -sf ../init.d/xinetd ${ETCDIR}/rc.d/rc4.d/S23xinetd
	ln -sf ../init.d/xinetd ${ETCDIR}/rc.d/rc5.d/S23xinetd
	ln -sf ../init.d/xinetd ${ETCDIR}/rc.d/rc6.d/K49xinetd

sil-atd: 
	rm -f ${ETCDIR}/rc.d/init.d/atd
	rm -f ${ETCDIR}/rc.d/rc0.d/K29atd
	rm -f ${ETCDIR}/rc.d/rc1.d/K29atd
	rm -f ${ETCDIR}/rc.d/rc2.d/S68atd
	rm -f ${ETCDIR}/rc.d/rc3.d/S68atd
	rm -f ${ETCDIR}/rc.d/rc4.d/S68atd
	rm -f ${ETCDIR}/rc.d/rc5.d/S68atd
	rm -f ${ETCDIR}/rc.d/rc6.d/K29atd

sil-acpid:
	rm -f ${ETCDIR}/rc.d/init.d/acpid
	rm -f ${ETCDIR}/rc.d/rc0.d/K32acpid
	rm -f ${ETCDIR}/rc.d/rc1.d/K32acpid
	rm -f ${ETCDIR}/rc.d/rc2.d/S18acpid
	rm -f ${ETCDIR}/rc.d/rc3.d/S18acpid
	rm -f ${ETCDIR}/rc.d/rc4.d/S18acpid
	rm -f ${ETCDIR}/rc.d/rc5.d/S18acpid
	rm -f ${ETCDIR}/rc.d/rc6.d/K32acpid

sil-alsa:
	rm -f ${ETCDIR}/rc.d/init.d/alsa
	rm -f ${ETCDIR}/rc.d/rc0.d/K35alsa
	rm -f ${ETCDIR}/rc.d/rc1.d/K35alsa
	rm -f ${ETCDIR}/rc.d/rc6.d/K35alsa
	rm -f ${ETCDIR}/rc.d/rcS.d/S60alsa

sil-httpd:
	rm -f ${ETCDIR}/rc.d/init.d/httpd
	rm -f ${ETCDIR}/rc.d/rc0.d/K28httpd
	rm -f ${ETCDIR}/rc.d/rc1.d/K28httpd
	rm -f ${ETCDIR}/rc.d/rc2.d/K28httpd
	rm -f ${ETCDIR}/rc.d/rc3.d/S32httpd
	rm -f ${ETCDIR}/rc.d/rc4.d/S32httpd
	rm -f ${ETCDIR}/rc.d/rc5.d/S32httpd
	rm -f ${ETCDIR}/rc.d/rc6.d/K28httpd

sil-hiawatha:
	rm -f ${ETCDIR}/rc.d/init.d/hiawatha
	rm -f ${ETCDIR}/rc.d/rc0.d/K28hiawatha
	rm -f ${ETCDIR}/rc.d/rc1.d/K28hiawatha
	rm -f ${ETCDIR}/rc.d/rc2.d/K28hiawatha
	rm -f ${ETCDIR}/rc.d/rc3.d/S32hiawatha
	rm -f ${ETCDIR}/rc.d/rc4.d/S32hiawatha
	rm -f ${ETCDIR}/rc.d/rc5.d/S32hiawatha
	rm -f ${ETCDIR}/rc.d/rc6.d/K28hiawatha
	
sil-lighttpd:
	rm -f ${ETCDIR}/rc.d/init.d/lighttpd
	rm -f ${ETCDIR}/rc.d/rc0.d/K28lighttpd
	rm -f ${ETCDIR}/rc.d/rc1.d/K28lighttpd
	rm -f ${ETCDIR}/rc.d/rc2.d/K28lighttpd
	rm -f ${ETCDIR}/rc.d/rc3.d/S32lighttpd
	rm -f ${ETCDIR}/rc.d/rc4.d/S32lighttpd
	rm -f ${ETCDIR}/rc.d/rc5.d/S32lighttpd
	rm -f ${ETCDIR}/rc.d/rc6.d/K28lighttpd
	
sil-nginx:
	rm -f ${ETCDIR}/rc.d/init.d/nginx
	rm -f ${ETCDIR}/rc.d/rc0.d/K28nginx
	rm -f ${ETCDIR}/rc.d/rc1.d/K28nginx
	rm -f ${ETCDIR}/rc.d/rc2.d/K28nginx
	rm -f ${ETCDIR}/rc.d/rc3.d/S32nginx
	rm -f ${ETCDIR}/rc.d/rc4.d/S32nginx
	rm -f ${ETCDIR}/rc.d/rc5.d/S32nginx
	rm -f ${ETCDIR}/rc.d/rc6.d/K28nginx

sil-openresty:
	rm -f ${ETCDIR}/rc.d/init.d/openresty

sil-php-fpm:
	rm -f ${ETCDIR}/rc.d/init.d/php-fpm
	rm -f ${ETCDIR}/rc.d/rc0.d/K28php-fpm
	rm -f ${ETCDIR}/rc.d/rc1.d/K28php-fpm
	rm -f ${ETCDIR}/rc.d/rc2.d/K28php-fpm
	rm -f ${ETCDIR}/rc.d/rc3.d/S32php-fpm
	rm -f ${ETCDIR}/rc.d/rc4.d/S32php-fpm
	rm -f ${ETCDIR}/rc.d/rc5.d/S32php-fpm
	rm -f ${ETCDIR}/rc.d/rc6.d/K28php-fpm

sil-autofs:
	rm -f $(EXTDIR)/rc.d/init.d/autofs
	rm -f $(EXTDIR)/rc.d/rcS.d/S52autofs

sil-avahi:
	rm -f ${ETCDIR}/rc.d/init.d/avahi
	rm -f ${ETCDIR}/rc.d/rc0.d/K28avahi
	rm -f ${ETCDIR}/rc.d/rc1.d/K28avahi
	rm -f ${ETCDIR}/rc.d/rc2.d/S34avahi
	rm -f ${ETCDIR}/rc.d/rc3.d/S34avahi
	rm -f ${ETCDIR}/rc.d/rc4.d/S34avahi
	rm -f ${ETCDIR}/rc.d/rc5.d/S34avahi
	rm -f ${ETCDIR}/rc.d/rc6.d/K28avahi

sil-bind:
	rm -f ${ETCDIR}/rc.d/init.d/bind
	rm -f ${ETCDIR}/rc.d/rc0.d/K49bind
	rm -f ${ETCDIR}/rc.d/rc1.d/K49bind
	rm -f ${ETCDIR}/rc.d/rc2.d/K49bind
	rm -f ${ETCDIR}/rc.d/rc3.d/S22bind
	rm -f ${ETCDIR}/rc.d/rc4.d/S22bind
	rm -f ${ETCDIR}/rc.d/rc5.d/S22bind
	rm -f ${ETCDIR}/rc.d/rc6.d/K49bind

sil-bluetooth:
	rm -f ${ETCDIR}/rc.d/init.d/bluetooth
	rm -f ${ETCDIR}/rc.d/rc0.d/K27bluetooth
	rm -f ${ETCDIR}/rc.d/rc1.d/K27bluetooth
	rm -f ${ETCDIR}/rc.d/rc2.d/S35bluetooth
	rm -f ${ETCDIR}/rc.d/rc3.d/S35bluetooth
	rm -f ${ETCDIR}/rc.d/rc4.d/S35bluetooth
	rm -f ${ETCDIR}/rc.d/rc5.d/S35bluetooth
	rm -f ${ETCDIR}/rc.d/rc6.d/K27bluetooth

sil-cups:
	rm -f ${ETCDIR}/rc.d/init.d/cups
	rm -f ${ETCDIR}/rc.d/rc0.d/K00cups
	rm -f ${ETCDIR}/rc.d/rc1.d/K00cups
	rm -f ${ETCDIR}/rc.d/rc2.d/S25cups
	rm -f ${ETCDIR}/rc.d/rc3.d/S25cups
	rm -f ${ETCDIR}/rc.d/rc4.d/S25cups
	rm -f ${ETCDIR}/rc.d/rc5.d/S25cups
	rm -f ${ETCDIR}/rc.d/rc6.d/K00cups

sil-saslauthd:
	rm -f ${ETCDIR}/rc.d/init.d/saslauthd
	rm -f ${ETCDIR}/sysconfig/saslauthd
	rm -f ${ETCDIR}/rc.d/rc0.d/K49saslauthd
	rm -f ${ETCDIR}/rc.d/rc1.d/K49saslauthd
	rm -f ${ETCDIR}/rc.d/rc2.d/S24saslauthd
	rm -f ${ETCDIR}/rc.d/rc3.d/S24saslauthd
	rm -f ${ETCDIR}/rc.d/rc4.d/S24saslauthd
	rm -f ${ETCDIR}/rc.d/rc5.d/S24saslauthd
	rm -f ${ETCDIR}/rc.d/rc6.d/K49saslauthd

sil-dbus: 
	rm -f ${ETCDIR}/rc.d/init.d/dbus
	rm -f ${ETCDIR}/rc.d/rc0.d/K30dbus
	rm -f ${ETCDIR}/rc.d/rc1.d/K30dbus
	rm -f ${ETCDIR}/rc.d/rc2.d/S29dbus
	rm -f ${ETCDIR}/rc.d/rc3.d/S29dbus
	rm -f ${ETCDIR}/rc.d/rc4.d/S29dbus
	rm -f ${ETCDIR}/rc.d/rc5.d/S29dbus
	rm -f ${ETCDIR}/rc.d/rc6.d/K30dbus

sil-wicd:
	rm -f ${ETCDIR}/rc.d/init.d/wicd
	rm -f ${ETCDIR}/rc.d/rc0.d/K20wicd
	rm -f ${ETCDIR}/rc.d/rc1.d/K20wicd
	rm -f ${ETCDIR}/rc.d/rc2.d/S30wicd
	rm -f ${ETCDIR}/rc.d/rc3.d/S30wicd
	rm -f ${ETCDIR}/rc.d/rc4.d/S30wicd
	rm -f ${ETCDIR}/rc.d/rc5.d/S30wicd
	rm -f ${ETCDIR}/rc.d/rc6.d/K20wicd

sil-dhcpd:
	rm -f ${ETCDIR}/rc.d/init.d/dhcpd
	rm -f ${ETCDIR}/sysconfig/dhcpd
	rm -f ${ETCDIR}/rc.d/rc0.d/K30dhcpd
	rm -f ${ETCDIR}/rc.d/rc1.d/K30dhcpd
	rm -f ${ETCDIR}/rc.d/rc2.d/K30dhcpd
	rm -f ${ETCDIR}/rc.d/rc3.d/S30dhcpd
	rm -f ${ETCDIR}/rc.d/rc4.d/S30dhcpd
	rm -f ${ETCDIR}/rc.d/rc5.d/S30dhcpd
	rm -f ${ETCDIR}/rc.d/rc6.d/K30dhcpd

sil-dovecot:
	rm -f ${ETCDIR}/rc.d/init.d/dovecot
	rm -f ${ETCDIR}/rc.d/rc0.d/K78dovecot
	rm -f ${ETCDIR}/rc.d/rc1.d/K78dovecot
	rm -f ${ETCDIR}/rc.d/rc2.d/K78dovecot
	rm -f ${ETCDIR}/rc.d/rc3.d/S27dovecot
	rm -f ${ETCDIR}/rc.d/rc4.d/S27dovecot
	rm -f ${ETCDIR}/rc.d/rc5.d/S27dovecot
	rm -f ${ETCDIR}/rc.d/rc6.d/K78dovecot

sil-exim:
	rm -f ${ETCDIR}/rc.d/init.d/exim
	rm -f ${ETCDIR}/rc.d/rc0.d/K25exim
	rm -f ${ETCDIR}/rc.d/rc1.d/K25exim
	rm -f ${ETCDIR}/rc.d/rc2.d/K25exim
	rm -f ${ETCDIR}/rc.d/rc3.d/S35exim
	rm -f ${ETCDIR}/rc.d/rc4.d/S35exim
	rm -f ${ETCDIR}/rc.d/rc5.d/S35exim
	rm -f ${ETCDIR}/rc.d/rc6.d/K25exim

sil-fcron:
	rm -f ${ETCDIR}/rc.d/init.d/fcron
	rm -f ${ETCDIR}/rc.d/rc0.d/K08fcron
	rm -f ${ETCDIR}/rc.d/rc1.d/K08fcron
	rm -f ${ETCDIR}/rc.d/rc2.d/S40fcron
	rm -f ${ETCDIR}/rc.d/rc3.d/S40fcron
	rm -f ${ETCDIR}/rc.d/rc4.d/S40fcron
	rm -f ${ETCDIR}/rc.d/rc5.d/S40fcron
	rm -f ${ETCDIR}/rc.d/rc6.d/K08fcron

sil-gdm:
	rm -f ${ETCDIR}/rc.d/init.d/gdm
	rm -f ${ETCDIR}/rc.d/rc0.d/K05gdm
	rm -f ${ETCDIR}/rc.d/rc1.d/K05gdm
	rm -f ${ETCDIR}/rc.d/rc2.d/K05gdm
	rm -f ${ETCDIR}/rc.d/rc3.d/K05gdm
	rm -f ${ETCDIR}/rc.d/rc4.d/K05gdm
	rm -f ${ETCDIR}/rc.d/rc5.d/S95gdm
	rm -f ${ETCDIR}/rc.d/rc6.d/K05gdm

sil-gpm:
	rm -f ${ETCDIR}/rc.d/init.d/gpm
	rm -f ${ETCDIR}/rc.d/rc0.d/K10gpm
	rm -f ${ETCDIR}/rc.d/rc1.d/K10gpm
	rm -f ${ETCDIR}/rc.d/rc2.d/S70gpm
	rm -f ${ETCDIR}/rc.d/rc3.d/S70gpm
	rm -f ${ETCDIR}/rc.d/rc4.d/S70gpm
	rm -f ${ETCDIR}/rc.d/rc5.d/S70gpm
	rm -f ${ETCDIR}/rc.d/rc6.d/K10gpm

sil-haveged:
	rm -f ${ETCDIR}/rc.d/init.d/haveged
	rm -f ${ETCDIR}/rc.d/rc0.d/K90haveged
	rm -f ${ETCDIR}/rc.d/rc1.d/K90haveged
	rm -f ${ETCDIR}/rc.d/rc2.d/K90haveged
	rm -f ${ETCDIR}/rc.d/rc3.d/S21haveged
	rm -f ${ETCDIR}/rc.d/rc4.d/S21haveged
	rm -f ${ETCDIR}/rc.d/rc5.d/S21haveged
	rm -f ${ETCDIR}/rc.d/rc6.d/K90haveged

sil-crond:
	rm -f ${ETCDIR}/rc.d/init.d/crond
	rm -f ${ETCDIR}/rc.d/rc0.d/K90crond
	rm -f ${ETCDIR}/rc.d/rc1.d/K90crond
	rm -f ${ETCDIR}/rc.d/rc2.d/S21crond
	rm -f ${ETCDIR}/rc.d/rc3.d/S21crond
	rm -f ${ETCDIR}/rc.d/rc4.d/S21crond
	rm -f ${ETCDIR}/rc.d/rc5.d/S21crond
	rm -f ${ETCDIR}/rc.d/rc6.d/K90crond

sil-heimdal:
	rm -f ${ETCDIR}/rc.d/init.d/heimdal
	rm -f ${ETCDIR}/rc.d/rc0.d/K42heimdal
	rm -f ${ETCDIR}/rc.d/rc1.d/K42heimdal
	rm -f ${ETCDIR}/rc.d/rc2.d/K42heimdal
	rm -f ${ETCDIR}/rc.d/rc3.d/S28heimdal
	rm -f ${ETCDIR}/rc.d/rc4.d/S28heimdal
	rm -f ${ETCDIR}/rc.d/rc5.d/S28heimdal
	rm -f ${ETCDIR}/rc.d/rc6.d/K42heimdal

sil-pcscd:
	rm -f ${ETCDIR}/rc.d/init.d/pcscd
	rm -f ${ETCDIR}/rc.d/rc0.d/K31pcscd
	rm -f ${ETCDIR}/rc.d/rc1.d/K31pcscd
	rm -f ${ETCDIR}/rc.d/rc2.d/K31pcscd
	rm -f ${ETCDIR}/rc.d/rc3.d/S31pcscd
	rm -f ${ETCDIR}/rc.d/rc4.d/S31pcscd
	rm -f ${ETCDIR}/rc.d/rc5.d/S31pcscd
	rm -f ${ETCDIR}/rc.d/rc6.d/K31pcscd

sil-sysklogd:
	rm -f ${ETCDIR}/rc.d/init.d/sysklogd
	rm -f ${ETCDIR}/rc.d/rc0.d/K90sysklogd
	rm -f ${ETCDIR}/rc.d/rc1.d/K90sysklogd
	rm -f ${ETCDIR}/rc.d/rc2.d/K90sysklogd
	rm -f ${ETCDIR}/rc.d/rc3.d/S10sysklogd
	rm -f ${ETCDIR}/rc.d/rc4.d/S10sysklogd
	rm -f ${ETCDIR}/rc.d/rc5.d/S10sysklogd
	rm -f ${ETCDIR}/rc.d/rc6.d/K90sysklogd

sil-iptables:
	rm -f ${ETCDIR}/rc.d/init.d/iptables
	rm -f ${ETCDIR}/rc.d/rc3.d/S19iptables
	rm -f ${ETCDIR}/rc.d/rc4.d/S19iptables
	rm -f ${ETCDIR}/rc.d/rc5.d/S19iptables

sil-krb5:
	rm -f ${ETCDIR}/rc.d/init.d/krb5
	rm -f ${ETCDIR}/rc.d/rc0.d/K42krb5
	rm -f ${ETCDIR}/rc.d/rc1.d/K42krb5
	rm -f ${ETCDIR}/rc.d/rc2.d/K42krb5
	rm -f ${ETCDIR}/rc.d/rc3.d/S28krb5
	rm -f ${ETCDIR}/rc.d/rc4.d/S28krb5
	rm -f ${ETCDIR}/rc.d/rc5.d/S28krb5
	rm -f ${ETCDIR}/rc.d/rc6.d/K42krb5
	
sil-plymouth:
	rm -f ${ETCDIR}/rc.d/init.d/plymouth
	rm -f ${ETCDIR}/rc.d/rc0.d/K20plymouth
	rm -f ${ETCDIR}/rc.d/rc1.d/K20plymouth
	rm -f ${ETCDIR}/rc.d/rc2.d/S20plymouth
	rm -f ${ETCDIR}/rc.d/rc3.d/S20plymouth
	rm -f ${ETCDIR}/rc.d/rc4.d/S20plymouth
	rm -f ${ETCDIR}/rc.d/rc5.d/S20plymouth
	rm -f ${ETCDIR}/rc.d/rc6.d/K20plymouth

sil-lprng:
	rm -f ${ETCDIR}/rc.d/init.d/lprng
	rm -f ${ETCDIR}/rc.d/rc0.d/K00lprng
	rm -f ${ETCDIR}/rc.d/rc1.d/K00lprng
	rm -f ${ETCDIR}/rc.d/rc2.d/S99lprng
	rm -f ${ETCDIR}/rc.d/rc3.d/S99lprng
	rm -f ${ETCDIR}/rc.d/rc4.d/S99lprng
	rm -f ${ETCDIR}/rc.d/rc5.d/S99lprng
	rm -f ${ETCDIR}/rc.d/rc6.d/K00lprng

sil-lxdm:
	rm -f ${ETCDIR}/rc.d/init.d/lxdm
	rm -f ${ETCDIR}/rc.d/rc0.d/K05lxdm
	rm -f ${ETCDIR}/rc.d/rc1.d/K05lxdm
	rm -f ${ETCDIR}/rc.d/rc2.d/K05lxdm
	rm -f ${ETCDIR}/rc.d/rc3.d/K05lxdm
	rm -f ${ETCDIR}/rc.d/rc4.d/K05lxdm
	rm -f ${ETCDIR}/rc.d/rc5.d/S95lxdm
	rm -f ${ETCDIR}/rc.d/rc6.d/K05lxdm
	
sil-lightdm:
	rm -f ${ETCDIR}/rc.d/init.d/lightdm
	rm -f ${ETCDIR}/rc.d/rc0.d/K05lightdm
	rm -f ${ETCDIR}/rc.d/rc1.d/K05lightdm
	rm -f ${ETCDIR}/rc.d/rc2.d/K05lightdm
	rm -f ${ETCDIR}/rc.d/rc3.d/K05lightdm
	rm -f ${ETCDIR}/rc.d/rc4.d/K05lightdm
	rm -f ${ETCDIR}/rc.d/rc5.d/S95lightdm
	rm -f ${ETCDIR}/rc.d/rc6.d/K05lightdm
	
sil-mdm:
	rm -f ${ETCDIR}/rc.d/init.d/mdm
	rm -f ${ETCDIR}/rc.d/rc0.d/K05mdm
	rm -f ${ETCDIR}/rc.d/rc1.d/K05mdm
	rm -f ${ETCDIR}/rc.d/rc2.d/K05mdm
	rm -f ${ETCDIR}/rc.d/rc3.d/K05mdm
	rm -f ${ETCDIR}/rc.d/rc4.d/K05mdm
	rm -f ${ETCDIR}/rc.d/rc5.d/S95mdm
	rm -f ${ETCDIR}/rc.d/rc6.d/K05mdm

sil-mysql:
	rm -f ${ETCDIR}/rc.d/init.d/mysql
	rm -f ${ETCDIR}/rc.d/rc0.d/K26mysql
	rm -f ${ETCDIR}/rc.d/rc1.d/K26mysql
	rm -f ${ETCDIR}/rc.d/rc2.d/K26mysql
	rm -f ${ETCDIR}/rc.d/rc3.d/S34mysql
	rm -f ${ETCDIR}/rc.d/rc4.d/S34mysql
	rm -f ${ETCDIR}/rc.d/rc5.d/S34mysql
	rm -f ${ETCDIR}/rc.d/rc6.d/K26mysql

sil-netfs:
	rm -f ${ETCDIR}/rc.d/init.d/netfs
	rm -f ${ETCDIR}/rc.d/rc0.d/K47netfs
	rm -f ${ETCDIR}/rc.d/rc1.d/K47netfs
	rm -f ${ETCDIR}/rc.d/rc2.d/K47netfs
	rm -f ${ETCDIR}/rc.d/rc3.d/S28netfs
	rm -f ${ETCDIR}/rc.d/rc4.d/S28netfs
	rm -f ${ETCDIR}/rc.d/rc5.d/S28netfs
	rm -f ${ETCDIR}/rc.d/rc6.d/K47netfs

sil-networkmanager:
	rm -f ${ETCDIR}/rc.d/init.d/networkmanager
	rm -f ${ETCDIR}/rc.d/rc0.d/K28networkmanager
	rm -f ${ETCDIR}/rc.d/rc1.d/K28networkmanager
	rm -f ${ETCDIR}/rc.d/rc2.d/S33networkmanager
	rm -f ${ETCDIR}/rc.d/rc3.d/S33networkmanager
	rm -f ${ETCDIR}/rc.d/rc4.d/S33networkmanager
	rm -f ${ETCDIR}/rc.d/rc5.d/S33networkmanager
	rm -f ${ETCDIR}/rc.d/rc6.d/K28networkmanager
	
sil-connmand:
	rm -f ${ETCDIR}/rc.d/init.d/connmand
	rm -f ${ETCDIR}/rc.d/rc0.d/K28connmand
	rm -f ${ETCDIR}/rc.d/rc1.d/K28connmand
	rm -f ${ETCDIR}/rc.d/rc2.d/S33connmand
	rm -f ${ETCDIR}/rc.d/rc3.d/S33connmand
	rm -f ${ETCDIR}/rc.d/rc4.d/S33connmand
	rm -f ${ETCDIR}/rc.d/rc5.d/S33connmand
	rm -f ${ETCDIR}/rc.d/rc6.d/K28connmand

sil-nfs-client:
	rm -f ${ETCDIR}/rc.d/init.d/nfs-client
	rm -f ${ETCDIR}/rc.d/rc0.d/K48nfs-client
	rm -f ${ETCDIR}/rc.d/rc1.d/K48nfs-client
	rm -f ${ETCDIR}/rc.d/rc2.d/K48nfs-client
	rm -f ${ETCDIR}/rc.d/rc3.d/S24nfs-client
	rm -f ${ETCDIR}/rc.d/rc4.d/S24nfs-client
	rm -f ${ETCDIR}/rc.d/rc5.d/S24nfs-client
	rm -f ${ETCDIR}/rc.d/rc6.d/K48nfs-client

sil-nfs-server:
	rm -f ${ETCDIR}/rc.d/init.d/nfs-server
	rm -f ${ETCDIR}/rc.d/rc0.d/K48nfs-server
	rm -f ${ETCDIR}/rc.d/rc1.d/K48nfs-server
	rm -f ${ETCDIR}/rc.d/rc2.d/K48nfs-server
	rm -f ${ETCDIR}/rc.d/rc3.d/S24nfs-server
	rm -f ${ETCDIR}/rc.d/rc4.d/S24nfs-server
	rm -f ${ETCDIR}/rc.d/rc5.d/S24nfs-server
	rm -f ${ETCDIR}/rc.d/rc6.d/K48nfs-server

sil-ntpd:
	rm -f ${ETCDIR}/rc.d/init.d/ntpd
	rm -f ${ETCDIR}/rc.d/rc0.d/K46ntpd
	rm -f ${ETCDIR}/rc.d/rc1.d/K46ntpd
	rm -f ${ETCDIR}/rc.d/rc2.d/K46ntpd
	rm -f ${ETCDIR}/rc.d/rc3.d/S46ntpd
	rm -f ${ETCDIR}/rc.d/rc4.d/S46ntpd
	rm -f ${ETCDIR}/rc.d/rc5.d/S46ntpd
	rm -f ${ETCDIR}/rc.d/rc6.d/K46ntpd

sil-slapd:
	rm -f ${ETCDIR}/rc.d/init.d/slapd
	rm -f ${ETCDIR}/sysconfig/slapd
	rm -f ${ETCDIR}/rc.d/rc0.d/K46slapd
	rm -f ${ETCDIR}/rc.d/rc1.d/K46slapd
	rm -f ${ETCDIR}/rc.d/rc2.d/S25slapd
	rm -f ${ETCDIR}/rc.d/rc3.d/S25slapd
	rm -f ${ETCDIR}/rc.d/rc4.d/S25slapd
	rm -f ${ETCDIR}/rc.d/rc5.d/S25slapd
	rm -f ${ETCDIR}/rc.d/rc6.d/K46slapd

sil-slim:
	rm -f ${ETCDIR}/rc.d/init.d/slim
	rm -f ${ETCDIR}/rc.d/rc0.d/K05slim
	rm -f ${ETCDIR}/rc.d/rc1.d/K05slim
	rm -f ${ETCDIR}/rc.d/rc2.d/K05slim
	rm -f ${ETCDIR}/rc.d/rc3.d/K05slim
	rm -f ${ETCDIR}/rc.d/rc4.d/K05slim
	rm -f ${ETCDIR}/rc.d/rc5.d/S95slim
	rm -f ${ETCDIR}/rc.d/rc6.d/K05slim

ukur-smartd: c
	rm -f ${ETCDIR}/rc.d/init.d/smartd
	rm -f ${ETCDIR}/rc.d/rc0.d/K70smartd
	rm -f ${ETCDIR}/rc.d/rc1.d/K70smartd
	rm -f ${ETCDIR}/rc.d/rc2.d/K70smartd
	rm -f ${ETCDIR}/rc.d/rc3.d/S21smartd
	rm -f ${ETCDIR}/rc.d/rc4.d/S21smartd
	rm -f ${ETCDIR}/rc.d/rc5.d/S21smartd
	rm -f ${ETCDIR}/rc.d/rc6.d/K70smartd

sil-postfix:
	rm -f ${ETCDIR}/rc.d/init.d/postfix
	rm -f ${ETCDIR}/rc.d/rc0.d/K25postfix
	rm -f ${ETCDIR}/rc.d/rc1.d/K25postfix
	rm -f ${ETCDIR}/rc.d/rc2.d/K25postfix
	rm -f ${ETCDIR}/rc.d/rc3.d/S35postfix
	rm -f ${ETCDIR}/rc.d/rc4.d/S35postfix
	rm -f ${ETCDIR}/rc.d/rc5.d/S35postfix
	rm -f ${ETCDIR}/rc.d/rc6.d/K25postfix

sil-dnsmasq:
	rm -f ${ETCDIR}/rc.d/init.d/dnsmasq
	rm -f ${ETCDIR}/rc.d/rc0.d/K33dnsmasq
	rm -f ${ETCDIR}/rc.d/rc1.d/K33dnsmasq
	rm -f ${ETCDIR}/rc.d/rc2.d/K33dnsmasq
	rm -f ${ETCDIR}/rc.d/rc3.d/S36dnsmasq
	rm -f ${ETCDIR}/rc.d/rc4.d/S36dnsmasq
	rm -f ${ETCDIR}/rc.d/rc5.d/S36dnsmasq
	rm -f ${ETCDIR}/rc.d/rc6.d/K33dnsmasq

sil-postgresql:
	rm -f ${ETCDIR}/rc.d/init.d/postgresql
	rm -f ${ETCDIR}/rc.d/rc0.d/K26postgresql
	rm -f ${ETCDIR}/rc.d/rc1.d/K26postgresql
	rm -f ${ETCDIR}/rc.d/rc2.d/K26postgresql
	rm -f ${ETCDIR}/rc.d/rc3.d/S34postgresql
	rm -f ${ETCDIR}/rc.d/rc4.d/S34postgresql
	rm -f ${ETCDIR}/rc.d/rc5.d/S34postgresql
	rm -f ${ETCDIR}/rc.d/rc6.d/K26postgresql

sil-proftpd:
	rm -f ${ETCDIR}/rc.d/init.d/proftpd
	rm -f ${ETCDIR}/rc.d/rc0.d/K28proftpd
	rm -f ${ETCDIR}/rc.d/rc1.d/K28proftpd
	rm -f ${ETCDIR}/rc.d/rc2.d/K28proftpd
	rm -f ${ETCDIR}/rc.d/rc3.d/S32proftpd
	rm -f ${ETCDIR}/rc.d/rc4.d/S32proftpd
	rm -f ${ETCDIR}/rc.d/rc5.d/S32proftpd
	rm -f ${ETCDIR}/rc.d/rc6.d/K28proftpd

sil-random:
	rm -f ${ETCDIR}/rc.d/init.d/random
	rm -f ${ETCDIR}/rc.d/rc0.d/K45random
	rm -f ${ETCDIR}/rc.d/rc1.d/S25random
	rm -f ${ETCDIR}/rc.d/rc2.d/S25random
	rm -f ${ETCDIR}/rc.d/rc3.d/S25random
	rm -f ${ETCDIR}/rc.d/rc4.d/S25random
	rm -f ${ETCDIR}/rc.d/rc5.d/S25random
	rm -f ${ETCDIR}/rc.d/rc6.d/K45random

sil-rpcbind: 
	rm -f ${ETCDIR}/rc.d/init.d/rpcbind
	rm -f ${ETCDIR}/rc.d/rc0.d/K49rpcbind
	rm -f ${ETCDIR}/rc.d/rc1.d/K49rpcbind
	rm -f ${ETCDIR}/rc.d/rc2.d/K49rpcbind
	rm -f ${ETCDIR}/rc.d/rc3.d/S22rpcbind
	rm -f ${ETCDIR}/rc.d/rc4.d/S22rpcbind
	rm -f ${ETCDIR}/rc.d/rc5.d/S22rpcbind
	rm -f ${ETCDIR}/rc.d/rc6.d/K49rpcbind

sil-rsyncd:
	rm -f ${ETCDIR}/rc.d/init.d/rsyncd
	rm -f ${ETCDIR}/rc.d/rc0.d/K30rsyncd
	rm -f ${ETCDIR}/rc.d/rc1.d/K30rsyncd
	rm -f ${ETCDIR}/rc.d/rc2.d/K30rsyncd
	rm -f ${ETCDIR}/rc.d/rc3.d/S30rsyncd
	rm -f ${ETCDIR}/rc.d/rc4.d/S30rsyncd
	rm -f ${ETCDIR}/rc.d/rc5.d/S30rsyncd
	rm -f ${ETCDIR}/rc.d/rc6.d/K30rsyncd

sil-samba:
	rm -f ${ETCDIR}/rc.d/init.d/samba
	rm -f ${ETCDIR}/rc.d/rc0.d/K48samba
	rm -f ${ETCDIR}/rc.d/rc1.d/K48samba
	rm -f ${ETCDIR}/rc.d/rc2.d/K48samba
	rm -f ${ETCDIR}/rc.d/rc3.d/S45samba
	rm -f ${ETCDIR}/rc.d/rc4.d/S45samba
	rm -f ${ETCDIR}/rc.d/rc5.d/S45samba
	rm -f ${ETCDIR}/rc.d/rc6.d/K48samba
	
sil-pulseaudio:
	rm -f ${ETCDIR}/rc.d/init.d/pulseaudio
	rm -f ${ETCDIR}/rc.d/rc0.d/K55pulseaudio
	rm -f ${ETCDIR}/rc.d/rc1.d/K55pulseaudio
	rm -f ${ETCDIR}/rc.d/rc2.d/K55pulseaudio
	rm -f ${ETCDIR}/rc.d/rc3.d/S55pulseaudio
	rm -f ${ETCDIR}/rc.d/rc4.d/S55pulseaudio
	rm -f ${ETCDIR}/rc.d/rc5.d/S55pulseaudio
	rm -f ${ETCDIR}/rc.d/rc6.d/K55pulseaudio

sil-sddm:
	rm -f ${ETCDIR}/rc.d/init.d/sddm
	rm -f ${ETCDIR}/rc.d/rc0.d/K05sddm
	rm -f ${ETCDIR}/rc.d/rc1.d/K05sddm
	rm -f ${ETCDIR}/rc.d/rc2.d/K05sddm
	rm -f ${ETCDIR}/rc.d/rc3.d/K05sddm
	rm -f ${ETCDIR}/rc.d/rc4.d/K05sddm
	rm -f ${ETCDIR}/rc.d/rc5.d/S95sddm
	rm -f ${ETCDIR}/rc.d/rc6.d/K05sddm

sil-sendmail:
	rm -f ${ETCDIR}/rc.d/init.d/sendmail
	rm -f ${ETCDIR}/rc.d/rc0.d/K25sendmail
	rm -f ${ETCDIR}/rc.d/rc1.d/K25sendmail
	rm -f ${ETCDIR}/rc.d/rc2.d/K25sendmail
	rm -f ${ETCDIR}/rc.d/rc3.d/S35sendmail
	rm -f ${ETCDIR}/rc.d/rc4.d/S35sendmail
	rm -f ${ETCDIR}/rc.d/rc5.d/S35sendmail
	rm -f ${ETCDIR}/rc.d/rc6.d/K25sendmail

sil-sshd:
	rm -f ${ETCDIR}/rc.d/init.d/sshd
	rm -f ${ETCDIR}/rc.d/rc0.d/K30sshd
	rm -f ${ETCDIR}/rc.d/rc1.d/K30sshd
	rm -f ${ETCDIR}/rc.d/rc2.d/K30sshd
	rm -f ${ETCDIR}/rc.d/rc3.d/S30sshd
	rm -f ${ETCDIR}/rc.d/rc4.d/S30sshd
	rm -f ${ETCDIR}/rc.d/rc5.d/S30sshd
	rm -f ${ETCDIR}/rc.d/rc6.d/K30sshd

sil-stunnel:
	rm -f ${ETCDIR}/rc.d/init.d/stunnel
	rm -f ${ETCDIR}/rc.d/rc0.d/K47stunnel
	rm -f ${ETCDIR}/rc.d/rc1.d/K47stunnel
	rm -f ${ETCDIR}/rc.d/rc2.d/K47stunnel
	rm -f ${ETCDIR}/rc.d/rc3.d/S55stunnel
	rm -f ${ETCDIR}/rc.d/rc4.d/S55stunnel
	rm -f ${ETCDIR}/rc.d/rc5.d/S55stunnel
	rm -f ${ETCDIR}/rc.d/rc6.d/K47stunnel

sil-svn:
	rm -f ${ETCDIR}/rc.d/init.d/svn
	rm -f ${ETCDIR}/rc.d/rc0.d/K27svn
	rm -f ${ETCDIR}/rc.d/rc1.d/K27svn
	rm -f ${ETCDIR}/rc.d/rc2.d/K27svn
	rm -f ${ETCDIR}/rc.d/rc3.d/S33svn
	rm -f ${ETCDIR}/rc.d/rc4.d/S33svn
	rm -f ${ETCDIR}/rc.d/rc5.d/S33svn
	rm -f ${ETCDIR}/rc.d/rc6.d/K27svn

sil-sysstat:
	rm -f ${ETCDIR}/rc.d/init.d/sysstat
	rm -f ${ETCDIR}/rc.d/rcS.d/S85sysstat

sil-unbound:
	rm -f ${ETCDIR}/rc.d/init.d/unbound
	rm -f ${ETCDIR}/rc.d/rc0.d/K79unbound
	rm -f ${ETCDIR}/rc.d/rc1.d/K79unbound
	rm -f ${ETCDIR}/rc.d/rc2.d/K79unbound
	rm -f ${ETCDIR}/rc.d/rc3.d/S21unbound
	rm -f ${ETCDIR}/rc.d/rc4.d/S21unbound
	rm -f ${ETCDIR}/rc.d/rc5.d/S21unbound
	rm -f ${ETCDIR}/rc.d/rc6.d/K79unbound

sil-virtuoso:
	rm -f ${ETCDIR}/rc.d/init.d/virtuoso
	rm -f ${ETCDIR}/rc.d/rc0.d/K40virtuoso
	rm -f ${ETCDIR}/rc.d/rc1.d/K40virtuoso
	rm -f ${ETCDIR}/rc.d/rc2.d/K40virtuoso
	rm -f ${ETCDIR}/rc.d/rc3.d/S47virtuoso
	rm -f ${ETCDIR}/rc.d/rc4.d/S47virtuoso
	rm -f ${ETCDIR}/rc.d/rc5.d/S47virtuoso
	rm -f ${ETCDIR}/rc.d/rc6.d/K40virtuoso

sil-vsftpd:
	rm -f ${ETCDIR}/rc.d/init.d/vsftpd
	rm -f ${ETCDIR}/rc.d/rc0.d/K28vsftpd
	rm -f ${ETCDIR}/rc.d/rc1.d/K28vsftpd
	rm -f ${ETCDIR}/rc.d/rc2.d/K28vsftpd
	rm -f ${ETCDIR}/rc.d/rc3.d/S32vsftpd
	rm -f ${ETCDIR}/rc.d/rc4.d/S32vsftpd
	rm -f ${ETCDIR}/rc.d/rc5.d/S32vsftpd
	rm -f ${ETCDIR}/rc.d/rc6.d/K28vsftpd

sil-winbindd:
	rm -f ${ETCDIR}/rc.d/init.d/winbindd
	rm -f ${ETCDIR}/rc.d/rc0.d/K49winbindd
	rm -f ${ETCDIR}/rc.d/rc1.d/K49winbindd
	rm -f ${ETCDIR}/rc.d/rc2.d/K49winbindd
	rm -f ${ETCDIR}/rc.d/rc3.d/S50winbindd
	rm -f ${ETCDIR}/rc.d/rc4.d/S50winbindd
	rm -f ${ETCDIR}/rc.d/rc5.d/S50winbindd
	rm -f ${ETCDIR}/rc.d/rc6.d/K49winbindd

sil-xinetd:
	rm -f ${ETCDIR}/rc.d/init.d/xinetd
	rm -f ${ETCDIR}/rc.d/rc0.d/K49xinetd
	rm -f ${ETCDIR}/rc.d/rc1.d/K49xinetd
	rm -f ${ETCDIR}/rc.d/rc2.d/K49xinetd
	rm -f ${ETCDIR}/rc.d/rc3.d/S23xinetd
	rm -f ${ETCDIR}/rc.d/rc4.d/S23xinetd
	rm -f ${ETCDIR}/rc.d/rc5.d/S23xinetd
	rm -f ${ETCDIR}/rc.d/rc6.d/K49xinetd
	


.PHONY: all create-dirs install files links rcS rc0 rc1 rc2 rc3 rc4 rc5 rc6 uninstall

