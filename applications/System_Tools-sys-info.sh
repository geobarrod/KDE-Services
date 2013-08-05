#!/bin/bash

#################################################################
# For KDE-Services. 2012-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

SYSINFO=$(kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="System Information" \
        --combobox="Choose keyword" Full Baseboard BIOS Cache Chassis Connector Memory Processor Slot System --default Full 2> /dev/null)
EXIT=$?

if [ "$EXIT" != "0" ]; then
    exit 0
fi

if [ "$SYSINFO" = "Full" ]; then
    kdesu --noignorebutton -d -c "dmidecode -q > /tmp/sysinfo.tmp"
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="Full System Information" --textbox /tmp/sysinfo.tmp --geometry 580x360 2> /dev/null
elif [ "$SYSINFO" = "Baseboard" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt baseboard > /tmp/sysinfo.tmp"
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="Baseboard Information" --textbox /tmp/sysinfo.tmp --geometry 580x360 2> /dev/null
elif [ "$SYSINFO" = "BIOS" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt bios > /tmp/sysinfo.tmp"
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="BIOS Information" --textbox /tmp/sysinfo.tmp --geometry 580x360 2> /dev/null
elif [ "$SYSINFO" = "Cache" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt cache > /tmp/sysinfo.tmp"
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="Cache Information" --textbox /tmp/sysinfo.tmp --geometry 580x360 2> /dev/null
elif [ "$SYSINFO" = "Chassis" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt chassis > /tmp/sysinfo.tmp"
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="Chassis Information" --textbox /tmp/sysinfo.tmp --geometry 580x360 2> /dev/null
elif [ "$SYSINFO" = "Connector" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt connector > /tmp/sysinfo.tmp"
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="Connector Information" --textbox /tmp/sysinfo.tmp --geometry 580x360 2> /dev/null
elif [ "$SYSINFO" = "Memory" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt memory > /tmp/sysinfo.tmp"
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="Memory Information" --textbox /tmp/sysinfo.tmp --geometry 580x360 2> /dev/null
elif [ "$SYSINFO" = "Processor" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt processor > /tmp/sysinfo.tmp"
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="Processor Information" --textbox /tmp/sysinfo.tmp --geometry 580x360 2> /dev/null
elif [ "$SYSINFO" = "Slot" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt slot > /tmp/sysinfo.tmp"
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="Slot Information" --textbox /tmp/sysinfo.tmp --geometry 580x360 2> /dev/null
elif [ "$SYSINFO" = "System" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt system > /tmp/sysinfo.tmp"
    kdialog --icon=/usr/share/icons/hicolor/512x512/apps/ks-hwinfo.png --caption="System Information" --textbox /tmp/sysinfo.tmp --geometry 580x360 2> /dev/null
fi

exit 0
