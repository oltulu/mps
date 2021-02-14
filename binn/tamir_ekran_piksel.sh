#!/bin/sh
# ekrandaki pikselleşme sorunun çözümü için kullanılmaktadır.
# amd vega3 ekran kartında test edilmiştir.
xfconf-query -c xfwm4 -p /general/vblank_mode -t string -s "xpresent" --create
