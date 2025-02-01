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
MODE="0"
BACKUP="$HOME/Backups"
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
TARGETBACKUP=""
ALL=""
KDESU="kdesu"
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

if-cancel-exit() {
	if [ "$?" != "0" ]; then
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		kdialog --icon=ks-error --title="Backup Tools" --passivepopup="[Canceled]"
		exit 1
	fi

	if [ "$MODE" = "" ]; then
		kdialog --icon=ks-error --title="Backup Tools" --passivepopup="[Canceled]   Please, select item. Try again" 2> /dev/null
		kill $(cat $PB_PIDFILE)
		rm $PB_PIDFILE
		exit 1
	fi
}

beginning-backup() {
	kdialog --icon=ks-database --title="Backup Tools" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
	BEGIN_TIME=$(date +%s)
}

finished-backup() {
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-database --title="Backup:   Saved on $HOME/Backups/" \
			--passivepopup="[Finished]   Elapsed Time: ${ELAPSED_TIME}s" 2> /dev/null
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-database --title="Backup:   Saved on $HOME/Backups/" \
			--passivepopup="[Finished]   Elapsed Time: ${ELAPSED_TIME}m" 2> /dev/null
	elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-database --title="Backup:   Saved on $HOME/Backups/" \
			--passivepopup="[Finished]   Elapsed Time: ${ELAPSED_TIME}h" 2> /dev/null
	elif [ "$ELAPSED_TIME" -gt "86399" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-database --title="Backup:   Saved on $HOME/Backups/" \
			--passivepopup="[Finished]   Elapsed Time: ${ELAPSED_TIME}d" 2> /dev/null
	fi
	echo "Finished All Backup" > /tmp/speak
	text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
	play /tmp/speak.wav 2> /dev/null
	rm -fr /tmp/speak*
	exit 0
}

beginning-restore() {
	kdialog --icon=ks-database --title="Backup Tools" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
	BEGIN_TIME=$(date +%s)
}

finished-restore() {
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-database --title="Restore:   $MODE" --passivepopup="[Finished]   Elapsed Time: ${ELAPSED_TIME}s" 2> /dev/null
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-database --title="Restore:   $MODE" --passivepopup="[Finished]   Elapsed Time: ${ELAPSED_TIME}m" 2> /dev/null
	elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-database --title="Restore:   $MODE" --passivepopup="[Finished]   Elapsed Time: ${ELAPSED_TIME}h" 2> /dev/null
	elif [ "$ELAPSED_TIME" -gt "86399" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-database --title="Restore:   $MODE" --passivepopup="[Finished]   Elapsed Time: ${ELAPSED_TIME}d" 2> /dev/null
	fi
	echo "Finished All Restore" > /tmp/speak
	text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
	play /tmp/speak.wav 2> /dev/null
	rm -fr /tmp/speak*
	exit 0
}

##############################
############ Main ############
##############################

MODE=$(kdialog --icon=ks-database --title="Backup Tools" --combobox="Choose Mode" Backup Restore --default Backup 2> /dev/null)
EXIT=$?
if-cancel-exit

if [ "$MODE" = "Backup" ]; then
	mkdir $BACKUP > /dev/null 2>&1
	ALL="$HOME/.aMule \
	$HOME/.anydesk \
	$HOME/.audacity-data \
	$HOME/.config \
	$HOME/.gnupg \
	$HOME/.hplip \
	$HOME/.i2p \
	$HOME/.icons \
	$HOME/.jdownloader \
	$HOME/.kde-services \
	$HOME/.mozilla \
	$HOME/.purple \
	$HOME/.ssh \
	$HOME/.thunderbird \
	$HOME/.tmux \
	$HOME/.wine \
	"
	TARGETBACKUP=$(kdialog --icon=ks-database --title="Backup Standard" --separate-output --radiolist="Select For Backup" \
	system "System Editable Text Configuration (/etc) and Root Home (/root)" off \
	All "All Below List" off \
	$HOME/.aMule aMule off \
	$HOME/.anydesk AnyDesk off \
	$HOME/.audacity-data Audacity off \
	$HOME/.config "General User Configuration (~/.config)" off \
	$HOME/.config/google-chrome "Google Chrome" off \
	$HOME/.gnupg GnuPG off \
	$HOME/.hplip "HPLip" off \
	$HOME/.i2p I2P off \
	$HOME/.icons "User Icons" off \
	$HOME/.jdownloader JDownloader off \
	$HOME/.kde-services KDE-Services off \
	$HOME/.mozilla Firefox off \
	$HOME/.purple Pidgin off \
	$HOME/.ssh SSH off \
	$HOME/.thunderbird Thunderbird off \
	$HOME/.tmux TMUX off \
	$HOME/.wine Wine off \
	--geometry 445 110 2> /dev/null)
	EXIT=$?
	if-cancel-exit
	if [ "$TARGETBACKUP" = "system" ]; then
		beginning-backup
		for i in $TARGETBACKUP; do
			mkdir $BACKUP/${i##*/} > /dev/null 2>&1
			$KDESU --noignorebutton -d -c "tar -JcPpf $BACKUP/${i##*/}/${i##*/}-backup-$(date +%d-%m-%Y_%H-%M).tar.xz /etc/ /opt/local/etc/ /root/ /usr/local/etc/"
			EXIT=$?
			if-cancel-exit
		done
		finished-backup
	fi
	if [ "$TARGETBACKUP" = "All" ]; then
		TARGETBACKUP=$ALL
		beginning-backup
		for i in $ALL; do
			mkdir $BACKUP/$(echo ${i##*/}|sed 's/^\.//') > /dev/null 2>&1
			tar -JcPpf $BACKUP/$(echo ${i##*/}|sed 's/^\.//')/$(echo ${i##*/}|sed 's/^\.//')-backup-$(date +%d-%m-%Y_%H-%M).tar.xz $i
		done
		finished-backup
else
	beginning-backup
	for i in $TARGETBACKUP; do
		mkdir $BACKUP/$(echo ${i##*/}|sed 's/^\.//') > /dev/null 2>&1
		tar -JcPpf $BACKUP/$(echo ${i##*/}|sed 's/^\.//')/$(echo ${i##*/}|sed 's/^\.//')-backup-$(date +%d-%m-%Y_%H-%M).tar.xz $i
	done
	finished-backup
	fi
else        
	if [ ! -d $BACKUP ]; then
		kdialog --icon=ks-error --title="Restore Standard" --passivepopup="[Canceled]   Backup Not Found: Please, first create \
			backup or paste your Backups directory on $HOME. Try again" 2> /dev/null
		exit 0
	fi
    
	MODE=$(kdialog --icon=ks-database --title="Restore Standard" --menu="Select For Restore" \
		$BACKUP/system "System Editable Text Configuration (/etc) and Root Home (/root)" \
		$BACKUP/aMule aMule \
		$BACKUP/anydesk AnyDesk \
		$BACKUP/audacity-data Audacity \
		$BACKUP/config "General User Configuration" \
		$BACKUP/google-chrome "Google Chrome" \
		$BACKUP/gnupg GnuPG \
		$BACKUP/hplip HPLip \
		$BACKUP/i2p I2P \
		$BACKUP/icons "User Icons" \
		$BACKUP/jdownloader JDownloader \
		$BACKUP/kde-services KDE-Services \
		$BACKUP/mozilla Firefox \
		$BACKUP/purple Pidgin \
		$BACKUP/ssh SSH \
		$BACKUP/thunderbird Thunderbird \
		$BACKUP/tmux TMUX \
		$BACKUP/wine Wine \
		--geometry 445 110 2> /dev/null)
		EXIT=$?
		if-cancel-exit
	if [ ! -d $MODE ]; then
		kdialog --icon=ks-error --title="Restore Standard" \
			--passivepopup="[Canceled]   Backup Not Found: Please, first create backup or paste your backup on $MODE. Try again" 2> /dev/null
		exit 1
	fi
	cd $MODE
	RESTORELIST=$(ls $MODE)
	MODE=$(kdialog --icon=ks-database --title="Restore Standard" --combobox="Select For Restore" $RESTORELIST 2> /dev/null)
	EXIT=$?
	if-cancel-exit
	if [ "$PWD" = "$BACKUP/system" ]; then
		beginning-restore
		$KDESU --noignorebutton -d -c "rm -fr /etc/ /opt/local/etc/ /root/ /usr/local/etc/ && tar -JxPpf $MODE > /dev/null 2>&1"
		EXIT=$?
		if-cancel-exit
		finished-restore
	fi
	beginning-restore
	rm -fr $(tar -tf $MODE 2> /dev/null|head -n1)
	tar -JxPpf $MODE > /dev/null 2>&1
	chown $USER:$USER $HOME
	finished-restore
fi
exit 0
