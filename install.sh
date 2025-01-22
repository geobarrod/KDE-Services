#################################################################
# Installing KDE-Services, to appropriate directories.		#
# Author: Geovani Barzaga Rodriguez <igeo.cu@gmail.com>.	#
# KDE-Services 2011-2025. GPLv3+				#
#################################################################

PREFIXmenu5=~/.local/share/kservices5/ServiceMenus
PREFIXmenu6=~/.local/share/kio/servicemenus
PREFIXservicetypes5=~/.local/share/kservicetypes5
PREFIXapp=~/.local/share/applications
PREFIXSVGicons=~/.local/share/icons/hicolor/scalable/apps
PREFIXmime=~/.local/share/mime/text
PREFIXappmerge=~/.config/kdedefaults/menus/applications-merged
PREFIXdeskdir=~/.local/share/desktop-directories
PREFIXdoc=~/.local/share/doc/kde-services

if [ "$KDE_SESSION_VERSION" == "5" ]; then
	mkdir -p ${PREFIXmenu5}
elif [ "$KDE_SESSION_VERSION" == "6" ]; then
	mkdir -p ${PREFIXmenu6}
fi
mkdir -p ${PREFIXservicetypes5}
mkdir -p ${PREFIXapp}
mkdir -p ${PREFIXSVGicons}
mkdir -p ${PREFIXmime}
mkdir -p ${PREFIXappmerge}
mkdir -p ${PREFIXdeskdir}
mkdir -p ${PREFIXdoc}

if [ "$KDE_SESSION_VERSION" == "5" ]; then
	cp ServiceMenus/* ${PREFIXmenu5}
elif [ "$KDE_SESSION_VERSION" == "6" ]; then
	cp ServiceMenus/* ${PREFIXmenu6}
fi
cp servicetypes/* ${PREFIXservicetypes5}
cp applications/* ${PREFIXapp}
cp scalable/apps/* ${PREFIXSVGicons}
cp mime/text/* ${PREFIXmime}
cp applications-merged/* ${PREFIXappmerge}
cp desktop-directories/* ${PREFIXdeskdir}
cp doc/* ${PREFIXdoc}

xdg-mime install --novendor ${PREFIXmime}/kde-services.xml
update-mime-database ~/.local/share/mime > /dev/null
xdg-icon-resource forceupdate --theme hicolor
xdg-desktop-menu forceupdate
