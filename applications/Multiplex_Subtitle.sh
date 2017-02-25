#!/bin/bash

#################################################################
# For KDE-Services. 2012-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
VIDEO="$1"
TMPFILE=/tmp/multiplex-subtitle.xml
LOG=multiplex-subtitle.log
VIDEOINFO=/tmp/videoinfo
PID="$$"
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        rm -fr $TMPFILE $LOG $VIDEOINFO
        exit 1
    fi
}

progressbar-start() {
    DBUSREF=$(kdialog --icon=ks-multiplexing-subs --title="Multiplex Subtitle" --progressbar "                                   " /ProcessDialog)
}

progressbar-close() {
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Multiplexing:  ${VIDEO##*/}"
}

##############################
############ Main ############
##############################

cd "${VIDEO%/*}"

ffprobe "$VIDEO" 2> $VIDEOINFO
CODEC=$(grep -o mpeg2video $VIDEOINFO)

if [ "$CODEC" != "mpeg2video" ]; then
    kdialog --icon=ks-error --title="Multiplex Subtitle" --passivepopup="[Canceled]   The video file isn't MPEG-2 stream."
    rm -fr $VIDEOINFO
else
    DIR="$(pwd)"

    SUBTITLE=$(kdialog --icon=ks-multiplexing-subs --title="Text Based Subtitle" \
             --getopenfilename "$DIR" "*.aqt *.ass *.js *.jss *.rt *.smi *.srt *.ssa *.sub *.txt" 2> /dev/null)
    if-cancel-exit

    FILEENCODE=$(file -b --mime-encoding $SUBTITLE|tr a-z A-Z)
    recode $FILEENCODE..UTF-8 $SUBTITLE

    cat > $TMPFILE << EOF
<subpictures format="NTSC">
  <stream>
    <textsub filename="$SUBTITLE"
    characterset="UTF-8"
    horizontal-alignment="center"
    left-margin="57"
    right-margin="57"
    bottom-margin="23"
    top-margin="23"
    fontsize="22.0"
    force="yes"
    vertical-alignment="bottom" />
  </stream>
</subpictures>
EOF

    DESTINATION="${VIDEO%.*}_subtitled.mpg"

    progressbar-start
    qdbusinsert
    BEGIN_TIME=$(date +%s)

    spumux "$TMPFILE" < "$VIDEO" > "${VIDEO%.*}_subtitled.mpg" 2> $LOG
    EXIT=$?

    if [ "$EXIT" = "0" ];then
        progressbar-close
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))

        if [ "$ELAPSED_TIME" -lt "60" ]; then
            kdialog --icon=ks-multiplexing-subs --title="Multiplex Subtitle" \
                           --passivepopup="[Finished]   ${VIDEO##*/}   Elapsed Time: ${ELAPSED_TIME}s"
        elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
            kdialog --icon=ks-multiplexing-subs --title="Multiplex Subtitle" \
                           --passivepopup="[Finished]   ${VIDEO##*/}   Elapsed Time: ${ELAPSED_TIME}m"
        elif [ "$ELAPSED_TIME" -gt "3599" ]; then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
            kdialog --icon=ks-multiplexing-subs --title="Multiplex Subtitle" \
                           --passivepopup="[Finished]   ${VIDEO##*/}   Elapsed Time: ${ELAPSED_TIME}h"
        fi

        echo "Finish Multiplexing Subtitle" > /tmp/speak
        text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
        play /tmp/speak.wav
        rm -fr /tmp/speak* $TMPFILE $LOG $VIDEOINFO
    else
        progressbar-close
        kdialog --icon=ks-error --title="Multiplex Subtitle" \
                       --passivepopup="[Canceled]   See $LOG file. The encoding of the subtitle file have to be UTF-8."
        rm -fr $TMPFILE $VIDEOINFO
    fi
fi

exit 0
