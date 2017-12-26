#!/bin/bash

#################################################################
# For KDE-Services. 2011-2017.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
MEGARC="$HOME/.megarc"
DBUSREF=""
EXIT=""
STDOUT=""
STDERR=""
EMAIL=""
NAME=""
PASS=""
LINK=""
FILES=""
SELECT_FILES=""
DIR="$2"

###################################
############ Functions ############
###################################

progressbar_start() {
	DBUSREF=$(kdialog --icon=ks-mega --title="MEGA Tools" --progressbar " " 0)
}

qdbusinsert() {
	qdbus $DBUSREF setLabelText "Running your request..."
}

progressbar_close() {
	qdbus $DBUSREF close
}

check_stderr() {
	if [ "$EXIT" != "0" ]; then
		qdbus $DBUSREF close
		if [[ "$(cat $STDERR|grep -ow EEXIST)" ]]; then
			kdialog --icon=ks-error --title="MEGA Tools" --passivepopup="[ERROR]   Registration failed: Email '$EMAIL' already registered, try again."
		elif [[ "$(cat $STDERR|grep -ow "Couldn't resolve host name")" ]]; then
			kdialog --icon=ks-error --title="MEGA Tools" --passivepopup="[ERROR]   Registration failed: HTTP POST failed, couldn't resolve host name, check your internet access, try again."
		elif [[ "$(cat $STDERR|grep -ow "You must specify your mega.nz username")" ]]; then
			kdialog --icon=ks-error --title="MEGA Tools" --passivepopup="[ERROR]   You must save your user login credentials in $MEGARC file. After try again."
			$0 save_user_login_credentials
		else
			kdialog --icon=ks-error --title="MEGA Tools" --passivepopup="$(cat $STDERR)"
		fi
		rm -f $STDOUT $STDERR
		exit 1
	fi
}

check_cancel() {
	if [ "$EXIT" != "0" ]; then
		exit 1
	fi
}

register_new_account() {
	STDOUT=/tmp/megareg.stdout
	STDERR=/tmp/megareg.stderr
	EMAIL=$(kdialog --icon=ks-mega --title="Register New Account" --inputbox="Enter email, it will serve as your new account username, which you will use to login")
	EXIT=$?
	check_cancel
	NAME=$(kdialog --icon=ks-mega --title="Register New Account" --inputbox="Enter your real (or fake) name")
	EXIT=$?
	check_cancel
	PASS=$(kdialog --title="Register New Account" --password="Enter user login password. No strength checking is done, so make sure you pick a strong password yourself")
	EXIT=$?
	check_cancel
	PASS2=$(kdialog --title="Register New Account" --password="Retype the previous password to check")
	EXIT=$?
	check_cancel

	if [ "$PASS" != "$PASS2" ]; then
		kdialog --icon=ks-error --title="Register New Account" --passivepopup="[Error]   Typed passwords not match, try again."
		rm -f $MEGARC
		exit 1
	elif [ -z "$PASS" ] || [ -z "${PASS// }" ]; then
		kdialog --icon=ks-error --title="Register New Account" --passivepopup="[Error]   Blank or whitespace passwords are not allowed, try again."
		rm -f $MEGARC
		exit 1
	elif [ "$PASS" == "$PASS2" ]; then
		cat > $MEGARC << EOF
[Login]
Username = $EMAIL
Password = $PASS
EOF
	fi
	chmod 600 $MEGARC
	progressbar_start
	qdbusinsert
	megareg --register --email $EMAIL --name "$NAME" --password "$PASS" > $STDOUT 2> $STDERR
	EXIT=$?
	check_stderr
	progressbar_close
	LINK=$(kdialog --icon=ks-mega --title="Register New Account" --inputbox="Registration email was sent to $EMAIL. Enter the registration link from the 'MEGA Signup' email or if you prefer to confirm the registration request from the email press the cancel button")
	EXIT=$?
	check_cancel
	progressbar_start
	qdbusinsert
	megareg --verify $(cat $STDOUT|grep megareg|awk '{print $3}') $LINK > $STDOUT 2> $STDERR
	EXIT=$?
	check_stderr
	progressbar_close
	kdialog --icon=ks-mega --title="Register New Account" --passivepopup="[Finished]   $(cat $STDOUT). User login credentials saved in $MEGARC file."
	rm -f $STDOUT $STDERR
	exit 0
}

save_user_login_credentials() {
	EMAIL=$(kdialog --icon=ks-mega --title="Save User Login Credentials" --inputbox="Enter email as your account username")
	EXIT=$?
	check_cancel
	PASS=$(kdialog --title="Save User Login Credentials" --password="Enter user login password")
	EXIT=$?
	check_cancel
	PASS2=$(kdialog --title="Save User Login Credentials" --password="Retype the previous password to check")
	EXIT=$?
	check_cancel

	if [ "$PASS" != "$PASS2" ]; then
		kdialog --icon=ks-error --title="Save User Login Credentials" --passivepopup="[Error]   Typed passwords not match, try again."
		rm -f $MEGARC
		exit 1
	elif [ -z "$PASS" ] || [ -z "${PASS// }" ]; then
		kdialog --icon=ks-error --title="Save User Login Credentials" --passivepopup="[Error]   Blank or whitespace passwords are not allowed, try again."
		rm -f $MEGARC
		exit 1
	elif [ "$PASS" == "$PASS2" ]; then
		cat > $MEGARC << EOF
[Login]
Username = $EMAIL
Password = $PASS
EOF
	fi
	chmod 600 $MEGARC
	progressbar_start
	qdbusinsert
	FREESPACE=$(megadf -h --free|xargs)
	progressbar_close
	kdialog --icon=ks-mega --title="Save User Login Credentials" --passivepopup="[Finished]   Available free space in the cloud: $FREESPACE. User login credentials saved in $MEGARC file."
	exit 0
}

show_cloud_space() {
	STDERR=/tmp/megadf.stderr
	progressbar_start
	qdbusinsert
	megadf 2> $STDERR
	EXIT=$?
	check_stderr
	SPACE=$(megadf -h|xargs)
	progressbar_close
	kdialog --icon=ks-mega --title="Show Available Cloud Space" --passivepopup="[Finished]   Available space in the cloud: $SPACE."
	rm -f $STDERR
	exit 0
}

create_remote_folder() {
	STDERR=/tmp/megamkdir.stderr
	FOLDER=$(kdialog --icon=ks-mega --title="Create New Remote Folder" --inputbox="Enter name for the new remote folder")
	EXIT=$?
	check_cancel
	progressbar_start
	qdbusinsert
	megamkdir /Root/$FOLDER 2> $STDERR
	EXIT=$?
	check_stderr
	progressbar_close
	kdialog --icon=ks-mega --title="Create New Remote Folder" --passivepopup="[Finished]   The new folder '$FOLDER' has been successfully created."
	rm -f $STDERR
	exit 0
}

list_file_stored() {
	STDOUT=/tmp/megals.stdout
	STDERR=/tmp/megals.stderr
	progressbar_start
	qdbusinsert
	megals -ehl --reload 2> $STDERR
	EXIT=$?
	check_stderr
	megals -ehl --reload|grep https:|awk '{print $1,$5,$6,$7,$8,$9}' > $STDOUT
	progressbar_close
	kdialog --icon=ks-mega --title="You have $(cat $STDOUT|grep https:|wc -l|xargs) Files Stored in Cloud" --textbox=$STDOUT 770 450
	rm -f $STDOUT $STDERR
	exit 0
}

remove_file_stored() {
	STDERR=/tmp/megarm.stderr
	progressbar_start
	qdbusinsert
	FILES=$(megals --reload|grep 'Root\/'|sed 's/^\/Root\///g'|awk '{print $1,$1}'|sed 's/$/ off/g'|xargs)
	progressbar_close
	SELECT_FILES=$(kdialog --icon=ks-mega --title="Remove Files Stored in Cloud" --separate-output --checklist="Select Files to Remove" All "All List" off $FILES)
	EXIT=$?
	check_stderr
	if [ "$SELECT_FILES" == "All" ]; then
		progressbar_start
		qdbusinsert
		megarm --reload $(megals --reload|grep 'Root\/') 2> $STDERR
		EXIT=$?
		progressbar_close
		check_stderr
		kdialog --icon=ks-mega --title="Remove Files Stored in Cloud" --passivepopup="[Finished]   The entire list has been successfully removed."
	else
		REMOVE_FILES=$(echo $SELECT_FILES|sed -e 's/^/\/Root\//g' -e 's/ / \/Root\//g')
		progressbar_start
		qdbusinsert
		megarm --reload $REMOVE_FILES 2> $STDERR
		EXIT=$?
		progressbar_close
		check_stderr
		kdialog --icon=ks-mega --title="Remove Files Stored in Cloud" --passivepopup="[Finished]   The selected file(s) has been successfully removed."
	fi
	rm -f $STDERR
	exit 0
}

upload_file() {
	STDERR=/tmp/megaput.stderr
	FILES=$(kdialog --icon=ks-mega --title="Select and Upload Files to Cloud" --multiple --getopenfilename "$DIR")
	EXIT=$?
	check_cancel
	progressbar_start
	qdbusinsert
	REMOTE_DIR=$(megals --reload 2> $STDERR|grep '\/Root'|awk '{print $1,$1}'|sed 's/$/ off/g'|xargs)
	if [ -s "$STDERR" ]; then
		EXIT=1
		progressbar_close
		check_stderr
	fi
	progressbar_close
	SELECT_REMOTE_PATH=$(kdialog --icon=ks-mega --title="Select Remote Path" --radiolist="Select Directory" $REMOTE_DIR)
	EXIT=$?
	check_cancel
	progressbar_start
	qdbusinsert
	megaput --reload --path $SELECT_REMOTE_PATH $FILES 2> $STDERR
	EXIT=$?
	progressbar_close
	check_stderr
	kdialog --icon=ks-mega --title="Upload Files to Cloud" --passivepopup="[Finished]   The selected file(s) has been successfully uploaded."
	rm -f $STDERR
	exit 0
}

sync_directory_tree()  {
	STDERR=/tmp/megacopy.stderr
	OPTION=$(kdialog --icon=ks-mega --title="Synchronize [from|to] Cloud" --combobox="Select Option" "Download Directory Tree" "Upload Directory Tree" --default "Upload Directory Tree")
	EXIT=$?
	check_cancel
	
	if [ "$OPTION" == "Upload Directory Tree" ]; then
		SRC_DIR=$(kdialog --icon=ks-mega --title="Select Directory" --getexistingdirectory "$DIR")
		EXIT=$?
		check_cancel
		progressbar_start
		qdbusinsert
		megacopy --reload --local $SRC_DIR --remote /Root 2> $STDERR
		EXIT=$?
		progressbar_close
		check_stderr
		kdialog --icon=ks-mega --title="Synchronize Directory Tree to Cloud" --passivepopup="[Finished]   The synchronization has been successfully."
		rm -f $STDERR
		exit 0
	elif [ "$OPTION" == "Download Directory Tree" ]; then
		DST_DIR=$(kdialog --icon=ks-mega --title="Select Destination Directory" --getexistingdirectory "$DIR")
		EXIT=$?
		check_cancel
		progressbar_start
		qdbusinsert
		megacopy --reload --local $DST_DIR --remote /Root --download 2> $STDERR
		EXIT=$?
		progressbar_close
		check_stderr
		kdialog --icon=ks-mega --title="Synchronize Directory Tree from Cloud" --passivepopup="[Finished]   The synchronization has been successfully."
		rm -f $STDERR
		exit 0
	fi
}

##############################
############ Main ############
##############################

if [ "$DIR" == "/usr/share/applications" ]; then
	DIR="~/"
fi

case "$1" in
	register_new_account) register_new_account ;;
	save_user_login_credentials) save_user_login_credentials ;;
	show_cloud_space) show_cloud_space ;;
	create_remote_folder) create_remote_folder ;;
	list_file_stored) list_file_stored ;;
	remove_file_stored) remove_file_stored ;;
	upload_file) upload_file ;;
	sync_directory_tree) sync_directory_tree ;;
esac
