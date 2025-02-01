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
# KDE-Services ⚙ 2012-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

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
