#!/bin/bash

#################################################################
# For KDE Services. 2012-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
DIR=""
MOUNTEXIT=""
MOVEXIT=""

###################################
############ Functions ############
###################################

check-exit() {
    if [ "$?" = "0" ]; then
        true
        MOVEXIT=0
    fi
}

##############################
############ Main ############
##############################

DIR=$(dirname "$1")
cd "$DIR"

mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")")" \
    "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")"|\
    sed 's/ /_/g')" 2> /dev/null
check-exit
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")")" "$(dirname \
    "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")"|sed 's/ /_/g')" 2> /dev/null
check-exit
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")")" "$(dirname "$(dirname \
    "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")"|sed 's/ /_/g')" 2> /dev/null
check-exit
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")")" "$(dirname "$(dirname "$(dirname \
    "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")"|sed 's/ /_/g')" 2> /dev/null
check-exit
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname \
    "$(pwd|grep " ")")")")")"|sed 's/ /_/g')" 2> /dev/null
check-exit
cd ./
mv "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")")" "$(dirname "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")"|\
    sed 's/ /_/g')" 2> /dev/null
check-exit
cd ./
mv "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")")" "$(dirname "$(dirname "$(dirname "$(pwd|grep " ")")")"|sed 's/ /_/g')" 2> /dev/null
check-exit
cd ./
mv "$(dirname "$(dirname "$(pwd|grep " ")")")" "$(dirname "$(dirname "$(pwd|grep " ")")"|sed 's/ /_/g')" 2> /dev/null
check-exit
cd ./
mv "$(dirname "$(pwd|grep " ")")" "$(dirname "$(pwd|grep " ")"|sed 's/ /_/g')" 2> /dev/null
check-exit
cd ./
mv "$(pwd|grep " ")" "$(pwd|grep " "|sed 's/ /_/g')" 2> /dev/null
check-exit
cd ./

RENAMETMP=$(ls *.* 2> /dev/null|grep " " > /tmp/rename)
RENAME=$(cat /tmp/rename)

for i in $RENAME; do
    mv *$i* $(ls *$i*|sed 's/ /_/g') 2> /dev/null
    check-exit
done

RENAMETMP=$(ls *.ISO 2> /dev/null > /tmp/rename)
RENAME=$(cat /tmp/rename)

for i in $RENAME; do
    mv *$i* $(ls *$i*|sed 's/.ISO$/.iso/g') 2> /dev/null
    check-exit
done

rm -fr /tmp/rename

fuseiso -p $1 $(ls $1|sed 's/.iso$//')
MOUNTEXIT=$?

if [ "$MOUNTEXIT" = "0" ]; then
    kdialog --icon=media-optical-recordable --title="Mount ISO Image" --passivepopup="[Finished]"
elif [ "$MOUNTEXIT" != "0" ] && [ "$MOVEXIT" != "0" ]; then
    kdialog --icon=application-exit --title="Mount ISO Image" \
                   --passivepopup="[Error] Can't mount ISO image: Already mount or check image integrity."
elif [ "$MOVEXIT" = "0" ]; then
    kdialog --icon=dialog-warning --title="Mount ISO Image" \
                   --passivepopup="Renamed path or filename of ISO image, because contain whitespaces or uppercase extension. Please try again."
fi

exit 0
