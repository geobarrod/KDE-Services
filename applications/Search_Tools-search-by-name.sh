#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
TMP=/tmp/SearchByName
WIDTH=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $1}')
HEIGHT=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $2}')

PATTERN=$(kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-search-name.svgz --title="Search by Name" --inputbox="Enter Pattern to Search" 2> /dev/null)

if [ "$?" != "0" ]; then
  exit 1
fi

DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-search-name.svgz --title="Search by Name" --progressbar "                                       " /ProgressDialog)
qdbus $DBUSREF setLabelText "Searching Name...:  $PATTERN"
locate -b $PATTERN > $TMP
qdbus $DBUSREF close
kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-search-name.svgz --title="Search by Name: $(cat $TMP|wc -l) matching entries with ($PATTERN)" \
               --textbox $TMP --geometry 900x300+$((WIDTH/2-900/2))+$((HEIGHT/2-300/2)) 2> /dev/null
rm -f $TMP

exit 0
