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
KDESU="kdesu"
PB_PIDFILE="$(mktemp)"

$KDESU -i ks-search-database-update --noignorebutton -d updatedb &

until [ "$(pidof kdesu)" = "" ]; do
	sleep 1
	true
done

kdialog --icon=ks-search-database-update --title="Update Search DataBase" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE

until [ "$(pidof updatedb)" = "" ]; do
	sleep 1
	true
done

kill $(cat $PB_PIDFILE)
rm $PB_PIDFILE
echo  "Finish Update Search Database" > /tmp/speak
text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
play /tmp/speak.wav 2> /dev/null
rm -f /tmp/speak*
kdialog --icon=ks-search-database-update --title="Update Search DataBase" --passivepopup="Finished" 2> /dev/null
exit 0
