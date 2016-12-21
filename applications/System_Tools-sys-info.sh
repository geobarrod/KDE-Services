#!/bin/bash

#################################################################
# For KDE-Services. 2012-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
WIDTH=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $1}')
HEIGHT=$(xrandr |grep '*'|awk -F " " '{print $1}'|awk -Fx '{print $2}')

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

SYSINFO=$(kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="System Information" \
        --combobox="Choose keyword" Full Baseboard BIOS Cache Chassis Connector Memory Processor Slot System --default Full 2> /dev/null)
if-cancel-exit

if [ "$SYSINFO" = "Full" ]; then
    kdesu --noignorebutton -d -c "dmidecode -q > /tmp/sysinfo.tmp"
    if-cancel-exit
    kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="Full System Information" --textbox /tmp/sysinfo.tmp --geometry 580x360+$((WIDTH/2-580/2))+$((HEIGHT/2-360/2)) 2> /dev/null
elif [ "$SYSINFO" = "Baseboard" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt baseboard > /tmp/sysinfo.tmp"
    if-cancel-exit
    kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="Baseboard Information" --textbox /tmp/sysinfo.tmp --geometry 580x360+$((WIDTH/2-580/2))+$((HEIGHT/2-360/2)) 2> /dev/null
elif [ "$SYSINFO" = "BIOS" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt bios > /tmp/sysinfo.tmp"
    if-cancel-exit
    kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="BIOS Information" --textbox /tmp/sysinfo.tmp --geometry 580x360+$((WIDTH/2-580/2))+$((HEIGHT/2-360/2)) 2> /dev/null
elif [ "$SYSINFO" = "Cache" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt cache > /tmp/sysinfo.tmp"
    if-cancel-exit
    kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="Cache Information" --textbox /tmp/sysinfo.tmp --geometry 580x360+$((WIDTH/2-580/2))+$((HEIGHT/2-360/2)) 2> /dev/null
elif [ "$SYSINFO" = "Chassis" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt chassis > /tmp/sysinfo.tmp"
    if-cancel-exit
    kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="Chassis Information" --textbox /tmp/sysinfo.tmp --geometry 580x360+$((WIDTH/2-580/2))+$((HEIGHT/2-360/2)) 2> /dev/null
elif [ "$SYSINFO" = "Connector" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt connector > /tmp/sysinfo.tmp"
    if-cancel-exit
    kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="Connector Information" --textbox /tmp/sysinfo.tmp --geometry 580x360+$((WIDTH/2-580/2))+$((HEIGHT/2-360/2)) 2> /dev/null
elif [ "$SYSINFO" = "Memory" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt memory > /tmp/sysinfo.tmp"
    if-cancel-exit
    kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="Memory Information" --textbox /tmp/sysinfo.tmp --geometry 580x360+$((WIDTH/2-580/2))+$((HEIGHT/2-360/2)) 2> /dev/null
elif [ "$SYSINFO" = "Processor" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt processor > /tmp/sysinfo.tmp"
    if-cancel-exit
    kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="Processor Information" --textbox /tmp/sysinfo.tmp --geometry 580x360+$((WIDTH/2-580/2))+$((HEIGHT/2-360/2)) 2> /dev/null
elif [ "$SYSINFO" = "Slot" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt slot > /tmp/sysinfo.tmp"
    if-cancel-exit
    kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="Slot Information" --textbox /tmp/sysinfo.tmp --geometry 580x360+$((WIDTH/2-580/2))+$((HEIGHT/2-360/2)) 2> /dev/null
elif [ "$SYSINFO" = "System" ]; then
    kdesu --noignorebutton -d -c "dmidecode -qt system > /tmp/sysinfo.tmp"
    if-cancel-exit
    kdialog --icon=/usr/share/icons/hicolor/scalable/apps/ks-hwinfo.svgz --title="System Information" --textbox /tmp/sysinfo.tmp --geometry 580x360+$((WIDTH/2-580/2))+$((HEIGHT/2-360/2)) 2> /dev/null
fi

exit 0
