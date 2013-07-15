#!/bin/bash

#################################################################
# For KDE Services. 2011-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
DESTINATION=""
DIR=""
CPUCORE=$(grep "cpu cores" /proc/cpuinfo|sort -u|awk -F : '{print $2}')
PID="$$"
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
COUNT=""
COUNTFILES=""
LOG=""
LOGERROR=""
FORMAT=""

###################################
############ Functions ############
###################################

logs() {
    LOG="/tmp/$(basename $i).log"
    LOGERROR="$(basename $i).err"
    rm -f $LOGERROR
}

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        rm -fr /tmp/convert*
        exit 0
    fi
}

if-ffmpeg-cancel() {
    if [ "$?" != "0" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Extracting audio track from $(basename $i) to $FORMAT" \
                       --passivepopup="[Canceled]   Check the path and filename not contain whitespaces. Check error log $LOGERROR. Try again"
        mv $LOG $DESTINATION/$LOGERROR
        continue
    fi
}

progressbar-start() {
    COUNT="0"
    COUNTFILES=$(echo $FILES|wc -w)
    COUNTFILES=$(expr $COUNTFILES + 1)
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio.png --caption="[Extract|Convert] Audio Track" --progressbar "				" $COUNTFILES)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "[Extract|Convert] Audio Track:  $(basename $i)  [$COUNT/$(expr $COUNTFILES - 1)]"
    qdbus $DBUSREF Set "" value $COUNT
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio.png --title="[Extract|Convert] Audio Track" \
                       --passivepopup="[Finished]  $(basename $i)   Elapsed Time: $ELAPSED_TIME s."
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio.png --title="[Extract|Convert] Audio Track" \
                       --passivepopup="[Finished]   $(basename $i)   Elapsed Time: $ELAPSED_TIME m."
    elif [ "$ELAPSED_TIME" -gt "3599" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio.png --title="[Extract|Convert] Audio Track" \
                       --passivepopup="[Finished]   $(basename $i)   Elapsed Time: $ELAPSED_TIME h."
    fi
    rm -f $LOG
}

##############################
############ Main ############
##############################

DIR=$1
cd "$DIR"

mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")")" \
    "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")"|\
    sed 's/ /_/g')" 2> /dev/null
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
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname \
    "$(dirname "$(pwd|grep " ")")")")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname \
    "$(pwd|grep " ")")")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")" "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(pwd|grep " ")")")" "$(dirname "$(dirname "$(pwd|grep " ")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(pwd|grep " ")")" "$(dirname "$(pwd|grep " ")"|sed 's/ /_/g')" 2> /dev/null
cd ./
DIR=$(pwd)

mv "$(pwd|grep " ")" "$(pwd|grep " "|sed 's/ /_/g')" 2> /dev/null

if [ "$?" != "0" ]; then
    cd ./
else
    cd "$(pwd|grep " "|sed 's/ /_/g')"
    DIR=$(pwd)
fi

RENAMETMP=$(ls *.mpg *.mpeg *.mpeg4 *.mp3 *.mp4 *.mov *.flv *.3gp *.avi *.dat *.vob *.m2v *.m4v *.mkv *.wmv *.wma *.flac *.ogg *.ogv *.wav \
          *.MPG *.MPEG *.MPEG4 *.MP3 *.MP4 *.MOV *.FLV *.3GP *.AVI *.DAT *.VOB *.M2V *.M4V *.MKV *.WMV *.WMA *.FLAC *.OGG *.OGV *.WAV \
          2> /dev/null|grep " " > /tmp/convert.rename)

RENAME=$(cat /tmp/convert.rename)

for i in $RENAME; do
    mv *$i* $(ls *$i*|sed 's/ /_/g')
done

PRIORITY="$(kdialog --geometry=100x150+10240 --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio.png --caption="[Extract|Convert] Audio Track" \
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

FILES=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio.png --caption="[Video|Audio] Files" --multiple --getopenfilename "$DIR" "*.3GP *.3gp *.AVI *.avi *.DAT \
      *.dat *.FLAC *.flac *.FLV *.flv *.M2V *.m2v *.M4V *.m4v *.MKV *.mkv *.MOV *.mov *.MP3 *.mp3 *.MP4 *.mp4 *.MPEG *.mpeg *.MPEG4 *.mpeg4 \
      *.MPG *.mpg *.OGG *.ogg *.OGV *.ogv *.VOB *.vob *.WAV *.wav *.WMA *.wma *.WMV *.wmv|All supported files" 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio.png --caption="Destination Audio Files" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

FORMAT=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio.png --caption="[Extract|Convert] Audio Track" \
       --combobox="Choose Audio Encoder" FLAC MP3 --default MP3 2> /dev/null)
if-cancel-exit
    
if [ "$FORMAT" = "MP3" ]; then
    MODE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-audio.png --caption="[Extract|Convert] Audio Track" \
     --combobox="Choose Audio Bitrate in b/s" 320k 256k 192k 128k 64k --default 320k 2> /dev/null)
    if-cancel-exit
    progressbar-start

    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        BEGIN_TIME=$(date +%s)
        qdbusinsert
        ffmpeg -y -i $i -acodec libmp3lame -ab $MODE "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$MODE.mp3" > $LOG 2>&1
        if-ffmpeg-cancel
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
        elapsedtime
    done
elif [ "$FORMAT" = "FLAC" ]; then
    progressbar-start

    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        BEGIN_TIME=$(date +%s)
        qdbusinsert
        ffmpeg -y -i $i -acodec flac "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.flac" > $LOG 2>&1
        if-ffmpeg-cancel
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
        elapsedtime
    done
fi
progressbar-close
echo "Finish Extracting Audio Track From All Files" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak* /tmp/convert*

exit 0
