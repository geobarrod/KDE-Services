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

HOST=""
LOGIN=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PATHSEND=""
SERVER=""

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
