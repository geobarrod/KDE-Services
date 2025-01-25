#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2011-2025.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################
# What file did it modify now here?
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
TMP=/tmp/mfh
PB_PIDFILE="$(mktemp)"
kdialog --icon=ks-search-name --title="Modified Files Here" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
find $1 -type f -newer "$HOME/.xsession-errors-:0" > $TMP; touch "$HOME/.xsession-errors-:0"
kill $(cat $PB_PIDFILE)
rm $PB_PIDFILE
kdialog --icon=ks-search-name --title="Modified Files Here: $(cat $TMP|wc -l) entries" \
               --textbox $TMP 900 300 2> /dev/null
rm -f $TMP

exit 0
