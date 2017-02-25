#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        exit 1
    fi
}

##############################
############ Main ############
##############################

SYSUSER=$(kdialog --icon=ks-system-process --title="Process Viewer - Htop" --combobox="Choose System User" $USER root --default $USER 2> /dev/null)
if-cancel-exit

if [ "$SYSUSER" = "$USER" ]; then
    xterm -T "Process Viewer - Htop" -bg black -fg white -e htop
else
    kdesu --noignorebutton -d xterm -T "Process Viewer - Htop (Root)" -bg black -fg white -e htop
    if-cancel-exit
fi

exit 0
