#!/bin/bash

#################################################################
# For KDE Services. 2012-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
VCODE=""
DBUSREF=""

URL=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-video-code-collector.png --caption="Youtube Video List Code Collector" --inputbox="Enter URL YouTube videos list." \
    2> /dev/null)

if [ "$?" != "0" ]; then
    exit 0
fi

###################################
############ Functions ############
###################################

progressbar-start() {
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-youtube-video-code-collector.png --caption="Youtube Video List Code Collector" --progressbar "           " /ProcessDialog)
}

progressbar-close() {
    qdbus $DBUSREF close
}

##############################
############ Main ############
##############################

DIR=$1
cd "$DIR"
DIR=$(pwd)

mkdir -p $HOME/.kde-services
touch $HOME/.kde-services/youtube-video-codes

progressbar-start
qdbus $DBUSREF setLabelText "Checking Availability..."
sleep 3

lynx -source "$URL"

if [ "$?" != "0" ]; then
    progressbar-close
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Youtube Video List Code Collector" \
                   --passivepopup="[Error]   Check network connection to URL:  $URL"
    exit 0
fi

VCODE="$(lynx -source "$URL"|grep -o "watch?v=..........."|sed -e 's/^watch?v=//g'|uniq|xargs)"

if [ "$VCODE" != "" ]; then
    echo "$VCODE" > $HOME/.kde-services/youtube-video-codes
    qdbus $DBUSREF setLabelText "Youtube video codes are captured. Launching YouTube Video Downloader..."
    sleep 3
    progressbar-close
    /usr/share/applications/YouTube_Tools-download-video.sh
else
    progressbar-close
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-warning.png --title="Youtube Video List Code Collector" \
                   --passivepopup="[Warning]   Not find YouTube video codes on this URL:  $URL"
fi

exit 0
