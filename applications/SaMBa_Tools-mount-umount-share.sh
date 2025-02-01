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
HOST=""
SHARE=""
USERNAME=""
PASSWD=""
VIEW_SHARE=""
OPTION=""
SERVER=""
KDESU="kdesu"

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
