#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################
# What file did it modify now here?
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
TMP=/tmp/mfh
WIDTH=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $1}')
HEIGHT=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $2}')

DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-search-name.svgz --title="Modified Files Here" --progressbar "                                       " /ProgressDialog)
qdbus $DBUSREF setLabelText "Searching..."
find $1 -type f -newer "$HOME/.xsession-errors-:0" > $TMP; touch "$HOME/.xsession-errors-:0"
qdbus $DBUSREF close
kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-search-name.svgz --title="Modified Files Here: $(cat $TMP|wc -l) entries" \
               --textbox $TMP --geometry 900x300+$((WIDTH/2-900/2))+$((HEIGHT/2-300/2)) 2> /dev/null
rm -f $TMP

exit 0
