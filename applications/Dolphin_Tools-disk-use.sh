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
BEGIN_TIME=$(date +%s)
ELAPSED_TIME=""
FINAL_TIME=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PB_PIDFILE="$(mktemp)"

###################################
############ Functions ############
###################################

progressbar-start() {
	kdialog --icon=ks-disk-space-used --title="Disk Space Used By... (Up 100 MB)" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

##############################
############ Main ############
##############################

progressbar-start
du -ah $1|egrep -e "^...T" -e "^..T" -e "^.T" -e "^...G" -e "^..G" -e "^.G" -e "^...M"|egrep -v "^.\..M"|egrep -v "^ ..M"|sort -rh > /tmp/info.tmp
sort -rh /tmp/info.tmp > /tmp/info
FINAL_TIME=$(date +%s)
ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
progressbar-stop

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
