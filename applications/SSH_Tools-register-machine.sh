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

MODE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-server.png --caption="SSH Tools - Registered Servers" --combobox="Select Mode" View Edit --default View 2> /dev/null)
if-cancel-exit

if [ "$MODE" = "View" ]; then
    if [ -s ~/.kde-services/machines ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-server.png --caption="SSH Tools - Registered Servers" --textbox ~/.kde-services/machines 2> /dev/null
    else
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-server.png --caption="Registered Servers" \
                       --sorry="No Find Servers: First Public Key Generation and Install Public Key in Remote Servers" 2> /dev/null
        exit 1
    fi
elif [ "$MODE" = "Edit" ]; then
    mkdir ~/.kde-services
    touch ~/.kde-services/machines
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-server.png --caption="SSH Tools - Registered Servers" \
                   --textinputbox="Edit a Hostname or IP address per line" "$(cat ~/.kde-services/machines|sort -u)" > ~/.kde-services/machines \
                   2> /dev/null
fi
exit 0
