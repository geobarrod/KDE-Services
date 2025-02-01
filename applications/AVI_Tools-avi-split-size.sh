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
FILE="$@"
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="AVI Split (To Size)" --passivepopup="[Canceled]"
		exit 1
	fi
}

if-avisplit-cancel() {
	if [ "$?" != "0" ]; then
		kdialog --icon=ks-error --title="AVI Split (To Size)" \
			--passivepopup="[Canceled]   Check the path and filename not contain whitespace. Check video format errors. Try again"
		exit 1
	fi
}

progressbar-start() {
	kdialog --icon=ks-video --title="AVI Split (To Size)" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-video --title="AVI Split (To Size)" \
			--passivepopup="[Finished]	${file##*/}   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-video --title="AVI Split (To Size)" \
			--passivepopup="[Finished]	${file##*/}   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-video --title="AVI Split (To Size)" \
			--passivepopup="[Finished]	${file##*/}   Elapsed Time: ${ELAPSED_TIME}h"
	elif [ "$ELAPSED_TIME" -gt "86399" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-video --title="AVI Split (To Size)" \
			--passivepopup="[Finished]	${file##*/}   Elapsed Time: ${ELAPSED_TIME}d"
	fi
}

##############################
############ Main ############
##############################

SIZE=$(kdialog --icon=ks-video --title="AVI Split (To Size)" --inputbox="Enter size in MBytes" 2> /dev/null)
if-cancel-exit
progressbar-start

for file in $FILE; do
	BEGIN_TIME=$(date +%s)
	avisplit -s $SIZE -i "$file" -o "${file%.*}_Size-Edited.avi"
	if-avisplit-cancel
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
done

progressbar-stop
echo "Finish Splitting AVI" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav 2> /dev/null
rm -fr /tmp/speak*

exit 0
