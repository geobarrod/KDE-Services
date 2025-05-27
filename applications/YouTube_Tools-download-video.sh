#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2012-2025.                                                       #
#                                                                                 #
# BSD 3-Clause License                                                            #
#                                                                                 #
# Copyright (c) 2025, Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.  #
#                                                                                 #
# Redistribution and use in source and binary forms, with or without              #
# modification, are permitted provided that the following conditions are met:     #
#                                                                                 #
#  1. Redistributions of source code must retain the above copyright notice, this #
#     list of conditions and the following disclaimer.                            #
#                                                                                 #
#  2. Redistributions in binary form must reproduce the above copyright notice,   #
#     this list of conditions and the following disclaimer in the documentation   #
#     and/or other materials provided with the distribution.                      #
#                                                                                 #
#  3. Neither the name of the copyright holder nor the names of its               #
#     contributors may be used to endorse or promote products derived from        #
#     this software without specific prior written permission.                    #
#                                                                                 #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"     #
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE  #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE    #
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL      #
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR      #
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER      #
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   #
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE   #
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.            #
###################################################################################

ATTEMPT=""
AUDIO_QUALITY=""
BEGIN_TIME=""
COUNT=""
COUNTFILES=""
DBUSREF=""
DESTINATION=""
DIR=""
ELAPSED_TIME=""
EXIT=""
FILE_STATUS=""
FILE_TMP=""
FILENAME=""
FINAL_TIME=""
INIT_TIME=""
LAST_TIME=""
LOG=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
RATE_LIMIT=""
SIZE=""
TOTAL_TIME=""
VCODE=""
VID=""
VIDEO_QUALITY=""
YTDLP=""
YTDLPID=""

###################################
############ Functions ############
###################################

if_cancel_exit() {
	if [ "$?" != "0" ];then
		qdbus6 $DBUSREF close
		kdialog --icon=ks-error --title="Download YouTube Video" --passivepopup="[Canceled]"
		exit 1
	fi
}

download_reattempt() {
	COUNT=$((++COUNT))
	qdbus6 $DBUSREF setLabelText "Downloading ${FILENAME} [$COUNT/$(($COUNTFILES-1))] Reattempts: [$ATTEMPT/10]"
}

youtube_error() {
	if [ "$EXIT" != "0" ];then
		kdialog --icon=ks-error --title="Download YouTube Video" \
			--passivepopup="[Error]   $FILENAME $VID MPEG-4 $SIZE   Check network connection or YouTube Video Code."
		echo "$VID" >> !!!_YouTube-Video-Code.err
		for ATTEMPT in {1..10}; do
			download_reattempt
			$YTDLP
			EXIT=$?
			if [ "$EXIT" = "0" ];then
				sed -i "/$VID/d" !!!_YouTube-Video-Code.err
				if [ "$(wc -w !!!_YouTube-Video-Code.err|awk '{print $1}')" = "0" ];then
					rm -f !!!_YouTube-Video-Code.err
				fi
			fi
		done
		continue
	fi
}

progressbar_start() {
	COUNT="0"
	COUNTFILES=$(echo $VCODE|wc -w)
	COUNTFILES=$((++COUNTFILES))
	DBUSREF=$(kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" --print-winid --progressbar "Downloading..." /ProcessDialog)
	qdbus6 $DBUSREF showCancelButton false
	sleep 1
}

progressbar_stop() {
	qdbus6 $DBUSREF Set "" value $COUNTFILES
	sleep 1
	qdbus6 $DBUSREF close
}

progressbar_percent() {
	while [ "$(ps auxw|grep -v grep|grep yt-dlp|awk -F " " '{print $2}')" != "" ];do
		FILE_TMP=""
		FILE_STATUS=""
		while [ -z "$FILE_TMP" ];do
			sleep 2
			FILE_TMP=$(cat $LOG|grep "download.*Destination:.*f${VIDEO_QUALITY}.mp4"|cut -f 2 -d ':'|xargs)
			FILE_STATUS=$(cat $LOG|grep -ow "has already been downloaded")
			if [ "$FILE_STATUS" == "has already been downloaded" ];then
				kill -9 $YTDLPID
				kdialog --icon=ks-error --title="Download YouTube Video" \
					--passivepopup "CANCELED: ${FILENAME} [$FORMAT] has already been downloaded"
				break
			fi
		done
		PERCENT=0
		while [ $PERCENT -lt 100 ];do
			sleep 2
			PERCENT=$(cat $LOG|grep '%'|tail -n1|cut -f1 -d '%'|cut -f1 -d '.'|sed 's@^.* @@')
			STATS=$(cat $LOG|grep '%'|tail -n1|awk -F " " '{print $3,$4,$5,$6,$7,$8}')
			qdbus6 $DBUSREF setLabelText "Downloading ${FILE_TMP} $STATS"
			qdbus6 $DBUSREF Set "" 'value' $PERCENT 2>/dev/null
		done
		FILE_TMP=""
		FILE_STATUS=""
		while [ -z "$FILE_TMP" ];do
			sleep 2
			FILE_TMP=$(cat $LOG|grep "download.*Destination:.*f${AUDIO_QUALITY}.mp4"|cut -f 2 -d ':'|xargs)
			FILE_STATUS=$(cat $LOG|grep -ow "has already been downloaded")
			if [ "$FILE_STATUS" == "has already been downloaded" ];then
				kill -9 $YTDLPID
				break
			fi
		done
		PERCENT=0
		while [ $PERCENT -lt 100 ];do
			sleep 2
			PERCENT=$(cat $LOG|grep '%'|tail -n1|cut -f1 -d '%'|cut -f1 -d '.'|sed 's@^.* @@')
			STATS=$(cat $LOG|grep '%'|tail -n1|awk -F " " '{print $3,$4,$5,$6,$7,$8}')
			qdbus6 $DBUSREF setLabelText "Downloading ${FILE_TMP} $STATS"
			qdbus6 $DBUSREF Set "" 'value' $PERCENT 2>/dev/null
		done
	done
}

downloading_video() {
	COUNT=$((++COUNT))
	qdbus6 $DBUSREF setLabelText "Downloading ${FILENAME} [$COUNT/$(($COUNTFILES-1))]"
}

finished() {
	if [ "$EXIT" = "0" ];then
		if [ "$ELAPSED_TIME" -lt "60" ];then
			kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
				--passivepopup="[Finished]   $FILENAME $VID MPEG-4 $SIZE   Elapsed Time: ${ELAPSED_TIME}s"
		elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ];then
			ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
			kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
				--passivepopup="[Finished]   $FILENAME $VID MPEG-4 $SIZE   Elapsed Time: ${ELAPSED_TIME}m"
		elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ];then
			ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
			kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
				--passivepopup="[Finished]   $FILENAME $VID MPEG-4 $SIZE   Elapsed Time: ${ELAPSED_TIME}h"
		elif [ "$ELAPSED_TIME" -gt "86399" ]; then
			ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
			kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
				--passivepopup="[Finished]   $FILENAME $VID MPEG-4 $SIZE   Elapsed Time: ${ELAPSED_TIME}d"
		fi
	fi
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
rm -f !!!_YouTube-Video-Code.err

VCODE=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--inputbox="Enter YouTube Video Code(s) separated by whitespace. By example in this URL: https://www.youtube.com/watch?v=DY-_o8z2ZFQ, \
the Code is: DY-_o8z2ZFQ" -- "$(cat $HOME/.kde-services/youtube-video-codes)" 2>/dev/null)
if_cancel_exit
echo $VCODE > $HOME/.kde-services/youtube-video-codes

DESTINATION=$(kdialog --icon=ks-youtube-download-video --title="Destination YouTube Video(s)" --getexistingdirectory "$DIR" 2>/dev/null)
if_cancel_exit

RATE_LIMIT=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--inputbox="Enter Download Rate Limit (e.g. 50K or 4.2M)" $(cat $HOME/.kde-services/youtube-download-rate-limit) 2>/dev/null)
if_cancel_exit
echo $RATE_LIMIT > $HOME/.kde-services/youtube-download-rate-limit

VIDEO_QUALITY=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--radiolist="Select Video Format" 571 "Ultra HD (8K)" on 628 "Ultra HD (4K)" off 623 "Ultra HD (2K)" off 617 "Full HD (1080p)" off 612 "HD (720p)" off 606 "Full WVGA (480p)" off 605 "nHD (360p)" off 604 "WQVGA (240p)" off 603 "YT144 (144p)" off GAR "Get Another Resolutions" off 2>/dev/null)
if_cancel_exit

AUDIO_QUALITY=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--radiolist="Select Audio Quality" 234 "Best audio quality (largest video file size)" on 233 "Worse audio quality (smaller video file size)" off 2>/dev/null)
if_cancel_exit

download_ultra_hd_8k() {
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Ultra_HD_(8K)_4320p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f $VIDEO_QUALITY+$AUDIO_QUALITY -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	youtube_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download_ultra_hd_4k() {
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Ultra_HD_(4K)_2160p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f $VIDEO_QUALITY+$AUDIO_QUALITY -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	youtube_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download_ultra_hd_2k() {
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Ultra_HD_(2K)_1440p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f $VIDEO_QUALITY+$AUDIO_QUALITY -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	youtube_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download_full_hd() {
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Full_HD_1080p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f $VIDEO_QUALITY+$AUDIO_QUALITY -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	youtube_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download_hd() {
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	SIZE="HD_720p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f $VIDEO_QUALITY+$AUDIO_QUALITY -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	youtube_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download_full_wvga(){
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Full_WVGA_480p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f $VIDEO_QUALITY+$AUDIO_QUALITY -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	youtube_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download_nhd() {
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	SIZE="nHD_360p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f $VIDEO_QUALITY+$AUDIO_QUALITY -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	youtube_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download_wqvga() {
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	SIZE="WQVGA_240p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f $VIDEO_QUALITY+$AUDIO_QUALITY -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	youtube_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download_yt144() {
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	SIZE="YT-144p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f $VIDEO_QUALITY+$AUDIO_QUALITY -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	youtube_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

get_another_resolutions() {
	VIDEO_QUALITY=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
			--radiolist="Select Video Quality" $(yt-dlp -F -- $VID|& grep -w "video only"|grep -vE "WARNING|webm"|grep -E "144|240|360|480|720|1080|1440|2160|4320"|awk -F " " '{print $1,$3$5$6$7$5$2,"off"}'|sort -nuk2,2|sed -e 's/~ /~/g' -e 's/KiB.*k/KiB/g' -e 's/MiB.*k/MiB/g'))
	if_cancel_exit
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	FORMAT="$(yt-dlp -F -- $VID|& grep -w "video only"|grep -vE "WARNING|webm"|grep -w $VIDEO_QUALITY|awk -F " " '{print $3}'|awk -Fx '{print $2}')"
	SIZE="${FORMAT}p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f $VIDEO_QUALITY+$AUDIO_QUALITY -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	youtube_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

cd $DESTINATION
INIT_TIME=$(date +%s)
progressbar_start

for VID in $VCODE; do
	YTDLP="yt-dlp -F http://www.youtube.com/watch?v=$VID"
	$YTDLP
	EXIT=$?
	youtube_error
done

if [ "$VIDEO_QUALITY" == "571" ];then
	for VID in $VCODE; do
		if [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 571)" ]];then
			download_ultra_hd_8k
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 628)" ]];then
			download_ultra_hd_4k
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 623)" ]];then
			download_ultra_hd_2k
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 617)" ]];then
			download_full_hd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 612)" ]];then
			download_hd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 606)" ]];then
			download_full_wvga
	        elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 605)" ]];then
			download_nhd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 604)" ]];then
			download_wqvga
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 603)" ]];then
			download_yt144
		fi
	done
elif [ "$VIDEO_QUALITY" == "628" ];then
	for VID in $VCODE; do
		if [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 628)" ]];then
			download_ultra_hd_4k
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 623)" ]];then
			download_ultra_hd_2k
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 617)" ]];then
			download_full_hd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 612)" ]];then
			download_hd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 606)" ]];then
			download_full_wvga
	        elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 605)" ]];then
			download_nhd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 604)" ]];then
			download_wqvga
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 603)" ]];then
			download_yt144
		fi
	done
elif [ "$VIDEO_QUALITY" == "623" ];then
	for VID in $VCODE; do
		if [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 623)" ]];then
			download_ultra_hd_2k
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 617)" ]];then
			download_full_hd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 612)" ]];then
			download_hd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 606)" ]];then
			download_full_wvga
    		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 605)" ]];then
			download_nhd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 604)" ]];then
			download_wqvga
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 603)" ]];then
			download_yt144
		fi
	done
elif [ "$VIDEO_QUALITY" == "617" ];then
	for VID in $VCODE; do
		if [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 617)" ]];then
			download_full_hd
	        elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 612)" ]];then
			download_hd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 606)" ]];then
			download_full_wvga
    		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 605)" ]];then
			download_nhd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 604)" ]];then
			download_wqvga
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 603)" ]];then
			download_yt144
		fi
	done
elif [ "$VIDEO_QUALITY" == "612" ];then
	for VID in $VCODE; do
		if [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 612)" ]];then
			download_hd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 606)" ]];then
			download_full_wvga
	        elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 605)" ]];then
			download_nhd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 604)" ]];then
			download_wqvga
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 603)" ]];then
			download_yt144
		fi
	done
elif [ "$VIDEO_QUALITY" == "606" ];then
	for VID in $VCODE; do
		if [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 606)" ]];then
			download_full_wvga
	        elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 605)" ]];then
			download_nhd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 604)" ]];then
			download_wqvga
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 603)" ]];then
			download_yt144
		fi
	done
elif [ "$VIDEO_QUALITY" == "605" ];then
	for VID in $VCODE; do
		if [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 605)" ]];then
			download_nhd
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 604)" ]];then
			download_wqvga
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 603)" ]];then
			download_yt144
		fi
	done
elif [ "$VIDEO_QUALITY" == "604" ];then
	for VID in $VCODE; do
		if [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 604)" ]];then
			download_wqvga
		elif [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 603)" ]];then
			download_yt144
		fi
	done
elif [ "$VIDEO_QUALITY" == "603" ];then
	for VID in $VCODE; do
		if [[ "$(yt-dlp -F http://www.youtube.com/watch?v=$VID|grep -w 603)" ]];then
			download_yt144
		fi
	done
elif [ "$VIDEO_QUALITY" == "GAR" ];then
	for VID in $VCODE; do
		get_another_resolutions
	done
fi

LAST_TIME=$(date +%s)
TOTAL_TIME=$((LAST_TIME-INIT_TIME))
progressbar_stop

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
