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
# KDE-Services ⚙ 2011-2025.                                            #
# Author: Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.   #
########################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
TMP=/tmp/SearchByString
PB_PIDFILE="$(mktemp)"
STRING=$(kdialog --icon=ks-search-string --title='Search by String' --inputbox='Enter String to Search' 2> /dev/null)
if [ "$?" != "0" ]; then
	exit 1
fi
kdialog --icon=ks-search-string --title="Search by String" --print-winid --progressbar "$(date) - Processing..." /ProcessDialog|grep -o '[[:digit:]]*' > $PB_PIDFILE
egrep -r "$STRING" "$1"/* > $TMP
kill $(cat $PB_PIDFILE)
rm $PB_PIDFILE
kdialog --icon=ks-search-string --title="Search by String: $(cat $TMP|wc -l) matching entries with ($STRING)" \
	--textbox $TMP 900 300 2> /dev/null
rm -f $TMP
exit 0
