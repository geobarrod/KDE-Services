#!/bin/bash

#################################################################
# For KDE Services. 2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
DIR=$(dirname "$1")
DBUSREF=""
COUNT=""
COUNTFILES=""
FILES=""

###################################
############# Functions ###########
###################################

exit-check() {
if [ "$?" != "0" ]; then
  exit 1
fi  
}

progressbar-start() {
    COUNT="0"
    COUNTFILES=$(echo $FILES|wc -w)
    COUNTFILES=$(expr $COUNTFILES + 1)
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-clock.png --caption="Change Timestamp To [File|Directory]" --progressbar "				" $COUNTFILES)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Change Timestamp To [File|Directory]:  $(basename $i)  [$COUNT/$(expr $COUNTFILES - 1)]"
    qdbus $DBUSREF Set "" value $COUNT
}

###################################
############### Main ##############
###################################

cd $DIR

if [ -d "$1" ]; then
  FILES=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-clock.png --title="Select Directory" --caption="Change Timestamp To [File|Directory]" --multiple --getexistingdirectory "$1")
  exit-check
elif [ -f "$1" ]; then
  FILES=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-clock.png --title="Select Files" --caption="Change Timestamp To [File|Directory]" --multiple --getopenfilename $DIR)
  exit-check
fi

TIMESTAMP=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-clock.png --caption="Change Timestamp To [File|Directory]" --inputbox="Enter New Timestamp" \
	    "$(date "+%Y-%m-%d %H:%M:%S")")
exit-check
progressbar-start

for i in $FILES; do
  COUNT=$(expr $COUNT + 1)
  qdbusinsert
  touch -cd "$TIMESTAMP" $i
done

progressbar-close
exit 0
