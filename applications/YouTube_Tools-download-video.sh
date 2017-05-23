#!/bin/bash

#################################################################
# For KDE-Services. 2012-2017.					#
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
WEIGHT=""
INIT_TIME=""
LAST_TIME=""
TOTAL_TIME=""

###################################
############ Functions ############
###################################

attempt-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Downloading:  $FILENAME $VID MPEG-4 $SIZE $WEIGHT  [$COUNT/$(($COUNTFILES-1))] Reattempt: $ATTEMPT"
    qdbus $DBUSREF Set "" value $COUNT
}

if-cancel-exit() {
    if [ "$?" != "0" ];then
    exit 0
    fi
}

youtube-error() {
    if [ "$EXIT" != "0" ];then
        kdialog --icon=ks-error --title="Download YouTube Video" \
                       --passivepopup="[Error]   $FILENAME $VID MPEG-4 $SIZE $WEIGHT   Check network connection or YouTube Video Code."
        echo "$VID" >> !!!_YouTube-Video-Code.err
        sed -i 's/hyphen//' !!!_YouTube-Video-Code.err
        
        for ATTEMPT in {1..10}; do
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
            kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
                           --passivepopup="[Finished]   $FILENAME $VID MPEG-4 $SIZE $WEIGHT   Elapsed Time: ${ELAPSED_TIME}s"
        elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ];then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
            kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
                           --passivepopup="[Finished]   $FILENAME $VID MPEG-4 $SIZE $WEIGHT   Elapsed Time: ${ELAPSED_TIME}m"
        elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ];then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
            kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
                           --passivepopup="[Finished]   $FILENAME $VID MPEG-4 $SIZE $WEIGHT   Elapsed Time: ${ELAPSED_TIME}h"
        elif [ "$ELAPSED_TIME" -gt "86399" ]; then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
            kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
                           --passivepopup="[Finished]   $FILENAME $VID MPEG-4 $SIZE $WEIGHT   Elapsed Time: ${ELAPSED_TIME}d"
        fi
    fi
}

progressbar-start() {
    COUNT="0"
    COUNTFILES=$(echo $VCODE|wc -w)
    COUNTFILES=$((++COUNTFILES))
    DBUSREF=$(kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" --progressbar "                      " $COUNTFILES)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
}

checking-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Checking Availability:  $VID  [$COUNT/$(($COUNTFILES-1))]"
    qdbus $DBUSREF Set "" value $COUNT
}

size-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Checking Frame Size:  $VID  [$COUNT/$(($COUNTFILES-1))]"
    qdbus $DBUSREF Set "" value $COUNT
}

download-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Downloading:  $FILENAME $VID MPEG-4 $SIZE $WEIGHT  [$COUNT/$(($COUNTFILES-1))]"
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

VCODE=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
    --inputbox="Enter YouTube Video Code(s) separated by whitespace. By example in this URL: http://www.youtube.com/watch?v=twepYLbAhNo, \
    the Code is twepYLbAhNo." "$(cat $HOME/.kde-services/youtube-video-codes)" 2> /dev/null)
if-cancel-exit
echo $VCODE > $HOME/.kde-services/youtube-video-codes
sed -i 's/hyphen//g' $HOME/.kde-services/youtube-video-codes

DESTINATION=$(kdialog --icon=ks-youtube-download-video --title="Destination YouTube Video(s)" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

QUALITY=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
        --radiolist="Select Video Quality" 3840x2160 "Ultra HD (4K)" on 2560x1440 "Ultra HD (2K)" off 1920x1080 "Full HD (1080p)" off 1280x720 "HD (720p)" off 854x480 "Full WVGA (480p)" off 640x360 "NHD (360p)" off 2> /dev/null)
if-cancel-exit

RATE_LIMIT=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
           --inputbox="Enter Download Rate Limit (e.g. 50K or 4.2M)" $(cat $HOME/.kde-services/youtube-download-rate-limit) 2> /dev/null)
if-cancel-exit
echo $RATE_LIMIT > $HOME/.kde-services/youtube-download-rate-limit

download-ultra-hd-4k() {
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Ultra_HD_(4K)_2160p"
	WEIGHT="$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 266|xargs -n1|grep MiB)"
	download-qdbusinsert
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 266+best -c -i -R infinite \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$PROGRAM
	EXIT=$?
	youtube-error
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download-ultra-hd-2k() {
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Ultra_HD_(2K)_1440p"
	WEIGHT="$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 264|xargs -n1|grep MiB)"
	download-qdbusinsert
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 264+best -c -i -R infinite \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$PROGRAM
	EXIT=$?
	youtube-error
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download-full-hd() {
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Full_HD_1080p"
	WEIGHT="$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 137|xargs -n1|grep MiB)"
	download-qdbusinsert
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 137+best -c -i -R infinite \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$PROGRAM
	EXIT=$?
	youtube-error
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download-hd() {
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	SIZE="HD_720p"
	WEIGHT="$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 136|xargs -n1|grep MiB)"
	download-qdbusinsert
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 136+best -c -i -R infinite \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$PROGRAM
	EXIT=$?
	youtube-error
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download-full-wvga(){
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Full_WVGA_480p"
	WEIGHT="$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 135|xargs -n1|grep MiB)"
	download-qdbusinsert
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 135+best -c -i -R infinite \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$PROGRAM
	EXIT=$?
	youtube-error
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download-nhd() {
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	SIZE="NHD_360p"
	WEIGHT="$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134|xargs -n1|grep MiB)"
	download-qdbusinsert
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -f 134+best -c -i -R infinite \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$PROGRAM
	EXIT=$?
	youtube-error
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

cd $DESTINATION
INIT_TIME=$(date +%s)

progressbar-start

VCODE=$(echo $VCODE|sed 's/hyphen//g')

for VID in $VCODE; do
    COUNT=$((++COUNT))
    checking-qdbusinsert
    PROGRAM="youtube-dl -F http://www.youtube.com/watch?v=$VID"
    $PROGRAM
    EXIT=$?
    youtube-error
done

if [ "$QUALITY" = "3840x2160" ];then
    COUNT="0"
    
    for VID in $VCODE; do
        COUNT=$((++COUNT))
        size-qdbusinsert
        
        if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 266)" ]];then
			download-ultra-hd-4k
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 264)" ]];then
			download-ultra-hd-2k
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 137)" ]];then
			download-full-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 136)" ]];then
			download-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 135)" ]];then
			download-full-wvga
        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134)" ]];then
			download-nhd
        fi
    done
elif [ "$QUALITY" = "2560x1440" ];then
    COUNT="0"
    
    for VID in $VCODE; do
        COUNT=$((++COUNT))
        size-qdbusinsert
        
        if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 264)" ]];then
			download-ultra-hd-2k
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 137)" ]];then
			download-full-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 136)" ]];then
			download-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 135)" ]];then
			download-full-wvga
        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134)" ]];then
			download-nhd
        fi
    done
elif [ "$QUALITY" = "1920x1080" ];then
    COUNT="0"
    
    for VID in $VCODE; do
        COUNT=$((++COUNT))
        size-qdbusinsert
        
        if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 137)" ]];then
			download-full-hd
        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 136)" ]];then
			download-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 135)" ]];then
			download-full-wvga
        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134)" ]];then
			download-nhd
        fi
    done
elif [ "$QUALITY" = "1280x720" ];then
    COUNT="0"
    
    for VID in $VCODE; do
        COUNT=$((++COUNT))
        size-qdbusinsert
        
        if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 136)" ]];then
			download-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 135)" ]];then
			download-full-wvga
        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134)" ]];then
			download-nhd
        fi
    done
elif [ "$QUALITY" = "854x480" ];then
    COUNT="0"
    
    for VID in $VCODE; do
        COUNT=$((++COUNT))
        size-qdbusinsert
        
		if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 135)" ]];then
			download-full-wvga
        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134)" ]];then
			download-nhd
        fi
    done
elif [ "$QUALITY" = "640x360" ];then
    COUNT="0"
    
    for VID in $VCODE; do
        COUNT=$((++COUNT))
        size-qdbusinsert
        
        if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134)" ]];then
			download-nhd
        fi
    done
fi

LAST_TIME=$(date +%s)
TOTAL_TIME=$((LAST_TIME-INIT_TIME))
progressbar-close

if [ "$TOTAL_TIME" -lt "60" ];then
    kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
                   --msgbox="The YouTube video(s) download to finished for ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}s" &
elif [ "$TOTAL_TIME" -gt "59" ] && [ "$TOTAL_TIME" -lt "3600" ];then
    TOTAL_TIME=$(echo "$TOTAL_TIME/60"|bc -l|sed 's/...................$//')
    kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
                   --msgbox="The YouTube video(s) download to finished for ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}m" &
elif [ "$TOTAL_TIME" -gt "3599" ] && [ "$TOTAL_TIME" -lt "86400" ];then
    TOTAL_TIME=$(echo "$TOTAL_TIME/3600"|bc -l|sed 's/...................$//')
    kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
                   --msgbox="The YouTube video(s) download to finished for ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}h" &
elif [ "$TOTAL_TIME" -gt "86399" ]; then
    TOTAL_TIME=$(echo "$TOTAL_TIME/86400"|bc -l|sed 's/...................$//')
    kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
                   --msgbox="The YouTube video(s) download to finished for ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}d" &
fi

echo "The YouTube videos download finished" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*

exit 0
