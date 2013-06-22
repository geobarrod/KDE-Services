#!/bin/bash

#################################################################
# For KDE Services. 2012-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
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
        exit 0
    fi
}

if-ffmpeg-cancel() {
    if [ "$?" != "0" ]; then
        kdialog --icon=application-exit --title="Record My Desktop" \
                       --passivepopup="[Canceled] Check the path and filename not contain spaces. Try again"
    fi
}

record-cancel() {
    kdialog --icon=media-tape --caption="Record My Desktop" --yes-label Stop --no-label Cancel \
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

FILENAME=$(kdialog --icon=media-tape --caption="Record My Desktop" --inputbox="Enter Video Filename" "RecordMyDesktop" 2> /dev/null)
if-cancel-exit

VCODEC=$(kdialog --icon=media-tape --caption="Record My Desktop" --menu="Choose Video Codec" mpg "MPEG-1" flv "FLV" avi "AVI" \
       --geometry 100x100+10240 2> /dev/null)
if-cancel-exit

DESTINATION=$(kdialog --icon=media-tape --caption="Destination Video" --getexistingdirectory "$DIR" 2> /dev/null)
if-cancel-exit


ffmpeg -y -f x11grab -s $DISRES -r 25 -sameq -mbd 2 -trellis 1 -sn -g 12 -i $DISPLAY $DESTINATION/$FILENAME.$VCODEC &
if-ffmpeg-cancel
FFPID="$!"

record-cancel

exit 0
