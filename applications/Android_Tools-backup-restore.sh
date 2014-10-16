#!/bin/bash

#################################################################
# For KDE-Services. 2014.										#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>				#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

if [ "$(pidof adb)" = "" ]; then
  kdesu --caption="Android Backup Manager" --noignorebutton -d adb start-server
fi

DIR=""
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
OPERATION=""
FILE=""
SERIAL=$(adb get-serialno)

###################################
############ Functions ############
###################################

check-device() {
  if [ "$SERIAL" = "unknown" ]; then
	kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Android Backup Manager" \
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

if-adb-exit() {
    if [ "$?" = "141" ]; then
	  kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Android Backup Manager" --passivepopup="[Canceled]   $OPERATION device $SERIAL."
	  exit 1
    fi
}

progressbar-start() {
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-backup-restore.png --caption="Android Backup Manager" --progressbar " " 0)
}

progressbar-close() {
    qdbus $DBUSREF close
}

qdbusinsert-backup() {
    qdbus $DBUSREF setLabelText "Backup all device's data to $FILE"
}

qdbusinsert-restore() {
    qdbus $DBUSREF setLabelText "Restore all device's data from $FILE"
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-backup-restore.png --title="Android Backup Manager" \
                       --passivepopup="[Finished]   $OPERATION device $SERIAL.   Elapsed Time: ${ELAPSED_TIME}s"
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-backup-restore.png --title="Android Backup Manager" \
                       --passivepopup="[Finished]   $OPERATION device $SERIAL.   Elapsed Time: ${ELAPSED_TIME}m"
    elif [ "$ELAPSED_TIME" -gt "3599" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-backup-restore.png --title="Android Backup Manager" \
                       --passivepopup="[Finished]   $OPERATION device $SERIAL.   Elapsed Time: ${ELAPSED_TIME}h"
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

PRIORITY="$(kdialog --geometry 100x150 --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-backup-restore.png --caption="Android Backup Manager" \
         --radiolist="Choose Scheduling Priority" Highest Highest off High High off Normal Normal on Low Low off Lowest Lowest off 2> /dev/null)"
if-cancel-exit

if [ "$PRIORITY" = "Highest" ]; then
    kdesu --noignorebutton -d -c "ionice -c 1 -n 0 -p $PID && chrt -op 0 $PID && renice -15 $PID" 2> /dev/null
elif [ "$PRIORITY" = "High" ]; then
    kdesu --noignorebutton -d -c "ionice -c 1 -n 0 -p $PID && chrt -op 0 $PID && renice -10 $PID" 2> /dev/null
elif [ "$PRIORITY" = "Normal" ]; then
    true
elif [ "$PRIORITY" = "Low" ]; then
    kdesu --noignorebutton -d -c "renice 10 $PID" 2> /dev/null
elif [ "$PRIORITY" = "Lowest" ]; then
    kdesu --noignorebutton -d -c "renice 15 $PID" 2> /dev/null
fi

OPERATION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-backup-restore.png --caption="Android Backup Manager" \
       --combobox="Select Operation" Backup Restore --default Backup 2> /dev/null)
if-cancel-exit

if [ "$OPERATION" = "Backup" ]; then
	DESTINATION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-backup-restore.png --title="Android Backup Manager" --caption="Backup File Destination" --getexistingdirectory "$DIR" 2> /dev/null)
	if-cancel-exit
	progressbar-start
	kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-backup-restore.png --title="Android Backup Manager" --passivepopup="Now unlock your device and confirm the backup operation."
	FILE="Android_device_${SERIAL}_backup-$(date +%Y%m%d_%H%M%S).abk"
	qdbusinsert-backup
	BEGIN_TIME=$(date +%s)
	adb backup -all -shared -f $DESTINATION/$FILE
	check-device
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
elif [ "$OPERATION" = "Restore" ]; then
	FILE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-backup-restore.png --title="Android Backup Manager" --caption="Select Android Backup File" --getopenfilename "$DIR" "*.AB *.ab *.ABK *.abk|*.ab, *.abk" 2> /dev/null)
	if-cancel-exit
    progressbar-start
	qdbusinsert-restore
	kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-android-backup-restore.png --title="Android Backup Manager" --passivepopup="Now unlock your device and confirm the restore operation."
	BEGIN_TIME=$(date +%s)
	adb restore $FILE
	check-device
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
fi
progressbar-close
echo "Finish Android Backup Manager Operation" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*
exit 0
