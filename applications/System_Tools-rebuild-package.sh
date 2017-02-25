#!/bin/bash

#################################################################
# For KDE-Services. 2011-2016.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/$USER/bin
GREEN='\E[32;40m'
GREENRED='\E[32;41m'
WHITE='\E[37;40m'
PACKAGESOURCE=""
APPNAME=""
NOTEXIST=""
LOCALVERSION=""
INTERNETVERSION=""
CANCELED="Canceled"
PID="$$"
EXIT=""
BINOPT=""
BEGIN_TIME=""
FINAL_TIME=""
ELAPSED_TIME=""

###################################
############ Functions ############
###################################

elapsed-time() {
    if [ "$ELAPSED_TIME" -lt "60" ]; then
        kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" --passivepopup="[Finished]. Compilation Time: ${ELAPSED_TIME}s" 2> /dev/null
    elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
        kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" --passivepopup="[Finished]. Compilation Time: ${ELAPSED_TIME}m" 2> /dev/null
    elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
        kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" --passivepopup="[Finished]. Compilation Time: ${ELAPSED_TIME}h" 2> /dev/null
    elif [ "$ELAPSED_TIME" -gt "86399" ]; then
        ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
        kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" --passivepopup="[Finished]. Compilation Time: ${ELAPSED_TIME}d" 2> /dev/null
    fi
}

if-cancel-exit() {
    if [ "$EXIT" = "2" ]; then
        rm -fr ~/rpmbuild/BUILD/* 2> /dev/null
        rm -fr ~/rpmbuild/BUILDROOT/* 2> /dev/null
        rm -fr ~/rpmbuild/SOURCES/* 2> /dev/null
        rm -fr ~/rpmbuild/SPECS/* 2> /dev/null
        rm -fr ~/rpmbuild/TMP/* 2> /dev/null
        kill -9 $(pidof xterm|awk -F " " '{print $1}') > /dev/null 2>&1
        exit 0
    fi
}

if-cancel-exit2() {
    if [ "$EXIT" = "1" ]; then
        rm -fr ~/rpmbuild/BUILD/* 2> /dev/null
        rm -fr ~/rpmbuild/BUILDROOT/* 2> /dev/null
        rm -fr ~/rpmbuild/SOURCES/* 2> /dev/null
        rm -fr ~/rpmbuild/SPECS/* 2> /dev/null
        rm -fr ~/rpmbuild/TMP/* 2> /dev/null
        kill -9 $(pidof xterm|awk -F " " '{print $1}') > /dev/null 2>&1
        exit 0
    fi
}

rpmbuild-error() {
    if [ "$?" != "0" ]; then
        echo "Error, Building Package. See debug console." > /tmp/speak
        text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
        play /tmp/speak.wav 2> /dev/null
        rm -fr /tmp/speak*
        echo -e "\n\n$GREEN>$GREENRED Error: Building $APPNAME Package.$GREEN Try Again.$WHITE\n"
        kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" \
                       --error="[Error]: Building $APPNAME Package. See $HOME/rpmbuild/TMP/$APPNAME.err and try again." 2> /dev/null &
        mv ~/rpmbuild/TMP/$APPNAME.log ~/rpmbuild/TMP/$APPNAME.err
    fi
}

rpm-install-error() {
    if [ "$EXIT" != "0" ]; then
        echo "Error, Installing Package. See debug console." > /tmp/speak
        text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
        play /tmp/speak.wav 2> /dev/null
        rm -fr /tmp/speak*
        echo -e "\n$GREEN>$GREENRED Error: Installing $APPNAME Package.$GREEN Try Again.$WHITE\n"
        kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" \
                       --error="[Error]: Installing $APPNAME Package. See debug console and try again." 2> /dev/null &
    fi
}

test-network() {
    if [ "$?" != "0" ]; then
        kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" \
            --error="No Internet Communication: You have some network or repositories problem, can't download $APPNAME source RPM package." \
            2> /dev/null
        rm -f /tmp/package-not-exist
        kill -9 $(pidof xterm|awk -F " " '{print $1}') > /dev/null 2>&1
        exit 0
    fi
}

sudo-no-timeout() {
    sudo grep passwd_timeout /etc/sudoers > /dev/null
    
    if [ "$?" != "0" ]; then
        echo -n "Enter Root "; su -c 'cat >> /etc/sudoers << EOF
Defaults    passwd_timeout = 0
Defaults    timestamp_timeout = -1
EOF'
    fi
}

rpmmacros-no-cflags() {
    sudo yum -y --nogpgcheck reinstall qt-devel kdelibs-devel > /dev/null
    BINOPT=$(cat ~/.kde-services/rebuild-package-cflags 2> /dev/null)
    kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package | B.O.O.=\"$BINOPT\"" \
            --yesnocancel="          Do you want to reconfigure Binary Optimization Option(s) of compilation?               " 2> /dev/null
    EXIT="$?"
    
    if [ "$EXIT" = "0" ]; then
        cat ~/.rpmmacros|grep -v optflags|grep -v global_cflags > ~/.rpmmacros.tmp
        cat ~/.rpmmacros.tmp > ~/.rpmmacros
        rm -f ~/.rpmmacros.tmp
    elif [ "$EXIT" = "1" ]; then
        BINOPT="-O2"
    elif [ "$EXIT" = "2" ]; then
        if-cancel-exit
    fi

    grep global_cflags ~/.rpmmacros > /dev/null 2>&1
    
    if [ "$?" != "0" ]; then
        BINOPT=$(kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" --combobox="Choose Binary Optimization Option(s)" \
               "Ofast -ffast-math -funroll-loops" "Ofast -funroll-loops" Ofast "O3 -ffast-math -funroll-loops" "O3 -funroll-loops" \
               O3 "O2 -ffast-math -funroll-loops" "O2 -funroll-loops" O2 O1 O0 Os --default "Ofast -ffast-math -funroll-loops" 2> /dev/null)
        EXIT=$?
        if-cancel-exit2
        
        if [ "$BINOPT" = "" ] || [ "$BINOPT" = " " ]; then
            BINOPT="O2"
        fi
        
        echo -e "\n%optflags\t\t-$BINOPT" >> ~/.rpmmacros
        echo -e "%__global_cflags\t-$BINOPT -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector \
                                                        --param=ssp-buffer-size=4 %{_hardened_cflags}" >> ~/.rpmmacros
        sudo sed -i "s;-O2;-$BINOPT;g" /usr/share/kde4/apps/cmake/modules/FindKDE4Internal.cmake > /dev/null 2>&1
        
        if [ "$(uname -m)" = "i686" ]; then
            sudo sed -i "s;-O2;-$BINOPT;g" /usr/lib/qt4/mkspecs/linux-g++/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;-$BINOPT;g" /usr/lib/qt4/mkspecs/linux-g++-32/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;-$BINOPT;g" /usr/lib/qt4/mkspecs/linux-g++-64/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;-$BINOPT;g" /usr/lib/qt4/mkspecs/common/gcc-base.conf > /dev/null 2>&1
        elif [ "$(uname -m)" = "x86_64" ]; then
            sudo sed -i "s;-O2;-$BINOPT;g" /usr/lib64/qt4/mkspecs/linux-g++/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;-$BINOPT;g" /usr/lib64/qt4/mkspecs/linux-g++-32/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;-$BINOPT;g" /usr/lib64/qt4/mkspecs/linux-g++-64/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;-$BINOPT;g" /usr/lib64/qt4/mkspecs/common/gcc-base.conf > /dev/null 2>&1
        fi
        
        mkdir ~/.kde-services > /dev/null 2>&1
        echo "-$BINOPT" > ~/.kde-services/rebuild-package-cflags
    fi
    
    grep fast-math /usr/share/kde4/apps/cmake/modules/FindKDE4Internal.cmake > /dev/null 2>&1
    
    if [ "$?" != "0" ]; then
        BINOPT=$(cat ~/.kde-services/rebuild-package-cflags 2> /dev/null)
        sudo sed -i "s;-O2;$BINOPT;g" /usr/share/kde4/apps/cmake/modules/FindKDE4Internal.cmake > /dev/null 2>&1
    fi
    
    grep fast-math /usr/lib/qt4/mkspecs/linux-g++/qmake.conf > /dev/null 2>&1
    
    if [ "$?" != "0" ]; then
        BINOPT=$(cat ~/.kde-services/rebuild-package-cflags 2> /dev/null)
        
        if [ "$(uname -m)" = "i686" ]; then
            sudo sed -i "s;-O2;$BINOPT;g" /usr/lib/qt4/mkspecs/linux-g++/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;$BINOPT;g" /usr/lib/qt4/mkspecs/linux-g++-32/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;$BINOPT;g" /usr/lib/qt4/mkspecs/linux-g++-64/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;$BINOPT;g" /usr/lib/qt4/mkspecs/common/gcc-base.conf > /dev/null 2>&1
        else
            sudo sed -i "s;-O2;$BINOPT;g" /usr/lib64/qt4/mkspecs/linux-g++/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;$BINOPT;g" /usr/lib64/qt4/mkspecs/linux-g++-32/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;$BINOPT;g" /usr/lib64/qt4/mkspecs/linux-g++-64/qmake.conf > /dev/null 2>&1
            sudo sed -i "s;-O2;$BINOPT;g" /usr/lib64/qt4/mkspecs/common/gcc-base.conf > /dev/null 2>&1
        fi
    
    fi
}

check-builddep() {
    if [ "$?" != "0" ]; then
        echo -e "\n$GREEN>$GREENRED Error: Installing Build Depends Package For $i.$GREEN$WHITE\n"
        sed -i "s;$i;;g" ~/.kde-services/source-packages
        cat ~/.kde-services/source-packages|xargs -n1|sort -u > /tmp/source-packages
        cat /tmp/source-packages > ~/.kde-services/source-packages
        cat ~/.kde-services/source-packages|xargs > /tmp/source-packages
        cat /tmp/source-packages > ~/.kde-services/source-packages
        rm -f /tmp/source-packages
        kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" \
                       --error="Can't install all the RPMs needed to build $i source RPM package. See debug console." 2> /dev/null &
        continue
    fi
}

notify() {
    if [ "$EXIT" = "0" ]; then
        kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" --passivepopup="Install $APPNAME   [Finished]" 2> /dev/null
    else
        kdialog --icon=ks-error --title="Rebuild RPM Package" --passivepopup="Install $APPNAME   [Error]: See debug console." \
                       2> /dev/null
    fi
}

finished() {
    elapsed-time
    echo "Finished Rebuilding Package" > /tmp/speak
    text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
    play /tmp/speak.wav 2> /dev/null
    rm -fr /tmp/speak*
}

rebuild-package() {
    cd ~/rpmbuild/SPECS
    ls *.spec > /dev/null 2>&1
    
    if [ "$?" != "0" ]; then
        echo -e "$GREEN- Nothing to do for $GREENRED$NOTEXIST$GREEN.$WHITE\n"
        rm -f /tmp/package-not-exist
        echo -e "$GREEN>($(date +%H"h":%M"m")) Finished.$WHITE\n"
        echo "Error. Nothing to do." > /tmp/speak
        text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
        play /tmp/speak.wav 2> /dev/null
        rm -fr /tmp/speak*
        exit 0
    fi
    
    kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" \
     --yesno "You can change Spec file(s) or Source Code in this pause. Do you want continuing with the RPM package(s) rebuilding process?" \
     2> /dev/null
    
    if [ "$?" = "1" ]; then
        rm -fr ~/rpmbuild/BUILD/* 2> /dev/null
        rm -fr ~/rpmbuild/BUILDROOT/* 2> /dev/null
        rm -fr ~/rpmbuild/SOURCES/* 2> /dev/null
        rm -fr ~/rpmbuild/SPECS/* 2> /dev/null
        rm -fr ~/rpmbuild/TMP/* 2> /dev/null
        kill -9 $(pidof xterm|awk -F " " '{print $1}') > /dev/null 2>&1
        exit 0
    fi
    
    BEGIN_TIME=$(date +%s)
    
    for i in $(ls *.spec); do
        APPNAME=$(ls $i|awk -F . '{print $1}')
        echo -e "\n\n$GREEN> Rebuild $APPNAME RPM Package...$WHITE\n"
        ccache -M 2 > /dev/null
        touch ~/rpmbuild/TMP/$APPNAME.log
        tail -fn0 ~/rpmbuild/TMP/$APPNAME.log|pv -cN "stdout+stderr data" -bt > /dev/null &
        QA_RPATHS=$[ 0x0001|0x0002|0x0004|0x0008|0x0010|0x0020 ] rpmbuild --clean --rmsource --rmspec -bb $i > ~/rpmbuild/TMP/$APPNAME.log 2>&1
        rpmbuild-error
        kill -9 $(pidof -x pv) > /dev/null 2>&1
        kill -9 $(pidof -x pv) > /dev/null 2>&1
        ccache -c > /dev/null
    done
    
    FINAL_TIME=$(date +%s)
    ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
}

install-package() {
    cd ~/rpmbuild/TMP
    
    for i in $(ls *.err 2> /dev/null|awk -F . '{print $1}'); do
        echo -e "$GREEN- Nothing to do for $GREENRED$i.$WHITE\n"
    done
    
    for i in $(ls *.log 2> /dev/null); do
        grep "[w|W]rote:" $i|awk -F : '{print $2}'|grep -v debuginfo|grep -v devel|grep -v noarch >> package.ins
        grep "[w|W]rote:" $i|awk -F : '{print $2}'|grep -e debuginfo -e devel -e noarch >> package.del
    done
    
    for i in $(cat package.ins 2> /dev/null); do
        echo ${i##*/} >> package.tmp
    done
    
    if [ ! -s package.tmp ]; then
        echo -e "\n$GREEN>$GREENRED Error:$GREEN No packages for install. Try Again.$WHITE\n"
        echo -e "$GREEN>($(date +%H"h":%M"m")) Finished.$WHITE\n"
        echo "Error. No packages for install." > /tmp/speak
        text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
        play /tmp/speak.wav 2> /dev/null
        rm -fr /tmp/speak*
        kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" --error="No packages for install. Try Again." 2> /dev/null
        exit 0
    fi
    
    mv -f package.tmp package.ins
    cd ~/rpmbuild/RPMS/$(uname -m)
    echo "Choose Rebuilded Package For Install." > /tmp/speak
    text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
    play /tmp/speak.wav 2> /dev/null
    rm -fr /tmp/speak*
    SHOWAPPNAME=$(cat ~/rpmbuild/TMP/package.ins|xargs -n1|awk -F " " '{print $1,$1}'|sed 's/$/ off/g'|xargs)
    INSTALLPKG=$(kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" --separate-output \
               --checklist="Choose Rebuilded Package(s) For Install" All "All List" off $SHOWAPPNAME 2> /dev/null)
    EXIT="$?"
    
    if [ "$EXIT" = "1" ] || [ "$INSTALLPKG" = "" ]; then
        rm -f $(cat ~/rpmbuild/TMP/package.del 2> /dev/null) ~/rpmbuild/TMP/*.log ~/rpmbuild/TMP/*.ins ~/rpmbuild/TMP/*.del
        finished
        echo -e "\n\n$GREEN> Check RPM package(s) at the following path $HOME/rpmbuild/RPMS/$(uname -m)/$WHITE\n"
        echo -e "$GREEN>($(date +%H"h":%M"m")) Finished.$WHITE\n"
        exit 0
    elif [ "$INSTALLPKG" = "All" ]; then
        echo -e "\n\n$GREEN> Installing RPM Packages...$WHITE\n"
        
        for i in $(cat ~/rpmbuild/TMP/package.ins 2> /dev/null); do
            APPNAME=${i##*/}
            sudo rpm -Uvh --force $i
            EXIT=$?
            rpm-install-error
            notify
        done
        
        rm -f $(cat ~/rpmbuild/TMP/package.del 2> /dev/null) ~/rpmbuild/TMP/*.log ~/rpmbuild/TMP/*.ins ~/rpmbuild/TMP/*.del
        finished
        echo -e "\n\n$GREEN> Check RPM package(s) at the following path $HOME/rpmbuild/RPMS/$(uname -m)/$WHITE\n"
        echo -e "$GREEN>($(date +%H"h":%M"m")) Finished.$WHITE\n"
        exit 0
    elif [ "$INSTALLPKG" != "" ]; then
        echo -e "\n\n$GREEN> Installing RPM Packages...$WHITE\n"
        INSTALLPKG=$(echo "$INSTALLPKG"|sed "s;All;;")
        echo $INSTALLPKG|xargs -n1 > ~/rpmbuild/TMP/package.ins
        
        for i in $(cat ~/rpmbuild/TMP/package.ins 2> /dev/null); do
            APPNAME=${i##*/}
            sudo rpm -Uvh --force $i
            EXIT=$?
            rpm-install-error
            notify
        done
        
        rm -f $(cat ~/rpmbuild/TMP/package.del 2> /dev/null) ~/rpmbuild/TMP/*.log ~/rpmbuild/TMP/*.ins ~/rpmbuild/TMP/*.del
        finished
        echo -e "\n\n$GREEN> Check RPM package(s) at the following path $HOME/rpmbuild/RPMS/$(uname -m)/$WHITE\n"
        echo -e "$GREEN>($(date +%H"h":%M"m")) Finished.$WHITE\n"
        exit 0
    fi
}

##############################
############ Main ############
##############################

rm -f /tmp/source-packages /tmp/package-not-exist > /dev/null 2>&1
echo -e "$GREEN> Running Rebuild RPM Package...$WHITE\n"

if [ "$(id|grep -o wheel)" != "wheel" ]; then
    kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" \
                   --sorry="Your user is not in the Administrators group (wheel), please add it. After relogin, try again." 2> /dev/null
    exit 0
fi

sudo-no-timeout
setterm -cursor off
echo -e "\n$GREEN> Check Build Require Depends...$WHITE\n"

if [ "$(yum list installed|grep -oe kdelibs-devel -oe rpmdevtools -oe yum-utils|awk -F . '{print $1}'|sort -u|xargs)" != \
    "kdelibs-devel rpmdevtools yum-utils" ]; then
    sudo yum -y --nogpgcheck install kdelibs-devel rpmdevtools yum-utils
fi

if [ "$(yum list installed|grep -oe autoconf -oe automake -oe binutils -oe bison -oe flex -oe gcc -oe gcc-c++ -oe gdb -oe gettext \
    -oe libtool -oe make -oe pkgconfig -oe redhat-rpm-config -oe rpm-build -oe strace -oe ccache|awk -F . '{print $1}'|sort -u|xargs)" != \
    "autoconf automake binutils bison ccache flex gcc gcc-c++ gdb gettext libtool make pkgconfig redhat-rpm-config rpm-build strace" ]; then
    sudo yum -y --nogpgcheck groupinstall "Development Tools" "C Development Tools and Libraries" "RPM Development Tools"
fi

sudo ln -fs /usr/bin/ccache /usr/local/bin/gcc
sudo ln -fs /usr/bin/ccache /usr/local/bin/g++
sudo ln -fs /usr/bin/ccache /usr/local/bin/cc
sudo ln -fs /usr/bin/ccache /usr/local/bin/c++
rpmmacros-no-cflags
echo -e "$GREEN> Cleaning $HOME/rpmbuild Tree...$WHITE\n"
rm -fr ~/rpmbuild/BUILD/* 2> /dev/null
rm -fr ~/rpmbuild/BUILDROOT/* 2> /dev/null
rm -fr ~/rpmbuild/SOURCES/* 2> /dev/null
rm -fr ~/rpmbuild/SPECS/* 2> /dev/null
rm -fr ~/rpmbuild/TMP/* 2> /dev/null
rpmdev-setuptree
mkdir -p ~/rpmbuild/TMP > /dev/null 2>&1
PACKAGESOURCE=$(kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" --yesnocancel "Have the source RPM package?" 2> /dev/null)
EXIT=$?
if-cancel-exit

if [ "$EXIT" = "1" ]; then
    if [ ! -s ~/.kde-services/source-packages ]; then
        mkdir ~/.kde-services 2> /dev/null
        echo "kate" > ~/.kde-services/source-packages
    fi
    
    SHOWAPPNAME=$(cat ~/.kde-services/source-packages|xargs -n1|awk -F " " '{print $1,$1}'|sed 's/$/ off/g'|xargs)
    APPNAME=$(kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" --separate-output \
            --checklist="Choose Compiled Application(s)" All "All List" off $SHOWAPPNAME Other Other off 2> /dev/null)
    EXIT=$?
    if-cancel-exit2
    
    if [ "$(echo $APPNAME|xargs)" = "All Other" ]; then
        kdialog --icon=ks-error --title="Rebuild RPM Package" --passivepopup="[Error]: Please select All-List or Other, not both." \
                       2> /dev/null
        echo -e "$GREEN> $GREENRED$CANCELED$GREEN.$WHITE\n"
        exit 0
    fi
    
    if [ "$APPNAME" = "Other" ]; then
        APPNAME=$(kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package" \
                --inputbox "Enter only the name of the package, you can enter multiple separated by whitespace." 2> /dev/null)
        EXIT=$?
        if-cancel-exit2
    fi
    
    if [ "$APPNAME" = "All" ] || [ "$APPNAME" = "" ]; then
        APPNAME=$(cat ~/.kde-services/source-packages)
    fi
    
    echo "$APPNAME"|xargs >> ~/.kde-services/source-packages
    cat ~/.kde-services/source-packages|xargs -n1|sort -u > /tmp/source-packages
    cat /tmp/source-packages > ~/.kde-services/source-packages
    cat ~/.kde-services/source-packages|xargs > /tmp/source-packages
    cat /tmp/source-packages > ~/.kde-services/source-packages
    echo -n "$APPNAME" > /tmp/source-packages
    APPNAME=$(cat /tmp/source-packages)
    rm -f /tmp/source-packages
    
    for i in $APPNAME; do
        sudo yum info $i > /dev/null 2>&1
        if [ "$?" != "0" ]; then
            echo -n "$i " >> /tmp/package-not-exist
            kdialog --icon=ks-error --title="Rebuild RPM Package" \
                           --passivepopup="$i   [Error]: This package not exist in your Repositories." 2> /dev/null
            sed -i "s;$i;;g" ~/.kde-services/source-packages
            cat ~/.kde-services/source-packages|xargs -n1|sort -u > /tmp/source-packages
            cat /tmp/source-packages > ~/.kde-services/source-packages
            cat ~/.kde-services/source-packages|xargs > /tmp/source-packages
            cat /tmp/source-packages > ~/.kde-services/source-packages
            rm -f /tmp/source-packages
            APPNAME=$(echo "$APPNAME"|sed "s/$i//g"|xargs -n1|sort -u)
            APPNAME=$(echo "$APPNAME"|xargs)
        fi
    done
    
    NOTEXIST=$(cat /tmp/package-not-exist 2> /dev/null)
    cd ~/rpmbuild/SRPMS
    
    for i in $APPNAME; do
        LOCALVERSION=$(ls $i* 2> /dev/null|sed "s/^.*$i-//"|sed 's/.fc...src.rpm$//')
        echo -e "$GREEN> Checking update for $i...$WHITE"
        INTERNETVERSION=$(yumdownloader --url --source $i|grep $i|grep -v "No source RPM found"|sed "s/^.*$i-//"|sed 's/.fc...src.rpm$//')
        test-network
        
        if [ "$LOCALVERSION" != "$INTERNETVERSION" ]; then
            rm -f $i*.src.rpm
        fi
        
        echo -e "\n$GREEN> Downloading $i Source RPM Package...$WHITE\n"
        sudo yumdownloader --source $i
        test-network
        echo -e "$GREEN> Installing RPMs Needed For Build $i...$WHITE\n"
        sudo yum-builddep -y --nogpgcheck $i*.src.rpm
        check-builddep
        echo -e "\n$GREEN> Installing Source RPM Package $i...$WHITE"
        rpm -Uvh $i*.src.rpm > /dev/null 2>&1
    done
    
    rebuild-package
    install-package
fi

if [ "$EXIT" = "0" ]; then
    SOURCEFILE=$(kdialog --icon=ks-rebuild-rpm --title="Rebuild RPM Package - Source RPM File" --multiple \
               --getopenfilename ~/rpmbuild/SRPMS .src.rpm 2> /dev/null)
    EXIT=$?
    if-cancel-exit2
    
    for i in $SOURCEFILE; do
        sudo chown $USER:$USER $i
        echo -e "$GREEN> Installing RPMs Needed For Build ${i##*/}...$WHITE\n"
        sudo yum-builddep -y --nogpgcheck $i
        check-builddep
        echo -e "\n$GREEN> Installing Source RPM Package ${i##*/}...$WHITE\n"
        rpm -Uvh $i > /dev/null 2>&1
    done
    
    rebuild-package
    install-package
fi

exit 0
