#!/bin/bash

###################################################################
# For KDE Services. 2011.                                         #
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>                #
###################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

kdesu --noignorebutton -d updatedb 2> /dev/null
echo  "Finish Update Search Database" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav 2> /dev/null
rm -f /tmp/speak*
kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-search-database-update.png --title="Update Search DB" --passivepopup="Finished" 2> /dev/null

exit 0
