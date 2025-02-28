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
CODEC=""
DESTINATION=""
DIR=""
DVD_NAME=""
ELAPSED_TIME=""
FILES=""
FINAL_TIME=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PB_PIDFILE="$(mktemp)"
PID="$$"
VIDEOINFO=/tmp/video.inf

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		rm -fr $VIDEOINFO
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="DVD Assembler" --passivepopup="[Canceled]"
		exit 1
	fi
}

if-dvdauthor-cancel() {
	if [ "$?" != "0" ]; then
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="DVD Assembler ($DVD_NAME)" \
			--passivepopup="[Canceled]   Check the path and filename not contain whitespaces. Check video format errors. Try again"
		exit 1
	fi
}

progressbar-start() {
	kdialog --icon=ks-media-optical-video --title="DVD Assembler" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

##############################
############ Main ############
##############################

DIR=$1
cd "$DIR"

mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")")" \
    "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")"|\
    sed 's/ /_/g')" 2> /dev/null
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
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname \
    "$(pwd|grep " ")")")")")"|sed 's/ /_/g')" 2> /dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")"|\
    sed 's/ /_/g')" 2> /dev/null
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

FILES=$(kdialog --icon=ks-media-optical-video --title="Source Video Files" --multiple \
		--getopenfilename "$DIR" "*.mp2 *.mpe *.mpeg *.mpg *.vob *.MP2 *.MPE *.MPEG *.MPG *.VOB|MPEG-2 files" 2> /dev/null)
if-cancel-exit

for VIDEO in $FILES; do
	ffprobe "$VIDEO" 2> $VIDEOINFO
	CODEC=$(grep -o mpeg2video $VIDEOINFO)
	if [ "$CODEC" != "mpeg2video" ]; then
		kdialog --icon=ks-error --title="DVD Assembler" \
			--passivepopup="[Excluded]   The video file ($VIDEO) isn't MPEG-2 stream." 2> /dev/null
		FILES=$(echo $FILES|sed "s;$VIDEO;;")
		if [ "$(echo $FILES)" = "" ]; then
			kdialog --icon=ks-error --title="DVD Assembler" --passivepopup="[Canceled]   Nothing to do." 2> /dev/null
			rm -fr $VIDEOINFO
			exit 1
		fi
		rm -fr $VIDEOINFO
	fi
done

DVD_NAME=$(kdialog --icon=ks-media-optical-video --title="DVD Assembler" --inputbox="Enter DVD name without whitespaces." 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=ks-media-optical-video --title="Destination DVD" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

progressbar-start

BEGIN_TIME=$(date +%s)

dvdauthor -tf $FILES -O $DESTINATION/$DVD_NAME
if-dvdauthor-cancel

genisoimage -R -J -o $DESTINATION/$DVD_NAME.iso $DESTINATION/$DVD_NAME

rm -fr $DESTINATION/$DVD_NAME
progressbar-stop

FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))

if [ "$ELAPSED_TIME" -lt "60" ]; then
	kdialog --icon=ks-media-optical-video --title="DVD Assembler" \
		--passivepopup="[Finished]   $DVD_NAME.iso    Elapsed Time: ${ELAPSED_TIME}s"
elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
	ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
	kdialog --icon=ks-media-optical-video --title="DVD Assembler" \
		--passivepopup="[Finished]   $DVD_NAME.iso   Elapsed Time: ${ELAPSED_TIME}m"
elif [ "$ELAPSED_TIME" -gt "3599" ]; then
	ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
	kdialog --icon=ks-media-optical-video --title="DVD Assembler" \
		--passivepopup="[Finished]   $DVD_NAME.iso   Elapsed Time: ${ELAPSED_TIME}h"
fi

echo "Finish DVD Assembler" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak*

exit 0

