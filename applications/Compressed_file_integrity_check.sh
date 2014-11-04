#!/bin/bash

#################################################################
# For KDE-Services. 2014.										#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>				#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
DIR="${1%/*}"
DBUSREF=""
FILE=$1
EXIT=""

###################################
############# Functions ###########
###################################

progressbar-start() {
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-compressed-file.png --caption="Compressed File Integrity Check" --progressbar " " 0)
}

progressbar-close() {
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Compressed file integrity checking to ${FILE##*/}"
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-compressed-file.png --title="Compressed File Integrity Check" \
                       --passivepopup="[Finished]  ${FILE##*/} is OK.   Elapsed Time: ${ELAPSED_TIME}s"
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-compressed-file.png --title="Compressed File Integrity Check" \
                       --passivepopup="[Finished]   ${FILE##*/} is OK.   Elapsed Time: ${ELAPSED_TIME}m"
    elif [ "$ELAPSED_TIME" -gt "3599" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-compressed-file.png --title="Compressed File Integrity Check" \
                       --passivepopup="[Finished]   ${FILE##*/} is OK.   Elapsed Time: ${ELAPSED_TIME}h"
    fi
}

exit-check() {
if [ "$EXIT" = "1" ]; then
	kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Compressed File Integrity Check" \
			--passivepopup="[Error]  ${FILE##*/}   Archive parsing failed! (Data is corrupted.)"
	qdbus $DBUSREF close
	exit 1
fi
while [ "$EXIT" = "2" ] || [ "$EXIT" = "1" ]; do
	PWD=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-compressed-file.png --title="Compressed File Integrity Check" \
			--password="The ${FILE##*/} archive is encrypted, requires a password for integrity check")
	lsar -t $FILE -p $PWD > /dev/null 2>&1
	EXIT=$?
done
}

###################################
############### Main ##############
###################################

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

progressbar-start
BEGIN_TIME=$(date +%s)
qdbusinsert
lsar -t $FILE > /dev/null 2>&1
EXIT=$?
exit-check
FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
progressbar-close
elapsedtime
exit 0
