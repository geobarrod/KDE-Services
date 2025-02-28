#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2012-2025.                                                       #
#                                                                                 #
# BSD 3-Clause License                                                            #
#                                                                                 #
# Copyright (c) 2025, Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.  #
#                                                                                 #
# Redistribution and use in source and binary forms, with or without              #
# modification, are permitted provided that the following conditions are met:     #
#                                                                                 #
#  1. Redistributions of source code must retain the above copyright notice, this #
#     list of conditions and the following disclaimer.                            #
#                                                                                 #
#  2. Redistributions in binary form must reproduce the above copyright notice,   #
#     this list of conditions and the following disclaimer in the documentation   #
#     and/or other materials provided with the distribution.                      #
#                                                                                 #
#  3. Neither the name of the copyright holder nor the names of its               #
#     contributors may be used to endorse or promote products derived from        #
#     this software without specific prior written permission.                    #
#                                                                                 #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"     #
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE  #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE    #
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL      #
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR      #
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER      #
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   #
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE   #
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.            #
###################################################################################

DBUSREF=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
VCODE=""

URL=$(kdialog --icon=ks-youtube-video-code-collector --title="YouTube Video List Code Collector" --inputbox="Enter URL of YouTube videos list." 2> /dev/null)
if [ "$?" != "0" ]; then
	exit 1
fi

###################################
############ Functions ############
###################################

progressbar_start() {
	DBUSREF=$(kdialog --icon=ks-YouTube-video-code-collector --title="YouTube Video List Code Collector" --progressbar "Collecting YouTube video codes…" /ProcessDialog)
	sleep 1
}

progressbar_stop() {
	qdbus6 $DBUSREF close
}

##############################
############ Main ############
##############################

DIR=$1
cd "$DIR"
DIR=$(pwd)

mkdir -p $HOME/.kde-services
touch $HOME/.kde-services/youtube-video-codes

progressbar_start
lynx -source "$URL"

if [ "$?" != "0" ]; then
	progressbar_stop
	kdialog --icon=ks-error --title="YouTube Video List Code Collector" \
		--passivepopup="ERROR: Please check your network connection to URL: $URL"
	exit 1
fi

VCODE="$(lynx -source "$URL"|grep -o "watch?v=..........."|sed -e 's/^watch?v=//g'|uniq|xargs)"

if [ "$VCODE" != "" ]; then
	echo "$VCODE" > $HOME/.kde-services/youtube-video-codes
	progressbar_stop
	~/.local/share/applications/YouTube_Tools-download-video.sh
else
	progressbar_stop
	kdialog --icon=ks-warning --title="YouTube Video List Code Collector" \
		--passivepopup="WARNING: Not find YouTube video codes on this URL: $URL"
fi

exit 0

