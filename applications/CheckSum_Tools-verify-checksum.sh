#!/bin/bash -x

#################################################################
# For KDE Services. 2011-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
CHECKSUMFILE=$(basename "$1"|grep -ioe ".md5$" -ioe ".sha1$" -ioe ".sha256$" -ioe ".sha512$"|sed 's/.//'|sort -u)
TMP=$(mktemp)
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
COUNT=""
COUNTFILE=""
HASH=""
FILE="$1"

###################################
############ Functions ############
###################################

finished() {
    if [ "$?" = "0" ]; then
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$(echo "$FINAL_TIME-$BEGIN_TIME"|bc)
        
        if [ "$ELAPSED_TIME" -lt "60" ]; then
            kdialog --icon=emblem-new --title="Verify $HASH CheckSum" \
                           --passivepopup="[Finished]   $(cat $TMP).   Elapsed Time: $ELAPSED_TIME s." 2> /dev/null
            
            elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
            kdialog --icon=emblem-new --title="Verify $HASH CheckSum" \
                           --passivepopup="[Finished]   $(cat $TMP).   Elapsed Time: $ELAPSED_TIME m." 2> /dev/null
            
            elif [ "$ELAPSED_TIME" -gt "3599" ]; then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
            kdialog --icon=emblem-new --title="Verify $HASH CheckSum" \
                           --passivepopup="[Finished]   $(cat $TMP).   Elapsed Time: $ELAPSED_TIME h." 2> /dev/null
        fi
        
    else
        kdialog --icon=application-exit --title="Verify $HASH CheckSum" \
                       --passivepopup="[Error]   $(cat $TMP|awk -F : '{print $3}')." 2> /dev/null
    fi
    
    rm -f $TMP
    qdbus $DBUSREF Set "" value $COUNTFILE
    sleep 1
    qdbus $DBUSREF close
    exit 0
}

progressbar-start() {
    COUNT="0"
    COUNTFILE=$(echo "$FILE"|wc -l)
    COUNTFILE=$(expr $COUNTFILE + 1)
    DBUSREF=$(kdialog --icon=emblem-new --caption="Verify $HASH CheckSum" --progressbar "                        " /ProgressDialog)
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Verify $HASH CheckSum:  $(basename "$FILE")"
    qdbus $DBUSREF Set "" value $COUNT
}

##############################
############ Main ############
##############################

cd $(dirname $1)

if [ "$CHECKSUMFILE" != "md5" ] && [ "$CHECKSUMFILE" != "MD5" ] && [ "$CHECKSUMFILE" != "sha1" ] && [ "$CHECKSUMFILE" != "SHA1" ] && \
    [ "$CHECKSUMFILE" != "sha256" ] && [ "$CHECKSUMFILE" != "SHA256" ] && [ "$CHECKSUMFILE" != "sha512" ] && [ "$CHECKSUMFILE" != "SHA512" ]; then
    kdialog --icon=application-exit --title="Verify CheckSum" \
                           --passivepopup="[Canceled]   Support only this checksum files: *.md5, *.sha1, *.sha256 and *.sha512" 2> /dev/null
    exit 1
fi

progressbar-start

if [ "$CHECKSUMFILE" = "md5" ] || [ "$CHECKSUMFILE" = "MD5" ]; then
    HASH=$(echo md5|tr a-z A-Z)
    COUNT=$(expr $COUNT + 1)
    qdbusinsert
    BEGIN_TIME=$(date +%s)
    md5sum -c "$1" > $TMP 2>&1
    finished
elif [ "$CHECKSUMFILE" = "sha1" ] || [ "$CHECKSUMFILE" = "SHA1" ]; then
    HASH=$(echo sha1|tr a-z A-Z)
    COUNT=$(expr $COUNT + 1)
    qdbusinsert
    BEGIN_TIME=$(date +%s)
    sha1sum -c "$1" > $TMP 2>&1
    finished
elif [ "$CHECKSUMFILE" = "sha256" ] || [ "$CHECKSUMFILE" = "SHA256" ]; then
    HASH=$(echo sha256|tr a-z A-Z)
    COUNT=$(expr $COUNT + 1)
    qdbusinsert
    BEGIN_TIME=$(date +%s)
    sha256sum -c "$1" > $TMP 2>&1
    finished
elif [ "$CHECKSUMFILE" = "sha512" ] || [ "$CHECKSUMFILE" = "SHA512" ]; then
    HASH=$(echo sha512|tr a-z A-Z)
    COUNT=$(expr $COUNT + 1)
    qdbusinsert
    BEGIN_TIME=$(date +%s)
    sha512sum -c "$1" > $TMP 2>&1
    finished
fi

exit 0
