#!/bin/bash

#################################################################
# For KDE-Services. 2012-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
SIZE=""
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
COUNT=""
COUNTFILES=""
FILES=""
DESTINATION=""
PIXEL="p"
DIR=""

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        qdbus $DBUSREF close
        exit 0
    fi
}

if-convert-cancel() {
    if [ "$?" != "0" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Image Resizer" \
            --passivepopup="[Canceled]   $(basename $i)                                             \
            Check the path and filename not contain whitespaces. Check image format errors. Check if the file format support resize to $SIZE pixels. Try again."
        continue
    fi
}

progressbar-start() {
    COUNT="0"
    COUNTFILES=$(echo $FILES|wc -w)
    COUNTFILES=$(expr $COUNTFILES + 1)
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-resize-image.png --caption="Image Resizer" --progressbar "                                         " $COUNTFILES)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Redimensioning:  $(basename $i) to $SIZE$PIXEL  [$COUNT/$(expr $COUNTFILES - 1)]"
    qdbus $DBUSREF Set "" value $COUNT
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-resize-image.png --title="Image Resizer" --passivepopup="[Finished]	Elapsed Time: $ELAPSED_TIME s."
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-resize-image.png --title="Image Resizer" --passivepopup="[Finished]	Elapsed Time: $ELAPSED_TIME m."
    elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-resize-image.png --title="Image Resizer" --passivepopup="[Finished]	Elapsed Time: $ELAPSED_TIME h."
    elif [ "$ELAPSED_TIME" -gt "86399" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-resize-image.png --title="Image Resizer" --passivepopup="[Finished]	Elapsed Time: $ELAPSED_TIME d."
    fi
}

##############################
############ Main ############
##############################

cd $(dirname "$1")

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
DIR=$(pwd)
mv "$(pwd|grep " ")" "$(pwd|grep " "|sed 's/ /_/g')" 2> /dev/null

if [ "$?" != "0" ]; then
    cd ./
else
    cd "$(pwd|grep " "|sed 's/ /_/g')"
    DIR=$(pwd)
fi

RENAMETMP=$(ls *.bmp *.eps *.gif *.ico *.jp2 *.jpeg *.jpg *.pbm *.pgm *.png *.ppm *.psd *.sgi *.tga *.tif *.tiff *.xpm *.BMP *.EPS \
          *.GIF *.ICO *.JP2 *.JPEG *.JPG *.PBM *.PGM *.PNG *.PPM *.PSD *.SGI *.TGA *.TIF *.TIFF *.XPM 2> /dev/null|grep " " \
          > /tmp/image-resize-convert.ren)

RENAME=$(cat /tmp/image-resize-convert.ren)

for i in $RENAME; do
    mv *$i* $(ls *$i*|sed 's/ /_/g')
done

FILES=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-resize-image.png --caption="Source Image Files" --multiple \
      --getopenfilename "$DIR" "*.bmp *.eps *.gif *.ico *.jp2 *.jpeg *.jpg *.pbm *.pgm *.png *.ppm *.psd *.sgi \
      *.tga *.tif *.tiff *.xpm *.BMP *.EPS *.GIF *.ICO *.JP2 *.JPEG *.JPG *.PBM *.PGM *.PNG *.PPM *.PSD *.SGI *.TGA \
      *.TIF *.TIFF *.XPM|All supported files" 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-resize-image.png --caption="Destination Image Files" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

SIZE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-resize-image.png --caption="Image Resizer" --inputbox="Enter size in pixels for frame width")
if-cancel-exit

BEGIN_TIME=$(date +%s)
progressbar-start

for i in $FILES; do
    COUNT=$(expr $COUNT + 1)
    qdbusinsert
    convert -resize $SIZE $i "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`_$SIZE$PIXEL.$(basename $i|cut -d. -f2)"
    if-convert-cancel
done

FINAL_TIME=$(date +%s)
ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
elapsedtime

progressbar-close
echo "Finish Image Resize" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav 2> /dev/null
rm -fr /tmp/speak* /tmp/image-resize-convert*

exit 0
