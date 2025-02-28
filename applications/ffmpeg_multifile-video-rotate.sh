#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2011-2025.                                                       #
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

ANGLE=""
BEGIN_TIME=""
DESTINATION=""
DIR=""
ELAPSED_TIME=""
FINAL_TIME=""
LOG=""
LOGERROR=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PB_PIDFILE="$(mktemp)"
PID="$$"

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
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="Rotate Video Files" --passivepopup="[Canceled]"
		exit 1
	fi
}

if-ffmpeg-cancel() {
	if [ "$?" != "0" ]; then
		kdialog --icon=ks-error --title="Rotating video file ${i##*/} to $ANGLE" \
			--passivepopup="[Canceled]   Check the path and filename not contain whitespaces. Check error log $LOGERROR. Try again"
		mv $LOG $DESTINATION/$LOGERROR
		continue
	fi
}

progressbar-start() {
	kdialog --icon=ks-video-rotate --title="Rotate Video Files" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-video-rotate --title="Rotate Video Files" \
			--passivepopup="[Finished]  ${i##*/}   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-video-rotate --title="Rotate Video Files" \
			--passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-video-rotate --title="Rotate Video Files" \
			--passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}h"
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

if [ "$DIR" == "~/.local/share/applications" ]; then
	DIR="~/"
fi

FILES=$(kdialog --icon=ks-video-rotate --title="Rotate Video Files" --multiple --getopenfilename "$DIR" "*.3GP *.3gp *.AVI *.avi *.DAT *.dat *.DV *.dv *.FLV *.flv *.M2V *.m2v *.M4V *.m4v \
		*.MKV *.mkv *.MOV *.mov *.MP4 *.mp4 *.MPEG *.mpeg *.MPEG4 *.mpeg4 *.MPG *.mpg *.OGV *.ogv *.VOB *.vob *.WEBM *.webm *.WMV *.wmv|*.3gp *.avi *.dat *.dv *.flv *.m2v *.m4v *.mkv *.mov *.mp4 *.mpeg *.mpeg4 *.mpg *.ogv *.vob *.webm *.wmv" 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=ks-video-rotate --title="Destination Video Files" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

ANGLE=$(kdialog --icon=ks-video-rotate --title="Rotate Video Files" \
		--combobox="Select rotation degree angle" "90 Clockwise" "90 Clockwise and Vertical Flip" "90 CounterClockwise" "90 CounterClockwise and Vertical Flip" "180 Clockwise" "Horizontal Mirror" "Vertical Mirror" --default "90 Clockwise")
if-cancel-exit

if [ "$ANGLE" = "90 Clockwise" ]; then
	progressbar-start

	for i in $FILES; do
		logs
		BEGIN_TIME=$(date +%s)
		DST_FILE="${i%.*}"
		ffmpeg -y -i $i -vf "transpose=clock" -c:a copy "$DESTINATION/${DST_FILE##*/}_90-Clockwise.${i:${#i}-3}" > $LOG 2>&1
		if-ffmpeg-cancel
		FINAL_TIME=$(date +%s)
		ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
		elapsedtime
	done
elif [ "$ANGLE" = "90 Clockwise and Vertical Flip" ]; then
	progressbar-start

	for i in $FILES; do
		logs
		BEGIN_TIME=$(date +%s)
		DST_FILE="${i%.*}"
		ffmpeg -y -i $i -vf "transpose=clock_flip" -c:a copy "$DESTINATION/${DST_FILE##*/}_90-Clockwise-VFlip.${i:${#i}-3}" > $LOG 2>&1
		if-ffmpeg-cancel
		FINAL_TIME=$(date +%s)
		ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
		elapsedtime
	done
elif [ "$ANGLE" = "90 CounterClockwise" ]; then
	progressbar-start

	for i in $FILES; do
		logs
		BEGIN_TIME=$(date +%s)
		DST_FILE="${i%.*}"
		ffmpeg -y -i $i -vf "transpose=cclock" -c:a copy "$DESTINATION/${DST_FILE##*/}_90-CounterClockwise.${i:${#i}-3}" > $LOG 2>&1
		if-ffmpeg-cancel
		FINAL_TIME=$(date +%s)
		ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
		elapsedtime
	done
elif [ "$ANGLE" = "90 CounterClockwise and Vertical Flip" ]; then
	progressbar-start

	for i in $FILES; do
		logs
		BEGIN_TIME=$(date +%s)
		DST_FILE="${i%.*}"
		ffmpeg -y -i $i -vf "transpose=cclock_flip" -c:a copy "$DESTINATION/${DST_FILE##*/}_90-CounterClockwise-VFlip.${i:${#i}-3}" > $LOG 2>&1
		if-ffmpeg-cancel
		FINAL_TIME=$(date +%s)
		ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
		elapsedtime
	done
elif [ "$ANGLE" = "180 Clockwise" ]; then
	progressbar-start

	for i in $FILES; do
		logs
		BEGIN_TIME=$(date +%s)
		DST_FILE="${i%.*}"
		ffmpeg -y -i $i -vf "transpose=clock,transpose=clock" -c:a copy "$DESTINATION/${DST_FILE##*/}_180-Clockwise.${i:${#i}-3}" > $LOG 2>&1
		if-ffmpeg-cancel
		FINAL_TIME=$(date +%s)
		ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
		elapsedtime
	done
elif [ "$ANGLE" = "Horizontal Mirror" ]; then
	progressbar-start

	for i in $FILES; do
		logs
		BEGIN_TIME=$(date +%s)
		DST_FILE="${i%.*}"
		ffmpeg -y -i $i -vf "transpose=clock,transpose=clock_flip" -c:a copy "$DESTINATION/${DST_FILE##*/}_HMirror.${i:${#i}-3}" > $LOG 2>&1
		if-ffmpeg-cancel
		FINAL_TIME=$(date +%s)
		ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
		elapsedtime
	done
elif [ "$ANGLE" = "Vertical Mirror" ]; then
	progressbar-start

	for i in $FILES; do
		logs
		BEGIN_TIME=$(date +%s)
		DST_FILE="${i%.*}"
		ffmpeg -y -i $i -vf "transpose=clock_flip,transpose=clock" -c:a copy "$DESTINATION/${DST_FILE##*/}_VMirror.${i:${#i}-3}" > $LOG 2>&1
		if-ffmpeg-cancel
		FINAL_TIME=$(date +%s)
		ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
		elapsedtime
	done
fi
progressbar-stop
echo "Finish Rotate Video Files" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*

exit 0
