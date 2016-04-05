#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.									#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>				#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
DESTINATION=""
DIR=""
CPUCORE=$(grep "cpu cores" /proc/cpuinfo|sort -u|awk -F: '{print $2}')
PID="$$"
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
COUNT=""
COUNTFILES=""
LOG=""
LOGERROR=""

###################################
############ Functions ############
###################################

logs() {
    LOG="/tmp/${i##*/}.log"
    LOGERROR="${i##*/}.err"
    rm -f $LOGERROR
}

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        rm -fr /tmp/convert*
        exit 1
    fi
}

if-ffmpeg-cancel() {
    if [ "$?" != "0" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Attaching ${COVER##*/} to ${i##*/}" \
                       --passivepopup="[Canceled]   Check the path and filename not contain whitespaces. Check error log $LOGERROR. Try again"
        mv $LOG $DESTINATION/$LOGERROR
        continue
    fi
}

progressbar-start() {
    COUNT="0"
    COUNTFILES=$(echo $FILES|wc -w)
    COUNTFILES=$((++COUNTFILES))
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio-mp3-attach-cover.png --caption="Attach Cover to MP3 Files" --progressbar "				" $COUNTFILES)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Attaching ${COVER##*/} to:  ${i##*/}  [$COUNT/$((COUNTFILES-1))]"
    qdbus $DBUSREF Set "" value $COUNT
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio-mp3-attach-cover.png --title="Attach Cover to MP3 Files" \
                       --passivepopup="[Finished]  ${i##*/}   Elapsed Time: ${ELAPSED_TIME}s"
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio-mp3-attach-cover.png --title="Attach Cover to MP3 Files" \
                       --passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}m"
    elif [ "$ELAPSED_TIME" -gt "3599" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio-mp3-attach-cover.png --title="Attach Cover to MP3 Files" \
                       --passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}h"
    fi
    rm -f $LOG
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

PRIORITY="$(kdialog --geometry 100x100 --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio-mp3-attach-cover.png --caption="Attach Cover to MP3 Files" \
         --radiolist="Choose Scheduling Priority" Highest Highest off High High off Normal Normal on 2> /dev/null)"
if-cancel-exit

if [ "$PRIORITY" = "Highest" ]; then
    kdesu --noignorebutton -d -c "ionice -c 1 -n 0 -p $PID && chrt -op 0 $PID && renice -15 $PID" 2> /dev/null
elif [ "$PRIORITY" = "High" ]; then
    kdesu --noignorebutton -d -c "ionice -c 1 -n 0 -p $PID && chrt -op 0 $PID && renice -10 $PID" 2> /dev/null
elif [ "$PRIORITY" = "Normal" ]; then
    true
fi

COVER=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio-mp3-attach-cover.png --caption="Picture File" \
        --getopenfilename "$DIR" "*.bmp *.gif *.jp2 *.jpeg *.jpg *.png *.tif *.tiff *.BMP *.GIF *.JP2 *.JPEG *.JPG *.PNG *.TIF *.TIFF|All supported files" 2> /dev/null)
if-cancel-exit

FILES=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio-mp3-attach-cover.png --caption="Audio MP3 Files" --multiple --getopenfilename "$DIR" "*.MP3 *.mp3|All supported files" 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio-mp3-attach-cover.png --caption="Destination Audio Files" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

progressbar-start
for i in $FILES; do
    logs
    COUNT=$((++COUNT))
    BEGIN_TIME=$(date +%s)
    qdbusinsert
    DST_FILE="${i%.*}"
    ffmpeg -y -i $i -i $COVER -c copy -map 0 -map 1 -metadata:s:v title="Album Cover Art" -metadata:s:v comment="Cover Art (Front)" "$DESTINATION/${DST_FILE##*/}_CoverArt.mp3" > $LOG 2>&1
    if-ffmpeg-cancel
    FINAL_TIME=$(date +%s)
    ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
    elapsedtime
done
progressbar-close
echo "Finish Attaching Cover to Audio Files" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak* /tmp/convert*

exit 0
