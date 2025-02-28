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
# Improved: Victor Guardiola (vguardiola) Jan 5 2014.                             #
#            Fixed the problem of [dir|file]name with whitespace.                 #
###################################################################################

MOUNTEXIT=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin

##############################
############ Main ############
##############################

cd "${1%/*}"

if [ "$1" == "${1%.*}.iso" ]; then
        fuseiso -p "$1" "${1%.iso}"
        MOUNTEXIT=$?
else
        rename .ISO .iso *
        kdialog --icon=ks-error --title="Mount ISO-9660 Image" \
                --passivepopup="[Error] Can't mount ${1##*/}: Renamed extension of ISO image, because contain uppercase characters. Please try again."
        exit 1
fi

if [ "$MOUNTEXIT" = "0" ]; then
        kdialog --icon=ks-media-optical-mount --title="Mount ISO-9660 Image" --passivepopup="[Finished] ${1##*/} mounted."
else
        kdialog --icon=ks-error --title="Mount ISO-9660 Image" \
                --passivepopup="[Error] Can't mount ${1##*/}: Already mount or check image integrity."
        exit 1
fi

exit 0

