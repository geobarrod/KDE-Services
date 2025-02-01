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
# KDE-Services ⚙ 2013-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

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
