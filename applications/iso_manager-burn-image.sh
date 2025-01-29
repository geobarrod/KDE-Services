#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2011-2025.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PID="$$"
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
FILE="$1"
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="Burn ISO-9660 Image" --passivepopup="[Canceled]"
		exit 1
	fi
}

progressbar-start() {
	kdialog --icon=ks-media-optical-burn --title="Burn ISO-9660 Image" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

##############################
############ Main ############
##############################

cd "${1%/*}"
BURNSPEED=$(kdialog --icon=ks-media-optical-burn --title="Burn ISO-9660 Image" \
		--combobox="Select Burn Speed Factor" 2 4 8 10 12 16 24 32 48 --default 4 2> /dev/null)
if-cancel-exit
progressbar-start
BEGIN_TIME=$(date +%s)
wodim -v blank=fast > burn_image.log
wodim -v speed=$BURNSPEED -eject "$1" >> burn_image.log
progressbar-stop
FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))

if [ "$ELAPSED_TIME" -lt "60" ]; then
	kdialog --icon=ks-media-optical-burn --title="Burn ISO-9660 Image" \
		--passivepopup="[Finished]   ${FILE##*/}   Elapsed Time: ${ELAPSED_TIME}s" 2> /dev/null
elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
	ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
	kdialog --icon=ks-media-optical-burn --title="Burn ISO-9660 Image" \
		--passivepopup="[Finished]   ${FILE##*/}   Elapsed Time: ${ELAPSED_TIME}m" 2> /dev/null
elif [ "$ELAPSED_TIME" -gt "3599" ]; then
	ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
	kdialog --icon=ks-media-optical-burn --title="Burn ISO-9660 Image" \
		--passivepopup="[Finished]   ${FILE##*/}   Elapsed Time: ${ELAPSED_TIME}h" 2> /dev/null
fi

echo "Finish Burn Image" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav 2> /dev/null
rm -fr /tmp/speak*
rm -f burn_image.log
exit 0
