#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
TMP="/tmp/sockets"
WIDTH=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $1}')
HEIGHT=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $2}')

ss -ntuap|grep LISTEN|sort -t: -nk 2 > $TMP
TOTAL=$(cat $TMP|wc -l)
kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-socket.svgz --title="Listening Sockets - $TOTAL" --textbox $TMP --geometry 700x250+$((WIDTH/2-700/2))+$((HEIGHT/2-250/2)) 2> /dev/null

rm -f $TMP
exit 0
