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

BEGIN_TIME=""
ELAPSED_TIME=""
FINAL_TIME=""
LOG=multiplex-subtitle.log
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PB_PIDFILE="$(mktemp)"
PID="$$"
TMPFILE=/tmp/multiplex-subtitle.xml
VIDEO="$1"
VIDEOINFO=/tmp/videoinfo

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		rm -fr $TMPFILE $LOG $VIDEOINFO
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="Multiplex Subtitle" --passivepopup="[Canceled]"
		exit 1
	fi
}

progressbar-start() {
	kdialog --icon=ks-multiplexing-subs --title="Multiplex Subtitle" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

##############################
############ Main ############
##############################

cd "${VIDEO%/*}"

ffprobe "$VIDEO" 2> $VIDEOINFO
CODEC=$(grep -o mpeg2video $VIDEOINFO)

if [ "$CODEC" != "mpeg2video" ]; then
	kdialog --icon=ks-error --title="Multiplex Subtitle" --passivepopup="[Canceled]   The video file isn't MPEG-2 stream."
	rm -fr $VIDEOINFO
else
	DIR="$(pwd)"
	SUBTITLE=$(kdialog --icon=ks-multiplexing-subs --title="Text Based Subtitle" \
			--getopenfilename "$DIR" "*.aqt *.ass *.js *.jss *.rt *.smi *.srt *.ssa *.sub *.txt" 2> /dev/null)
	if-cancel-exit

	FILEENCODE=$(file -b --mime-encoding $SUBTITLE|tr a-z A-Z)
	recode $FILEENCODE..UTF-8 $SUBTITLE

	cat > $TMPFILE << EOF
<subpictures format="NTSC">
  <stream>
    <textsub filename="$SUBTITLE"
    characterset="UTF-8"
    horizontal-alignment="center"
    left-margin="57"
    right-margin="57"
    bottom-margin="23"
    top-margin="23"
    fontsize="22.0"
    force="yes"
    vertical-alignment="bottom" />
  </stream>
</subpictures>
EOF

	DESTINATION="${VIDEO%.*}_subtitled.mpg"

	progressbar-start
	BEGIN_TIME=$(date +%s)

	spumux "$TMPFILE" < "$VIDEO" > "${VIDEO%.*}_subtitled.mpg" 2> $LOG
	EXIT=$?

	if [ "$EXIT" = "0" ];then
		progressbar-stop
		FINAL_TIME=$(date +%s)
		ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))

		if [ "$ELAPSED_TIME" -lt "60" ]; then
			kdialog --icon=ks-multiplexing-subs --title="Multiplex Subtitle" \
				--passivepopup="[Finished]   ${VIDEO##*/}   Elapsed Time: ${ELAPSED_TIME}s"
		elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
			ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
			kdialog --icon=ks-multiplexing-subs --title="Multiplex Subtitle" \
				--passivepopup="[Finished]   ${VIDEO##*/}   Elapsed Time: ${ELAPSED_TIME}m"
		elif [ "$ELAPSED_TIME" -gt "3599" ]; then
			ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
			kdialog --icon=ks-multiplexing-subs --title="Multiplex Subtitle" \
				--passivepopup="[Finished]   ${VIDEO##*/}   Elapsed Time: ${ELAPSED_TIME}h"
		fi

		echo "Finish Multiplexing Subtitle" > /tmp/speak
		text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
		play /tmp/speak.wav
		rm -fr /tmp/speak* $TMPFILE $LOG $VIDEOINFO
	else
		progressbar-stop
		kdialog --icon=ks-error --title="Multiplex Subtitle" \
			--passivepopup="[Canceled]   See $LOG file. The encoding of the subtitle file have to be UTF-8."
		rm -fr $TMPFILE $VIDEOINFO
	fi
fi

exit 0
