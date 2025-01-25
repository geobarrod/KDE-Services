#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2011-2025.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
DESTINATION=""
DIR=""
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
LOG=""
LOGERROR=""
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

logs() {
	LOG="/tmp/${FILES[$ARRAY_NUMBER]##*/}.log"
	LOGERROR="${FILES[$ARRAY_NUMBER]##*/}.err"
	rm -f $LOGERROR
}

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		exit 1
	fi
}

if-ffmpeg-cancel() {
	if [ "$?" != "0" ]; then
		kdialog --icon=ks-error --title="Adding ${SUBS[$ARRAY_NUMBER]##*/} to ${FILES[$ARRAY_NUMBER]##*/}" \
			--passivepopup="[Canceled]   Check the path and filename not contain whitespaces. Check error log $LOGERROR. Try again"
		mv $LOG $DESTINATION/$LOGERROR
		continue
	fi
}

progressbar-start() {
	kdialog --icon=ks-add-subs --title="Add Subtitle to MP4 File" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-add-subs --title="Add Subtitle to MP4 File" \
			--passivepopup="[Finished]  ${FILES[$ARRAY_NUMBER]##*/}   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-add-subs --title="Add Subtitle to MP4 File" \
			--passivepopup="[Finished]   ${FILES[$ARRAY_NUMBER]##*/}   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-add-subs --title="Add Subtitle to MP4 File" \
			--passivepopup="[Finished]   ${FILES[$ARRAY_NUMBER]##*/}   Elapsed Time: ${ELAPSED_TIME}h"
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

FILES=($(kdialog --icon=ks-add-subs --title="Video Files" --multiple --getopenfilename "$DIR" "*.MP4 *.mp4|*.mp4" 2> /dev/null))
if-cancel-exit

SUBS=($(kdialog --icon=ks-add-subs --title="Subtitle Files" --multiple --getopenfilename "$DIR" "*.SRT *.srt|*.srt" 2> /dev/null))
if-cancel-exit

DESTINATION=$(kdialog --icon=ks-add-subs --title="Destination Video Files" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

ARRAY_NUMBER="0"
TOTAL_ARRAY="${#FILES[*]}"

progressbar-start
while [ "$ARRAY_NUMBER" -lt "$TOTAL_ARRAY" ]; do
	logs
	BEGIN_TIME=$(date +%s)
	DST_FILE="${FILES[$ARRAY_NUMBER]%.*}"
	ffmpeg -y -i ${FILES[$ARRAY_NUMBER]} -sub_charenc $(file -i ${SUBS[$ARRAY_NUMBER]}|xargs -n1|grep charset=|awk -F= '{print $2}') -i ${SUBS[$ARRAY_NUMBER]} -c copy -c:s mov_text "$DESTINATION/${DST_FILE##*/}_Subtitled.mp4" > $LOG 2>&1
	if-ffmpeg-cancel
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
	ARRAY_NUMBER=$((ARRAY_NUMBER+1))
done
progressbar-stop
echo "Finish Adding Subtitle to MP4 File" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*

exit 0
