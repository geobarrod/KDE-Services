#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2011-2025.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
TMP=/tmp/SearchHere
PB_PIDFILE="$(mktemp)"
PATTERN=$(kdialog --icon=ks-search-name --title="Search Here" --inputbox="Enter Pattern To Search" 2> /dev/null)
if [ "$?" != "0" ]; then
  exit 1
fi
kdialog --icon=ks-search-name --title="Search Here" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
find $1 -iname "*$PATTERN*" > $TMP
kill $(cat $PB_PIDFILE)
rm $PB_PIDFILE
kdialog --icon=ks-search-name --title="Search Here: $(cat $TMP|wc -l) matching entries with ($PATTERN)" --textbox $TMP 900 300 2> /dev/null
rm -f $TMP
exit 0
