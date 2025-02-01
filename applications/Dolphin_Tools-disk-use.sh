#!/usr/bin/env bash
########################################################################
# This program is free software; you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation; either version 3 of the License, or    #
# (at your option) any later version.                                  #
#                                                                      #
# This program is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License for more details.                         #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with this program; if not, write to the Free Software          #
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,           #
# MA 02110-1301, USA.                                                  #
#                                                                      #
#                                                                      #
# KDE-Services ⚙ 2011-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
BEGIN_TIME=$(date +%s)
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

progressbar-start() {
	kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB)" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

##############################
############ Main ############
##############################

progressbar-start
du -ah $1|egrep -e "^...T" -e "^..T" -e "^.T" -e "^...G" -e "^..G" -e "^.G" -e "^...M"|egrep -v "^.\..M"|egrep -v "^ ..M"|sort -rh > /tmp/info.tmp
sort -rh /tmp/info.tmp > /tmp/info
FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
progressbar-stop

if [ -s /tmp/info ]; then
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB) Elapsed Time: ${ELAPSED_TIME}s" --textbox /tmp/info 640 480 2> /dev/null
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB) Elapsed Time: ${ELAPSED_TIME}m" --textbox /tmp/info 640 480 2> /dev/null
	elif [ "$ELAPSED_TIME" -gt "3599" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB) Elapsed Time: ${ELAPSED_TIME}h" --textbox /tmp/info 640 480 2> /dev/null
	fi
	rm -fr /tmp/info*
else
	kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB)" --sorry="No Find Files or Directory Up 100 MB" 2> /dev/null
	kill -9 $(pidof knotify4)
	rm -fr /tmp/info*
fi

exit 0
