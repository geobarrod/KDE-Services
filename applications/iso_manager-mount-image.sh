#!/bin/bash

#################################################################
# For KDE-Services. 2012-2015.									#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>				#
# Improved by Victor Guardiola (vguardiola) Jan 5 2014			#
# 	-Fixed the problem of [dir|file]name with whitespaces.		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
MOUNTEXIT=""

##############################
############ Main ############
##############################

cd "${1%/*}"

if [ "$1" == "${1%.*}.iso" ]; then
   fuseiso -p "$1" "${1%.iso}"
   MOUNTEXIT=$?
else
   rename .ISO .iso *
   kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Mount ISO Image" \
                   --passivepopup="[Error] Can't mount ${1##*/}: Renamed extension of ISO image, because contain uppercase characters. Please try again."
   exit 1
fi

if [ "$MOUNTEXIT" = "0" ]; then
   kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-media-optical-mount.png --title="Mount ISO Image" --passivepopup="[Finished] ${1##*/} mounted."
else
   kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Mount ISO Image" \
                   --passivepopup="[Error] Can't mount ${1##*/}: Already mount or check image integrity."
   exit 1
fi

exit 0
