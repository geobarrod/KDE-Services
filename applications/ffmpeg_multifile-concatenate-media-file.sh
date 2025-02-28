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

BEGIN_TIME=""
DESTINATION=""
DIR=""
ELAPSED_TIME=""
FILE_LIST="/tmp/ConcatenateMediaFilesSameCodec"
FILENAME=""
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

