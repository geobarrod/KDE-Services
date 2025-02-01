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
DIR=""
DISRES=$(xrandr -q|grep current|awk -F , '{print $2}'|awk '{print $2,$4}'|sed 's/ /x/')
FILENAME=""
VCODEC=""
DESTINATION=""
FFPID=""

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
