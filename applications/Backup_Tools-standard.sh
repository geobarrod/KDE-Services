#!/bin/bash

#################################################################
# For KDE Services. 2011-2013.					#
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
        exit 0
    fi
    
    if [ "$MODE" = "" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="[Backup|Restore] Tools" \
                       --passivepopup="[Canceled]   Please, select item. Try again" 2> /dev/null
        exit 0
    fi
}

beginning-backup() {
    COUNT="0"
    COUNTFILES=$(echo $TARGETBACKUP|wc -w)
    COUNTFILES=$(expr $COUNTFILES + 1)
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --caption="[Backup|Restore] Tools" --progressbar "                             " $COUNTFILES)
    BEGIN_TIME=$(date +%s)
}

finished-backup() {
    FINAL_TIME=$(date +%s)
    ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
    
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
    
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --title="Backup:   Saved on $HOME/Backups/" \
                       --passivepopup="[Finished]   Elapsed Time: $ELAPSED_TIME s." 2> /dev/null
        
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --title="Backup:   Saved on $HOME/Backups/" \
                       --passivepopup="[Finished]   Elapsed Time: $ELAPSED_TIME m." 2> /dev/null
        
    elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --title="Backup:   Saved on $HOME/Backups/" \
                       --passivepopup="[Finished]   Elapsed Time: $ELAPSED_TIME h." 2> /dev/null
        
    elif [ "$ELAPSED_TIME" -gt "86399" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --title="Backup:   Saved on $HOME/Backups/" \
                       --passivepopup="[Finished]   Elapsed Time: $ELAPSED_TIME d." 2> /dev/null
    fi
    
    echo "Finished All Backup" > /tmp/speak
    text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
    play /tmp/speak.wav 2> /dev/null
    rm -fr /tmp/speak*
}

beginning-restore() {
    COUNT="0"
    COUNTFILES=$(echo $MODE|wc -w)
    COUNTFILES=$(expr $COUNTFILES + 1)
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --caption="[Backup|Restore] Tools" --progressbar "                             " $COUNTFILES)
    BEGIN_TIME=$(date +%s)
    COUNT=$(expr $COUNT + 1)
}

finished-restore() {
    FINAL_TIME=$(date +%s)
    ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
    
    qdbus $DBUSREF Set "" value $COUNTFILES
    sleep 1
    qdbus $DBUSREF close
    
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --title="Restore:   $MODE" --passivepopup="[Finished]   Elapsed Time: $ELAPSED_TIME s." 2> /dev/null
        
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --title="Restore:   $MODE" --passivepopup="[Finished]   Elapsed Time: $ELAPSED_TIME m." 2> /dev/null
        
    elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --title="Restore:   $MODE" --passivepopup="[Finished]   Elapsed Time: $ELAPSED_TIME h." 2> /dev/null
        
    elif [ "$ELAPSED_TIME" -gt "86399" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --title="Restore:   $MODE" --passivepopup="[Finished]   Elapsed Time: $ELAPSED_TIME d." 2> /dev/null
    fi
    
    echo "Finished All Restore" > /tmp/speak
    text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
    play /tmp/speak.wav 2> /dev/null
    rm -fr /tmp/speak*
}

backup-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Backup:  $i  [$COUNT/$(expr $COUNTFILES - 1)]"
    qdbus $DBUSREF Set "" value $COUNT
}

restore-qdbusinsert() {
    qdbus $DBUSREF setLabelText "Restore:  $MODE"
    qdbus $DBUSREF Set "" value $COUNT
}

##############################
############ Main ############
##############################

MODE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --caption="[Backup|Restore] Tools" --combobox="Choose Mode" Backup Restore --default Backup 2> /dev/null)
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
         $HOME/.thunderbird \
         $HOME/.config/xmoto
    "
    TARGETBACKUP=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --caption="Backup Standard" --separate-output --checklist="Select For Backup" \
         All "All List" off \
         $HOME/.filezilla FileZilla off \
         $HOME/.gnupg GnuPG off \
         $HOME/.mozilla/firefox Firefox off \
         $HOME/.config/google-chrome "Google Chrome" off \
         $HOME/.kde "KDE User Configuration" off \
         $HOME/.kde-services KDE-Services off \
         $HOME/.purple Pidgin off \
         $HOME/.thunderbird Thunderbird off \
         $HOME/.config/xmoto X-Moto off \
         2> /dev/null)
    EXIT=$?
    if-cancel-exit
    
    if [ "$TARGETBACKUP" = "All" ]; then
        TARGETBACKUP=$ALL
        beginning-backup
            for i in $ALL; do
                COUNT=$(expr $COUNT + 1)
                mkdir $BACKUP/$(basename $i|sed 's/\.//g') > /dev/null 2>&1
                backup-qdbusinsert
                tar -jcPpf $BACKUP/$(basename $i|sed 's/\.//g')/$(basename $i|sed 's/\.//g')-backup-$(date +%d-%m-%Y_%H-%M).tar.bz2 $i
            done
        finished-backup
    else
        beginning-backup
            for i in $TARGETBACKUP; do
                COUNT=$(expr $COUNT + 1)
                mkdir $BACKUP/$(basename $i|sed 's/\.//g') > /dev/null 2>&1
                backup-qdbusinsert
                tar -jcPpf $BACKUP/$(basename $i|sed 's/\.//g')/$(basename $i|sed 's/\.//g')-backup-$(date +%d-%m-%Y_%H-%M).tar.bz2 $i
            done
        finished-backup
    fi
else        
    if [ ! -d $BACKUP ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Restore Standard" --passivepopup="[Canceled]   Backup Not Found: Please, first create \
                       backup or paste your Backups directory on $HOME. Try again" 2> /dev/null
        exit 0
    fi
    
    MODE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --caption="Restore Standard" --menu="Select For Restore" \
         $BACKUP/filezilla FileZilla \
         $BACKUP/firefox Firefox \
         $BACKUP/gnupg GnuPG \
         $BACKUP/google-chrome "Google Chrome" \
         $BACKUP/kde "KDE User Configuration" \
         $BACKUP/kde-services KDE-Services \
         $BACKUP/purple Pidgin \
         $BACKUP/thunderbird Thunderbird \
         $BACKUP/xmoto X-Moto \
         2> /dev/null)
    EXIT=$?
    if-cancel-exit
    
    if [ ! -d $MODE ]; then
        kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-error.png --title="Restore Standard" \
                       --passivepopup="[Canceled]   Backup Not Found: Please, first create backup or paste your backup on $MODE. Try again" \
                       2> /dev/null
        exit 0
    fi
    
    cd $MODE
    RESTORELIST=$(ls $MODE)
    MODE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-database.png --caption="Restore Standard" --combobox="Select For Restore" $RESTORELIST 2> /dev/null)
    EXIT=$?
    if-cancel-exit
    beginning-restore
    rm -fr $(tar -tf $MODE 2> /dev/null|head -n1)
    restore-qdbusinsert
    tar -jxPpf $MODE > /dev/null 2>&1
    chown $USER:$USER $HOME
    finished-restore
fi

exit 0
