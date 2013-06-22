#!/bin/bash

#################################################################
# For KDE Services. 2011-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin

export $(dbus-launch)

STRING=$(kdialog --icon=edit-find-mail --caption='Search By String' --inputbox='Enter String To Search' 2> /dev/null)
DBUSREF=$(kdialog --icon=edit-find-mail --caption="Search By String" --progressbar "                                        " /ProgressDialog)
qdbus $DBUSREF setLabelText "Searching string ($STRING) on $(basename $1) directory recursively..."
grep -r "$STRING" $1/* > /tmp/SearchByString
qdbus $DBUSREF close
kdialog --icon=edit-find-mail --caption="Search By String: $(cat /tmp/SearchByString|wc -l) matching entries with ($STRING)" \
               --textbox /tmp/SearchByString 900 300 2> /dev/null
rm -f /tmp/SearchByString

exit 0
