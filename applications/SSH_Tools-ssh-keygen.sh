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

KDESU="kdesu"
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin

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

LOGIN=$(kdialog --icon=ks-keygen --title="SSH Tools - Public Key Generation" --combobox="Select User" $USER root --default $USER 2> /dev/null)
if-cancel-exit

if [ "$LOGIN" = "$USER" ]; then
	xterm -si -s -sl 1000000 -sb -T "SSH Tools - Public Key Generation For $LOGIN" -bg black -fg white -e ssh-keygen
	kdialog --icon=ks-keygen --title="SSH Tools" --passivepopup="[Finished]   Public Key Generation For $LOGIN"
elif [ "$LOGIN" = "root" ]; then
	$KDESU -i ks-keygen --noignorebutton -d -c "xterm -si -s -sl 1000000 -sb -T "SSH Tools - Public Key Generation For $LOGIN" -bg black -fg white -e ssh-keygen"
	if-cancel-exit
	kdialog --icon=ks-keygen --title="SSH Tools" --passivepopup="[Finished]   Public Key Generation For $LOGIN"
fi

exit 0

