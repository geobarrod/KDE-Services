#!/bin/bash

#################################################################
# For KDE-Services. 2012-2017.					#
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
        exit 1
    fi
}

if-ffmpeg-cancel() {
    if [ "$?" != "0" ]; then
        kdialog --icon=ks-error --title="Record My Desktop" \
                       --passivepopup="[Canceled] Check the path and filename not contain spaces. Try again"
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
