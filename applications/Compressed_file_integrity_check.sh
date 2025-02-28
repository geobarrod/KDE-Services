#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2014-2025.                                                       #
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
EXIT=""
FILE=$@
FINAL_TIME=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PB_PIDFILE="$(mktemp)"

###################################
############# Functions ###########
###################################

progressbar-start() {
	kdialog --icon=ks-compressed-file --title="Compressed File Integrity Check" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

elapsedtime() {
	if [ "$ELAPSED_TIME" -lt "60" ]; then
		kdialog --icon=ks-compressed-file --title="Compressed File Integrity Check" \
			--passivepopup="[Finished]  ${file##*/} is OK.   Elapsed Time: ${ELAPSED_TIME}s"
	elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-compressed-file --title="Compressed File Integrity Check" \
			--passivepopup="[Finished]   ${file##*/} is OK.   Elapsed Time: ${ELAPSED_TIME}m"
	elif [ "$ELAPSED_TIME" -gt "3599" ]; then
		ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
		kdialog --icon=ks-compressed-file --title="Compressed File Integrity Check" \
			--passivepopup="[Finished]   ${file##*/} is OK.   Elapsed Time: ${ELAPSED_TIME}h"
	fi
}

exit-check() {
	if [ "$EXIT" = "1" ]; then
		kdialog --icon=ks-error --title="Compressed File Integrity Check" \
			--passivepopup="[Error]  ${file##*/}   Archive parsing failed! (Data is corrupted.)"
		exit 1
	fi
	while [ "$EXIT" = "2" ] || [ "$EXIT" = "1" ]; do
		PWD=$(kdialog --icon=ks-compressed-file --title="Compressed File Integrity Check" \
			--password="The ${file##*/} archive is encrypted, requires a password for integrity check")
		lsar -t $file -p $PWD > /dev/null 2>&1
		EXIT=$?
	done
}

###################################
############### Main ##############
###################################

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

	BEGIN_TIME=$(date +%s)
	lsar -t $file > /dev/null 2>&1
	EXIT=$?
	exit-check
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	elapsedtime
done
progressbar-stop
exit 0

