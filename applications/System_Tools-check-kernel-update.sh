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

SYSKERNELVERSION=$(uname -r|sed 's/.fc.*$//')
INTERNETVERSION=$(yumdownloader --url --source kernel|grep kernel|grep -v "No source RPM found"|sed 's/^.*kernel-//'|sed 's/.fc...src.rpm$//')
yumdownloader --url --source kernel > /dev/null 2>&1
EXIT=$?

if [ "$EXIT" != "0" ]; then
    kdialog --icon=ks-kernel-update --title="Build Custom Kernel" \
                   --error="No Internet Communication: You have some network problem, can't check updates." 2> /dev/null
    EXIT=6
fi

if [ "$EXIT" = "0" ]; then
    if [ "$SYSKERNELVERSION" != "$INTERNETVERSION" ]; then
        kdialog --icon=ks-kernel-update --title="Check Kernel Update" \
                    --yesno "New version available: kernel-$INTERNETVERSION. Do you want to download it and use it?" 2> /dev/null
        EXIT=$?
    
        if [ "$EXIT" = "0" ]; then
            xterm -T "Build Custom Kernel" -bg black -fg white -e ~/.local/share/applications/System_Tools-build-custom-kernel.sh &
        else
            exit 0
        fi
    else
        kdialog --icon=ks-kernel-update --title="Check Kernel Update" --sorry "No update available." 2> /dev/null
    fi
fi

exit 0
