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
# KDE-Services ⚙ 2011-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
DESTINATION=""
DIR=""
PID="$$"
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
LOG=""
LOGERROR=""
FILENAME=""
FILE_LIST="/tmp/ConcatenateMediaFilesSameCodec"
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

logs() {
	LOG="/tmp/$FILENAME.log"
	LOGERROR="$FILENAME.err"
	rm -f $LOGERROR
}

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="Concatenate Media Files with Same Codec" --passivepopup="[Canceled]"
		exit 1
	fi
}

if-ffmpeg-cancel() {
	if [ "$?" != "0" ]; then
		kdialog --icon=ks-error --title="Concatenating $FILENAME" \
			--passivepopup="[Canceled]   Check the path and filename not contain whitespaces. Check error log $LOGERROR. Try again"
		mv $LOG $DESTINATION/$LOGERROR
		continue
	fi
}

delete-file-list() {
	rm -f $FILE_LIST
}

progressbar-start() {
	kdialog --icon=ks-concatenate-media-file --title="Concatenate Media Files with Same Codec" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-concatenate-media-file --title="Concatenate Media Files with Same Codec" \
			--passivepopup="[Finished]  $FILENAME   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-concatenate-media-file --title="Concatenate Media Files with Same Codec" \
			--passivepopup="[Finished]   $FILENAME   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-concatenate-media-file --title="Concatenate Media Files with Same Codec" \
			--passivepopup="[Finished]   $FILENAME   Elapsed Time: ${ELAPSED_TIME}h"
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

FILES=$(kdialog --icon=ks-concatenate-media-file --title="Concatenate Media Files with Same Codec" --multiple --getopenfilename "$DIR" "*.3GP *.3gp *.AVI *.avi *.DAT \
	*.dat *.DV *.dv *.FLAC *.flac *.FLV *.flv *.M2V *.m2v *.M4A *.m4a *.M4V *.m4v *.MKV *.mkv *.MOV *.mov *.MP3 *.mp3 *.MP4 *.mp4 *.MPEG *.mpeg *.MPEG4 *.mpeg4 *.MPG *.mpg *.OGG *.ogg *.OGV *.ogv *.VOB *.vob \
	*.WAV *.wav *.WEBM *.webm *.WMA *.wma *.WMV *.wmv|*.3gp *.avi *.dat *.dv *.flac *.flv *.m2v *.m4a *.m4v *.mkv *.mov *.mp3 *.mp4 *.mpeg *.mpeg4 *.mpg *.ogg *.ogv *.vob *.wav *.webm *.wma *.wmv" 2> /dev/null)
if-cancel-exit

FILENAME=$(kdialog --icon=ks-concatenate-media-file --title="Concatenate Media Files with Same Codec" \
			--inputbox="Enter filename without whitespaces for new concatenated media file" New_Concatenated_Media_File)
if-cancel-exit

DESTINATION=$(kdialog --icon=ks-concatenate-media-file --title="Destination Media Files" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

delete-file-list
progressbar-start
logs
BEGIN_TIME=$(date +%s)
for f in $FILES; do
	echo "file '$f'" >> $FILE_LIST
done
ffmpeg -y -f concat -safe 0 -i $FILE_LIST -c copy "$DESTINATION/$FILENAME.mkv" > $LOG 2>&1
if-ffmpeg-cancel
FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
elapsedtime
progressbar-stop
delete-file-list

echo "Finish Concatenate Media Files with Same Codec" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*

exit 0
