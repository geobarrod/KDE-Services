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
PROTOCOL=""
DIALOG=""

###################################
############ Functions ############
###################################

bookmark() {
    if [ "$(grep -o "<ID>" ~/.local/share/user-places.xbel|wc -l)" == "0" ]; then
        rm -f ~/.local/share/user-places.xbel*
    fi
    
    sed -i "s;</xbel>;;g" ~/.local/share/user-places.xbel
    sed -i "s;^</bookmark>;;" ~/.local/share/user-places.xbel
    cat >> ~/.local/share/user-places.xbel << EOF
<bookmark href="$PROTOCOL://$DIALOG/">
 <title>$(echo $PROTOCOL|tr a-z A-Z) - $DIALOG</title>
 <bookmark href="$PROTOCOL://$DIALOG/">
  <title>$(echo $PROTOCOL|tr a-z A-Z) - $DIALOG</title>
  <info>
   <metadata owner="http://freedesktop.org">
    <bookmark:icon name="folder-remote"/>
   </metadata>
   <metadata owner="http://www.kde.org">
    <IsHidden>false</IsHidden>
   </metadata>
  </info>
 </bookmark>
EOF
    dolphin $PROTOCOL://$DIALOG 2> /dev/null
    exit 0
}

##############################
############ Main ############
##############################

if [ ! -s ~/.kde-services/machines ] || [ $(cat ~/.kde-services/machines|wc -w) == "0" ]; then
    mkdir ~/.kde-services 2> /dev/null
    echo localhost > ~/.kde-services/machines 2> /dev/null
fi

if [ -s ~/.kde-services/machines ]; then
    SERVER=$(cat ~/.kde-services/machines)
    PROTOCOL=$(kdialog --icon=ks-folder-remote --title="Dolphin Tools" --combobox="Select Protocol" ftp sftp smb --default ftp 2> /dev/null)
    
    if [ "$?" -gt "0" ]; then
        exit 0
    fi
    
    DIALOG=$(kdialog --icon=ks-folder-remote --title="Dolphin Tools" --combobox="Select Hostname or IP Address" $SERVER \
           --default $(head -n1 ~/.kde-services/machines) 2> /dev/null)
    
    if [ "$?" -gt "0" ]; then
        DIALOG=$(kdialog --icon=ks-folder-remote --title="Dolphin Tools" \
               --inputbox="Enter Hostname or IP Address" localhost.localdomain --default  2> /dev/null)
    
    if [ "$?" -gt "0" ]; then
        exit 0
    fi
    
    echo $DIALOG >> ~/.kde-services/machines
    sort -u ~/.kde-services/machines > /tmp/machines
    mv /tmp/machines ~/.kde-services/machines
    
    bookmark
    fi
    
    bookmark
else
    DIALOG=$(kdialog --icon=ks-folder-remote --title="Dolphin Tools" \
           --inputbox="Enter Hostname or IP Address" localhost.localdomain 2> /dev/null)
    
    if [ "$?" -gt "0" ]; then
	exit 0
    fi
    
    echo $DIALOG >> ~/.kde-services/machines
    sort -u ~/.kde-services/machines > /tmp/machines
    mv /tmp/machines ~/.kde-services/machines
    
    SERVER=$(cat ~/.kde-services/machines)
    PROTOCOL=$(kdialog --icon=ks-folder-remote --title="Dolphin Tools" --combobox="Select Protocol" ftp sftp smb --default ftp 2> /dev/null)
    
    if [ "$?" -gt "0" ]; then
	exit 0
    fi

    bookmark
fi

exit 0
