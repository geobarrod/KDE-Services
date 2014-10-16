#!/bin/bash

#################################################################
# For KDE-Services. 2014.										#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>				#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

if [ "$(pidof adb)" = "" ]; then
  kdesu --caption="Android Reboot Manager" --noignorebutton -d adb start-server
fi

BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
OPERATION=""
SERIAL=$(adb get-serialno)

###################################
############ Functions ############
###################################

check-device() {
  if [ "$SERIAL" = "unknown" ]; then
	kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Android Reboot Manager" \
			--passivepopup="[Canceled]   Check if your device with Android system is connected on your PC and NOT bootloader mode. \
			[1]-Connect your device to PC USB. [2]-Go to device Settings. [3]-Go to Developer options. [4]-Enable USB debugging option. Try again."
	exit 1
  fi
}

check-device

if-cancel-exit() {
    if [ "$?" != "0" ]; then
	  exit 1
    fi
}

progressbar-start() {
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-reboot.png --caption="Android Reboot Manager" --progressbar " " 0)
}

progressbar-close() {
    qdbus $DBUSREF close
}

qdbusinsert-reboot() {
    qdbus $DBUSREF setLabelText "Rebooting $OPERATION device $SERIAL"
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-reboot.png --title="Android Reboot Manager" \
                       --passivepopup="[Finished]   Reboot $OPERATION device $SERIAL.   Elapsed Time: ${ELAPSED_TIME}s"
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-reboot.png --title="Android Reboot Manager" \
                       --passivepopup="[Finished]   Reboot $OPERATION device $SERIAL.   Elapsed Time: ${ELAPSED_TIME}m"
    elif [ "$ELAPSED_TIME" -gt "3599" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-reboot.png --title="Android Reboot Manager" \
                       --passivepopup="[Finished]   Reboot $OPERATION device $SERIAL.   Elapsed Time: ${ELAPSED_TIME}h"
    fi
}

##############################
############ Main ############
##############################

OPERATION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-reboot.png --caption="Android Reboot Manager" \
       --combobox="Select Reboot Operation" Bootloader Recovery System --default System 2> /dev/null)
if-cancel-exit

if [ "$OPERATION" = "System" ]; then
	progressbar-start
    qdbusinsert-reboot
    BEGIN_TIME=$(date +%s)
    adb reboot
    FINAL_TIME=$(date +%s)
    ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
    elapsedtime
 elif [ "$OPERATION" = "Bootloader" ]; then
    progressbar-start
    qdbusinsert-reboot
	BEGIN_TIME=$(date +%s)
	adb reboot bootloader
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
elif [ "$OPERATION" = "Recovery" ]; then
    progressbar-start
    qdbusinsert-reboot
	BEGIN_TIME=$(date +%s)
	adb reboot recovery
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
fi
progressbar-close
echo "Finish Android Reboot Manager Operation" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*
exit 0
