#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2011-2025.                                                       #
#                                                                                 #
# BSD 3-Clause License                                                            #
#                                                                                 #
# Copyright (c) 2025, Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.  #
#                                                                                 #
# Redistribution and use in source and binary forms, with or without              #
# modification, are permitted provided that the following conditions are met:     #
#                                                                                 #
#  1. Redistributions of source code must retain the above copyright notice, this #
#     list of conditions and the following disclaimer.                            #
#                                                                                 #
#  2. Redistributions in binary form must reproduce the above copyright notice,   #
#     this list of conditions and the following disclaimer in the documentation   #
#     and/or other materials provided with the distribution.                      #
#                                                                                 #
#  3. Neither the name of the copyright holder nor the names of its               #
#     contributors may be used to endorse or promote products derived from        #
#     this software without specific prior written permission.                    #
#                                                                                 #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"     #
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE  #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE    #
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL      #
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR      #
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER      #
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   #
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE   #
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.            #
###################################################################################

BEGIN_TIME=""
ELAPSED_TIME=""
FILE=$@
FINAL_TIME=""
HASH=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PB_PIDFILE="$(mktemp)"
TMP=$(mktemp)

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
	kdialog --icon=ks-checksum --title="Verify $HASH CheckSum" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
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
		progressbar-stop
		exit 1
	fi

	if [ "$CHECKSUMFILE" = "md5" ] || [ "$CHECKSUMFILE" = "MD5" ]; then
		HASH=$(echo md5|tr a-z A-Z)
		BEGIN_TIME=$(date +%s)
		md5sum -c "$file" > $TMP 2>&1
		finished
	elif [ "$CHECKSUMFILE" = "sha1" ] || [ "$CHECKSUMFILE" = "SHA1" ]; then
		HASH=$(echo sha1|tr a-z A-Z)
		BEGIN_TIME=$(date +%s)
		sha1sum -c "$file" > $TMP 2>&1
		finished
	elif [ "$CHECKSUMFILE" = "sha256" ] || [ "$CHECKSUMFILE" = "SHA256" ]; then
		HASH=$(echo sha256|tr a-z A-Z)
		BEGIN_TIME=$(date +%s)
		sha256sum -c "$file" > $TMP 2>&1
		finished
	elif [ "$CHECKSUMFILE" = "sha512" ] || [ "$CHECKSUMFILE" = "SHA512" ]; then
		HASH=$(echo sha512|tr a-z A-Z)
		BEGIN_TIME=$(date +%s)
		sha512sum -c "$file" > $TMP 2>&1
		finished
	fi
done
progressbar-stop
exit 0

