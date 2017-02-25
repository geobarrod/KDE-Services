#!/bin/bash

#################################################################
# For KDE-Services. 2011-2015.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
TMP=$(mktemp)
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
DBUSREF=""
COUNT=""
COUNTFILES=""
HASH=""
FILE=$@

###################################
############ Functions ############
###################################

finished() {
    if [ "$?" = "0" ]; then
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
        
        if [ "$ELAPSED_TIME" -lt "60" ]; then
            kdialog --icon=ks-checksum --title="Verify $HASH CheckSum" \
                           --passivepopup="[Finished]   $(cat $TMP).   Elapsed Time: ${ELAPSED_TIME}s" 2> /dev/null
            
            elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
            kdialog --icon=ks-checksum --title="Verify $HASH CheckSum" \
                           --passivepopup="[Finished]   $(cat $TMP).   Elapsed Time: ${ELAPSED_TIME}m" 2> /dev/null
            
            elif [ "$ELAPSED_TIME" -gt "3599" ]; then
            ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
            kdialog --icon=ks-checksum --title="Verify $HASH CheckSum" \
                           --passivepopup="[Finished]   $(cat $TMP).   Elapsed Time: ${ELAPSED_TIME}h" 2> /dev/null
        fi
        
    else
        kdialog --icon=ks-error --title="Verify $HASH CheckSum" \
                       --passivepopup="[Error]   $(cat $TMP|awk -F : '{print $3}')." 2> /dev/null
    fi
    rm -f $TMP
}

progressbar-start() {
    COUNT="0"
    COUNTFILES=$(echo $FILE|wc -w)
    COUNTFILES=$((++COUNTFILES))
    DBUSREF=$(kdialog --icon=ks-checksum --title="Verify $HASH CheckSum" --progressbar "                        " $COUNTFILES)
}

qdbusinsert() {
    qdbus $DBUSREF setLabelText "Verify $HASH CheckSum:  ${file##*/}  [$COUNT/$((COUNTFILES-1))]"
    qdbus $DBUSREF Set "" value $COUNT
}

##############################
############ Main ############
##############################

progressbar-start

for file in $FILE; do
	cd "${file%/*}"

	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")")" \
		"$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")"|\
		sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")" "$(dirname \
		"$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")" "$(dirname "$(dirname \
		"$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")" "$(dirname "$(dirname "$(dirname \
		"$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname \
		"$(pwd|grep " ")")")")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")"|\
		sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")" "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(dirname "$(pwd|grep " ")")")" "$(dirname "$(dirname "$(pwd|grep " ")")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(dirname "$(pwd|grep " ")")" "$(dirname "$(pwd|grep " ")"|sed 's/ /_/g')" 2> /dev/null
	cd ./
	mv "$(pwd|grep " ")" "$(pwd|grep " "|sed 's/ /_/g')" 2> /dev/null
	cd ./

	for i in *; do
		mv "$i" "${i// /_}" 2> /dev/null
	done

	DIR="$(pwd)"
	CHECKSUMFILE=${file##*.}
	
	if [ "$CHECKSUMFILE" != "md5" ] && [ "$CHECKSUMFILE" != "MD5" ] && [ "$CHECKSUMFILE" != "sha1" ] && [ "$CHECKSUMFILE" != "SHA1" ] && \
		[ "$CHECKSUMFILE" != "sha256" ] && [ "$CHECKSUMFILE" != "SHA256" ] && [ "$CHECKSUMFILE" != "sha512" ] && [ "$CHECKSUMFILE" != "SHA512" ]; then
		kdialog --icon=ks-error --title="Verify CheckSum" \
							--passivepopup="[Canceled]   Support only this checksum files: *.md5, *.sha1, *.sha256 and *.sha512" 2> /dev/null
		qdbus $DBUSREF close
		exit 1
	fi

	if [ "$CHECKSUMFILE" = "md5" ] || [ "$CHECKSUMFILE" = "MD5" ]; then
		HASH=$(echo md5|tr a-z A-Z)
		COUNT=$((++COUNT))
		qdbusinsert
		BEGIN_TIME=$(date +%s)
		md5sum -c "$file" > $TMP 2>&1
		finished
	elif [ "$CHECKSUMFILE" = "sha1" ] || [ "$CHECKSUMFILE" = "SHA1" ]; then
		HASH=$(echo sha1|tr a-z A-Z)
		COUNT=$((++COUNT))
		qdbusinsert
		BEGIN_TIME=$(date +%s)
		sha1sum -c "$file" > $TMP 2>&1
		finished
	elif [ "$CHECKSUMFILE" = "sha256" ] || [ "$CHECKSUMFILE" = "SHA256" ]; then
		HASH=$(echo sha256|tr a-z A-Z)
		COUNT=$((++COUNT))
		qdbusinsert
		BEGIN_TIME=$(date +%s)
		sha256sum -c "$file" > $TMP 2>&1
		finished
	elif [ "$CHECKSUMFILE" = "sha512" ] || [ "$CHECKSUMFILE" = "SHA512" ]; then
		HASH=$(echo sha512|tr a-z A-Z)
		COUNT=$((++COUNT))
		qdbusinsert
		BEGIN_TIME=$(date +%s)
		sha512sum -c "$file" > $TMP 2>&1
		finished
	fi
done
qdbus $DBUSREF Set "" value $COUNTFILES
sleep 1
qdbus $DBUSREF close
exit 0
