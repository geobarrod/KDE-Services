#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2014-2025.                                                       #
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

DESTINATION=""
DEVICE=""
DIR=""
LABEL=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PB_PIDFILE="$(mktemp)"
SIZE=""
STERR=/tmp/dd.err

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ] || [ "$DEVICE" == "" ]; then
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="DiskCloner" --passivepopup="[Canceled]"
		exit 1
	fi
}

if-dd-error() {
	if [ "$?" != "0" ]; then
		kdialog --icon=ks-error --title="DiskCloner" --passivepopup="[Canceled]   $(cat $STERR). Try again"
		eject
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="DiskCloner" --passivepopup="[Canceled]"
		exit 1
	fi
}

progressbar-start() {
	kdialog --icon=ks-media-optical-clone --title="DiskCloner" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-media-optical-clone --title="DiskCloner" \
			--passivepopup="[Finished]  $LABEL.iso   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-media-optical-clone --title="DiskCloner" \
			--passivepopup="[Finished]   $LABEL.iso   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-media-optical-clone --title="DiskCloner" \
			--passivepopup="[Finished]   $LABEL.iso   Elapsed Time: ${ELAPSED_TIME}h"
	fi
}

##############################
############ Main ############
##############################

DIR=$1
cd "$DIR"
DIR=$(pwd)

if [ "$DIR" == "~/.local/share/applications" ]; then
	DIR="~/"
fi

DEVICE=$(kdialog --icon=ks-media-optical-clone --title="DiskCloner" --combobox="Select Device to Clone" "$(lsblk -po NAME,SIZE,LABEL|grep "sr[0-9]")" 2> /dev/null)
if-cancel-exit
LABEL="$(echo $DEVICE|awk -F" " '{print $3}')"
SIZE="$(echo $DEVICE|awk -F" " '{print $2}'|awk -F. '{print $1}')"
DEVICE=$(echo $DEVICE|awk -F" " '{print $1}')
DESTINATION=$(kdialog --icon=ks-media-optical-clone --title="Destination ISO Image File" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

progressbar-start
BEGIN_TIME=$(date +%s)
dd bs=2048 if=$DEVICE of="$DESTINATION/$LABEL.iso" 2> $STERR
if-dd-error
FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
progressbar-stop
echo "Finish Media Optical Clone" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak* $STERR
elapsedtime
eject

exit 0
