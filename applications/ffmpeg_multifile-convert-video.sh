#!/bin/bash

#################################################################
# For KDE-Services. 2011-2014.									#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>				#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
FILES=""
DESTINATION=""
RESOLUTION=""
CODEC=""
STD=""
DIR=""
FORMAT="0"
TIMEPOSITION=""
FILESIZE=""
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
    
    if [ "$FORMAT" = "" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Convert Video From ($DIR/)" \
                       --passivepopup="[Canceled]   Please select video format. Try again"
        rm -fr /tmp/convert*
        exit 0
    fi
}

if-ffmpeg-cancel() {
    if [ "$?" != "0" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Converting video ${i##*/}" \
                       --passivepopup="[Canceled]   Check the path and filename not contain whitespaces. Check error log $LOGERROR. Try again"
        mv $LOG $DESTINATION/$LOGERROR
        continue
    fi
}

time-position() {
    TIMEPOSITION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" \
                 --inputbox="Enter time position in seconds or hh:mm:ss[.xxx]" 00:00:00.000)
    if-cancel-exit
}

progressbar-start() {
    COUNT="0"
    COUNTFILES=$(echo $FILES|wc -w)
    COUNTFILES=$((++COUNTFILES))
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --progressbar "                                " $COUNTFILES)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Converting Video:  ${i##*/}  [$COUNT/$(($COUNTFILES-1))]"
    qdbus $DBUSREF Set "" value $COUNT
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --title="Converting Video" --passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}s"
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --title="Converting Video" --passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}m"
    elif [ "$ELAPSED_TIME" -gt "3599" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --title="Converting Video" --passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}h"
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

PRIORITY="$(kdialog --geometry 100x100 --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" \
         --radiolist="Choose Scheduling Priority" Highest Highest off High High off Normal Normal on 2> /dev/null)"
if-cancel-exit

if [ "$PRIORITY" = "Highest" ]; then
    kdesu --noignorebutton -d -c "ionice -c 1 -n 0 -p $PID && chrt -op 0 $PID && renice -15 $PID" 2> /dev/null
elif [ "$PRIORITY" = "High" ]; then
    kdesu --noignorebutton -d -c "ionice -c 1 -n 0 -p $PID && chrt -op 0 $PID && renice -10 $PID" 2> /dev/null
elif [ "$PRIORITY" = "Normal" ]; then
    true
fi

FILES=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Source Video Files" --multiple --getopenfilename "$DIR" "*.3GP *.3gp *.AVI *.avi *.DAT \
      *.dat *.DV *.dv *.FLV *.flv *.M2V *.m2v *.M4V *.m4v *.MKV *.mkv *.MOV *.mov *.MP4 *.mp4 *.MPEG *.mpeg *.MPEG4 *.mpeg4 *.MPG *.mpg \
      *.OGV *.ogv *.VOB *.vob *.WEBM *.webm *.WMV *.wmv|All supported files" 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Destination Video Files" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

MODE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Resolution" mobile "Mobile Phones (3GP)" \
     4K "Resolution Ultra-HD (4K)" 2K "Resolution DCI (2K)" 1080 "Resolution Full-HD (1080p)" 720 "Resolution HD (720p)" 480 "Resolution ED (480p)" 360 "Resolution NHD (360p)" 240 "Resolution QVGA (240p)" \
     same "Same Resolution" standards "Standards (VCD - SVCD - DVD)" web "Web (FLV - WebM)" --geometry 250x240 2> /dev/null)
if-cancel-exit
############################### Mobile ###############################
if [ "$MODE" = "mobile" ]; then
    RESOLUTION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Resolution" 128x96 "SQCIF (128x96)" 176x144 "QCIF (176x144)" 320x240 "QVGA (320x240)" \
				352x288 "CIF (352x288)" --geometry 100x195 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$((++COUNT))
        BEGIN_TIME=$(date +%s)
        qdbusinsert
        DST_FILE="${i%.*}"
        ffmpeg -y -i $i -q:v 0 -mbd 2 -s $RESOLUTION -strict experimental -c:a aac -c:v mpeg4 -b:v 1000k -trellis 1 -sn -g 12 \
            "$DESTINATION/${DST_FILE##*/}_$RESOLUTION.3gp" > $LOG 2>&1
        if-ffmpeg-cancel
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
        elapsedtime
    done
fi
############################### 4K ###############################
if [ "$MODE" = "4K" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" avi "AVI" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$((++COUNT))
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s 4095x2160 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_Ultra-HD_4K.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -c:v libx264 -q:v 0 -mbd 2 -s 4k -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_H.264_Ultra-HD_4K.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s 4k -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_Ultra-HD_4K.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
    done
fi
############################### 2K ###############################
if [ "$MODE" = "2K" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" avi "AVI" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$((++COUNT))
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s 2k -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_Ultra-HD_2K.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -c:v libx264 -q:v 0 -mbd 2 -s 2k -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_H.264_Ultra-HD_2K.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s 2k -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_Ultra-HD_2K.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
    done
fi
############################### 1080p ###############################
if [ "$MODE" = "1080" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" avi "AVI" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$((++COUNT))
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s hd1080 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_Full-HD_1080p.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -c:v libx264 -q:v 0 -mbd 2 -s hd1080 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_H.264_Full-HD_1080p.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s hd1080 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_Full-HD_1080p.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
    done
fi
############################### 720p ###############################
if [ "$MODE" = "720" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" avi "AVI" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$((++COUNT))
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s hd720 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_HD_720p.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -c:v libx264 -q:v 0 -mbd 2 -s hd720 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_H.264_HD_720p.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s hd720 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_HD_720p.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
    done
fi
############################### 480p ###############################
if [ "$MODE" = "480" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" avi "AVI" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$((++COUNT))
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s hd480 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_ED_480p.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -c:v libx264 -q:v 0 -mbd 2 -s hd480 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_H.264_ED_480p.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s hd480 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_ED_480p.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
    done
fi
############################### 360p ###############################
if [ "$MODE" = "360" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" avi "AVI" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$((++COUNT))
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s nhd -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_NHD_360p.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -c:v libx264 -q:v 0 -mbd 2 -s nhd -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_H.264_NHD_360p.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s nhd -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_NHD_360p.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
    done
fi
############################### 240p ###############################
if [ "$MODE" = "240" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" avi "AVI" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$((++COUNT))
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s qvga -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_240p.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -c:v libx264 -q:v 0 -mbd 2 -s qvga -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_H.264_240p.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s qvga -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_240p.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
    done
fi
############################### same ###############################
if [ "$MODE" = "same" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" avi "AVI" flv "FLV" mpg "MPEG-1" mpg2 "MPEG-2" mp4-h.264 \
          "MPEG-4 (H.264)" webm "WebM" --geometry 100x165 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$((++COUNT))
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_sr.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -c:v libx264 -q:v 0 -mbd 2 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_H.264_sr.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_sr.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi

        if [ "$CODEC" = "flv" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -c:v flv -b:v 1000k -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_sr.flv" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi

        if [ "$CODEC" = "webm" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -c:v libvpx -b:v 1000k -c:a libvorbis -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_sr.webm" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi

        if [ "$CODEC" = "mpg2" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -c:v mpeg2video -c:a libmp3lame -b:a 192k -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_sr.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
    done
fi
############################### standards ###############################
if [ "$MODE" = "standards" ]; then
    STD=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" \
        --menu="Choose Standard Video Resolution" vcd "VCD" vcd-700 "VCD (700 MB)" svcd "SVCD" \
        svcd-700 "SVCD (700 MB)" dvd "DVD" dvd-4.7 "DVD (4.7 GB)" dvd-8.0 "DVD (8.0 GB)" --geometry 100x185 2> /dev/null)
    if-cancel-exit
    
    if [ "$STD" = "vcd" ] || [ "$STD" = "vcd-700" ];then
        FORMAT=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" \
               --combobox="Enter Video Format" film-vcd ntsc-vcd pal-vcd  --default film-vcd 2> /dev/null)
        if-cancel-exit
    fi
    
    if [ "$STD" = "svcd" ] || [ "$STD" = "svcd-700" ];then
        FORMAT=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" \
               --combobox="Enter Video Format" film-svcd ntsc-svcd pal-svcd --default film-svcd 2> /dev/null)
        if-cancel-exit
    fi
    
    if [ "$STD" = "dvd" ] || [ "$STD" = "dvd-4.7" ] || [ "$STD" = "dvd-8.0" ];then
        FORMAT=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" \
               --combobox="Enter Video Format" film-dvd ntsc-dvd pal-dvd --default film-dvd 2> /dev/null)
        if-cancel-exit
    fi
    
    if [ "$STD" = "vcd-700" ];then
        time-position
        FILESIZE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert To VCD (700 MB)" \
                 --inputbox="Enter the file size limit in bytes, ex: 700 MB = 734003200" 734003200 2> /dev/null)
        if-cancel-exit
    fi
    
    if [ "$STD" = "svcd-700" ];then
        time-position
        FILESIZE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert To SVCD (700 MB)" \
                 --inputbox="Enter the file size limit in bytes, ex: 700 MB = 734003200" 734003200 2> /dev/null)
        if-cancel-exit
    fi
    
    if [ "$STD" = "dvd-4.7" ];then
        time-position
        FILESIZE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert To DVD (4.7 GB)" \
                 --inputbox="Enter the file size limit in bytes, ex: 4.4 GB = 4724464025" 4724464025 2> /dev/null)
        if-cancel-exit
    fi
    
    if [ "$STD" = "dvd-8.0" ];then
        time-position
        FILESIZE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert To DVD (8.0 GB)" \
                 --inputbox="Enter the file size limit in bytes, ex: 8.0 GB = 8589934592" 8589934592 2> /dev/null)
        if-cancel-exit
    fi
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$((++COUNT))
        if [ "$STD" = "vcd" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -target $FORMAT -mbd 2 -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$STD" = "vcd-700" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -target $FORMAT -ss $TIMEPOSITION -fs $FILESIZE -mbd 2 -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$STD" = "svcd" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -target $FORMAT -mbd 2 -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$STD" = "svcd-700" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -target $FORMAT -ss $TIMEPOSITION -fs $FILESIZE -mbd 2 -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$STD" = "dvd" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -target $FORMAT -mbd 2 -trellis 1 -sn -g 12 -ac 6 \
                "$DESTINATION/${DST_FILE##*/}_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$STD" = "dvd-4.7" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -target $FORMAT -ss $TIMEPOSITION -fs $FILESIZE -mbd 2 -trellis 1 -sn -g 12 -ac 6 \
                "$DESTINATION/${DST_FILE##*/}_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
        
        if [ "$STD" = "dvd-8.0" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -target $FORMAT -ss $TIMEPOSITION -fs $FILESIZE -mbd 2 -trellis 1 -sn -g 12 -ac 6 \
                "$DESTINATION/${DST_FILE##*/}_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
        fi
    done
fi
############################### web ###############################
if [ "$MODE" = "web" ]; then
    RESOLUTION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Resolution" 128x96 "SQCIF (128x96)" 176x144 "QCIF (176x144)" 320x240 "QVGA (320x240)" \
				352x288 "CIF (352x288)" 640x360 "NHD (640x360)" 852x480 "ED (852x480)" 1280x720 "HD (1280x720)" 1920x1080 "Full-HD (1920x1080)" 2048x1080 "Ultra-HD 2K (2048x1080)" 4096x2160 "Ultra-HD 4K (4096x2160)" \
				--geometry 200x225 2> /dev/null)
    if-cancel-exit
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" flv "FLV" webm "WebM" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    if [ "$CODEC" = "flv" ];then
	  progressbar-start
	  for i in $FILES; do
            logs
            COUNT=$((++COUNT))
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s $RESOLUTION -c:v flv -b:v 1000k -c:a libmp3lame -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_$RESOLUTION.flv" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
	  done
    fi

	if [ "$CODEC" = "webm" ];then
	  progressbar-start
	  for i in $FILES; do
            logs
            COUNT=$((++COUNT))
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            DST_FILE="${i%.*}"
            ffmpeg -y -i $i -q:v 0 -mbd 2 -s $RESOLUTION -c:v libvpx -b:v 1000k -c:a libvorbis -trellis 1 -sn -g 12 \
                "$DESTINATION/${DST_FILE##*/}_$RESOLUTION.webm" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
            elapsedtime
	  done
	fi
fi

progressbar-close
echo "Finish Convertion All Video" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak* /tmp/convert*

exit 0
