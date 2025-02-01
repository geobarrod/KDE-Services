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

SYSUSER=$(kdialog --icon=ks-system-process --title="Process Viewer - Htop" --combobox="Choose System User" $USER root --default $USER 2> /dev/null)
if-cancel-exit

if [ "$SYSUSER" = "$USER" ]; then
	xterm -T "Process Viewer - Htop" -bg black -fg white -e htop
else
	$KDESU -i ks-system-process --noignorebutton -d -c "xterm -T "Process Viewer - Htop (Root)" -bg black -fg white -e htop"
	if-cancel-exit
fi

exit 0
