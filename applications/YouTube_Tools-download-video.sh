#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2012-2026.                                                       #
#                                                                                 #
# BSD 3-Clause License                                                            #
#                                                                                 #
# Copyright (c) 2026, Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.  #
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
AUDIO_LANG=""
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
FORMAT=""
INIT_TIME=""
LAST_TIME=""
LOG=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
RATE_LIMIT=""
SUB_LANG=""
TOTAL_TIME=""
VCODE=""
VID=""
VR=""
YTDLP=""
YTDLPID=""

###################################
############ Functions ############
###################################

if_cancel_exit() {
	if [ "$EXIT" != "0" ];then
		kill -9 $YTDLPID
		qdbus6 $DBUSREF close
		kdialog --icon=ks-error --title="Download YouTube Video" --passivepopup="CANCELED"
		exit 1
	fi
}

download_reattempt() {
    qdbus6 $DBUSREF setLabelText "Downloading ${FILENAME} [$FORMAT] [$COUNT/$(($COUNTFILES-1))] Reattempts: [$ATTEMPT/10]"
}

ytdlp_error() {
	if [ "$EXIT" != "0" ];then
		kdialog --icon=ks-error --title="Download YouTube Video" \
			--passivepopup="ERROR: Downloading ${FILENAME} [$FORMAT]. Please check your network connection or the validity of the YouTube video code."
		echo "$VID" >> !_YouTube-Video-Code.err
		for ATTEMPT in {1..10};do
			download_reattempt
			$YTDLP
			EXIT=$?
			if [ "$EXIT" = "0" ];then
				if [ "$(wc -w !_YouTube-Video-Code.err|awk '{print $1}')" = "0" ];then
					rm -f !_YouTube-Video-Code.err
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
	DBUSREF=$(kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" --progressbar "Getting all available video resolutions…" 1 100)
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
			sleep 0.5
			FILE_TMP=$(cat $LOG|grep "Destination:.*"|cut -f 2 -d ':'|tail -n1|xargs)
			FILE_STATUS=$(cat $LOG|grep -ow "has already been downloaded")
			if [ "$FILE_STATUS" == "has already been downloaded" ];then
				kdialog --icon=ks-error --title="YouTube Download Video List" \
					--passivepopup "CANCELED: $FILE_TMP has already been downloaded"
				break
			fi
		done
		PERCENT=0
		while [ $PERCENT -lt 100 ];do
			sleep 0.5
			PERCENT=$(cat $LOG|grep '%'|tail -n1|cut -f1 -d '%'|cut -f1 -d '.'|sed 's@^.* @@')
			STATS=$(cat $LOG|grep '%'|tail -n1|awk -F " " '{print $3,$4,$5,$6,$7,$8,$9,$10,$11}')
			qdbus6 $DBUSREF setLabelText "Downloading $FILE_TMP $STATS"
			qdbus6 $DBUSREF Set "" 'value' $PERCENT 2>/dev/null
		done
	done
}

checking_audio_availability() {
	qdbus6 $DBUSREF setLabelText "Checking audio availability…"
}

checking_subtitle_availability() {
	qdbus6 $DBUSREF setLabelText "Checking subtitle availability…"
}

downloading_video() {
	qdbus6 $DBUSREF setLabelText "Downloading ${FILENAME} [$FORMAT] [$COUNT/$(($COUNTFILES-1))]"
}

finished() {
	if [ "$EXIT" = "0" ];then
		if [ "$ELAPSED_TIME" -lt "60" ];then
			kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
				--passivepopup="Download completed ${FILENAME} [$FORMAT] in ${ELAPSED_TIME}s"
		elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ];then
			ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
			kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
				--passivepopup="Download completed ${FILENAME} [$FORMAT] in ${ELAPSED_TIME}m"
		elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ];then
			ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
			kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
				--passivepopup="Download completed ${FILENAME} [$FORMAT] in ${ELAPSED_TIME}h"
		elif [ "$ELAPSED_TIME" -gt "86399" ]; then
			ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
			kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" \
				--passivepopup="Download completed ${FILENAME} [$FORMAT] in ${ELAPSED_TIME}d"
		fi
	fi
}

##############################
############ Main ############
##############################

trap 'rm -f "$LOG"; [ -n "$DBUSREF" ] && qdbus6 "$DBUSREF" close 2>/dev/null' INT TERM EXIT
DIR=$1
cd "$DIR"
DIR=$(pwd)

mkdir -p $HOME/.kde-services
touch $HOME/.kde-services/youtube-video-codes
touch $HOME/.kde-services/youtube-download-rate-limit
rm -f !_YouTube-Video-Code.err

VCODE=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--inputbox="Enter YouTube video code(s) separated by whitespace. By example in this URL: https://www.youtube.com/watch?v=DY-_o8z2ZFQ, the code is: DY-_o8z2ZFQ" -- "$(cat $HOME/.kde-services/youtube-video-codes)" 2>/dev/null)
EXIT=$?
if_cancel_exit
echo $VCODE > $HOME/.kde-services/youtube-video-codes

DESTINATION=$(kdialog --icon=ks-youtube-download-video --title="Destination YouTube Video(s)" --getexistingdirectory "$DIR" 2>/dev/null)
EXIT=$?
if_cancel_exit

RATE_LIMIT=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--inputbox="Enter download rate limit, example: 50K (= 50Kbps) or 5.5M (= 5.5Mbps)." $(cat $HOME/.kde-services/youtube-download-rate-limit) 2>/dev/null)
EXIT=$?
if_cancel_exit
echo $RATE_LIMIT > $HOME/.kde-services/youtube-download-rate-limit

progressbar_start

VR=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
			--radiolist="Select Video Resolution" $(yt-dlp -F -- $VCODE \
			|& grep -w "video only"|grep -vE "WARNING|webm"|grep -E "144|240|360|480|720|1080|1440|2160|4320" \
			|awk -F " " '{print $3,$3$5$6,$7$5$2,"off"}'|sort -nuk1,1|sed -e 's/~ /~/g' -e 's/KiB.*k/KiB/g' -e 's/MiB.*k/MiB/g'))
EXIT=$?
if_cancel_exit

#checking_audio_availability
#AUDIO_LANG=[language=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
#		--radiolist="Select Audio Language" default Default on $(yt-dlp -F -- $VCODE|& grep -w "audio only"|grep -vE "WARNING|drc"|grep -w m4a|awk -F " " '{print $16,$16$6$17$6$14$6$7$6$2,"off"}'|sed -e 's/,//g' -e 's/\[//g' -e 's/\]//g'))]
#EXIT=$?
#if_cancel_exit
#AUDIO_LANG=$(echo "${AUDIO_LANG}"|grep -vE "default|medium")

#checking_subtitle_availability
#SUB_LANG="--embed-subs --sub-langs $(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
#		--radiolist="Select Subtitle Language" default Default on $(yt-dlp --list-subs -- $VCODE|sed -ne '/Available subtitles for/,$p'|grep -vE "Available|Language"|awk -F " " '{print $1,$2,"off"}'))"
#EXIT=$?
#if_cancel_exit
#SUB_LANG="$(echo "${SUB_LANG}"|grep -vE "default")"

qdbus6 $DBUSREF setLabelText "Downloading video…"
cd $DESTINATION
INIT_TIME=$(date +%s)
COUNT="0"
for VID in $VCODE;do
	COUNT=$((++COUNT))
	FILENAME="$(yt-dlp -e http://www.youtube.com/watch?v=$VID)"
	FH="$(echo $VR|awk -Fx '{print $2}')"
	FORMAT="${FH}p"
	downloading_video
	BEGIN_TIME=$(date +%s)
	LOG=$(mktemp)
	YTDLP="yt-dlp -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_[${FORMAT}].%\(ext\)s" \
			-f wv[height=${FH}]+wa -c -i \
			-R infinite --newline --progress --embed-chapters --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$YTDLP > $LOG &
	YTDLPID=$!
	EXIT=$?
	ytdlp_error
	progressbar_percent
	rm $LOG
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
done

LAST_TIME=$(date +%s)
TOTAL_TIME=$((LAST_TIME-INIT_TIME))
progressbar_stop

if [ "$TOTAL_TIME" -lt "60" ];then
	kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--msgbox="The YouTube video(s) download to finished on ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}s" &
elif [ "$TOTAL_TIME" -gt "59" ] && [ "$TOTAL_TIME" -lt "3600" ];then
	TOTAL_TIME=$(echo "$TOTAL_TIME/60"|bc -l|sed 's/...................$//')
	kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--msgbox="The YouTube video(s) download to finished on ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}m" &
elif [ "$TOTAL_TIME" -gt "3599" ] && [ "$TOTAL_TIME" -lt "86400" ];then
	TOTAL_TIME=$(echo "$TOTAL_TIME/3600"|bc -l|sed 's/...................$//')
	kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--msgbox="The YouTube video(s) download to finished on ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}h" &
elif [ "$TOTAL_TIME" -gt "86399" ]; then
	TOTAL_TIME=$(echo "$TOTAL_TIME/86400"|bc -l|sed 's/...................$//')
	kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--msgbox="The YouTube video(s) download to finished on ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}d" &
fi

echo "The YouTube videos download finished" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*
rm $LOG
exit 0
