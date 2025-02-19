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
# KDE-Services ⚙ 2013-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
APP_NAME=system-monitor
fERROR="/tmp/$APP_NAME.1"
lERROR="/tmp/$APP_NAME.2"
TMP="/tmp/$APP_NAME"
MAIL="root"
PID_FILE="/var/run/$APP_NAME.pid"
CHECKPID=$(ps -p $(cat $PID_FILE 2> /dev/null) 2> /dev/null|grep System_Tools|awk -F " " '{print $1}')
SELECT=""
MODE=""

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
