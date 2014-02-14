#!/bin/bash

#################################################################
# For KDE-Services. 2011-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
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
    LOG="/tmp/$(basename $i).log"
    LOGERROR="$(basename $i).err"
    rm -f $LOGERROR
}

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        rm -fr /tmp/convert*
        exit 0
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
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Converting video $(basename $i)" \
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
    COUNTFILES=$(expr $COUNTFILES + 1)
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --progressbar "                                " $COUNTFILES)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Converting Video:  $(basename $i)  [$COUNT/$(expr $COUNTFILES - 1)]"
    qdbus $DBUSREF Set "" value $COUNT
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --title="Converting Video" --passivepopup="[Finished]   $(basename $i)   Elapsed Time: $ELAPSED_TIME s."
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --title="Converting Video" --passivepopup="[Finished]   $(basename $i)   Elapsed Time: $ELAPSED_TIME m."
    elif [ "$ELAPSED_TIME" -gt "3599" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --title="Converting Video" --passivepopup="[Finished]   $(basename $i)   Elapsed Time: $ELAPSED_TIME h."
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
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname\
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
DIR=$(pwd)

mv "$(pwd|grep " ")" "$(pwd|grep " "|sed 's/ /_/g')" 2> /dev/null

if [ "$?" != "0" ]; then
    cd ./
else
    cd "$(pwd|grep " "|sed 's/ /_/g')"
    DIR=$(pwd)
fi

RENAMETMP=$(ls *.mpg *.mpeg *.mpeg4 *.mp4 *.mov *.flv *.3gp *.avi *.dat *.vob *.m2v *.m4v *.mkv *.wmv *.ogv *.dv *.MPG *.MPEG *.MPEG4 *.MP4 \
          *.MOV *.FLV *.3GP *.AVI *.DAT *.VOB *.M2V *.M4V *.MKV *.WMV *.OGV *.DV 2> /dev/null|grep " " > /tmp/convert.rename)

RENAME=$(cat /tmp/convert.rename)

for i in $RENAME; do
    mv *$i* $(ls *$i*|sed 's/ /_/g')
done

PRIORITY="$(kdialog --geometry 100x150 --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" \
         --radiolist="Choose Scheduling Priority" Highest Highest off High High off Normal Normal on Low Low off Lowest Lowest off \
         2> /dev/null)"
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

FILES=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Source Video Files" --multiple --getopenfilename "$DIR" "*.3GP *.3gp *.AVI *.avi *.DAT \
      *.dat *.DV *.dv *.FLV *.flv *.M2V *.m2v *.M4V *.m4v *.MKV *.mkv *.MOV *.mov *.MP4 *.mp4 *.MPEG *.mpeg *.MPEG4 *.mpeg4 *.MPG *.mpg \
      *.OGV *.ogv *.VOB *.vob *.WMV *.wmv|All supported files" 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Destination Video Files" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

MODE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Mode" mobile "Mobile Phones (3GP)" \
     4K "Resolution Ultra-HD (4K)" 2K "Resolution Ultra-HD (2K)" 1080 "Resolution Full-HD (1080p)" 720 "Resolution HD (720p)" 480 "Resolution ED (480p)" 240 "Resolution 240p" \
     same "Same Resolution" standards "Standards (VCD - SVCD - DVD)" web "Web (FLV)" --geometry 250x225 2> /dev/null)
if-cancel-exit
############################### Mobile ###############################
if [ "$MODE" = "mobile" ]; then
    RESOLUTION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Resolution" 128x96 128x96 176x144 176x144 \
               352x288 352x288 --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        BEGIN_TIME=$(date +%s)
        qdbusinsert
        ffmpeg -y -i $i -qscale 0 -mbd 2 -s $RESOLUTION -strict experimental -acodec aac -vcodec mpeg4 -vb 1000k -trellis 1 -sn -g 12 \
            "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$RESOLUTION.3gp" > $LOG 2>&1
        if-ffmpeg-cancel
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
        elapsedtime
    done
fi
############################### 4K ###############################
if [ "$MODE" = "4K" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" avi "AVI" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s 4095x2160 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_Ultra-HD_4K.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -vcodec libx264 -qscale 0 -mbd 2 -s 4k -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_H.264_Ultra-HD_4K.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s 4k -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_Ultra-HD_4K.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
    done
fi
############################### 2K ###############################
if [ "$MODE" = "2K" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" avi "AVI" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s 2k -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_Ultra-HD_2K.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -vcodec libx264 -qscale 0 -mbd 2 -s 2k -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_H.264_Ultra-HD_2K.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s 2k -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_Ultra-HD_2K.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
    done
fi
############################### 1080p ###############################
if [ "$MODE" = "1080" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" avi "AVI" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s hd1080 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_Full-HD_1080p.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -vcodec libx264 -qscale 0 -mbd 2 -s hd1080 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_H.264_Full-HD_1080p.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s hd1080 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_Full-HD_1080p.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
    done
fi
############################### 720p ###############################
if [ "$MODE" = "720" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" avi "AVI" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s hd720 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_HD_720p.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -vcodec libx264 -qscale 0 -mbd 2 -s hd720 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_H.264_HD_720p.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s hd720 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_HD_720p.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
    done
fi
############################### 480p ###############################
if [ "$MODE" = "480" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" avi "AVI" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s hd480 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_ED_480p.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -vcodec libx264 -qscale 0 -mbd 2 -s hd480 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_H.264_ED_480p.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s hd480 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_ED_480p.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
    done
fi
############################### 240p ###############################
if [ "$MODE" = "240" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" avi "AVI" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s qvga -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_240p.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -vcodec libx264 -qscale 0 -mbd 2 -s qvga -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_H.264_240p.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -s qvga -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_240p.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
    done
fi
############################### same ###############################
if [ "$MODE" = "same" ]; then
    CODEC=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Video Codec" mpg "MPEG-1" mp4-h.264 \
          "MPEG-4 (H.264)" avi "AVI" --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        if [ "$CODEC" = "mpg" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_sr.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "mp4-h.264" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -vcodec libx264 -qscale 0 -mbd 2 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_H.264_sr.mp4" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$CODEC" = "avi" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -qscale 0 -mbd 2 -acodec libmp3lame -ab 192k -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_sr.avi" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
    done
fi
############################### standards ###############################
if [ "$MODE" = "standards" ]; then
    STD=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" \
        --menu="Choose Video Standard" vcd "VCD" vcd-700 "VCD (700 MB)" svcd "SVCD" \
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
        COUNT=$(expr $COUNT + 1)
        if [ "$STD" = "vcd" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -target $FORMAT -mbd 2 -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$STD" = "vcd-700" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -ss $TIMEPOSITION -fs $FILESIZE -i $i -target $FORMAT -mbd 2 -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$STD" = "svcd" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -target $FORMAT -mbd 2 -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$STD" = "svcd-700" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -ss $TIMEPOSITION -fs $FILESIZE -i $i -target $FORMAT -mbd 2 -trellis 1 -sn -g 12 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$STD" = "dvd" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -i $i -target $FORMAT -mbd 2 -trellis 1 -sn -g 12 -ac 6 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$STD" = "dvd-4.7" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -ss $TIMEPOSITION -fs $FILESIZE -i $i -target $FORMAT -mbd 2 -trellis 1 -sn -g 12 -ac 6 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
        
        if [ "$STD" = "dvd-8.0" ];then
            BEGIN_TIME=$(date +%s)
            qdbusinsert
            ffmpeg -y -ss $TIMEPOSITION -fs $FILESIZE -i $i -target $FORMAT -mbd 2 -trellis 1 -sn -g 12 -ac 6 \
                "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$FORMAT.mpg" > $LOG 2>&1
            if-ffmpeg-cancel
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            elapsedtime
        fi
    done
fi
############################### web ###############################
if [ "$MODE" = "web" ]; then
    RESOLUTION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-video.png --caption="Convert Video From Here" --menu="Choose Resolution" 128x96 128x96 176x144 176x144 \
               352x288 352x288 --geometry 100x100 2> /dev/null)
    if-cancel-exit
    
    progressbar-start
    
    for i in $FILES; do
        logs
        COUNT=$(expr $COUNT + 1)
        BEGIN_TIME=$(date +%s)
        qdbusinsert
        ffmpeg -y -i $i -qscale 0 -mbd 2 -s $RESOLUTION -vcodec flv -vb 1000k -acodec libmp3lame -trellis 1 -sn -g 12 \
            "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$RESOLUTION.flv" > $LOG 2>&1
        if-ffmpeg-cancel
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
        elapsedtime
    done
fi

progressbar-close
echo "Finish Convertion All Video" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak* /tmp/convert*

exit 0
