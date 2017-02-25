#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
OPTION=""
SERVER=""
LOGIN=""
HOST=""
MOUNTPOINT=""

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" -gt "0" ]; then
        exit 0
    fi
}

connect() {
    echo $HOST >> ~/.kde-services/machines
    sort -u ~/.kde-services/machines > /tmp/machines
    mv /tmp/machines ~/.kde-services/machines
    mkdir $HOME/$HOST 2> /dev/null
    sshfs -o reconnect $LOGIN@$HOST:/ $HOME/$HOST
    dolphin --title="SSH Tools - $HOST" $HOME/$HOST 2> /dev/null
    exit 0
}

##############################
############ Main ############
##############################

if [ ! -s ~/.kde-services/machines ]; then
    mkdir ~/.kde-services 2> /dev/null
    echo localhost > ~/.kde-services/machines 2> /dev/null
fi

OPTION=$(kdialog --icon=ks-sshfs --title="SSH Tools - Mount point to Remote Directory" \
       --combobox="Select Option" "Mount Remote Directory" "Umount Remote Directory" --default "Mount Remote Directory" 2> /dev/null)
if-cancel-exit

if [ "$OPTION" = "Mount Remote Directory" ]; then
    SERVER=$(cat ~/.kde-services/machines)
    LOGIN=$(kdialog --icon=ks-sshfs --title="SSH Tools - Mount point to Remote Directory" --combobox="Select User" $USER root \
          --default $USER 2> /dev/null)
    if-cancel-exit
    HOST=$(kdialog --icon=ks-sshfs --title="SSH Tools - Mount point to Remote Directory" --combobox="Select Hostname or IP Address" $SERVER  \
           --default $(head -n1 ~/.kde-services/machines) 2> /dev/null)
    
    if [ "$?" -gt "0" ]; then
        HOST=$(kdialog --icon=ks-sshfs --title="SSH Tools - Mount point to Remote Directory" \
               --inputbox="Enter Hostname or IP Address" localhost.localdomain  2> /dev/null)
        if-cancel-exit
        connect
    fi
    
    connect

elif [ "$OPTION" = "Umount Remote Directory" ]; then
    MOUNTPOINT=$(mount |grep fuse.sshfs|awk -F " " '{print $3}')
    
    if [ "$MOUNTPOINT" = "" ]; then
        kdialog --icon=ks-sshfs --title="SSH Tools - Mount point to Remote Directory" \
                       --sorry="No Mount point: First Mount Remote Directory" 2> /dev/null
        exit 1
    fi
    
    HOST=$(kdialog --icon=ks-sshfs --title="SSH Tools - Mount point to Remote Directory" \
           --combobox="Select Mount point" $MOUNTPOINT  \
           --default $(echo $(mount |grep fuse.sshfs|awk -F " " '{print $3}')|xargs -n1 2> /dev/null|head -n1) 2> /dev/null)
    if-cancel-exit
    fusermount -zu $HOST && rm -rf $HOST
    kdialog --icon=ks-sshfs --title="SSH Tools - Mount point to Remote Directory" --passivepopup="[Finished]" 2> /dev/null
fi
