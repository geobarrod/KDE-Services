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

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
SYSKERNELVERSION=$(uname -r|sed 's/.fc.*$//')
INTERNETVERSION=$(yumdownloader --url --source kernel|grep kernel|grep -v "No source RPM found"|sed 's/^.*kernel-//'|sed 's/.fc...src.rpm$//')

yumdownloader --url --source kernel > /dev/null 2>&1
EXIT=$?

if [ "$EXIT" != "0" ]; then
        kdialog --icon=ks-kernel-update --title="Build Custom Kernel" \
                --error="No Internet Communication: You have some network problem, can't check updates." 2> /dev/null
        EXIT=6
fi

if [ "$EXIT" = "0" ]; then
        if [ "$SYSKERNELVERSION" != "$INTERNETVERSION" ]; then
                kdialog --icon=ks-kernel-update --title="Check Kernel Update" \
                        --yesno "New version available: kernel-$INTERNETVERSION. Do you want to download it and use it?" 2> /dev/null
                EXIT=$?
        
                if [ "$EXIT" = "0" ]; then
                        xterm -T "Build Custom Kernel" -bg black -fg white -e ~/.local/share/applications/System_Tools-build-custom-kernel.sh &
                else
                        exit 1
                fi
        else
                kdialog --icon=ks-kernel-update --title="Check Kernel Update" --sorry "No update available." 2> /dev/null
        fi
fi

exit 0
