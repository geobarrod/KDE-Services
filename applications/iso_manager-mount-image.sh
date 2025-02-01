#!/usr/bin/env bash
########################################################################
# This program is free software; you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation; either version 3 of the License, or    #
# (at your option) any later version.                                  #
#                                                                      #
# This program is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License for more details.                         #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with this program; if not, write to the Free Software          #
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,           #
# MA 02110-1301, USA.                                                  #
#                                                                      #
#                                                                      #
# KDE-Services ⚙ 2012-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
# Improved: Victor Guardiola (vguardiola) Jan 5 2014.                  #
#            Fixed the problem of [dir|file]name with whitespace.      #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
MOUNTEXIT=""

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
