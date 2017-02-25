#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
DIR=""
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
OPERATION=""
PARTITION=""
FILE=""
DATE=$(date +%Y-%m-%d--%H-%M-%S)
LOG=/tmp/abm.log

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" != "0" ]; then
	  exit 1
    fi
}

if [ "$(pidof adb)" = "" ]; then
  kdesu -i ks-android-backup-restore --noignorebutton -d adb start-server
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

if-adb-exit() {
    if [ "$?" = "141" ]; then
	  kdialog --icon=ks-error --title="Android Backup Manager" --passivepopup="[Canceled]   $OPERATION device $SERIAL."
	  exit 1
    fi
}

progressbar-start() {
    DBUSREF=$(kdialog --icon=ks-android-backup-restore --title="Android Backup Manager" --progressbar " " 0)
}

progressbar-close() {
    qdbus $DBUSREF close
}

qdbusinsert-backup-data() {
    qdbus $DBUSREF setLabelText "Backup all device's data to ${FILE##*/}..."
}

qdbusinsert-restore-data() {
    qdbus $DBUSREF setLabelText "Restore all device's data from ${FILE##*/}..."
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=ks-android-backup-restore --title="Android Backup Manager" \
                       --passivepopup="[Finished]   $OPERATION device $SERIAL. $(cat $LOG)  Elapsed Time: ${ELAPSED_TIME}s"
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=ks-android-backup-restore --title="Android Backup Manager" \
                       --passivepopup="[Finished]   $OPERATION device $SERIAL. $(cat $LOG)  Elapsed Time: ${ELAPSED_TIME}m"
    elif [ "$ELAPSED_TIME" -gt "3599" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=ks-android-backup-restore --title="Android Backup Manager" \
                       --passivepopup="[Finished]   $OPERATION device $SERIAL. $(cat $LOG)  Elapsed Time: ${ELAPSED_TIME}h"
    fi
}

##############################
############ Main ############
##############################

DIR=$1
cd "$DIR"

mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")")" \
    "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")"|sed\
    's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")" "$(dirname \
    "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")" "$(dirname "$(dirname \
    "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")" "$(dirname "$(dirname "$(dirname \
    "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname\
    "$(pwd|grep " ")")")")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")"\
    |sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")" "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(pwd|grep " ")")")" "$(dirname "$(dirname "$(pwd|grep " ")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(pwd|grep " ")")" "$(dirname "$(pwd|grep " ")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(pwd|grep " ")" "$(pwd|grep " "|sed 's/ /_/g')" 2> /dev/null
cd ./

for i in *; do
    mv "$i" "${i// /_}" 2> /dev/null
done

DIR="$(pwd)"

if [ "$DIR" == "/usr/share/applications" ]; then
    DIR="~/"
fi

OPERATION=$(kdialog --icon=ks-android-backup-restore --title="Android Backup Manager" \
       --combobox="Select Operation" Backup Restore --default Backup 2> /dev/null)
if-cancel-exit

if [ "$OPERATION" = "Backup" ]; then
	DESTINATION=$(kdialog --icon=ks-android-backup-restore --title="Android Backup Manager - Backup File Destination" --getexistingdirectory "$DIR" 2> /dev/null)
	if-cancel-exit
	progressbar-start
	kdialog --icon=ks-android-backup-restore --title="Android Backup Manager" --passivepopup="Now unlock your device and confirm the backup operation."
	FILE="Android_device_${SERIAL}_full-data-backup_${DATE}.abk"
	qdbusinsert-backup-data
	BEGIN_TIME=$(date +%s)
	adb backup -all -shared -f $DESTINATION/$FILE 2> $LOG
	check-device
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
elif [ "$OPERATION" = "Restore" ]; then
	FILE=$(kdialog --icon=ks-android-backup-restore --title="Android Backup Manager - Select Android Backup File" --getopenfilename "$DIR" "*.AB *.ab *.ABK *.abk|*.ab, *.abk" 2> /dev/null)
	if-cancel-exit
    progressbar-start
	qdbusinsert-restore-data
	kdialog --icon=ks-android-backup-restore --title="Android Backup Manager" --passivepopup="Now unlock your device and confirm the restore operation."
	BEGIN_TIME=$(date +%s)
	adb restore $FILE 2> $LOG
	check-device
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
fi
progressbar-close
echo "Finish Android Backup Manager Operation" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak* $LOG
exit 0
