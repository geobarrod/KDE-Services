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

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PID="/tmp/connect-sentry.pid"
CHECKPID=$(ps -p $(cat $PID 2>/dev/null) 2>/dev/null|grep Network_Tools|awk -F " " '{print $1}')

if-cancel-exit() {
        if [ "$?" != "0" ]; then
                exit 1
        fi
}

STATE=$(kdialog --icon=ks-sentry-on --title="Connect Sentry" --combobox="Choose Status" Enabled Disabled --default Enabled 2>/dev/null)
if-cancel-exit

if [ "$STATE" = "Enabled" ]; then
        if [ "$(cat $PID 2>/dev/null)" = "$CHECKPID" ] && [ -s $PID ]; then
                kdialog --icon=ks-sentry-on --title="Connect Sentry" --sorry="Already Running." 2>/dev/null
                exit 1
        fi

        if [ ! -s ~/.kde-services/ports ]; then
                mkdir -p ~/.kde-services 2>/dev/null
                echo -n > ~/.kde-services/ports
        fi
    
        SHOWPORTS=$(cat ~/.kde-services/ports|sed 's/ or sport = :/,/g'|sed 's/^sport = ://g')
        PORTS=$(kdialog --icon=ks-sentry-on --title="Connect Sentry" \
                        --inputbox="Enter ports number separate by comma to monitor it" $SHOWPORTS 2>/dev/null)
        if-cancel-exit
        echo -n $PORTS > ~/.kde-services/ports
        sed -i -e "s;,; or sport = :;g" ~/.kde-services/ports
        sed -i -e "s;^;sport = :;g" ~/.kde-services/ports
        echo -n > /tmp/timestamp
        echo -n > /tmp/timestamp2
        MYPORTS=$(cat ~/.kde-services/ports)
        ss -tno state established "( $MYPORTS )" &>/dev/null

        if [ "$?" != "0" ]; then
                kdialog --icon=ks-error --title="Connect Sentry - Aborted By Wrong Syntax" --passivepopup="$PORTS" 2>/dev/null
                exit 1
        fi

        echo $$ > $PID
        kdialog --icon=ks-sentry-on --title="Connect Sentry" --passivepopup="[Enabled]" 2>/dev/null
    
        while true; do
                ss -tno state established "( $MYPORTS )"|grep -v "127.0.0.1"|grep -w timer|awk -F " " '{print $3,$4}' > /tmp/timestamp
                sleep 1
                ss -tno state established "( $MYPORTS )"|grep -v "127.0.0.1"|grep -w timer|awk -F " " '{print $3,$4}' > /tmp/timestamp2
                diff /tmp/timestamp /tmp/timestamp2 > /tmp/established
                EXIT=$?
                EST=$(cat /tmp/established|grep ">"|awk -F " " '{print $2,$3}')
        
                if [ "$EXIT" != "0" ]; then
                        kdialog --icon=ks-sentry-warning --title="Connection Established - $(date "+%b %d %H:%M %Y")" --passivepopup="$EST" 2>/dev/null
                fi
        done

elif [ "$STATE" = "Disabled" ]; then
        kill -9 $(cat $PID 2>/dev/null) 2>/dev/null
        rm -f $PID 2>/dev/null
        kdialog --icon=ks-sentry-off --title="Connect Sentry" --passivepopup="[Disabled]" 2>/dev/null

elif [ "$STATE" = "" ]; then
        kdialog --icon=ks-sentry-on --title="Connect Sentry" \
                --error="Please choose the Connect Sentry Status (Enable or Disabled)." 2>/dev/null
fi

exit 0
