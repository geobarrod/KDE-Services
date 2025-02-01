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

LOGIN=$(kdialog --icon=ks-keygen --title="SSH Tools - Public Key Generation" --combobox="Select User" $USER root --default $USER 2> /dev/null)
if-cancel-exit

if [ "$LOGIN" = "$USER" ]; then
	xterm -si -s -sl 1000000 -sb -T "SSH Tools - Public Key Generation For $LOGIN" -bg black -fg white -e ssh-keygen
	kdialog --icon=ks-keygen --title="SSH Tools" --passivepopup="[Finished]   Public Key Generation For $LOGIN"
elif [ "$LOGIN" = "root" ]; then
	$KDESU -i ks-keygen --noignorebutton -d -c "xterm -si -s -sl 1000000 -sb -T "SSH Tools - Public Key Generation For $LOGIN" -bg black -fg white -e ssh-keygen"
	if-cancel-exit
	kdialog --icon=ks-keygen --title="SSH Tools" --passivepopup="[Finished]   Public Key Generation For $LOGIN"
fi
exit 0
