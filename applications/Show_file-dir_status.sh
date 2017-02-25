#!/bin/bash

#################################################################
# For KDE-Services. 2013-2017.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

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
