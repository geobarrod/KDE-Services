#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2011-2025.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
KDESU="/usr/local/lib/libexec/*/kdesu"
PB_PIDFILE="$(mktemp)"

$KDESU --noignorebutton -d updatedb & 2> /dev/null

until [ "$(pidof kdesu)" = "" ]; do
	sleep 1
	true
done

kdialog --icon=ks-search-database-update --title="Update Search DataBase" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE

until [ "$(pidof updatedb)" = "" ]; do
	sleep 1
	true
done

kill $(cat $PB_PIDFILE)
rm $PB_PIDFILE
echo  "Finish Update Search Database" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav 2> /dev/null
rm -f /tmp/speak*
kdialog --icon=ks-search-database-update --title="Update Search DataBase" --passivepopup="Finished" 2> /dev/null
exit 0
