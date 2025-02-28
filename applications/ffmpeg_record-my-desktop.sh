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

DESTINATION=""
DIR=""
DISRES=$(xrandr -q|grep current|awk -F , '{print $2}'|awk '{print $2,$4}'|sed 's/ /x/')
FFPID=""
FILENAME=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
VCODEC=""

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        exit 1
    fi
}

if-ffmpeg-cancel() {
    if [ "$?" != "0" ]; then
        kdialog --icon=ks-error --title="Record My Desktop" \
                       --passivepopup="[Canceled] Check the path and filename not contain whitespace. Try again"
    fi
}

record-cancel() {
    kdialog --icon=ks-media-tape --title="Record My Desktop" --yes-label Stop --no-label Cancel \
                   --yesno="Record My Desktop is running, saving video to $DESTINATION/$FILENAME.$VCODEC" 2> /dev/null
    
    if [ "$?" = "0" ] || [ "$?" != "0" ]; then
        kill -9 $FFPID
        exit 0
    fi
}

##############################
############ Main ############
##############################

DIR=$1
cd "$DIR"
DIR=$(pwd)

FILENAME=$(kdialog --icon=ks-media-tape --title="Record My Desktop" --inputbox="Enter Video Filename" "RecordMyDesktop_$HOSTNAME" 2> /dev/null)
if-cancel-exit

VCODEC=$(kdialog --icon=ks-media-tape --title="Record My Desktop" --menu="Choose Video Codec" avi "AVI" flv "FLV" mpg "MPEG-1" webm "WebM" 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=ks-media-tape --title="Destination Video" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit


ffmpeg -y -f x11grab -s $DISRES -i $DISPLAY -q:v 0 -b:v 1000k -mbd 2 -trellis 1 -sn -g 12 $DESTINATION/$FILENAME.$VCODEC &
if-ffmpeg-cancel
FFPID="$!"

record-cancel

exit 0
