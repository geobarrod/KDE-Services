#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
COUNT=""
COUNTFILES=""
FILE="$@"

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        qdbus $DBUSREF close
        exit 1
    fi
}

if-avisplit-cancel() {
    if [ "$?" != "0" ]; then
        qdbus $DBUSREF close
        kdialog --icon=ks-error --title="AVI Split (To Size)" \
                       --passivepopup="[Canceled]   Check the path and filename not contain spaces. Check video format errors. Try again"
        exit 1
    fi
}

progressbar-start() {
    COUNT="0"
    COUNTFILES=$(echo $FILE|wc -w)
    COUNTFILES=$((++COUNTFILES))
    DBUSREF=$(kdialog --icon=ks-video --title="AVI Split (To Size)" --progressbar "\t\t\t\t\t\t\t" $COUNTFILES)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "AVI Split (To Size):  ${file##*/}  [$COUNT/$((COUNTFILES-1))]"
    qdbus $DBUSREF Set "" value $COUNT
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=ks-video --title="AVI Split (To Size)" \
                       --passivepopup="[Finished]	${file##*/}   Elapsed Time: ${ELAPSED_TIME}s"
        
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=ks-video --title="AVI Split (To Size)" \
                       --passivepopup="[Finished]	${file##*/}   Elapsed Time: ${ELAPSED_TIME}m"
        
    elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=ks-video --title="AVI Split (To Size)" \
                       --passivepopup="[Finished]	${file##*/}   Elapsed Time: ${ELAPSED_TIME}h"
        
    elif [ "$ELAPSED_TIME" -gt "86399" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
        kdialog --icon=ks-video --title="AVI Split (To Size)" \
                       --passivepopup="[Finished]	${file##*/}   Elapsed Time: ${ELAPSED_TIME}d"
    fi
}

##############################
############ Main ############
##############################

SIZE=$(kdialog --icon=ks-video --title="AVI Split (To Size)" --inputbox="Enter size in MBytes" 2> /dev/null)
if-cancel-exit
progressbar-start

for file in $FILE; do
	COUNT=$((++COUNT))
	qdbusinsert
	BEGIN_TIME=$(date +%s)
	avisplit -s $SIZE -i "$file" -o "${file%.*}_Size-Edited.avi"
	if-avisplit-cancel
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
done

progressbar-close
echo "Finish Splitting AVI" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav 2> /dev/null
rm -fr /tmp/speak*

exit 0
