#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2011-2025.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
TMP="/tmp/socks"

netstat -nltu|sort -t: -nuk2|grep -v connections|awk -F " " -v OFS='\t' '{print $1,$4,$6}' > $TMP
TOTAL=$(cat $TMP|wc -l)
kdialog --icon=ks-socket --title="Listening Sockets - $TOTAL" --textbox $TMP --geometry 480x360 2> /dev/null
rm -f $TMP
exit 0
