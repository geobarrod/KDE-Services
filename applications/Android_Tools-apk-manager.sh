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
DIR=""
ELAPSED_TIME=""
FILES=""
FINAL_TIME=""
KDESU="kdesu"
KdialogPID=""
LOG="${0##*/}.log"
MyAPKs=/tmp/my-apks
OPERATION=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		kill -9 $KdialogPID 2>/dev/null
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="Android Package Manager" --passivepopup="[Canceled]"
		exit 1
	fi
}

if [ "$(pidof adb)" = "" ]; then
	$KDESU -i ks-android-apk-manager --noignorebutton -d -c "adb start-server"
	if-cancel-exit
fi

SERIAL=$(adb get-serialno)

check-device() {
	if [ "$SERIAL" = "unknown" ]; then
		kdialog --icon=ks-error --title="Android Package Manager" \
		--passivepopup="[Canceled]   Check if your device with Android system is connected on your PC and NOT bootloader mode. \
		[1]-Connect your device to PC USB. [2]-Go to device Settings. [3]-Go to Developer options. [4]-Enable USB debugging option. Try again."
		exit 1
	fi
}

check-device

progressbar-start() {
	kdialog --icon=ks-android-apk-manager --title="Android Package Manager" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-android-apk-manager --title="Android Package Manager" \
		--passivepopup="[Finished]   $OPERATION ${i##*/} on device $SERIAL.   $(cat $LOG|grep -v pkg).   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-android-apk-manager --title="Android Package Manager" \
		--passivepopup="[Finished]   $OPERATION ${i##*/} on device $SERIAL.   $(cat $LOG|grep -v pkg).   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-android-apk-manager --title="Android Package Manager" \
		--passivepopup="[Finished]   $OPERATION ${i##*/} on device $SERIAL.   $(cat $LOG|grep -v pkg).   Elapsed Time: ${ELAPSED_TIME}h"
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
    's/ /_/g')" 2>/dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")" "$(dirname \
    "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")"|sed 's/ /_/g')" 2>/dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")" "$(dirname "$(dirname \
    "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")"|sed 's/ /_/g')" 2>/dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")" "$(dirname "$(dirname "$(dirname \
    "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")"|sed 's/ /_/g')" 2>/dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname\
    "$(pwd|grep " ")")")")")"|sed 's/ /_/g')" 2>/dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")"\
    |sed 's/ /_/g')" 2>/dev/null
cd ./
mv "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")" "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")"|sed 's/ /_/g')" 2>/dev/null
cd ./
mv "$(dirname "$(dirname "$(pwd|grep " ")")")" "$(dirname "$(dirname "$(pwd|grep " ")")"|sed 's/ /_/g')" 2>/dev/null
cd ./
mv "$(dirname "$(pwd|grep " ")")" "$(dirname "$(pwd|grep " ")"|sed 's/ /_/g')" 2>/dev/null
cd ./
mv "$(pwd|grep " ")" "$(pwd|grep " "|sed 's/ /_/g')" 2>/dev/null
cd ./

for i in *; do
	mv "$i" "${i// /_}" 2>/dev/null
done

DIR="$(pwd)"

if [ "$DIR" == "~/.local/share/applications" ]; then
	DIR="~/"
fi

OPERATION=$(kdialog --icon=ks-android-apk-manager --title="Android Package Manager" \
       --combobox="Select Operation" Install Uninstall --default Install 2>/dev/null)
if-cancel-exit

if [ "$OPERATION" = "Install" ]; then
	FILES=$(kdialog --icon=ks-android-apk-manager --title="Android Package Manager - Select Apk Files" --multiple --getopenfilename "$DIR" "*.APK *.apk|*.apk" 2>/dev/null)
	if-cancel-exit
	progressbar-start

	for i in $FILES; do
		BEGIN_TIME=$(date +%s)
		adb install -r $i &> $LOG
		check-device
		FINAL_TIME=$(date +%s)
		ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
		elapsedtime
	done
elif [ "$OPERATION" = "Uninstall" ]; then
	adb shell su -c "ls -l /data/data/" > $MyAPKs
	cat $MyAPKs|sort -k 6|awk -F" " '{print $6}' > ${MyAPKs}2
	kdialog --icon=ks-android-apk-manager \
		--title="Android Package Manager - $(cat $MyAPKs|wc -l) applications" --textbox=${MyAPKs}2 450 450 2>/dev/null &
	KdialogPID=$(ps aux|grep "my-apks2"|grep -v grep|awk -F" " '{print $2}')
	FILES=$(kdialog --icon=ks-android-apk-manager --title="Android Package Manager" --inputbox="Enter Android applications from textbox separated by whitespace." 2>/dev/null)
	if-cancel-exit
	kill -9 $KdialogPID 2>/dev/null
	progressbar-start

	for i in $FILES; do
		BEGIN_TIME=$(date +%s)
		adb uninstall $i &> $LOG
		check-device
		FINAL_TIME=$(date +%s)
		ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
		elapsedtime
	done
fi
progressbar-stop
echo "Finish Android Package Manager Operation" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav
rm -fr /tmp/speak* $LOG $MyAPKs ${MyAPKs}2
exit 0
