#!/bin/bash

#################################################################
# For KDE-Services. 2011-2017.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
TMP="/tmp/sockets"

ss -ntuap|grep LISTEN|sort -t: -nk 2 > $TMP
TOTAL=$(cat $TMP|wc -l)
kdialog --icon=ks-socket --title="Listening Sockets - $TOTAL" --textbox $TMP 700 250 2> /dev/null

rm -f $TMP
exit 0
