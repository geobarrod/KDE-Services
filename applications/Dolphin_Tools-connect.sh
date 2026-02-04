#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2011-2026.                                                       #
#                                                                                 #
# BSD 3-Clause License                                                            #
#                                                                                 #
# Copyright (c) 2026, Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.  #
#                                                                                 #
# Redistribution and use in source and binary forms, with or without              #
# modification, are permitted provided that the following conditions are met:     #
#                                                                                 #
#  1. Redistributions of source code must retain the above copyright notice, this #
#     list of conditions and the following disclaimer.                            #
#                                                                                 #
#  2. Redistributions in binary form must reproduce the above copyright notice,   #
#     this list of conditions and the following disclaimer in the documentation   #
#     and/or other materials provided with the distribution.                      #
#                                                                                 #
#  3. Neither the name of the copyright holder nor the names of its               #
#     contributors may be used to endorse or promote products derived from        #
#     this software without specific prior written permission.                    #
#                                                                                 #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"     #
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE  #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE    #
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL      #
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR      #
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER      #
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   #
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE   #
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.            #
###################################################################################

DIALOG=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PROTOCOL=""

###################################
############ Functions ############
###################################

bookmark() {
    if [ "$(grep -o "<ID>" ~/.local/share/user-places.xbel|wc -l)" == "0" ]; then
        rm -f ~/.local/share/user-places.xbel*
    fi
    
    sed -i "" "s;</xbel>;;g" ~/.local/share/user-places.xbel
    sed -i "" "s;^</bookmark>;;" ~/.local/share/user-places.xbel
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
