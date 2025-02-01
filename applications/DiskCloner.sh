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
# KDE-Services ⚙ 2014-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
DIR=""
DEVICE=""
DESTINATION=""
SIZE=""
LABEL=""
STERR=/tmp/dd.err
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ] || [ "$DEVICE" == "" ]; then
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="DiskCloner" --passivepopup="[Canceled]"
		exit 1
	fi
}

if-dd-error() {
	if [ "$?" != "0" ]; then
		kdialog --icon=ks-error --title="DiskCloner" --passivepopup="[Canceled]   $(cat $STERR). Try again"
		eject
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="DiskCloner" --passivepopup="[Canceled]"
		exit 1
	fi
}

progressbar-start() {
	kdialog --icon=ks-media-optical-clone --title="DiskCloner" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-media-optical-clone --title="DiskCloner" \
			--passivepopup="[Finished]  $LABEL.iso   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-media-optical-clone --title="DiskCloner" \
			--passivepopup="[Finished]   $LABEL.iso   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-media-optical-clone --title="DiskCloner" \
			--passivepopup="[Finished]   $LABEL.iso   Elapsed Time: ${ELAPSED_TIME}h"
	fi
}

##############################
############ Main ############
##############################

DIR=$1
cd "$DIR"
DIR=$(pwd)

if [ "$DIR" == "~/.local/share/applications" ]; then
	DIR="~/"
fi

DEVICE=$(kdialog --icon=ks-media-optical-clone --title="DiskCloner" --combobox="Select Device to Clone" "$(lsblk -po NAME,SIZE,LABEL|grep "sr[0-9]")" 2> /dev/null)
if-cancel-exit
LABEL="$(echo $DEVICE|awk -F" " '{print $3}')"
SIZE="$(echo $DEVICE|awk -F" " '{print $2}'|awk -F. '{print $1}')"
DEVICE=$(echo $DEVICE|awk -F" " '{print $1}')
DESTINATION=$(kdialog --icon=ks-media-optical-clone --title="Destination ISO Image File" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

progressbar-start
BEGIN_TIME=$(date +%s)
dd bs=2048 if=$DEVICE of="$DESTINATION/$LABEL.iso" 2> $STERR
if-dd-error
FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
progressbar-stop
echo "Finish Media Optical Clone" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak* $STERR
elapsedtime
eject

exit 0
