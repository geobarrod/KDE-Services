#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2011-2025.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin

locate -S > /tmp/StatisticsLocateDB
kdialog --icon=ks-search-stats --title="Statistics Search DataBase" --textbox /tmp/StatisticsLocateDB 400 160 2> /dev/null
rm -f /tmp/StatisticsLocateDB

exit 0
