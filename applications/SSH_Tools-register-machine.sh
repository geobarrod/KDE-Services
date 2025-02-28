#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2011-2025.                                                       #
#                                                                                 #
# BSD 3-Clause License                                                            #
#                                                                                 #
# Copyright (c) 2025, Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.  #
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

HEIGHT=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $2}')
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
WIDTH=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $1}')

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
                --textinputbox="Edit a Hostname or IP address per line" "$(cat ~/.kde-services/machines|sort -u)" > ~/.kde-services/machines 2> /dev/null
fi

exit 0
