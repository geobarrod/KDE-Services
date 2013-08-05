#!/bin/bash

###################################################################
# For KDE-Services. 2011.                                         #
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>                #
###################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
TMP="/tmp/sockets"

ss -ntuap|grep LISTEN|sort -t: -nk 2 > $TMP
TOTAL=$(cat $TMP|wc -l)
kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-socket.png --caption="Listening Sockets - $TOTAL" --textbox $TMP --geometry 700x250 2> /dev/null

rm -f $TMP
exit 0
