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

DBUSREF=""
LOG=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
YTDLPID=""

###################################
############ Functions ############
###################################

progressbar_start() {
	DBUSREF=$(kdialog --icon=ks-youtube-download-video --title="YouTube Download Video List" --progressbar "Downloading YouTube video list…" 1 100)
	qdbus6 $DBUSREF showCancelButton false
	sleep 1
}

progressbar_stop() {
	qdbus6 $DBUSREF close
}

progressbar_percent() {
	while [ "$(ps auxw|grep -v grep|grep yt-dlp|awk -F " " '{print $2}')" != "" ];do
		ITEM=""
		FILE_TMP=""
		FILE_STATUS=""
		while [ -z "$FILE_TMP" ];do
			sleep 0.5
			ITEM=$(cat $LOG|grep "Downloading item.*"|cut -f 2 -d ']'|tail -n1|xargs)
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
			qdbus6 $DBUSREF setLabelText "$ITEM $FILE_TMP $STATS"
			qdbus6 $DBUSREF Set "" 'value' $PERCENT 2>/dev/null
		done
	done
}

##############################
############ Main ############
##############################

trap 'rm -f "$LOG"; [ -n "$DBUSREF" ] && qdbus6 "$DBUSREF" close 2>/dev/null' INT TERM EXIT
DIR=$1
cd "$DIR"
DIR=$(pwd)

mkdir -p $HOME/.kde-services
touch $HOME/.kde-services/youtube-video-list

URL=$(kdialog --icon=ks-youtube-download-video --title="YouTube Download Video List" --inputbox="Enter URL of YouTube videos list." "$(cat $HOME/.kde-services/youtube-video-list)" 2> /dev/null)
if [ "$?" != "0" ];then
	exit 1
fi
echo $URL > $HOME/.kde-services/youtube-video-list

DESTINATION=$(kdialog --icon=ks-youtube-download-video --title="Destination YouTube Video(s)" --getexistingdirectory "$DIR" 2>/dev/null)
if [ "$?" != "0" ];then
	qdbus6 $DBUSREF close
	kdialog --icon=ks-error --title="YouTube Download Video List" --passivepopup="CANCELED"
	exit 1
fi

progressbar_start

lynx -source "$URL"
if [ "$?" != "0" ];then
	progressbar_stop
	kdialog --icon=ks-error --title="YouTube Download Video List" \
		--passivepopup="ERROR: Please check your network connection to URL: $URL"
	exit 1
fi

cd $DESTINATION

INIT_TIME=$(date +%s)
LOG=$(mktemp)
yt-dlp -o %\(upload_date\)s_%\(title\)s_\(%\(id\)s\).%\(ext\)s \
	-f b -c -i -R infinite --newline --progress --embed-chapters \
	--windows-filenames --restrict-filenames --merge-output-format mp4 \
	--abort-on-unavailable-fragments "$URL" > $LOG &
YTDLPID=$!
if [ "$?" != "0" ];then
	kill -9 $YTDLPID
	qdbus6 $DBUSREF close
	kdialog --icon=ks-error --title="YouTube Download Video List" --passivepopup="CANCELED"
	exit 1
fi
progressbar_percent
rm $LOG
LAST_TIME=$(date +%s)
TOTAL_TIME=$((LAST_TIME-INIT_TIME))
progressbar_stop

if [ "$TOTAL_TIME" -lt "60" ];then
	kdialog --icon=ks-youtube-download-video --title="YouTube Download Video List" \
		--msgbox="The YouTube video(s) download to finished on ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}s" &
elif [ "$TOTAL_TIME" -gt "59" ] && [ "$TOTAL_TIME" -lt "3600" ];then
	TOTAL_TIME=$(echo "$TOTAL_TIME/60"|bc -l|sed 's/...................$//')
	kdialog --icon=ks-youtube-download-video --title="YouTube Download Video List" \
		--msgbox="The YouTube video(s) download to finished on ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}m" &
elif [ "$TOTAL_TIME" -gt "3599" ] && [ "$TOTAL_TIME" -lt "86400" ];then
	TOTAL_TIME=$(echo "$TOTAL_TIME/3600"|bc -l|sed 's/...................$//')
	kdialog --icon=ks-youtube-download-video --title="YouTube Download Video List" \
		--msgbox="The YouTube video(s) download to finished on ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}h" &
elif [ "$TOTAL_TIME" -gt "86399" ];then
	TOTAL_TIME=$(echo "$TOTAL_TIME/86400"|bc -l|sed 's/...................$//')
	kdialog --icon=ks-youtube-download-video --title="YouTube Download Video List" \
		--msgbox="The YouTube video(s) download to finished on ${DESTINATION##*/} directory.   Total time: ${TOTAL_TIME}d" &
fi

echo "The YouTube videos list download finished" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*
exit 0
