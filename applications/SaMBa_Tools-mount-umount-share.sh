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

HOST=""
KDESU="kdesu"
OPTION=""
PASSWD=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
SERVER=""
SHARE=""
USERNAME=""
VIEW_SHARE=""

###################################
############ Functions ############
###################################

check_stderr() {
	if [ "$?" != "0" ]; then
		kdialog --icon=ks-error --title="SaMBa Shares Mounter" \
			--passivepopup="[Error] 1-SaMBa share directory need authentication. 2-The SaMBa username or password is wrong." 2> /dev/null
		exit 1
	fi
}

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		exit 1
	fi
}

mount_share() {
	VIEW_SHARE=$(smbclient -N -L //$HOST 2> /dev/null|grep -w Disk|awk -F " " '{print $1}')
	if [ "$VIEW_SHARE" = "" ]; then
		kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" --sorry="$HOST not have SaMBa share directory." 2> /dev/null &
		exit 0
	fi
	SHARE=$(kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" \
		--combobox="Select SaMBa Share Directory" $VIEW_SHARE --default $(echo $VIEW_SHARE|xargs -n1 2> /dev/null|head -n1) 2> /dev/null)
	if-cancel-exit
	for share in $(mount|grep -w cifs|awk -F " " '{print $3}'); do
		if [ "$share" = "$HOME/SaMBa-Shares/$HOST-$SHARE" ]; then
			kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" \
				--sorry="Already mounted on $HOME/SaMBa-Shares/$HOST-$SHARE." 2> /dev/null
			exit 0
		fi
	done
	kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" \
		--yesno="Have authentication this SaMBa share directory: //$HOST/$SHARE ?" 2> /dev/null
	if [ "$?" = "0" ]; then
		USERNAME=$(kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" --inputbox="Enter SaMBa Username" 2> /dev/null)
		if-cancel-exit
		PASSWD=$(kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" \
			--password="Enter SaMBa Password For $USERNAME" 2> /dev/null)
		if-cancel-exit
		mkdir -p $HOME/SaMBa-Shares/$HOST-$SHARE 2> /dev/null
		$KDESU -i ks-smbf --noignorebutton -d -c "mount -t cifs -o username=$USERNAME,password=$PASSWD //$HOST/$SHARE $HOME/SaMBa-Shares/$HOST-$SHARE"
		check_stderr
		kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" \
			--passivepopup="[Finished] //$HOST/$SHARE mounted on $HOME/SaMBa-Shares/$HOST-$SHARE." 2> /dev/null
		exit 0
	else
		mkdir -p $HOME/SaMBa-Shares/$HOST-$SHARE 2> /dev/null
		$KDESU -i ks-smbf --noignorebutton -d -c "mount -t cifs -o guest //$HOST/$SHARE $HOME/SaMBa-Shares/$HOST-$SHARE"
		check_stderr
		kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" \
			--passivepopup="[Finished] //$HOST/$SHARE mounted on $HOME/SaMBa-Shares/$HOST-$SHARE." 2> /dev/null
		exit 0
	fi
}

##############################
############ Main ############
##############################

if [ ! -s ~/.kde-services/machines ]; then
	mkdir ~/.kde-services 2> /dev/null
	echo localhost > ~/.kde-services/machines 2> /dev/null
fi
OPTION=$(kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" \
	--combobox="Select Option" "Mount SaMBa Share Directory" "Unmount SaMBa Share Directory" --default "Mount SaMBa Share Directory" 2> /dev/null)
if-cancel-exit
if [ "$OPTION" = "" ]; then
	kdialog --icon=ks-error --title="SaMBa Shares Mounter" --passivepopup="[Error] Please select one option. Try again." 2> /dev/null
	exit 0
elif [ "$OPTION" = "Mount SaMBa Share Directory" ]; then
	SERVER=$(cat ~/.kde-services/machines)
	HOST=$(kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" --combobox="Select Hostname or IP Address" $SERVER \
		--default $(head -n1 ~/.kde-services/machines) 2> /dev/null)

	if [ "$?" != "0" ]; then
		HOST=$(kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" \
			--inputbox="Enter Hostname or IP Address" localhost.localdomain 2> /dev/null)
		if-cancel-exit
		echo $HOST >> ~/.kde-services/machines
		sort -u ~/.kde-services/machines > /tmp/machines
		cat /tmp/machines > ~/.kde-services/machines
		rm -f /tmp/machines
		mount_share
	fi
	mount_share
elif [ "$OPTION" = "Unmount SaMBa Share Directory" ]; then
	VIEW_SHARE=$(mount|grep -w cifs|awk -F " " '{print $3}')
	if [ "$VIEW_SHARE" = "" ]; then
		kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" --sorry="Not have mounted SaMBa share directory." 2> /dev/null &
		rm -fr $HOME/SaMBa-Shares
		exit 0
	fi
	SHARE=$(kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" \
		--combobox="Select Mounted SaMBa Share Directory" $VIEW_SHARE \
		--default $(echo $(mount|grep -w cifs|awk -F " " '{print $3}')|xargs -n1 2> /dev/null|head -n1) 2> /dev/null)
	if-cancel-exit
	$KDESU -i ks-smbf --noignorebutton -d -c "umount $SHARE && rm -fr $SHARE"
	kdialog --icon=ks-smbfs --title="SaMBa Shares Mounter" --passivepopup="[Finished] $SHARE Unmounted." 2> /dev/null
	VIEW_SHARE=$(mount|grep -w cifs|awk -F " " '{print $3}')
	if [ "$VIEW_SHARE" = "" ]; then
		rm -fr $HOME/SaMBa-Shares
	fi
fi
exit 0

