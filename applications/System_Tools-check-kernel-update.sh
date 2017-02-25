#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

SYSKERNELVERSION=$(uname -r|sed 's/.fc.*$//')
INTERNETVERSION=$(yumdownloader --url --source kernel|grep kernel|grep -v "No source RPM found"|sed 's/^.*kernel-//'|sed 's/.fc...src.rpm$//')
yumdownloader --url --source kernel > /dev/null 2>&1
EXIT=$?

if [ "$EXIT" != "0" ]; then
    kdialog --icon=ks-kernel-update --title="Build Custom Kernel" \
                   --error="No Internet Communication: You have some network problem, can't check updates." 2> /dev/null
    EXIT=6
fi

if [ "$EXIT" = "0" ]; then
    if [ "$SYSKERNELVERSION" != "$INTERNETVERSION" ]; then
        kdialog --icon=ks-kernel-update --title="Check Kernel Update" \
                    --yesno "New version available: kernel-$INTERNETVERSION. Do you want to download it and use it?" 2> /dev/null
        EXIT=$?
    
        if [ "$EXIT" = "0" ]; then
            xterm -T "Build Custom Kernel" -bg black -fg white -e /usr/share/applications/System_Tools-build-custom-kernel.sh &
        else
            exit 0
        fi
    else
        kdialog --icon=ks-kernel-update --title="Check Kernel Update" --sorry "No update available." 2> /dev/null
    fi
fi

exit 0
