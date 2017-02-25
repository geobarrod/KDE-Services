#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
TARGET=$@
OWNER=""
MODE=""
MODE2=""
DBUSREF=""
STDERR="/tmp/change-owner-here"
SYSUSERS=$(awk -F : '{print $1}' /etc/passwd|sort)

###################################
############ Functions ############
###################################

check-stderr() {
    if [ -s "$STDERR" ]; then
        su -c 'kdialog --icon=ks-error --title="Change Owner Directory" \
                              --passivepopup="[Error] $(cat $STDERR)" 2> /dev/null' $USER
        rm -f $STDERR
        qdbus $DBUSREF close
        exit 1
    fi
}
        
progressbar-start() {
    DBUSREF=$(kdialog --icon=ks-owner --title="Change Owner Here" --progressbar "                            " /ProgressDialog)
}

progressbar-close() {
    qdbus $DBUSREF Set "" value 0
    sleep 1
    qdbus $DBUSREF close
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Changing owner and mode bits..."
}

##############################
############ Main ############
##############################

rm -f $STDERR
OWNER=$(kdialog --icon=ks-owner --title="Change Owner Here" --combobox="Select Owner" $SYSUSERS --default $USER 2> /dev/null)

if [ "$?" -gt "0" ]; then
    kill -9 $(pidof knotify4)
    exit 0
fi

if [ -d "$@" ]; then
    MODE=$(kdialog --icon=ks-owner --title="Change Owner Here" \
         --menu="Change Mode Bits (Owner-Group-Others)" 755 "755 (rwx-rx-rx)" 775 "775 (rwx-rwx-rx)" 777 "777 (rwx-rwx-rwx)" 700 "700 (rwx--)" \
         2> /dev/null)
    
    if [ "$?" -gt "0" ]; then
        kill -9 $(pidof knotify4)
        exit 0
    fi
    
    kdialog --icon=ks-owner --title="Change Owner Here" --yesnocancel Recursively? 2> /dev/null
    EXIT=$?
    
    if [ "$EXIT" = "2" ]; then
        kill -9 $(pidof knotify4)
        exit 0
    fi
    
    progressbar-start
    
    if [ "$EXIT" = "1" ]; then
        qdbusinsert
        export TARGET OWNER MODE STDERR
        chown $OWNER:$OWNER $@ 2>> $STDERR
        check-stderr
        chmod $MODE $@ 2>> $STDERR
        check-stderr
        progressbar-close
        su -c 'kdialog --icon=ks-owner --title="Change Owner Directory" \
                              --passivepopup="[Finished] New directory owner: ($OWNER) with mode bits: ($MODE)." 2> /dev/null' $USER
        rm -f $STDERR
        unset TARGET OWNER MODE STDERR
        kill -9 $(pidof knotify4)
        exit 0
    fi
    
    if [ "$EXIT" = "0" ]; then
        qdbusinsert
        export TARGET OWNER MODE STDERR
        chown -R $OWNER:$OWNER $@ 2>> $STDERR
        check-stderr
        chmod -R $MODE $@ 2>> $STDERR
        check-stderr
        progressbar-close
        su -c 'kdialog --icon=ks-owner --title="Change Owner Directory" \
                              --passivepopup="[Finished] New directory owner: ($OWNER) with mode bits: ($MODE) recursively." 2> /dev/null' $USER
        rm -f $STDERR
        unset TARGET OWNER MODE STDERR
        kill -9 $(pidof knotify4)
        exit 0
    fi
fi

MODE2=$(kdialog --icon=ks-owner --title="Change Owner Here" --menu="Change Mode Bits (Owner-Group-Others)" 644 "644 (rw-r-r)" \
      664 "664 (rw-rw-r)" 666 "666 (rw-rw-rw)" 600 "600 (rw--)" 744 "744 (rwx-r-r)" 774 "774 (rwx-rwx-r)" 755 "755 (rwx-rx-rx)" 775 "775\
      (rwx-rwx-rx)" 777 "777 (rwx-rwx-rwx)" 700 "700 (rwx--)" 2> /dev/null)

if [ "$?" -gt "0" ]; then
    kill -9 $(pidof knotify4)
    exit 0
fi

progressbar-start
qdbusinsert
export TARGET OWNER MODE2 STDERR
chown $OWNER:$OWNER $@ 2>> $STDERR
check-stderr
chmod $MODE2 $@ 2>> $STDERR
check-stderr
progressbar-close
su -c 'kdialog --icon=ks-owner --title="Change Owner File" \
                      --passivepopup="[Finished] New file owner: ($OWNER) with mode bits: ($MODE2)." 2> /dev/null' $USER
rm -f $STDERR
unset TARGET OWNER MODE2 STDERR
kill -9 $(pidof knotify4)
exit 0
