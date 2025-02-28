#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2012-2025.                                                       #
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

DIR="$1"
EXIT=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PID=""

cd "$DIR"

if [ "$UID" != "0" ]; then
    PORT=$(kdialog --icon=ks-folder-public-web --title="HTTP Server" \
         --inputbox="Enter a integer number for service port greater than 1023. Allowed range from 1024 to 65535." 8080 2> /dev/null)
    EXIT="$?"
else
    PORT=$(kdialog --icon=ks-folder-public-web --title="HTTP Server" \
         --inputbox="Enter a integer number for service port. Allowed range from 1 to 65535." 80 2> /dev/null)
    EXIT="$?"
fi

if [ "$PORT" -lt "1" ] || [ "$PORT" -gt "65535" ]; then
    if [ "$UID" != "0" ]; then
        kdialog --icon=ks-error --title="HTTP Server" --passivepopup="[Error]   Port number $PORT out of range. \
                       Allowed range from 1024 to 65535 for unprivileged user, change it and try again."
    else
        kdialog --icon=ks-error --title="HTTP Server" --passivepopup="[Error]   Port number $PORT out of range. \
                       Allowed range from 1 to 65535 for privileged user, change it and try again."
    fi
    exit 0
fi

if [ "$EXIT" != "0" ]; then
    exit 0
fi

lsof -i :$PORT > /dev/null
EXIT="$?"

if [ "$EXIT" != "0" ]; then
    python -m http.server $PORT &
    PID="$!"
    sleep 1
    
    lsof -i :$PORT > /dev/null
    EXIT="$?"
    
    if [ "$EXIT" != "0" ]; then
        kdialog --icon=ks-error --title="HTTP Server" \
                       --passivepopup="[Permission Denied]   Unprivileged user can't use port number $PORT, use port number greater than 1023. \
                       Try again."
        exit 0
    fi
    
    if [ "$PORT" != "80" ]; then
        kdialog --icon=ks-folder-public-web --title="HTTP Server" --yes-label Background --no-label Stop \
                       --warningyesno="Published \"${1##*/}\" directory. Access via web: http://$HOSTNAME:$PORT" 2> /dev/null
        EXIT="$?"
    else
        kdialog --icon=ks-folder-public-web --title="HTTP Server" --yes-label Background --no-label Stop \
                       --warningyesno="Published \"${1##*/}\" directory. Access via web: http://$HOSTNAME" 2> /dev/null
        EXIT="$?"
    fi
    
    if [ "$EXIT" = "1" ]; then
        kill -9 $PID
    fi
else
    kdialog --icon=ks-error --title="HTTP Server" --passivepopup="[Error]   Port number $PORT already in use, change it and try again."
fi

exit 0

