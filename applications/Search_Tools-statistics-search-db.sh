#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.									#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>				#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

locate -S > /tmp/StatisticsLocateDB
kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-search-stats.svgz --caption="Statistics Search DataBase" --textbox /tmp/StatisticsLocateDB 400 155 2> /dev/null
rm -f /tmp/StatisticsLocateDB

exit 0
