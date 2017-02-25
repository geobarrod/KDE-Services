#!/bin/bash

#################################################################
# For KDE-Services. 2011-2017.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################
# What file did it modify now here?
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
TMP=/tmp/mfh
DBUSREF=$(kdialog --icon=ks-search-name --title="Modified Files Here" --progressbar "                                       " /ProgressDialog)
qdbus $DBUSREF setLabelText "Searching..."
find $1 -type f -newer "$HOME/.xsession-errors-:0" > $TMP; touch "$HOME/.xsession-errors-:0"
qdbus $DBUSREF close
kdialog --icon=ks-search-name --title="Modified Files Here: $(cat $TMP|wc -l) entries" \
               --textbox $TMP 900 300 2> /dev/null
rm -f $TMP

exit 0
