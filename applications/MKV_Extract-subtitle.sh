#!/bin/bash

#################################################################
# For KDE-Services. 2012-2017.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
MKV="$1"
PID="$$"
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        rm -fr /tmp/mkvinfo*
        exit 1
    fi
}

progressbar-start() {
    DBUSREF=$(kdialog --icon=ks-extracting-subs --title="MKV Extract Subtitle" --progressbar "                               " /ProcessDialog)
}

progressbar-close() {
qdbus $DBUSREF close
}

qdbusinsert() {
qdbus $DBUSREF setLabelText "Extracting:  ${MKV##*/}"
}

##############################
############ Main ############
##############################

cd "${MKV%/*}"
ffprobe "$MKV" 2> /tmp/mkvinfo
grep -e 'Subtitle' /tmp/mkvinfo|awk -F : '{print $1,$2,$3}' > /tmp/mkvinfo2
cat /tmp/mkvinfo2|sed 's/^    //g' > /tmp/mkvinfo3
cat /tmp/mkvinfo3|sed 's/ /_/g' > /tmp/mkvinfo4
TID=$(kdialog --icon=ks-extracting-subs --title="MKV Extract Subtitle" \
    --radiolist="Select Subtitle For Extract" $(cat -n /tmp/mkvinfo4 |sed 's/$/ off/g'))
if-cancel-exit

progressbar-start
qdbusinsert
BEGIN_TIME=$(date +%s)
mkvextract tracks "$MKV" $((TID+1)):"${MKV%.*}_$(cat -n /tmp/mkvinfo4|grep -w $TID|awk -F_ '{print $3}'|sed 's/[[:digit:]]//').srt"
progressbar-close
FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))

if [ "$ELAPSED_TIME" -lt "60" ]; then
    kdialog --icon=ks-extracting-subs --title="MKV Extract Subtitle" --passivepopup="[Finished]   ${MKV##*/}   Elapsed Time: ${ELAPSED_TIME}s"
elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
    ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
    kdialog --icon=ks-extracting-subs --title="MKV Extract Subtitle" --passivepopup="[Finished]   ${MKV##*/}   Elapsed Time: ${ELAPSED_TIME}m"
elif [ "$ELAPSED_TIME" -gt "3599" ]; then
    ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
    kdialog --icon=ks-extracting-subs --title="MKV Extract Subtitle" --passivepopup="[Finished]   ${MKV##*/}   Elapsed Time: ${ELAPSED_TIME}h"
fi

echo "Finish Extracting Subtitle" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak* /tmp/mkvinfo*

exit 0
