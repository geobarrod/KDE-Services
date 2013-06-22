#!/bin/bash

###################################################################
# For KDE Services. 2011.                                         #
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>                #
###################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

export $(dbus-launch)

locate -S > /tmp/StatisticsLocateDB
kdialog --icon=edit-find-replace --caption="Statistics Search DB" --textbox /tmp/StatisticsLocateDB 400 155 2> /dev/null
rm -f /tmp/StatisticsLocateDB

exit 0
