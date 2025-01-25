#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2016-2025.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
OPERATION=""
KDESU="/usr/local/lib/libexec/*/kdesu"
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		  exit 1
	fi
}

if [ "$(pidof adb)" = "" ]; then
	$KDESU -i ks-android-reboot --noignorebutton -d adb start-server
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
		$KDESU -i ks-android-reboot --noignorebutton -d fastboot reboot
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
		$KDESU -i ks-android-reboot --noignorebutton -d fastboot reboot-bootloader
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
