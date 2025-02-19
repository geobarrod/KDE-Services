#!/usr/bin/env bash
########################################################################
# This program is free software; you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation; either version 3 of the License, or    #
# (at your option) any later version.                                  #
#                                                                      #
# This program is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License for more details.                         #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with this program; if not, write to the Free Software          #
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,           #
# MA 02110-1301, USA.                                                  #
#                                                                      #
#                                                                      #
# KDE-Services ⚙ 2013-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
FORMAT=""
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
FILES=""
DESTINATION=""
DIR=""
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="Image Converter" --passivepopup="[Canceled]"
		exit 1
	fi
}

if-convert-cancel() {
	if [ "$?" != "0" ]; then
		kdialog --icon=ks-error --title="Image Converter" \
			--passivepopup="[Canceled]   ${i##*/}                                             \
			Check the path and filename not contain whitespaces. Check image format errors. Try again."
		continue
	fi
}

progressbar-start() {
	kdialog --icon=ks-image --title="Image Converter" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-image --title="Image Converter" --passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-image --title="Image Converter" --passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-image --title="Image Converter" --passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}h"
	elif [ "$ELAPSED_TIME" -gt "86399" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-image --title="Image Converter" --passivepopup="[Finished]   ${i##*/}   Elapsed Time: ${ELAPSED_TIME}d"
	fi
}

##############################
############ Main ############
##############################

DIR="${1%/*}"
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

FILES=$(kdialog --icon=ks-image --title="Source Image Files" --multiple \
		--getopenfilename "$DIR" "*.bmp *.eps *.gif *.ico *.jp2 *.jpeg *.jpg *.pbm *.pgm * *.ppm *.psd *.sgi *.svg \
		*.tga *.tif *.tiff *.xpm *.BMP *.EPS *.GIF *.ICO *.JP2 *.JPEG *.JPG *.PBM *.PGM *.PNG *.PPM *.PSD *.SGI *.SVG *.TGA \
		*.TIF *.TIFF *.XPM|*.bmp *.eps *.gif *.ico *.jp2 *.jpeg *.jpg *.pbm *.pgm * *.ppm *.psd *.sgi *.svg *.tga *.tif *.tiff *.xpm" 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=ks-image --title="Destination Image Files" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit

FORMAT=$(kdialog --icon=ks-image --title="Image Converter" \
		--combobox="Select Format" BMP EPS GIF ICO JPEG "JPEG 2000" PBM PDF PGM PNG PPM PSD SGI TGA TIFF XPM --default PNG)
if-cancel-exit

BEGIN_TIME=$(date +%s)
progressbar-start

if [ "$FORMAT" = "BMP" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 "$DESTINATION/${DST_FILE##*/}.bmp"
		if-convert-cancel
	done
elif [ "$FORMAT" = "EPS" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 "$DESTINATION/${DST_FILE##*/}.eps"
		if-convert-cancel
	done
elif [ "$FORMAT" = "GIF" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 -transparent white "$DESTINATION/${DST_FILE##*/}.gif"
		if-convert-cancel
	done
elif [ "$FORMAT" = "ICO" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 -transparent white -resize 128 "$DESTINATION/${DST_FILE##*/}.ico"
		if-convert-cancel
	done
elif [ "$FORMAT" = "JPEG" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 "$DESTINATION/${DST_FILE##*/}.jpg"
		if-convert-cancel
	done
elif [ "$FORMAT" = "JPEG 2000" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 75 "$DESTINATION/${DST_FILE##*/}.jp2"
		if-convert-cancel
	done
elif [ "$FORMAT" = "PBM" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 "$DESTINATION/${DST_FILE##*/}.pbm"
		if-convert-cancel
	done
elif [ "$FORMAT" = "PDF" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 "$DESTINATION/${DST_FILE##*/}.pdf"
		if-convert-cancel
	done
elif [ "$FORMAT" = "PGM" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 "$DESTINATION/${DST_FILE##*/}.pgm"
		if-convert-cancel
	done
elif [ "$FORMAT" = "PNG" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 -transparent white "$DESTINATION/${DST_FILE##*/}"
		if-convert-cancel
	done
elif [ "$FORMAT" = "PPM" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 "$DESTINATION/${DST_FILE##*/}.ppm"
		if-convert-cancel
	done
elif [ "$FORMAT" = "PSD" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 -transparent white "$DESTINATION/${DST_FILE##*/}.psd"
		if-convert-cancel
	done
elif [ "$FORMAT" = "SGI" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 -transparent white "$DESTINATION/${DST_FILE##*/}.sgi"
		if-convert-cancel
	done
elif [ "$FORMAT" = "TGA" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 -transparent white "$DESTINATION/${DST_FILE##*/}.tga"
		if-convert-cancel
	done
elif [ "$FORMAT" = "TIFF" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 -transparent white "$DESTINATION/${DST_FILE##*/}.tif"
		if-convert-cancel
	done
elif [ "$FORMAT" = "XPM" ]; then
	for i in $FILES; do
		DST_FILE="${i%.*}"
		convert $i -quality 100 -transparent white "$DESTINATION/${DST_FILE##*/}.xpm"
		if-convert-cancel
	done
fi

FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
elapsedtime

progressbar-stop
echo "Finish Image Converter" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav 2> /dev/null
rm -fr /tmp/speak* /tmp/image-resize-convert*

exit 0
