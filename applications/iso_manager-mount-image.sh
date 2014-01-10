#!/bin/bash -x

#################################################################
# For KDE-Services. 2012-2014.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
# Improved by Victor Guardiola (vguardiola) Jan 5 2014		#
# 	-Fixed the problem of [dir|file]name with whitespaces.	#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
MOUNTEXIT=""

##############################
############ Main ############
##############################

DIR=$(dirname "$1")
cd "$DIR"

if [ "$(basename "$1" .ISO)" == "${1##*/}" ]; then
   fuseiso -p "$1" "${1%.iso}"
   MOUNTEXIT=$?
else
   rename .ISO .iso *
   kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Mount ISO Image" \
                   --passivepopup="[Error] Can't mount ISO image: Renamed extension of ISO image, because contain uppercase characters. Please try again."
   exit 1
fi

if [ "$MOUNTEXIT" = "0" ]; then
   kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-media-optical-mount.png --title="Mount ISO Image" --passivepopup="[Finished]"
else
   kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Mount ISO Image" \
                   --passivepopup="[Error] Can't mount ISO image: Already mount or check image integrity."
   exit 1
fi

exit 0
