#!/bin/bash

#################################################################
# For KDE-Services. 2011-2017.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
MODE="0"
BACKUP="$HOME/Backups"
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
COUNT=""
COUNTFILES=""
TARGETBACKUP=""
ALL=""

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$EXIT" != "0" ]; then
		qdbus $DBUSREF close
        exit 1
    fi
    
    if [ "$MODE" = "" ]; then
        kdialog --icon=ks-error --title="Backup Tools" \
                       --passivepopup="[Canceled]   Please, select item. Try again" 2> /dev/null
		qdbus $DBUSREF close
        exit 1
    fi
}

beginning-backup() {
    COUNT="0"
    COUNTFILES=$(echo $TARGETBACKUP|wc -w)
    COUNTFILES=$((++COUNTFILES))
    DBUSREF=$(kdialog --icon=ks-database --title="Backup Tools" --progressbar "                             " $COUNTFILES)
    BEGIN_TIME=$(date +%s)
}

finished-backup() {
    FINAL_TIME=$(date +%s)
    ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
    
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
    
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
    COUNT="0"
    COUNTFILES=$(echo $MODE|wc -w)
    COUNTFILES=$((++COUNTFILES))
    DBUSREF=$(kdialog --icon=ks-database --title="Backup Tools" --progressbar "                             " $COUNTFILES)
    BEGIN_TIME=$(date +%s)
    COUNT=$((++COUNT))
}

finished-restore() {
    FINAL_TIME=$(date +%s)
    ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
    
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
    
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

backup-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Backup:  $i  [$COUNT/$(($COUNTFILES-1))]"
    qdbus $DBUSREF Set "" value $COUNT
}

restore-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Restore:  $MODE"
    qdbus $DBUSREF Set "" value $COUNT
}

##############################
############ Main ############
##############################

MODE=$(kdialog --icon=ks-database --title="Backup Tools" --combobox="Choose Mode" Backup Restore --default Backup 2> /dev/null)
EXIT=$?
if-cancel-exit

if [ "$MODE" = "Backup" ]; then
    mkdir $BACKUP > /dev/null 2>&1
    ALL="$HOME/.filezilla \
        $HOME/.gnupg \
        $HOME/.mozilla/firefox \
        $HOME/.config/google-chrome \
        $HOME/.kde \
        $HOME/.kde-services \
        $HOME/.purple \
        $HOME/.ssh \
        $HOME/.thunderbird \
        $HOME/.wine \
        $HOME/.config/xmoto
    "
    TARGETBACKUP=$(kdialog --icon=ks-database --title="Backup Standard" --separate-output --radiolist="Select For Backup" \
        system "Editable Text Configuration (/etc) and Root Home (/root)" off \
        All "All Below List" off \
        $HOME/.filezilla FileZilla off \
        $HOME/.gnupg GnuPG off \
        $HOME/.mozilla/firefox Firefox off \
        $HOME/.config/google-chrome "Google Chrome" off \
        $HOME/.kde "KDE User Configuration" off \
        $HOME/.kde-services KDE-Services off \
        $HOME/.purple Pidgin off \
        $HOME/.ssh SSH off \
        $HOME/.thunderbird Thunderbird off \
        $HOME/.wine Wine off \
        $HOME/.config/xmoto X-Moto off \
        2> /dev/null)
    EXIT=$?
    if-cancel-exit
    
    if [ "$TARGETBACKUP" = "system" ]; then
        beginning-backup
        for i in $TARGETBACKUP; do
            COUNT=$((++COUNT))
            mkdir $BACKUP/${i##*/} > /dev/null 2>&1
            backup-qdbusinsert
            kdesu --noignorebutton -d -c "tar -jcPpf $BACKUP/${i##*/}/${i##*/}-backup-$(date +%d-%m-%Y_%H-%M).tar.bz2 /etc/ /root/"
			EXIT=$?
			if-cancel-exit
        done
        finished-backup
    fi
    
    if [ "$TARGETBACKUP" = "All" ]; then
        TARGETBACKUP=$ALL
        beginning-backup
        for i in $ALL; do
            COUNT=$((++COUNT))
            mkdir $BACKUP/$(echo ${i##*/}|sed 's/^\.//') > /dev/null 2>&1
            backup-qdbusinsert
            tar -jcPpf $BACKUP/$(echo ${i##*/}|sed 's/^\.//')/$(echo ${i##*/}|sed 's/^\.//')-backup-$(date +%d-%m-%Y_%H-%M).tar.bz2 $i
        done
        finished-backup
    else
        beginning-backup
        for i in $TARGETBACKUP; do
            COUNT=$((++COUNT))
            mkdir $BACKUP/$(echo ${i##*/}|sed 's/^\.//') > /dev/null 2>&1
            backup-qdbusinsert
            tar -jcPpf $BACKUP/$(echo ${i##*/}|sed 's/^\.//')/$(echo ${i##*/}|sed 's/^\.//')-backup-$(date +%d-%m-%Y_%H-%M).tar.bz2 $i
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
         $BACKUP/system "Editable Text Configuration (/etc) and Root Home (/root)" \
         $BACKUP/filezilla FileZilla \
         $BACKUP/firefox Firefox \
         $BACKUP/gnupg GnuPG \
         $BACKUP/google-chrome "Google Chrome" \
         $BACKUP/kde "KDE User Configuration" \
         $BACKUP/kde-services KDE-Services \
         $BACKUP/purple Pidgin \
         $BACKUP/ssh SSH \
         $BACKUP/thunderbird Thunderbird \
         $BACKUP/wine Wine \
         $BACKUP/xmoto X-Moto \
         2> /dev/null)
    EXIT=$?
    if-cancel-exit
    
    if [ ! -d $MODE ]; then
        kdialog --icon=ks-error --title="Restore Standard" \
                       --passivepopup="[Canceled]   Backup Not Found: Please, first create backup or paste your backup on $MODE. Try again" \
                       2> /dev/null
        exit 1
    fi
    
    cd $MODE
    RESTORELIST=$(ls $MODE)
    MODE=$(kdialog --icon=ks-database --title="Restore Standard" --combobox="Select For Restore" $RESTORELIST 2> /dev/null)
    EXIT=$?
    if-cancel-exit
    
    if [ "$PWD" = "$BACKUP/system" ]; then
        beginning-restore
        restore-qdbusinsert
        kdesu --noignorebutton -d -c "rm -fr /etc/ /root/ && tar -jxPpf $MODE > /dev/null 2>&1"
		EXIT=$?
		if-cancel-exit
        finished-restore
    fi
    
    beginning-restore
    rm -fr $(tar -tf $MODE 2> /dev/null|head -n1)
    restore-qdbusinsert
    tar -jxPpf $MODE > /dev/null 2>&1
    chown $USER:$USER $HOME
    finished-restore
fi

exit 0
