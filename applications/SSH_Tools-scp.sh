#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
SERVER=""
HOST=""
LOGIN=""
PATHSEND=""

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" -gt "0" ]; then
        exit 0
    fi
}

##############################
############ Main ############
##############################

if [ -s ~/.kde-services/machines ]; then
    SERVER=$(cat ~/.kde-services/machines)
    HOST=$(kdialog --icon=ks-terminal --title="SSH Tools - Send To" --combobox="Select Hostname or IP Address" $SERVER \
           --default $(head -n1 ~/.kde-services/machines) 2> /dev/null)
    if-cancel-exit
    LOGIN=$(kdialog --icon=ks-terminal --title="SSH Tools - Send To $HOST" --combobox="Select User" $USER root \
          --default $USER 2> /dev/null)
    if-cancel-exit
    PATHSEND=$(kdialog --icon=ks-terminal --title="SSH Tools - Send To $HOST" --inputbox="Enter Path To Send" ~/ 2> /dev/null)
    if-cancel-exit
    scp -2pr "$1" $LOGIN@$HOST:$PATHSEND
    echo "Finish Send To Remote Server" > /tmp/speak
    text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
    play /tmp/speak.wav 2> /dev/null
    rm -fr /tmp/speak*
    kdialog --icon=ks-terminal --title="SSH Tools" --passivepopup="[Finished]   Send ${1##*/} To $HOST by $LOGIN" 2> /dev/null
    exit 0
else
    kdialog --icon=ks-terminal --title="SSH Tools - Send To $HOST by $LOGIN" \
                       --sorry="No Find Server: First Public Key Generation and Install Public Key in Remote Server" 2> /dev/null
    exit 1
fi
