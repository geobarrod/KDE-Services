#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
WIDTH=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $1}')
HEIGHT=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $2}')

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

MODE=$(kdialog --icon=ks-server --title="SSH Tools - Registered Servers" --combobox="Select Mode" View Edit --default View 2> /dev/null)
if-cancel-exit

if [ "$MODE" = "View" ]; then
    if [ -s ~/.kde-services/machines ]; then
        kdialog --icon=ks-server --title="SSH Tools - Registered Servers" --textbox ~/.kde-services/machines 2> /dev/null
    else
        kdialog --icon=ks-server --title="Registered Servers" \
                       --sorry="No Find Servers: First Public Key Generation and Install Public Key in Remote Servers" 2> /dev/null
        exit 1
    fi
elif [ "$MODE" = "Edit" ]; then
    mkdir ~/.kde-services
    touch ~/.kde-services/machines
    kdialog --icon=ks-server --title="SSH Tools - Registered Servers" \
                   --textinputbox="Edit a Hostname or IP address per line" "$(cat ~/.kde-services/machines|sort -u)" > ~/.kde-services/machines \
                   2> /dev/null
fi
exit 0
