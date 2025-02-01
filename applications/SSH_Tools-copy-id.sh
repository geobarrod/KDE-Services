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

SERVER=$(kdialog --icon=ks-key --title="SSH Tools - Install Public Key" \
       --inputbox="Enter Hostname or IP Address" localhost.localdomain 2> /dev/null)
if-cancel-exit
LOGIN=$(kdialog --icon=ks-key --title="SSH Tools - Install Public Key" --combobox="Select User" $USER root --default $USER 2> /dev/null)
if-cancel-exit
mkdir ~/.kde-services 2> /dev/null
echo $SERVER >> ~/.kde-services/machines
sort -u ~/.kde-services/machines > /tmp/machines
mv /tmp/machines ~/.kde-services/machines
xterm -si -s -sl 1000000 -sb -T "SSH Tools - Install Public Key on $SERVER" -bg black -fg white -e "ssh-copy-id -i $LOGIN@$SERVER"
if-cancel-exit
kdialog --icon=ks-key --title="SSH Tools" --passivepopup="[Finished]   Install Public Key on $SERVER"
exit 0
