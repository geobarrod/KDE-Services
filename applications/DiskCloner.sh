#!/bin/bash

#################################################################
# For KDE-Services. 2014-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
DIR=""
DEVICE=""
DESTINATION=""
SIZE=""
LABEL=""
STERR=/tmp/dd.err

###################################
############ Functions ############
###################################

if-cancel-exit() {
  if [ "$?" != "0" ] || [ "$DEVICE" == "" ]; then
	exit 1
  fi
}
if-dd-error() {
  if [ "$?" != "0" ]; then
	kdialog --icon=ks-error --title="DiskCloner" --passivepopup="[Canceled]   $(cat $STERR). Try again"
	qdbus $DBUSREF close
	eject
	exit 1
  fi
}
progressbar-start() {
  DBUSREF=$(kdialog --icon=ks-media-optical-clone --title="DiskCloner" --progressbar " " 0)
}

qdbusinsert() {
	qdbus $DBUSREF setLabelText "Cloning $DEVICE to $DESTINATION/$LABEL.iso"
}

progressbar-close() {
  qdbus $DBUSREF close
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

if [ "$DIR" == "/usr/share/applications" ]; then
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
qdbusinsert
BEGIN_TIME=$(date +%s)
dd bs=2048 if=$DEVICE of="$DESTINATION/$LABEL.iso" 2> $STERR
if-dd-error
FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
progressbar-close
echo "Finish Media Optical Clone" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak* $STERR
elapsedtime
eject

exit 0
