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
# KDE-Services ⚙ 2016-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
OPERATION=""
KDESU="kdesu"
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="Android Reboot Manager" --passivepopup="[Canceled]"
		exit 1
	fi
}

if [ "$(pidof adb)" = "" ]; then
	$KDESU -i ks-android-reboot --noignorebutton -d -c "adb start-server"
	if-cancel-exit
fi

SERIAL=$(adb get-serialno)

check-device() {
	if [ "$(adb devices|grep -v List|awk -F" " '{print $2}'|head -n1)" != "device" ] && \
		[ "$(adb devices|grep -v List|awk -F" " '{print $2}'|head -n1)" != "recovery" ] && \
		[ "$(fastboot devices|awk -F" " '{print $3}')" != "fastboot" ]; then
		kdialog --icon=ks-error --title="Android Reboot Manager" \
			--passivepopup="[Canceled]   Check if your device with Android system is connected on your PC. \
			[1]-Connect your device to PC USB. [2]-Go to device Settings. [3]-Go to Developer options. [4]-Enable USB debugging option. Try again."
		exit 1
	fi
}

check-device

progressbar-start() {
	kdialog --icon=ks-android-reboot --title="Android Reboot Manager" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-android-reboot --title="Android Reboot Manager" \
			--passivepopup="[Finished]   Reboot $OPERATION device $SERIAL.   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-android-reboot --title="Android Reboot Manager" \
			--passivepopup="[Finished]   Reboot $OPERATION device $SERIAL.   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-android-reboot --title="Android Reboot Manager" \
			--passivepopup="[Finished]   Reboot $OPERATION device $SERIAL.   Elapsed Time: ${ELAPSED_TIME}h"
	fi
}

##############################
############ Main ############
##############################

OPERATION=$(kdialog --icon=ks-android-reboot --title="Android Reboot Manager" \
	--combobox="Select Reboot Operation" Bootloader Recovery System --default System 2> /dev/null)
if-cancel-exit

if [ "$OPERATION" = "System" ]; then
	progressbar-start
	BEGIN_TIME=$(date +%s)
	if [ "$(adb devices|grep -v List|awk -F" " '{print $2}'|head -n1)" = "device" ] || [ "$(adb devices|grep -v List|awk -F" " '{print $2}'|head -n1)" = "recovery" ]; then
		adb reboot
	elif [ "$(fastboot devices|awk -F" " '{print $3}')" = "fastboot" ]; then
		$KDESU -i ks-android-reboot --noignorebutton -d -c "fastboot reboot"
		if-cancel-exit
	fi
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
elif [ "$OPERATION" = "Bootloader" ]; then
	progressbar-start
	BEGIN_TIME=$(date +%s)
	if [ "$(adb devices|grep -v List|awk -F" " '{print $2}'|head -n1)" = "device" ] || [ "$(adb devices|grep -v List|awk -F" " '{print $2}'|head -n1)" = "recovery" ]; then
		adb reboot bootloader
	elif [ "$(fastboot devices|awk -F" " '{print $3}')" = "fastboot" ]; then
		$KDESU -i ks-android-reboot --noignorebutton -d -c "fastboot reboot-bootloader"
		if-cancel-exit
	fi
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
elif [ "$OPERATION" = "Recovery" ] && [ "$SERIAL" != "" ] && [ "$(fastboot devices|awk -F" " '{print $1}')" = "" ]; then
	progressbar-start
	BEGIN_TIME=$(date +%s)
	adb reboot recovery
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
else
	kdialog --icon=ks-error --title="Android Reboot Manager" \
		--passivepopup="[Canceled]   Check if your device with Android system is connected on your PC and NOT bootloader mode. \
		[1]-Connect your device to PC USB. [2]-Go to device Settings. [3]-Go to Developer options. [4]-Enable USB debugging option. Try again."
fi
progressbar-stop
echo "Finish Android Reboot Manager Operation" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*
exit 0
