#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2011-2025.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
TMP=/tmp/SearchByString
PB_PIDFILE="$(mktemp)"
STRING=$(kdialog --icon=ks-search-string --title='Search by String' --inputbox='Enter String to Search' 2> /dev/null)
if [ "$?" != "0" ]; then
  exit 1
fi
kdialog --icon=ks-search-string --title="Search by String" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
egrep -r "$STRING" "$1"/* > $TMP
kill $(cat $PB_PIDFILE)
rm $PB_PIDFILE
kdialog --icon=ks-search-string --title="Search by String: $(cat $TMP|wc -l) matching entries with ($STRING)" \
               --textbox $TMP 900 300 2> /dev/null
rm -f $TMP
exit 0
