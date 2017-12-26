#!/bin/bash

#################################################################
# For KDE-Services. 2011-2017.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
BEGIN_TIME=$(date +%s)

###################################
############ Functions ############
###################################

progressbar-start() {
  DBUSREF=$(kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB)" --progressbar " " 0)
}

qdbusinsert() {
	qdbus $DBUSREF setLabelText "Compute disk space used..."
}

progressbar-close() {
  qdbus $DBUSREF close
}

##############################
############ Main ############
##############################

progressbar-start
qdbusinsert
du -ah $1|egrep -e "^...T" -e "^..T" -e "^.T" -e "^...G" -e "^..G" -e "^.G" -e "^...M"|egrep -v "^.\..M"|egrep -v "^ ..M"|sort -rh > /tmp/info.tmp
sort -rh /tmp/info.tmp > /tmp/info
FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
progressbar-close

if [ -s /tmp/info ]; then
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB) Elapsed Time: ${ELAPSED_TIME}s" --textbox /tmp/info 640 480 2> /dev/null
    
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB) Elapsed Time: ${ELAPSED_TIME}m" --textbox /tmp/info 640 480 2> /dev/null
    
    elif [ "$ELAPSED_TIME" -gt "3599" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB) Elapsed Time: ${ELAPSED_TIME}h" --textbox /tmp/info 640 480 2> /dev/null
    fi
    
    rm -fr /tmp/info*
else
    kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB)" --sorry="No Find Files or Directory Up 100 MB" 2> /dev/null
    kill -9 $(pidof knotify4)
    rm -fr /tmp/info*
fi

exit 0
