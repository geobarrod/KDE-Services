#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
DBUSREF=""
DROPBOX="/usr/share/applications/Dropbox_Tools-frontend.py"
DROPBOX_PATH="$(tail -n1 $HOME/.dropbox/host.db|base64 -d)"
FILE="$2"
EXIT=""
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""
ET=""
MATCH=0
LOGIN=""
PASS=""
PASS2=""
STRONGPASS=$(tr -dc a-z0-9 < /dev/urandom|head -c128|sed 's/[^ ]\+/\L\u&/g'|tr -d '\n'|xargs)

###################################
############ Functions ############
###################################

elapsed-time() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
	ET="${ELAPSED_TIME}s"
	true
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ET="$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')m"
	true
    elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
        ET="$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')h"
	true
    elif [ "$ELAPSED_TIME" -gt "86399" ]; then
        ET="$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')d"
	true
    fi
}

check_stderr() {
    if [ "$EXIT" != "0" ]; then
	qdbus $DBUSREF close
	kdialog --icon=ks-error \
                       --title="Dropbox Tools" \
                       --passivepopup="[Canceled]   Download error, check your internet connection is up."
	exit 1
    fi
}

finish-update() {
    echo "Finish Update Dropbox Service" > /tmp/speak
    text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
    play /tmp/speak.wav 2> /dev/null
    rm -fr /tmp/speak*
}

clipboard_url() {
    LOGIN=$(kdialog --icon=ks-dropbox --title="Dropbox Tools" \
			--inputbox="Enter username for access via web to public Dropbox folder")
    while [ "$MATCH" != "1" ]; do
	PASS=$(kdialog --password="Enter password for access via web to public Dropbox folder" --title="Dropbox Tools")
	PASS2=$(kdialog --password="Retype password for access via web to public Dropbox folder" --title="Dropbox Tools")
	if [ "$PASS" == "$PASS2" ]; then
	    MATCH=1
	    cat > $DROPBOX_PATH/Public/index.html << EOF
<script language=JavaScript>m='%3C%21DOCTYPE%20html%20PUBLIC%20%22-//W3C//DTD%20XHTML%201.1//EN%22%20%22http%3A//www.w3.org/TR/xhtml11/dtd/xhtml11.dtd%22%3E%0A%3Chtml%3E%0A%3Chead%3E%0A%3Cmeta%20charset%3D%22utf-8%22%3E%0A%3Ctitle%3EDropbox%20Authentication%3C/title%3E%0A%3Clink%20rel%3D%22shortcut%20icon%22%20href%3D%22http%3A//www.dropbox.com/static/1238803391/images/favicon.ico%22/%3E%0A%3Clink%20rel%3D%22stylesheet%22%20href%3D%22http%3A//www.dropbox.com/static/1241315492/css/sprites.css%22%20type%3D%22text/css%22%20media%3D%22screen%22/%3E%0A%3CA%20href%3D%22https%3A//www.dropbox.com/referrals/NTEwMTI3MjM5%22%3E%0A%3Ccenter%3E%3CIMG%20alt%3D%22dropbox%22%20src%3D%22http%3A//www.dropbox.com/static/images/main_logo%22%20title%3D%22Get%20a%20free%20Dropbox%20account%22%3E%3C/center%3E%0A%3C/A%3E%0A%3C/head%3E%0A%3Cbody%3E%0A%3Cscript%20language%3DJavaScript%3E%0A//Disable%20right%20mouse%20click%20Script%0A//By%20Maximus%20%28maximus@nsimail.com%29%20w/%20mods%20by%20DynamicDrive%0A//For%20full%20source%20code%2C%20visit%20http%3A//www.dynamicdrive.com%0Avar%20message%3D%22Function%20Disabled%21%22%3B%0Afunction%20clickIE4%28%29%7B%0Aif%20%28event.button%3D%3D2%29%7B%0Aalert%28message%29%3B%0Areturn%20false%3B%0A%7D%0A%7D%0Afunction%20clickNS4%28e%29%7B%0Aif%20%28document.layers%7C%7Cdocument.getElementById%26%26%21document.all%29%7B%0Aif%20%28e.which%3D%3D2%7C%7Ce.which%3D%3D3%29%7B%0Aalert%28message%29%3B%0Areturn%20false%3B%0A%7D%0A%7D%0A%7D%0Aif%20%28document.layers%29%7B%0Adocument.captureEvents%28Event.MOUSEDOWN%29%3B%0Adocument.onmousedown%3DclickNS4%3B%0A%7D%0Aelse%20if%20%28document.all%26%26%21document.getElementById%29%7B%0Adocument.onmousedown%3DclickIE4%3B%0A%7D%0Adocument.oncontextmenu%3Dnew%20Function%28%22alert%28message%29%3Breturn%20false%22%29%0A%3C/script%3E%0A%3Cform%3E%0A%3CH3%3E%0A%3Cp%3E%3Ccenter%3EUsername%20%3A%0A%3Cinput%20type%3D%22text%22%20name%3D%22text1%22%3E%0A%3C/center%3E%0A%3C/p%3E%0A%3Cp%3E%3Ccenter%3EPassword%20%3A%0A%3Cinput%20type%3D%22password%22%20name%3D%22text2%22%3E%0A%3C/center%3E%0A%3Ccenter%3E%3Cinput%20type%3D%22button%22%20value%3D%22Check%20In%22%20name%3D%22Submit%22%20onclick%3Djavascript%3Avalidate%28text1.value%2C%22$LOGIN%22%2Ctext2.value%2C%22$PASS%22%29%3E%3C/center%3E%0A%3C/p%3E%0A%3C/H3%3E%0A%3C/form%3E%0A%3Cscript%20language%20%3D%20%22javascript%22%3E%0A/*%0AScript%20by%20Anubhav%20Misra%20%28anubhav_misra@hotmail.com%29%0ASubmitted%20to%20JavaScript%20Kit%20%28http%3A//javascriptkit.com%29%0AFor%20this%20and%20400+%20free%20scripts%2C%20visit%20http%3A//javascriptkit.com%0AAdapted%20for%20KDE-Services%20by%20Geovani%20B.%20R.%20%28geobarrod%29%20igeo.cu@gmail.com%0A*/%0Afunction%20validate%28text1%2Ctext2%2Ctext3%2Ctext4%29%0A%7B%0Aif%20%28text1%3D%3Dtext2%20%26%26%20text3%3D%3Dtext4%29%0Aload%28%27$($DROPBOX puburl $DROPBOX_PATH/Public/${FILE##*/})%27%29%3B%0Aelse%20%0A%7B%0Aload%28%27index.html%27%29%3B%0A%7D%0A%7D%0Afunction%20load%28url%29%0A%7B%0Alocation.href%3Durl%3B%0A%7D%0A%3C/script%3E%0A%3C/body%3E%0A%3C/html%3E%0A';d=unescape(m);document.write(d);</script>
EOF
	    if [ "$PASS" != "" ]; then
		rm -f $DROPBOX_PATH/Public/'.config;'*
		echo [Options] > $DROPBOX_PATH/Public/'.config;'$STRONGPASS
		echo encrypt=true >> $DROPBOX_PATH/Public/'.config;'$STRONGPASS
	    fi
	else
	    kdialog --icon=ks-error \
                       --title="Dropbox Tools" \
                       --passivepopup="[Error]   Typed passwords not match, try again."
	fi
    done
    qdbus org.kde.klipper /klipper org.kde.klipper.klipper.setClipboardContents "$($DROPBOX puburl $DROPBOX_PATH/Public/index.html)"
}

dropbox_not_installed() {
        kdialog --icon=ks-error \
                       --title="Dropbox Tools" \
                       --passivepopup="[Canceled]   Please, install and configure the Dropbox service, running \"Install Dropbox service\"."
}

copy() {
    if [ -f $HOME/.dropbox/host.db ]; then
        DBUSREF=$(kdialog --icon=ks-dropbox --title="Dropbox Tools" --progressbar " " /ProgressDialog)
        qdbus $DBUSREF setLabelText "Copying ${FILE##*/} to $DROPBOX_PATH..."
	BEGIN_TIME=$(date +%s)
        cp -rf $FILE $DROPBOX_PATH
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
        qdbus $DBUSREF close
        elapsed-time
        kdialog --icon=ks-dropbox \
                       --title="Dropbox Tools" \
                       --passivepopup="[Finished]   Copied ${FILE##*/} to $DROPBOX_PATH.   [$ET]"
    else
        dropbox_not_installed
    fi
}

move() {
    if [ -f $HOME/.dropbox/host.db ]; then
        DBUSREF=$(kdialog --icon=ks-dropbox --title="Dropbox Tools" --progressbar " " /ProgressDialog)
        qdbus $DBUSREF setLabelText "Moving ${FILE##*/} to $DROPBOX_PATH..."
	BEGIN_TIME=$(date +%s)
        mv -f $FILE $DROPBOX_PATH
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
        qdbus $DBUSREF close
        elapsed-time
        kdialog --icon=ks-dropbox \
                       --title="Dropbox Tools" \
                       --passivepopup="[Finished]   Moved ${FILE##*/} to $DROPBOX_PATH.   [$ET]"
    else
        dropbox_not_installed
    fi
}

copy_pub() {
    if [ -f $HOME/.dropbox/host.db ]; then
        DBUSREF=$(kdialog --icon=ks-dropbox --title="Dropbox Tools" --progressbar " " /ProgressDialog)
        qdbus $DBUSREF setLabelText "Copying ${FILE##*/} to $DROPBOX_PATH/Public..."
	BEGIN_TIME=$(date +%s)
        cp -rf $FILE $DROPBOX_PATH/Public
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
        qdbus $DBUSREF close
        clipboard_url
        elapsed-time
        kdialog --icon=ks-dropbox \
                       --title="Dropbox Tools" \
                       --passivepopup="[Finished]   Copied ${FILE##*/} to $DROPBOX_PATH/Public. Copied public URL to clipboard.   [$ET]"
    else
        dropbox_not_installed
    fi
}

move_pub() {
    if [ -f $HOME/.dropbox/host.db ]; then
        DBUSREF=$(kdialog --icon=ks-dropbox --title="Dropbox Tools" --progressbar " " /ProgressDialog)
        qdbus $DBUSREF setLabelText "Moving ${FILE##*/} to $DROPBOX_PATH/Public..."
	BEGIN_TIME=$(date +%s)
        mv -f $FILE $DROPBOX_PATH/Public
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
        qdbus $DBUSREF close
        clipboard_url
        elapsed-time
        kdialog --icon=ks-dropbox \
                       --title="Dropbox Tools" \
                       --passivepopup="[Finished]   Moved ${FILE##*/} to $DROPBOX_PATH/Public. Copied public URL to clipboard.   [$ET]"
    else
        dropbox_not_installed
    fi
}

get_pub_url() {
    if [ "${FILE%/*}" == "$DROPBOX_PATH/Public" ]; then
        clipboard_url
        kdialog --icon=ks-dropbox \
                       --title="Dropbox Tools" \
                       --passivepopup="[Finished]   Copied public URL to clipboard."
    elif [ ! -f $HOME/.dropbox/host.db ]; then
	dropbox_not_installed
    else
        kdialog --icon=ks-error \
                       --title="Dropbox Tools" \
                       --passivepopup="[Canceled]   Please, copy or move ${FILE##*/} to $DROPBOX_PATH/Public directory and try again."
    fi
}

install_service() {
    BEGIN_TIME=$(date +%s)
    $DROPBOX start -i
    EXIT=$?
    check_stderr
    FINAL_TIME=$(date +%s)
    ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
    elapsed-time
    kdialog --icon=ks-dropbox \
                       --title="Dropbox Tools" \
                       --passivepopup="[Finished]   Installed Dropbox service.   [$ET]"
    echo "Finish Install Dropbox Service" > /tmp/speak
    text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
    play /tmp/speak.wav 2> /dev/null
    rm -fr /tmp/speak*
}

start_service() {
    if [ -f $HOME/.dropbox-dist/dropboxd ]; then
	DBUSREF=$(kdialog --icon=ks-dropbox --title="Dropbox Tools" --progressbar " " /ProgressDialog)
        qdbus $DBUSREF setLabelText "Starting Dropbox service..."
	BEGIN_TIME=$(date +%s)
	$DROPBOX start
	FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
        qdbus $DBUSREF close
        elapsed-time
	kdialog --icon=ks-dropbox-on \
                   --title="Dropbox Tools" \
                   --passivepopup="[Finished]   Started Dropbox.   [$ET]"
    else
	dropbox_not_installed
    fi
}

stop_service() {
    if [ -f $HOME/.dropbox-dist/dropboxd ]; then
    DBUSREF=$(kdialog --icon=ks-dropbox --title="Dropbox Tools" --progressbar " " /ProgressDialog)
    qdbus $DBUSREF setLabelText "Stoping Dropbox service..."
    BEGIN_TIME=$(date +%s)
    $DROPBOX stop
    FINAL_TIME=$(date +%s)
    ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
    qdbus $DBUSREF close
    elapsed-time
    kdialog --icon=ks-dropbox-off \
                   --title="Dropbox Tools" \
                   --passivepopup="[Finished]   Stoped Dropbox.   [$ET]"
    else
	dropbox_not_installed
    fi
}

autostart_service() {
    if [ -f $HOME/.dropbox-dist/dropboxd ]; then
    cat > $HOME/.config/autostart/dropbox.desktop << EOF
[Desktop Entry]
Name=Dropbox
GenericName=File Synchronizer
Comment=Sync your files across computers and to the web
Exec=$DROPBOX start -i
Terminal=false
Type=Application
Icon=ks-dropbox
Categories=Network;FileTransfer;
StartupNotify=false
EOF
    kdialog --icon=ks-dropbox \
                   --title="Dropbox Tools" \
                   --passivepopup="[Finished]   Enabled Dropbox service autostart."
    else
	dropbox_not_installed
    fi
}

update_service() {
    if [ -f $HOME/.dropbox-dist/dropboxd ] && [ "$(uname -m)" == "i686" ]; then
	stop_service
	DBUSREF=$(kdialog --icon=ks-dropbox --title="Dropbox Tools" --progressbar " " /ProgressDialog)
	qdbus $DBUSREF setLabelText "Updating Dropbox service..."
	rm -fr $HOME/.dropbox-dist
	cd $HOME
	BEGIN_TIME=$(date +%s)
	wget -rcnd -O - "https://www.dropbox.com/download?plat=lnx.x86"|tar xzf -
	EXIT=$?
	check_stderr
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	qdbus $DBUSREF close
	elapsed-time
	kdialog --icon=ks-dropbox \
                       --title="Dropbox Tools" \
                       --passivepopup="[Finished]   Updated Dropbox service.   [$ET]"
	start_service
	finish-update
    elif [ -f $HOME/.dropbox-dist/dropboxd ] && [ "$(uname -m)" == "x86_64" ]; then
	stop_service
	DBUSREF=$(kdialog --icon=ks-dropbox --title="Dropbox Tools" --progressbar " " /ProgressDialog)
	qdbus $DBUSREF setLabelText "Updating Dropbox service..."
	rm -fr $HOME/.dropbox-dist
	cd $HOME
	BEGIN_TIME=$(date +%s)
	wget -rcnd -O - "https://www.dropbox.com/download?plat=lnx.x86_64"|tar xzf -
	EXIT=$?
	check_stderr
	FINAL_TIME=$(date +%s)
	ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
	qdbus $DBUSREF close
	elapsed-time
        kdialog --icon=ks-dropbox \
                       --title="Dropbox Tools" \
                       --passivepopup="[Finished]   Updated Dropbox service.   [$ET]"
	start_service
	finish-update
    else
	dropbox_not_installed
    fi
}

##############################
############ Main ############
##############################

case "$1" in
    copy) copy ;;
    move) move ;;
    copy_pub) copy_pub ;;
    move_pub) move_pub ;;
    get_pub_url) get_pub_url ;;
    install_service) install_service ;;
    start_service) start_service ;;
    stop_service) stop_service ;;
    autostart_service) autostart_service ;;
    update_service) update_service ;;
esac
