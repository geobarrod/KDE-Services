#!/usr/bin/env bash
########################################################################
# This program is free software; you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation; either version 3 of the License, or    #
# (at your option) any later version.                                  #
#                                                                      #
# This program is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License for more details.                         #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with this program; if not, write to the Free Software          #
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,           #
# MA 02110-1301, USA.                                                  #
#                                                                      #
#                                                                      #
# KDE-Services ⚙ 2012-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
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
COUNT=""
COUNTFILES=""
FILENAME=""
SIZE=""
INIT_TIME=""
LAST_TIME=""
TOTAL_TIME=""
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ];then
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="Download YouTube Video" --passivepopup="[Canceled]"
		exit 1
	fi
}

youtube-error() {
	if [ "$EXIT" != "0" ];then
		kdialog --icon=ks-error --title="Download YouTube Video" \
			--passivepopup="[Error]   $FILENAME $VID MPEG-4 $SIZE   Check network connection or YouTube Video Code."
		echo "$VID" >> !!!_YouTube-Video-Code.err
		sed -i 's/hyphen//' !!!_YouTube-Video-Code.err
		for ATTEMPT in {1..10}; do
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

progressbar-start() {
	kdialog --icon=ks-youtube-download-video --title="Download YouTube Video" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
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
sed -i 's/^-/hyphen-/' $HOME/.kde-services/youtube-video-codes
rm -f !!!_YouTube-Video-Code.err

VCODE=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--inputbox="Enter YouTube Video Code(s) separated by whitespace. By example in this URL: https://www.youtube.com/watch?v=DY-_o8z2ZFQ,\
		the Code is: DY-_o8z2ZFQ" "$(cat $HOME/.kde-services/youtube-video-codes)" 2> /dev/null)
if-cancel-exit
echo $VCODE > $HOME/.kde-services/youtube-video-codes
sed -i 's/hyphen//g' $HOME/.kde-services/youtube-video-codes

DESTINATION=$(kdialog --icon=ks-youtube-download-video --title="Destination YouTube Video(s)" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

RATE_LIMIT=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--inputbox="Enter Download Rate Limit (e.g. 50K or 4.2M)" $(cat $HOME/.kde-services/youtube-download-rate-limit) 2> /dev/null)
if-cancel-exit
echo $RATE_LIMIT > $HOME/.kde-services/youtube-download-rate-limit

QUALITY=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
		--radiolist="Select Video Quality" 7680x4320 "Ultra HD (8K)" on 3840x2160 "Ultra HD (4K)" off 2560x1440 "Ultra HD (2K)" off 1920x1080 "Full HD (1080p)" off 1280x720 "HD (720p)" off 854x480 "Full WVGA (480p)" off 640x360 "nHD (360p)" off 426x240 "WQVGA (240p)" off 256x144 "YT144 (144p)" off GAR "Get Another Resolutions" off 2> /dev/null)
if-cancel-exit

download-ultra-hd-8k() {
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Ultra_HD_(8K)_4320p"
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f bv[ext=mp4][height=4320]+ba[ext=m4a] -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID|"
	$PROGRAM
	EXIT=$?
	youtube-error
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download-ultra-hd-4k() {
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	SIZE="Ultra_HD_(4K)_2160p"
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f bv[ext=mp4][height=2160]+ba[ext=m4a] -c -i -R infinite --windows-filenames --restrict-filenames \
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
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f bv[ext=mp4][height=1440]+ba[ext=m4a] -c -i -R infinite --windows-filenames --restrict-filenames \
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
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f bv[ext=mp4][height=1080]+ba[ext=m4a] -c -i -R infinite --windows-filenames --restrict-filenames \
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
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f bv[ext=mp4][height=720]+ba[ext=m4a] -c -i -R infinite --windows-filenames --restrict-filenames \
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
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f bv[ext=mp4][height=480]+ba[ext=m4a] -c -i -R infinite --windows-filenames --restrict-filenames \
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
	SIZE="nHD_360p"
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f bv[ext=mp4][height=360]+ba[ext=m4a] -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$PROGRAM
	EXIT=$?
	youtube-error
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download-wqvga() {
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	SIZE="WQVGA_240p"
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f bv[ext=mp4][height=240]+ba[ext=m4a] -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$PROGRAM
	EXIT=$?
	youtube-error
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

download-yt144() {
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	SIZE="YT_144p"
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f bv[ext=mp4][height=144]+ba[ext=m4a] -c -i -R infinite --windows-filenames --restrict-filenames \
			-r $RATE_LIMIT --merge-output-format mp4 http://www.youtube.com/watch?v=$VID"
	$PROGRAM
	EXIT=$?
	youtube-error
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	finished
}

get-another-resolutions() {
	QUALITY=$(kdialog --icon=ks-youtube-download-video --title="YouTube Video Downloader" \
			--radiolist="Select Video Quality" $(youtube-dl -F $VID 2>&1|grep -w "video only"|grep -vE "WARNING|webm"|grep -wE "144p|240p|360p|480p|720p|1080p|1440p|2160p|4320p"|awk -F " " '{print $3,$3$5$6$5$2,"off"}'))
	if-cancel-exit
	FILENAME="$(youtube-dl -e http://www.youtube.com/watch?v=$VID)"
	FORMAT="$(echo $QUALITY|awk -Fx '{print $2}')"
	SIZE="${FORMAT}p"
	BEGIN_TIME=$(date +%s)
	PROGRAM="youtube-dl -o "%\(upload_date\)s_%\(title\)s_\(%\(id\)s\)_$SIZE.%\(ext\)s" -S "codec:h264" -f bv[ext=mp4][height=${FORMAT}]+ba[ext=m4a] -c -i -R infinite --windows-filenames --restrict-filenames \
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
	PROGRAM="youtube-dl -F http://www.youtube.com/watch?v=$VID"
	$PROGRAM
	EXIT=$?
	youtube-error
done

if [ "$QUALITY" == "7680x4320" ];then
	for VID in $VCODE; do
		if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 571)" ]];then
			download-ultra-hd-8k
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 401)" ]];then
			download-ultra-hd-4k
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 400)" ]];then
			download-ultra-hd-2k
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 399)" ]];then
			download-full-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 398)" ]];then
			download-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 397)" ]];then
			download-full-wvga
	        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 396)" ]];then
			download-nhd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 395)" ]];then
			download-wqvga
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 394)" ]];then
			download-yt144
		fi
	done
elif [ "$QUALITY" == "3840x2160" ];then
	for VID in $VCODE; do
		if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 401)" ]];then
			download-ultra-hd-4k
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 400)" ]];then
			download-ultra-hd-2k
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 399)" ]];then
			download-full-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 398)" ]];then
			download-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 397)" ]];then
			download-full-wvga
	        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 396)" ]];then
			download-nhd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 395)" ]];then
			download-wqvga
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 394)" ]];then
			download-yt144
		fi
	done
elif [ "$QUALITY" == "2560x1440" ];then
	for VID in $VCODE; do
		if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 400)" ]];then
			download-ultra-hd-2k
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 399)" ]];then
			download-full-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 398)" ]];then
			download-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 397)" ]];then
			download-full-wvga
    		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 396)" ]];then
			download-nhd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 395)" ]];then
			download-wqvga
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 394)" ]];then
			download-yt144
		fi
	done
elif [ "$QUALITY" == "1920x1080" ];then
	for VID in $VCODE; do
		if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 137)" ]];then
			download-full-hd
	        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 136)" ]];then
			download-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 135)" ]];then
			download-full-wvga
    		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134)" ]];then
			download-nhd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 395)" ]];then
			download-wqvga
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 394)" ]];then
			download-yt144
		fi
	done
elif [ "$QUALITY" == "1280x720)" ];then
	for VID in $VCODE; do
		if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 136)" ]];then
			download-hd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 135)" ]];then
			download-full-wvga
	        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134)" ]];then
			download-nhd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 395)" ]];then
			download-wqvga
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 394)" ]];then
			download-yt144
		fi
	done
elif [ "$QUALITY" == "854x480" ];then
	for VID in $VCODE; do
		if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 135)" ]];then
			download-full-wvga
	        elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134)" ]];then
			download-nhd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 395)" ]];then
			download-wqvga
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 394)" ]];then
			download-yt144
		fi
	done
elif [ "$QUALITY" == "640x360" ];then
	for VID in $VCODE; do
		if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 134)" ]];then
			download-nhd
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 395)" ]];then
			download-wqvga
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 394)" ]];then
			download-yt144
		fi
	done
elif [ "$QUALITY" == "426x240" ];then
	for VID in $VCODE; do
		if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 133)" ]];then
			download-wqvga
		elif [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 394)" ]];then
			download-yt144
		fi
	done
elif [ "$QUALITY" == "256x144" ];then
	for VID in $VCODE; do
		if [[ "$(youtube-dl -F http://www.youtube.com/watch?v=$VID|grep -w 160)" ]];then
			download-yt144
		fi
	done
elif [ "$QUALITY" == "GAR" ];then
	for VID in $VCODE; do
		get-another-resolutions
	done
fi

LAST_TIME=$(date +%s)
TOTAL_TIME=$((LAST_TIME-INIT_TIME))
progressbar-stop

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
