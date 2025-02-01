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
# KDE-Services ⚙ 2012-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
EXIT=""
PID=""
DIR="$1"

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
