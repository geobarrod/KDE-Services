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
# KDE-Services ⚙ 2011-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
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
