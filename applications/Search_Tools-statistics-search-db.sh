#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
WIDTH=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $1}')
HEIGHT=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $2}')

locate -S > /tmp/StatisticsLocateDB
kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-search-stats.svgz --title="Statistics Search DataBase" --textbox /tmp/StatisticsLocateDB --geometry 400x160+$((WIDTH/2-400/2))+$((HEIGHT/2-160/2)) 2> /dev/null
rm -f /tmp/StatisticsLocateDB

exit 0
