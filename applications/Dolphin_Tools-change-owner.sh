#!/bin/bash

#################################################################
# For KDE-Services. 2011-2014.									#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>				#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
OBJECT=$1
OWNER=""
MODE=""
MODE2=""
DBUSREF=""
SYSUSERS=$(awk -F : '{print $1}' /etc/passwd|sort)

###################################
############ Functions ############
###################################

progressbar-start() {
    DBUSREF=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-owner.png --caption="Change Owner Here" --progressbar "                            " /ProgressDialog)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value 0
    sleep 1
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Change Owner for:  ${OBJECT##*/}"
}

##############################
############ Main ############
##############################

OWNER=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-owner.png --caption="Change Owner Here" --combobox="Select Owner" $SYSUSERS --default $USER 2> /dev/null)

if [ "$?" -gt "0" ]; then
    kill -9 $(pidof knotify4)
    exit 0
fi

if [ -d "$1" ]; then
    MODE=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-owner.png --caption="Change Owner Here" \
         --menu="Change Mode Bits (Owner-Group-Others)" 755 "755 (rwx-rx-rx)" 775 "775 (rwx-rwx-rx)" 777 "777 (rwx-rwx-rwx)" 700 "700 (rwx--)" \
         2> /dev/null)
    
    if [ "$?" -gt "0" ]; then
        kill -9 $(pidof knotify4)
        exit 0
    fi
    
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-owner.png --caption="Change Owner Here" --yesnocancel Recursively? 2> /dev/null
    EXIT=$?
    
    if [ "$EXIT" = "2" ]; then
        kill -9 $(pidof knotify4)
        exit 0
    fi
    
    progressbar-start
    
    if [ "$EXIT" = "1" ]; then
        qdbusinsert
        chown $OWNER:$OWNER $1
        chmod $MODE $1
        export OBJECT OWNER MODE
        progressbar-close
        su -c 'kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-owner.png --title="Change Owner Directory ($OBJECT) To ($OWNER ($MODE))" \
                              --passivepopup="[Finished]" 2> /dev/null' $USER
        kill -9 $(pidof knotify4)
        unset OBJECT OWNER MODE
        exit 0
    fi
    
    if [ "$EXIT" = "0" ]; then
        qdbusinsert
        chown -R $OWNER:$OWNER $1
        chmod -R $MODE $1
        export OBJECT OWNER MODE
        progressbar-close
        su -c 'kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-owner.png --title="Change Owner Directory ($OBJECT) To ($OWNER ($MODE)) Recursively" \
                              --passivepopup="[Finished]" 2> /dev/null' $USER
        kill -9 $(pidof knotify4)
        unset OBJECT OWNER MODE
        exit 0
    fi
fi

MODE2=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-owner.png --caption="Change Owner Here" --menu="Change Mode Bits (Owner-Group-Others)" 644 "644 (rw-r-r)" \
      664 "664 (rw-rw-r)" 666 "666 (rw-rw-rw)" 600 "600 (rw--)" 744 "744 (rwx-r-r)" 774 "774 (rwx-rwx-r)" 755 "755 (rwx-rx-rx)" 775 "775\
      (rwx-rwx-rx)" 777 "777 (rwx-rwx-rwx)" 700 "700 (rwx--)" 2> /dev/null)

if [ "$?" -gt "0" ]; then
    kill -9 $(pidof knotify4)
    exit 0
fi

progressbar-start
qdbusinsert
chown $OWNER:$OWNER $1
chmod $MODE2 $1
export OBJECT OWNER MODE2
progressbar-close
su -c 'kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-owner.png --title="Change Owner File ($OBJECT) To ($OWNER ($MODE2))" \
                      --passivepopup="[Finished]" 2> /dev/null' $USER
kill -9 $(pidof knotify4)
unset OBJECT OWNER MODE2
exit 0
