#!/bin/bash

#################################################################
# For KDE Services. 2011-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

export $(dbus-launch)

PATTERN=$(kdialog --icon=edit-find-project --caption="Search By Name" --inputbox="Enter Pattern To Search" 2> /dev/null)
DBUSREF=$(kdialog --icon=edit-find-project --caption="Search By Name" --progressbar "                                       " /ProgressDialog)
qdbus $DBUSREF setLabelText "Searching name:  $PATTERN"
locate -b $PATTERN > /tmp/SearchByName
qdbus $DBUSREF close
kdialog --icon=edit-find-project --caption="Search By Name: `cat /tmp/SearchByName|wc -l` matching entries with ($PATTERN)" \
               --textbox /tmp/SearchByName 900 300 2> /dev/null
rm -f /tmp/SearchByName

exit 0
