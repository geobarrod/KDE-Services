#!/bin/bash

#################################################################
# For KDE-Services. 2011-2017.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
DESTINATION=""
CODEC=""
DIR=""
FILES=""
PID="$$"
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
VIDEOINFO=/tmp/video.inf
DVD_NAME=""
DBUSREF=""

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        rm -fr $VIDEOINFO
        exit 1
    fi
}

if-dvdauthor-cancel() {
    if [ "$?" != "0" ]; then
        kdialog --icon=ks-error --title="DVD Assembler ($DVD_NAME)" \
                       --passivepopup="[Canceled]   Check the path and filename not contain whitespaces. Check video format errors. Try again"
        exit 1
    fi
}

progressbar-start() {
    DBUSREF=$(kdialog --icon=ks-media-optical-video --title="DVD Assembler" --progressbar "			" /ProcessDialog)
}

progressbar-close() {
    qdbus $DBUSREF close
}

assembling-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Assembling:  $DVD_NAME.iso"
}

creating-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Creating:  $DVD_NAME.iso"
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
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname \
    "$(pwd|grep " ")")")")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")"|\
    sed 's/ /_/g')" 2> /dev/null
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

FILES=$(kdialog --icon=ks-media-optical-video --title="Source Video Files" --multiple \
      --getopenfilename "$DIR" "*.mp2 *.mpe *.mpeg *.mpg *.vob *.MP2 *.MPE *.MPEG *.MPG *.VOB|MPEG-2 files" 2> /dev/null)
if-cancel-exit

for VIDEO in $FILES; do
    ffprobe "$VIDEO" 2> $VIDEOINFO
    CODEC=$(grep -o mpeg2video $VIDEOINFO)
    
    if [ "$CODEC" != "mpeg2video" ]; then
        kdialog --icon=ks-error --title="DVD Assembler" \
                       --passivepopup="[Excluded]   The video file ($VIDEO) isn't MPEG-2 stream." 2> /dev/null
        FILES=$(echo $FILES|sed "s;$VIDEO;;")
        
        if [ "$(echo $FILES)" = "" ]; then
            kdialog --icon=ks-error --title="DVD Assembler" --passivepopup="[Canceled]   Nothing to do." 2> /dev/null
            rm -fr $VIDEOINFO
            exit 1
        fi
        
        rm -fr $VIDEOINFO
    fi
done

DVD_NAME=$(kdialog --icon=ks-media-optical-video --title="DVD Assembler" --inputbox="Enter DVD name without whitespaces." 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=ks-media-optical-video --title="Destination DVD" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

progressbar-start

assembling-qdbusinsert

BEGIN_TIME=$(date +%s)

dvdauthor -tf $FILES -O $DESTINATION/$DVD_NAME
if-dvdauthor-cancel

creating-qdbusinsert

genisoimage -R -J -o $DESTINATION/$DVD_NAME.iso $DESTINATION/$DVD_NAME

rm -fr $DESTINATION/$DVD_NAME
progressbar-close

FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))

if [ "$ELAPSED_TIME" -lt "60" ]; then
    kdialog --icon=ks-media-optical-video --title="DVD Assembler" \
                   --passivepopup="[Finished]   $DVD_NAME.iso    Elapsed Time: ${ELAPSED_TIME}s"
elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
    ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
    kdialog --icon=ks-media-optical-video --title="DVD Assembler" \
                   --passivepopup="[Finished]   $DVD_NAME.iso   Elapsed Time: ${ELAPSED_TIME}m"
elif [ "$ELAPSED_TIME" -gt "3599" ]; then
    ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
    kdialog --icon=ks-media-optical-video --title="DVD Assembler" \
                   --passivepopup="[Finished]   $DVD_NAME.iso   Elapsed Time: ${ELAPSED_TIME}h"
fi

echo "Finish DVD Assembler" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*

exit 0
