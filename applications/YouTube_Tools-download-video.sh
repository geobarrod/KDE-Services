#!/bin/bash

#################################################################
# For KDE-Services. 2012-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
DIR=""
VCODE=""
DESTINATION=""
QUALITY=""
RATE_LIMIT=""
EXIT=""
VID=""
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
ATTEMPT=""
PROGRAM=""
DBUSREF=""
COUNT=""
COUNTFILES=""
FILENAME=""
SIZE=""
INIT_TIME=""
LAST_TIME=""
TOTAL_TIME=""

###################################
############ Functions ############
###################################

attempt-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Downloading:  $FILENAME $VID MP4 $SIZE  [$COUNT/$(expr $COUNTFILES - 1)] Reattempt: $ATTEMPT"
    qdbus $DBUSREF Set "" value $COUNT
}

if-cancel-exit() {
    if [ "$?" != "0" ];then
    exit 0
    fi
}

youtube-error() {
    if [ "$EXIT" != "0" ];then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Download YouTube Video" \
                       --passivepopup="[Error]   $FILENAME $VID MP4 $SIZE   Check network connection or YouTube Video Code."
        echo "$VID" >> !!!_YouTube-Video-Code.err
        sed -i 's/hyphen//' !!!_YouTube-Video-Code.err
        
        for ATTEMPT in {1..100}; do
            attempt-qdbusinsert
            $PROGRAM
            EXIT=$?
            
            if [ "$EXIT" = "0" ];then
                sed -i "s;$VID;;g" !!!_YouTube-Video-Code.err
                
                if [ "$(wc -w !!!_YouTube-Video-Code.err|awk '{print $1}')" = "0" ];then
                    rm -f !!!_YouTube-Video-Code.err
                fi
            fi
        done
    
        continue
    fi
}

finished() {
    if [ "$EXIT" = "0" ];then
        if [ "$ELAPSED_TIME" -lt "60" ];then
            kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --title="Download YouTube Video" \
                           --passivepopup="[Finished]   $FILENAME $VID MP4 $SIZE   Elapsed Time: $ELAPSED_TIME s."
        elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ];then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
            kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --title="Download YouTube Video" \
                           --passivepopup="[Finished]   $FILENAME $VID MP4 $SIZE   Elapsed Time: $ELAPSED_TIME m."
        elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ];then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
            kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --title="Download YouTube Video" \
                           --passivepopup="[Finished]   $FILENAME $VID MP4 $SIZE   Elapsed Time: $ELAPSED_TIME h."
        elif [ "$ELAPSED_TIME" -gt "86399" ]; then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
            kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --title="Download YouTube Video" \
                           --passivepopup="[Finished]   $FILENAME $VID MP4 $SIZE   Elapsed Time: $ELAPSED_TIME d."
        fi
    fi
}

progressbar-start() {
    COUNT="0"
    COUNTFILES=$(echo $VCODE|wc -w)
    COUNTFILES=$(expr $COUNTFILES + 1)
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --caption="Download YouTube Video" --progressbar "                      " $COUNTFILES)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
}

checking-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Checking Availability:  $VID  [$COUNT/$(expr $COUNTFILES - 1)]"
    qdbus $DBUSREF Set "" value $COUNT
}

size-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Checking Frame Size:  $VID  [$COUNT/$(expr $COUNTFILES - 1)]"
    qdbus $DBUSREF Set "" value $COUNT
}

download-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Downloading:  $FILENAME $VID MP4 $SIZE  [$COUNT/$(expr $COUNTFILES - 1)]"
    qdbus $DBUSREF Set "" value $COUNT
}

##############################
############ Main ############
##############################

DIR=$1
cd "$DIR"
DIR=$(pwd)

mkdir -p $HOME/.kde-services
touch $HOME/.kde-services/youtube-video-codes
touch $HOME/.kde-services/youtube-download-rate-limit
sed -i 's/^-/hyphen-/' $HOME/.kde-services/youtube-video-codes
rm -f !!!_YouTube-Video-Code.err

VCODE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --caption="YouTube Video Downloader" \
    --inputbox="Enter YouTube Video Code(s) separated by whitespace. By example in this URL: http://www.youtube.com/watch?v=twepYLbAhNo, \
    the Code is twepYLbAhNo." "$(cat $HOME/.kde-services/youtube-video-codes)" 2> /dev/null)
if-cancel-exit
echo $VCODE > $HOME/.kde-services/youtube-video-codes
sed -i 's/hyphen//g' $HOME/.kde-services/youtube-video-codes

DESTINATION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --caption="Destination YouTube Video(s)" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

QUALITY=$(kdialog --geometry 100x100 --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --caption="YouTube Video Downloader" \
        --radiolist="Select Video Quality" 1080x1920 1080p on 720x1280 720p off 360x640 360p off 2> /dev/null)
if-cancel-exit

RATE_LIMIT=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --caption="YouTube Video Downloader" \
           --inputbox="Enter Download Rate Limit (e.g. 50K or 4.2M)" $(cat $HOME/.kde-services/youtube-download-rate-limit) 2> /dev/null)
if-cancel-exit
echo $RATE_LIMIT > $HOME/.kde-services/youtube-download-rate-limit

cd $DESTINATION
INIT_TIME=$(date +%s)

progressbar-start

VCODE=$(echo $VCODE|sed 's/hyphen//g')

for VID in $VCODE; do
    COUNT=$(expr $COUNT + 1)
    checking-qdbusinsert
    PROGRAM="youtube-dl -F http://www.youtube.com/watch?v=$VID"
    $PROGRAM
    EXIT=$?
    youtube-error
done

if [ "$QUALITY" = "1080x1920" ];then
    COUNT="0"
    
    for VID in $VCODE; do
        COUNT=$(expr $COUNT + 1)
        size-qdbusinsert
        
        if [ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w mp4|grep -o 1080x1920)" = "1080x1920" ];then
            FILENAME=$(youtube-dl -e http://www.youtube.com/watch?v=$VID|sed 's/ /_/g')
            SIZE="1080p"
            download-qdbusinsert
            BEGIN_TIME=$(date +%s)
            PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(stitle\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 37 --max-quality 37 -c -i -R 1000000 \
                    -r $RATE_LIMIT http://www.youtube.com/watch?v=$VID"
            $PROGRAM
            EXIT=$?
            youtube-error
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            finished
        elif [ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w mp4|grep -o 720x1280)" = "720x1280" ];then
            FILENAME=$(youtube-dl -e http://www.youtube.com/watch?v=$VID|sed 's/ /_/g')
            SIZE="720p"
            download-qdbusinsert
            BEGIN_TIME=$(date +%s)
            PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(stitle\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 22 --max-quality 22 -c -i -R 1000000 \
                    -r $RATE_LIMIT http://www.youtube.com/watch?v=$VID"
            $PROGRAM
            EXIT=$?
            youtube-error
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            finished
        elif [ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w mp4|grep -o 360x640)" = "360x640" ];then
            FILENAME=$(youtube-dl -e http://www.youtube.com/watch?v=$VID|sed 's/ /_/g')
            SIZE="360p"
            download-qdbusinsert
            BEGIN_TIME=$(date +%s)
            PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(stitle\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 18 --max-quality 18 -c -i -R 1000000 \
                    -r $RATE_LIMIT http://www.youtube.com/watch?v=$VID"
            $PROGRAM
            EXIT=$?
            youtube-error
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            finished
        fi
    done
elif [ "$QUALITY" = "720x1280" ];then
    COUNT="0"
    
    for VID in $VCODE; do
        COUNT=$(expr $COUNT + 1)
        size-qdbusinsert
        
        if [ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w mp4|grep -o 720x1280)" = "720x1280" ];then
            FILENAME=$(youtube-dl -e http://www.youtube.com/watch?v=$VID|sed 's/ /_/g')
            SIZE="720p"
            download-qdbusinsert
            BEGIN_TIME=$(date +%s)
            PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(stitle\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 22 --max-quality 22 -c -i -R 1000000 \
                    -r $RATE_LIMIT http://www.youtube.com/watch?v=$VID"
            $PROGRAM
            EXIT=$?
            youtube-error
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            finished
        elif [ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w mp4|grep -o 360x640)" = "360x640" ];then
            FILENAME=$(youtube-dl -e http://www.youtube.com/watch?v=$VID|sed 's/ /_/g')
            SIZE="360p"
            download-qdbusinsert
            BEGIN_TIME=$(date +%s)
            PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(stitle\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 18 --max-quality 18 -c -i -R 1000000 \
                    -r $RATE_LIMIT http://www.youtube.com/watch?v=$VID"
            $PROGRAM
            EXIT=$?
            youtube-error
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            finished
        fi
    done
elif [ "$QUALITY" = "360x640" ];then
    COUNT="0"
    
    for VID in $VCODE; do
        COUNT=$(expr $COUNT + 1)
        size-qdbusinsert
        
        if [ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w mp4|grep -o 360x640)" = "360x640" ];then
            FILENAME=$(youtube-dl -e http://www.youtube.com/watch?v=$VID|sed 's/ /_/g')
            SIZE="360p"
            download-qdbusinsert
            BEGIN_TIME=$(date +%s)
            PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(stitle\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 18 --max-quality 18 -c -i -R 1000000 \
                    -r $RATE_LIMIT http://www.youtube.com/watch?v=$VID"
            $PROGRAM
            EXIT=$?
            youtube-error
            FINAL_TIME=$(date +%s)
            ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
            finished
        fi
    done
fi

LAST_TIME=$(date +%s)
TOTAL_TIME=$(echo "$LAST_TIME-$INIT_TIME"|bc)
progressbar-close

if [ "$TOTAL_TIME" -lt "60" ];then
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --caption="YouTube Video Downloader" \
                   --msgbox="The YouTube video(s) download to finished for $(basename $DESTINATION) directory.   Total time: $TOTAL_TIME s." &
elif [ "$TOTAL_TIME" -gt "59" ] && [ "$TOTAL_TIME" -lt "3600" ];then
    TOTAL_TIME=$(echo "$TOTAL_TIME/60"|bc -l|sed 's/...................$//')
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --caption="YouTube Video Downloader" \
                   --msgbox="The YouTube video(s) download to finished for $(basename $DESTINATION) directory.   Total time: $TOTAL_TIME m." &
elif [ "$TOTAL_TIME" -gt "3599" ] && [ "$TOTAL_TIME" -lt "86400" ];then
    TOTAL_TIME=$(echo "$TOTAL_TIME/3600"|bc -l|sed 's/...................$//')
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --caption="YouTube Video Downloader" \
                   --msgbox="The YouTube video(s) download to finished for $(basename $DESTINATION) directory.   Total time: $TOTAL_TIME h." &
elif [ "$TOTAL_TIME" -gt "86399" ]; then
    TOTAL_TIME=$(echo "$TOTAL_TIME/86400"|bc -l|sed 's/...................$//')
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-download-video.png --caption="YouTube Video Downloader" \
                   --msgbox="The YouTube video(s) download to finished for $(basename $DESTINATION) directory.   Total time: $TOTAL_TIME d." &
fi

echo "The YouTube videos download finished" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*

exit 0
