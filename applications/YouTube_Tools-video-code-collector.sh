#!/usr/bin/env bash

#################################################################
# For KDE-Services. 2012-2025.                                  #
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>              #
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
VCODE=""
PB_PIDFILE="$(mktemp)"

URL=$(kdialog --icon=ks-youtube-video-code-collector --title="Youtube Video List Code Collector" --inputbox="Enter URL YouTube videos list." 2> /dev/null)

if [ "$?" != "0" ]; then
	exit 0
fi

###################################
############ Functions ############
###################################

progressbar-start() {
	kdialog --icon=ks-youtube-video-code-collector --title="Youtube Video List Code Collector" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
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
lynx -source "$URL"

if [ "$?" != "0" ]; then
	progressbar-stop
	kdialog --icon=ks-error --title="Youtube Video List Code Collector" \
		--passivepopup="[Error]   Check network connection to URL:  $URL"
	exit 0
fi

VCODE="$(lynx -source "$URL"|grep -o "watch?v=..........."|sed -e 's/^watch?v=//g'|uniq|xargs)"

if [ "$VCODE" != "" ]; then
	echo "$VCODE" > $HOME/.kde-services/youtube-video-codes
	progressbar-stop
	~/.local/share/applications/YouTube_Tools-download-video.sh
else
	progressbar-stop
	kdialog --icon=ks-warning --title="Youtube Video List Code Collector" \
		--passivepopup="[Warning]   Not find YouTube video codes on this URL:  $URL"
fi

exit 0
