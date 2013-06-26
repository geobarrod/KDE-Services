#!/bin/bash

#################################################################
# For KDE Services. 2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
FORMAT=""
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
COUNT=""
COUNTFILES=""
FILES=""
DESTINATION=""
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
        kdialog --icon=application-exit --title="Image Converter" \
            --passivepopup="[Canceled]   $(basename $i)                                             \
            Check the path and filename not contain whitespaces. Check image format errors. Try again."
        continue
    fi
}

progressbar-start() {
    COUNT="0"
    COUNTFILES=$(echo $FILES|wc -w)
    COUNTFILES=$(expr $COUNTFILES + 1)
    DBUSREF=$(kdialog --icon=image-x-generic --caption="Image Converter" --progressbar "                                         " $COUNTFILES)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Converting:  $(basename $i) to $FORMAT [$COUNT/$(expr $COUNTFILES - 1)]"
    qdbus $DBUSREF Set "" value $COUNT
}

elapsedtime() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=image-x-generic --title="Image Converter" --passivepopup="[Finished]	Elapsed Time: $ELAPSED_TIME s."
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=image-x-generic --title="Image Converter" --passivepopup="[Finished]	Elapsed Time: $ELAPSED_TIME m."
    elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=image-x-generic --title="Image Converter" --passivepopup="[Finished]	Elapsed Time: $ELAPSED_TIME h."
    elif [ "$ELAPSED_TIME" -gt "86399" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
        kdialog --icon=image-x-generic --title="Image Converter" --passivepopup="[Finished]	Elapsed Time: $ELAPSED_TIME d."
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

RENAMETMP=$(ls *.bmp *.eps *.gif *.ico *.jp2 *.jpeg *.jpg *.pbm *.pgm *.png *.ppm *.psd *.sgi *.svg *.tga *.tif *.tiff *.xpm *.BMP *.EPS \
          *.GIF *.ICO *.JP2 *.JPEG *.JPG *.PBM *.PGM *.PNG *.PPM *.PSD *.SGI *.SVG *.TGA *.TIF *.TIFF *.XPM 2> /dev/null|grep " " \
          > /tmp/image-resize-convert.ren)

RENAME=$(cat /tmp/image-resize-convert.ren)

for i in $RENAME; do
    mv *$i* $(ls *$i*|sed 's/ /_/g')
done

FILES=$(kdialog --icon=image-x-generic --caption="Source Image Files" --multiple \
      --getopenfilename "$DIR" "*.bmp *.eps *.gif *.ico *.jp2 *.jpeg *.jpg *.pbm *.pgm *.png *.ppm *.psd *.sgi *.svg \
      *.tga *.tif *.tiff *.xpm *.BMP *.EPS *.GIF *.ICO *.JP2 *.JPEG *.JPG *.PBM *.PGM *.PNG *.PPM *.PSD *.SGI *.SVG *.TGA \
      *.TIF *.TIFF *.XPM|All supported files" 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=image-x-generic --caption="Destination Image Files" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

FORMAT=$(kdialog --icon=image-x-generic --caption="Image Converter" \
       --combobox="Select Format" BMP EPS GIF ICO JPEG "JPEG 2000" PBM PDF PGM PNG PPM PSD SGI TGA TIFF XPM --default PNG)
if-cancel-exit

BEGIN_TIME=$(date +%s)
progressbar-start

if [ "$FORMAT" = "BMP" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.bmp"
        if-convert-cancel
    done
elif [ "$FORMAT" = "EPS" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.eps"
        if-convert-cancel
    done
elif [ "$FORMAT" = "GIF" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 -transparent white "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.gif"
        if-convert-cancel
    done
elif [ "$FORMAT" = "ICO" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 -transparent white -resize 128 "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.ico"
        if-convert-cancel
    done
elif [ "$FORMAT" = "JPEG" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.jpg"
        if-convert-cancel
    done
elif [ "$FORMAT" = "JPEG 2000" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 75 "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.jp2"
        if-convert-cancel
    done
elif [ "$FORMAT" = "PBM" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.pbm"
        if-convert-cancel
    done
elif [ "$FORMAT" = "PDF" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.pdf"
        if-convert-cancel
    done
elif [ "$FORMAT" = "PGM" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.pgm"
        if-convert-cancel
    done
elif [ "$FORMAT" = "PNG" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 -transparent white "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.png"
        if-convert-cancel
    done
elif [ "$FORMAT" = "PPM" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.ppm"
        if-convert-cancel
    done
elif [ "$FORMAT" = "PSD" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 -transparent white "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.psd"
        if-convert-cancel
    done
elif [ "$FORMAT" = "SGI" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 -transparent white "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.sgi"
        if-convert-cancel
    done
elif [ "$FORMAT" = "TGA" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 -transparent white "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.tga"
        if-convert-cancel
    done
elif [ "$FORMAT" = "TIFF" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 -transparent white "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.tif"
        if-convert-cancel
    done
elif [ "$FORMAT" = "XPM" ]; then
    for i in $FILES; do
        COUNT=$(expr $COUNT + 1)
        qdbusinsert
        convert $i -quality 100 -transparent white "`echo $DESTINATION/$(basename $i) | perl -pe 's/\\.[^.]+$//'`.xpm"
        if-convert-cancel
    done
fi

FINAL_TIME=$(date +%s)
ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
elapsedtime

progressbar-close
echo "Finish Image Converter" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav 2> /dev/null
rm -fr /tmp/speak* /tmp/image-resize-convert*

exit 0
