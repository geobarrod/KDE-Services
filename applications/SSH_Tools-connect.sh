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
HOST=""
SERVER=""
LOGIN=""

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
    HOST=$(kdialog --icon=ks-connect-to --title="SSH Tools - Connect to" --combobox="Select Hostname or IP Address" $SERVER \
               --default $(head -n1 ~/.kde-services/machines) 2> /dev/null)
    if-cancel-exit
    LOGIN=$(kdialog --icon=ks-connect-to --title="SSH Tools - Connect to $HOST" --combobox="Select User" $USER root --default $USER 2> /dev/null)
    if-cancel-exit
    xterm -si -s -sl 1000000 -sb -bg black -fg white -e "ssh $LOGIN@$HOST"
    exit 0
else
        kdialog --icon=ks-connect-to --title="SSH Tools - Connect to" \
                       --sorry="No Find Server: First Public Key Generation and Install Public Key in Remote Server" 2> /dev/null
        exit 1
fi
