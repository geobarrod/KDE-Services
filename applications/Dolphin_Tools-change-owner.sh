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

MODE=""
MODE2=""
OWNER=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PB_PIDFILE="$(mktemp)"
STDERR="/tmp/change-owner-here"
SYSUSERS=$(awk -F : '{print $1}' /etc/passwd|sort)
TARGET=$@

###################################
############ Functions ############
###################################

check-stderr() {
	if [ -s "$STDERR" ]; then
		su -c 'kdialog --icon=ks-error --title="Change Owner Directory" \
			--passivepopup="[Error] $(cat $STDERR)" 2> /dev/null' $USER
		rm -f $STDERR
		exit 1
	fi
}

progressbar-start() {
	kdialog --icon=ks-owner --title="Change Owner Here" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
}

progressbar-stop() {
	kill $(cat $PB_PIDFILE)
	rm $PB_PIDFILE
}

##############################
############ Main ############
##############################

rm -f $STDERR
OWNER=$(kdialog --icon=ks-owner --title="Change Owner Here" --combobox="Select Owner" $SYSUSERS --default $USER 2> /dev/null)

if [ "$?" -gt "0" ]; then
	kill -9 $(pidof knotify4)
	exit 0
fi

if [ -d "$@" ]; then
	MODE=$(kdialog --icon=ks-owner --title="Change Owner Here" \
		--menu="Change Mode Bits (Owner-Group-Others)" 755 "755 (rwx-rx-rx)" 775 "775 (rwx-rwx-rx)" 777 "777 (rwx-rwx-rwx)" 700 "700 (rwx--)" 2> /dev/null)
	if [ "$?" -gt "0" ]; then
		kill -9 $(pidof knotify4)
		exit 0
	fi
	kdialog --icon=ks-owner --title="Change Owner Here" --yesnocancel Recursively? 2> /dev/null
	EXIT=$?
	if [ "$EXIT" = "2" ]; then
		kill -9 $(pidof knotify4)
		exit 0
	fi
	progressbar-start
	if [ "$EXIT" = "1" ]; then
		export TARGET OWNER MODE STDERR
		chown $OWNER:$OWNER $@ 2>> $STDERR
		check-stderr
		chmod $MODE $@ 2>> $STDERR
		check-stderr
		progressbar-stop
		su -c 'kdialog --icon=ks-owner --title="Change Owner Directory" \
				--passivepopup="[Finished] New directory owner: ($OWNER) with mode bits: ($MODE)." 2> /dev/null' $USER
		rm -f $STDERR
		unset TARGET OWNER MODE STDERR
		kill -9 $(pidof knotify4)
		exit 0
	fi
	if [ "$EXIT" = "0" ]; then
		export TARGET OWNER MODE STDERR
		chown -R $OWNER:$OWNER $@ 2>> $STDERR
		check-stderr
		chmod -R $MODE $@ 2>> $STDERR
		check-stderr
		progressbar-stop
		su -c 'kdialog --icon=ks-owner --title="Change Owner Directory" \
			--passivepopup="[Finished] New directory owner: ($OWNER) with mode bits: ($MODE) recursively." 2> /dev/null' $USER
		rm -f $STDERR
		unset TARGET OWNER MODE STDERR
		kill -9 $(pidof knotify4)
		exit 0
	fi
fi

MODE2=$(kdialog --icon=ks-owner --title="Change Owner Here" --menu="Change Mode Bits (Owner-Group-Others)" 644 "644 (rw-r-r)" \
	664 "664 (rw-rw-r)" 666 "666 (rw-rw-rw)" 600 "600 (rw--)" 744 "744 (rwx-r-r)" 774 "774 (rwx-rwx-r)" 755 "755 (rwx-rx-rx)" 775 "775\
	(rwx-rwx-rx)" 777 "777 (rwx-rwx-rwx)" 700 "700 (rwx--)" 2> /dev/null)

if [ "$?" -gt "0" ]; then
	kill -9 $(pidof knotify4)
	exit 0
fi

progressbar-start
export TARGET OWNER MODE2 STDERR
chown $OWNER:$OWNER $@ 2>> $STDERR
check-stderr
chmod $MODE2 $@ 2>> $STDERR
check-stderr
progressbar-stop
su -c 'kdialog --icon=ks-owner --title="Change Owner File" \
	--passivepopup="[Finished] New file owner: ($OWNER) with mode bits: ($MODE2)." 2> /dev/null' $USER
rm -f $STDERR
unset TARGET OWNER MODE2 STDERR
kill -9 $(pidof knotify4)
exit 0

