#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2013-2025.                                                       #
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

###################################
############### Main ##############
###################################

cd "${1%/*}"
stat --printf "Name:\t\t %n\n" "${1##*/}" > /tmp/show-status
stat --printf "Location:\t\t %n\n" "$1" >> /tmp/show-status
stat --printf "User name of owner:\t %U\n" "$1" >> /tmp/show-status
stat --printf "User ID of owner:\t %u\n" "$1" >> /tmp/show-status
stat --printf "Group name of owner:\t %G\n" "$1" >> /tmp/show-status
stat --printf "Group ID of owner:\t %g\n" "$1" >> /tmp/show-status
stat --printf "Access rights:\t %A\n" "$1" >> /tmp/show-status
stat --printf "Access rights in octal:\t %a\n" "$1" >> /tmp/show-status
stat --printf "Type:\t\t %F\n" "$1" >> /tmp/show-status
stat --printf "Major device type in hex:\t %t\n" "$1" >> /tmp/show-status
stat --printf "Minor device type in hex:\t %T\n" "$1" >> /tmp/show-status
stat --printf "Total size, in bytes:\t %s\n" "$1" >> /tmp/show-status
stat --printf "SELinux security context: %C\n" "$1" >> /tmp/show-status
stat --printf "Number of hard links:\t %h\n" "$1" >> /tmp/show-status
stat --printf "Inode number:\t %i\n" "$1" >> /tmp/show-status
stat --printf "Mount point:\t %m\n" "$1" >> /tmp/show-status
stat -f --printf "File system type:\t %T\n" "$1" >> /tmp/show-status
stat -f --printf "Max length of filenames:\t %l\n" "$1" >> /tmp/show-status
stat --printf "Time of file birth:\t %w\n" "$1" >> /tmp/show-status
stat --printf "Time of last access:\t %x\n" "$1" >> /tmp/show-status
stat --printf "Time of last modification: %y\n" "$1" >> /tmp/show-status
stat --printf "Time of last change:\t %z\n" "$1" >> /tmp/show-status
kdialog --icon=ks-info --title="Show [File|Directory] Status" --textbox /tmp/show-status 500 450 2> /dev/null
rm -f /tmp/show-status

exit 0

