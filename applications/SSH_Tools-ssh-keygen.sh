#!/bin/bash

#################################################################
# For KDE-Services. 2011-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

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

LOGIN=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-keygen.png --caption="SSH Tools - Public Key Generation" --combobox="Select User" $USER root --default $USER 2> /dev/null)
if-cancel-exit

if [ "$LOGIN" = "$USER" ]; then
    xterm -si -s -sl 1000000 -sb -T "SSH Tools - Public Key Generation For $LOGIN" -bg black -fg white -e ssh-keygen
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-keygen.png --title="SSH Tools - Public Key Generation For $LOGIN" --passivepopup="[Finished]"
elif [ "$LOGIN" = "root" ]; then
    kdesu --noignorebutton -d xterm -si -s -sl 1000000 -sb -T "SSH Tools - Public Key Generation For $LOGIN" -bg black -fg white -e ssh-keygen
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-keygen.png --title="SSH Tools - Public Key Generation For $LOGIN" --passivepopup="[Finished]"
fi
exit 0
