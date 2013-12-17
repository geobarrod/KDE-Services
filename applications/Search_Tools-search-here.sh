#!/bin/bash

#################################################################
# For KDE-Services. 2011-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
TMP=/tmp/SearchHere

PATTERN=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-search-name.png --caption="Search Here" --inputbox="Enter Pattern To Search" 2> /dev/null)

if [ "$?" != "0" ]; then
  exit 1
fi

DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-search-name.png --caption="Search Here" --progressbar "                                       " /ProgressDialog)
qdbus $DBUSREF setLabelText "Searching [File|Dir]name...:  $PATTERN"
find $1 -iname "*$PATTERN*" > $TMP
qdbus $DBUSREF close
kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-search-name.png --caption="Search Here: $(cat $TMP|wc -l) matching entries with ($PATTERN)" \
               --textbox $TMP 900 300 2> /dev/null
rm -f $TMP

exit 0
