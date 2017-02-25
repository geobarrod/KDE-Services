#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

kdesu --noignorebutton -d updatedb & 2> /dev/null

until [ "$(pidof kdesu)" = "" ]; do
  sleep 1
  true
done

DBUSREF=$(kdialog --icon=ks-search-database-update --title="Update Search DataBase" --progressbar "                                        " /ProgressDialog)
qdbus $DBUSREF setLabelText "Updating search database..."

until [ "$(pidof updatedb)" = "" ]; do
  sleep 1
  true
done

qdbus $DBUSREF close
echo  "Finish Update Search Database" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav 2> /dev/null
rm -f /tmp/speak*
kdialog --icon=ks-search-database-update --title="Update Search DataBase" --passivepopup="Finished" 2> /dev/null

exit 0
