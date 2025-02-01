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

SYSINFO=$(kdialog --icon=ks-hwinfo --title="System Information" \
	--combobox="Choose keyword" Full Baseboard BIOS Cache Chassis Connector Memory Processor Slot System --default Full 2> /dev/null)
if-cancel-exit

if [ "$SYSINFO" = "Full" ]; then
	$KDESU -i ks-hwinfo --noignorebutton -d -c "dmidecode -q > /tmp/sysinfo.tmp"
	if-cancel-exit
	kdialog --icon=ks-hwinfo --title="Full System Information" --textbox /tmp/sysinfo.tmp 580 360 2> /dev/null
elif [ "$SYSINFO" = "Baseboard" ]; then
	$KDESU -i ks-hwinfo --noignorebutton -d -c "dmidecode -qt baseboard > /tmp/sysinfo.tmp"
	if-cancel-exit
	kdialog --icon=ks-hwinfo --title="Baseboard Information" --textbox /tmp/sysinfo.tmp 580 360 2> /dev/null
elif [ "$SYSINFO" = "BIOS" ]; then
	$KDESU -i ks-hwinfo --noignorebutton -d -c "dmidecode -qt bios > /tmp/sysinfo.tmp"
	if-cancel-exit
	kdialog --icon=ks-hwinfo --title="BIOS Information" --textbox /tmp/sysinfo.tmp 580 360 2> /dev/null
elif [ "$SYSINFO" = "Cache" ]; then
	$KDESU -i ks-hwinfo --noignorebutton -d -c "dmidecode -qt cache > /tmp/sysinfo.tmp"
	if-cancel-exit
	kdialog --icon=ks-hwinfo --title="Cache Information" --textbox /tmp/sysinfo.tmp 580 360 2> /dev/null
elif [ "$SYSINFO" = "Chassis" ]; then
	$KDESU -i ks-hwinfo --noignorebutton -d -c "dmidecode -qt chassis > /tmp/sysinfo.tmp"
	if-cancel-exit
	kdialog --icon=ks-hwinfo --title="Chassis Information" --textbox /tmp/sysinfo.tmp 580 360 2> /dev/null
elif [ "$SYSINFO" = "Connector" ]; then
	$KDESU -i ks-hwinfo --noignorebutton -d -c "dmidecode -qt connector > /tmp/sysinfo.tmp"
	if-cancel-exit
	kdialog --icon=ks-hwinfo --title="Connector Information" --textbox /tmp/sysinfo.tmp 580 360 2> /dev/null
elif [ "$SYSINFO" = "Memory" ]; then
	$KDESU -i ks-hwinfo --noignorebutton -d -c "dmidecode -qt memory > /tmp/sysinfo.tmp"
	if-cancel-exit
	kdialog --icon=ks-hwinfo --title="Memory Information" --textbox /tmp/sysinfo.tmp 580 360 2> /dev/null
elif [ "$SYSINFO" = "Processor" ]; then
	$KDESU -i ks-hwinfo --noignorebutton -d -c "dmidecode -qt processor > /tmp/sysinfo.tmp"
	if-cancel-exit
	kdialog --icon=ks-hwinfo --title="Processor Information" --textbox /tmp/sysinfo.tmp 580 360 2> /dev/null
elif [ "$SYSINFO" = "Slot" ]; then
	$KDESU -i ks-hwinfo --noignorebutton -d -c "dmidecode -qt slot > /tmp/sysinfo.tmp"
	if-cancel-exit
	kdialog --icon=ks-hwinfo --title="Slot Information" --textbox /tmp/sysinfo.tmp 580 360 2> /dev/null
elif [ "$SYSINFO" = "System" ]; then
	$KDESU -i ks-hwinfo --noignorebutton -d -c "dmidecode -qt system > /tmp/sysinfo.tmp"
	if-cancel-exit
	kdialog --icon=ks-hwinfo --title="System Information" --textbox /tmp/sysinfo.tmp 580 360 2> /dev/null
fi

exit 0
