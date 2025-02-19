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
PID="/tmp/connect-sentry.pid"
CHECKPID=$(ps -p $(cat $PID 2> /dev/null) 2> /dev/null|grep Network_Tools|awk -F " " '{print $1}')

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        exit 1
    fi
}

STATE=$(kdialog --icon=ks-sentry-on --title="Connect Sentry" --combobox="Choose Status" Enabled Disabled --default Enabled 2> /dev/null)
if-cancel-exit

if [ "$STATE" = "Enabled" ]; then
    if [ "$(cat $PID 2> /dev/null)" = "$CHECKPID" ] && [ -s $PID ]; then
        kdialog --icon=ks-sentry-on --title="Connect Sentry" --sorry="Already Running." 2> /dev/null
        exit 0
    fi
    
    if [ ! -s ~/.kde-services/ports ]; then
        mkdir -p ~/.kde-services 2> /dev/null
        echo -n > ~/.kde-services/ports
    fi
    
    SHOWPORTS=$(cat ~/.kde-services/ports|sed 's/ or sport = :/,/g'|sed 's/^sport = ://g')
    PORTS=$(kdialog --icon=ks-sentry-on --title="Connect Sentry" \
          --inputbox="Enter ports number separate by comma to monitor it" $SHOWPORTS 2> /dev/null)
    if-cancel-exit
    echo -n $PORTS > ~/.kde-services/ports
    sed -i -e "s;,; or sport = :;g" ~/.kde-services/ports
    sed -i -e "s;^;sport = :;g" ~/.kde-services/ports
    echo -n > /tmp/timestamp
    echo -n > /tmp/timestamp2
    MYPORTS=$(cat ~/.kde-services/ports)
    ss -tno state established "( $MYPORTS )" > /dev/null 2>&1
    
    if [ "$?" != "0" ]; then
        kdialog --icon=ks-error --title="Connect Sentry - Aborted By Wrong Syntax" --passivepopup="$PORTS" 2> /dev/null
        exit 0
    fi
    
    echo $$ > $PID
    kdialog --icon=ks-sentry-on --title="Connect Sentry" --passivepopup="[Enabled]" 2> /dev/null
    
    while true; do
        ss -tno state established "( $MYPORTS )"|grep -v "127.0.0.1"|grep -w timer|awk -F " " '{print $3,$4}' > /tmp/timestamp
        sleep 1
        ss -tno state established "( $MYPORTS )"|grep -v "127.0.0.1"|grep -w timer|awk -F " " '{print $3,$4}' > /tmp/timestamp2
        diff /tmp/timestamp /tmp/timestamp2 > /tmp/established
        EXIT=$?
        EST=$(cat /tmp/established|grep ">"|awk -F " " '{print $2,$3}')
        
        if [ "$EXIT" != "0" ]; then
            kdialog --icon=ks-sentry-warning --title="Connection Established - $(date "+%b %d %H:%M %Y")" --passivepopup="$EST" 2> /dev/null
        fi
    done
    
elif [ "$STATE" = "Disabled" ]; then
    kill -9 $(cat $PID 2> /dev/null) 2> /dev/null
    rm -f $PID 2> /dev/null
    kdialog --icon=ks-sentry-off --title="Connect Sentry" --passivepopup="[Disabled]" 2> /dev/null

elif [ "$STATE" = "" ]; then
    kdialog --icon=ks-sentry-on --title="Connect Sentry" \
                   --error="Please choose the Connect Sentry Status (Enable or Disabled)." 2> /dev/null
fi

exit 0
