#!/bin/bash

#################################################################
# For KDE Services. 2011-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

SYSUSER=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-system-process.png --caption="Process Viewer - Htop" --combobox="Choose System User" $USER root --default $USER 2> /dev/null)
EXIT=$?

if [ "$EXIT" != "0" ]; then
    exit 0
fi

if [ "$SYSUSER" = "$USER" ]; then
    xterm -T "Process Viewer - Htop" -bg black -fg white -e htop
else
    kdesu --noignorebutton -d xterm -T "Process Viewer - Htop (Root)" -bg black -fg white -e htop
fi

exit 0
