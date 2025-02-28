#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2012-2025.                                                       #
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

KDESU="kdesu"
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin

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

