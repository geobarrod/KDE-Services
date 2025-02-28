#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2013-2025.                                                       #
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

APP_NAME=system-monitor
fERROR="/tmp/$APP_NAME.1"
lERROR="/tmp/$APP_NAME.2"
MAIL="root"
MODE=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PID_FILE="/var/run/$APP_NAME.pid"
CHECKPID=$(ps -p $(cat $PID_FILE 2> /dev/null) 2> /dev/null|grep System_Tools|awk -F " " '{print $1}')
SELECT=""
TMP="/tmp/$APP_NAME"

###################################
############ Functions ############
###################################

if-cancel-exit() {
        if [ "$?" != "0" ]; then
                exit 1
        fi
}

##############################
############ Main ############
##############################

export $(dbus-launch)

STATE=$(kdialog --icon=ks-error --title="System Monitor" --combobox="Choose Status" Enabled Disabled --default Enabled 2> /dev/null)
if-cancel-exit

if [ "$STATE" == "Enabled" ]; then
        if [ "$CHECKPID" == "$(cat $PID_FILE 2> /dev/null)" ] && [ -s $PID_FILE ]; then
                kdialog --icon=ks-error --title="System Monitor" --passivepopup="Service Already Running."
                exit 1
        fi

        SELECT=$(kdialog --icon=ks-error --title="System Monitor" \
                        --combobox="Select mode" Error Fail Warning Error+Fail Error+Warning Error+Fail+Warning Fail+Warning --default Error+Fail+Warning)
        if-cancel-exit

        if [ "$SELECT" == "Error" ]; then
                MODE="-i error"
        elif [ "$SELECT" == "Fail" ]; then
                MODE="-i fail"
        elif [ "$SELECT" == "Warning" ]; then
                MODE="-i warning"
        elif [ "$SELECT" == "Error+Fail" ]; then
                MODE="-i -e error -e fail"
        elif [ "$SELECT" == "Error+Warning" ]; then
                MODE="-i -e error -e warning"
        elif [ "$SELECT" == "Error+Fail+Warning" ]; then
                MODE="-i -e error -e fail -e warning"
        elif [ "$SELECT" == "Fail+Warning" ]; then
                MODE="-i -e fail -e warning"
        fi

        egrep $MODE /var/log/messages > $fERROR
        echo $$ > $PID_FILE
        kdialog --icon=ks-error --title="System Monitor" \
                --passivepopup="[Enabled]   The messages of alert show up in /dev/pts/0, /dev/tty12 and root's mail" 2> /dev/null

        while true;do
                egrep $MODE /var/log/messages > $lERROR
                ERRORdiff=$(diff $fERROR $lERROR|egrep '>')
                kdialog --icon=ks-error --title="System Monitor" --passivepopup="$ERRORdiff" 2> /dev/null
                if [ "$ERRORdiff" != "" ];then
                        if [ -c /dev/pts/0 ];then
                                echo -e "\n$ERRORdiff\n" > /dev/pts/0
                        fi
                        if [ -c /dev/tty12 ];then
                                echo -e "\n$ERRORdiff\n" > /dev/tty12
                        fi
                        echo "$ERRORdiff" > $TMP
                        mail -s "System Monitor" $MAIL < $TMP
                        rm -f $TMP
                fi
                sleep 5
                mv $lERROR $fERROR
        done
elif [ "$STATE" == "Disabled" ]; then
        kill -9 $(cat $PID_FILE 2> /dev/null) 2> /dev/null
        rm -f $PID_FILE $lERROR $fERROR $TMP
        kdialog --icon=ks-error --title="System Monitor" --passivepopup="[Disabled]" 2> /dev/null
        exit 0
fi
exit 0
