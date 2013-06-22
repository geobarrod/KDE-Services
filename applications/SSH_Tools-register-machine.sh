#!/bin/bash

#################################################################
# For KDE Services. 2011-2013.					#
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

MODE=$(kdialog --icon=server --caption="SSH Tools - Registered Machine" --combobox="Select Mode" View Edit --default View 2> /dev/null)
if-cancel-exit

if [ "$MODE" = "View" ]; then
    if [ -s ~/.kde-services/machines ]; then
        kdialog --icon=server --caption="SSH Tools - Registered Machine" --textbox ~/.kde-services/machines 2> /dev/null
    else
        kdialog --icon=server --caption="Registered Machines" \
                       --sorry="No Find Machine: First Public Key Generation and Install Public Key in Remote Machine" 2> /dev/null
        exit 1
    fi
elif [ "$MODE" = "Edit" ]; then
    mkdir ~/.kde-services
    touch ~/.kde-services/machines
    kdialog --icon=server --caption="SSH Tools - Registered Machine" \
                   --textinputbox="Edit a Hostname or IP address per line" "$(cat ~/.kde-services/machines|sort -u)" > ~/.kde-services/machines \
                   2> /dev/null
#    sort -u ~/.kde-services/machines.tmp > ~/.kde-services/machines
fi
exit 0
