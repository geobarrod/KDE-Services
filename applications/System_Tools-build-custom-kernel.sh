#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2011-2026.                                                       #
#                                                                                 #
# BSD 3-Clause License                                                            #
#                                                                                 #
# Copyright (c) 2026, Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.  #
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

BEGIN_TIME=""
BINOPT=""
ELAPSED_TIME=""
EXIT=""
FINAL_TIME=""
GREEN='\E[32;40m'
GREENRED='\E[32;41m'
INTERNETVERSION=""
KERNELFILE=""
KERNELSOURCEPATH=""
KERNELVERSION=""
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:~/bin
PID="$$"
WHITE='\E[37;40m'

###################################
############ Functions ############
###################################

elapsed-time() {
        if [ "$ELAPSED_TIME" -lt "60" ]; then
                kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" --passivepopup="[Finished]. Compilation Time: ${ELAPSED_TIME}s" 2>/dev/null
        elif [ "$ELAPSED_TIME" -gt "59" ] && [ "$ELAPSED_TIME" -lt "3600" ]; then
                ELAPSED_TIME=$(echo "$ELAPSED_TIME/60"|bc -l|sed 's/...................$//')
                kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" --passivepopup="[Finished]. Compilation Time: ${ELAPSED_TIME}m" 2>/dev/null
        elif [ "$ELAPSED_TIME" -gt "3599" ] && [ "$ELAPSED_TIME" -lt "86400" ]; then
                ELAPSED_TIME=$(echo "$ELAPSED_TIME/3600"|bc -l|sed 's/...................$//')
                kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" --passivepopup="[Finished]. Compilation Time: ${ELAPSED_TIME}h" 2>/dev/null
        elif [ "$ELAPSED_TIME" -gt "86399" ]; then
                ELAPSED_TIME=$(echo "$ELAPSED_TIME/86400"|bc -l|sed 's/...................$//')
                kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" --passivepopup="[Finished]. Compilation Time: ${ELAPSED_TIME}d" 2>/dev/null
        fi
}

if-cancel-exit() {
        if [ "$EXIT" = "2" ]; then
                rm -fr ~/rpmbuild/BUILD/* 2>/dev/null
                rm -fr ~/rpmbuild/BUILDROOT/* 2>/dev/null
                rm -fr ~/rpmbuild/SOURCES/* 2>/dev/null
                rm -fr ~/rpmbuild/SPECS/* 2>/dev/null
                rm -fr ~/rpmbuild/TMP/* 2>/dev/null
                kill -9 $(pidof xterm|awk -F " " '{print $1}') &>/dev/null
                exit 1
        fi
}

if-cancel-exit2() {
        if [ "$EXIT" = "1" ]; then
                rm -fr ~/rpmbuild/BUILD/* 2>/dev/null
                rm -fr ~/rpmbuild/BUILDROOT/* 2>/dev/null
                rm -fr ~/rpmbuild/SOURCES/* 2>/dev/null
                rm -fr ~/rpmbuild/SPECS/* 2>/dev/null
                rm -fr ~/rpmbuild/TMP/* 2>/dev/null
                kill -9 $(pidof xterm|awk -F " " '{print $1}') &>/dev/null
                exit 1
        fi
}

before-compile() {
        kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" \
                --yesno "You can change Spec file(s) or Source Code in this pause. Do you want continuing with the Kernel recompilation process?" \
        2>/dev/null
        
        if [ "$?" = "1" ]; then
                rm -fr ~/rpmbuild/BUILD/* 2>/dev/null
                rm -fr ~/rpmbuild/BUILDROOT/* 2>/dev/null
                rm -fr ~/rpmbuild/SOURCES/* 2>/dev/null
                rm -fr ~/rpmbuild/SPECS/* 2>/dev/null
                rm -fr ~/rpmbuild/TMP/* 2>/dev/null
                kill -9 $(pidof xterm|awk -F " " '{print $1}') &>/dev/null
                exit 1
        fi
}

rpmbuild-error() {
        if [ "$?" != "0" ]; then
                mv ~/rpmbuild/TMP/kernel.log ~/rpmbuild/TMP/kernel.err
                kill -9 $(pidof -x tail) &>/dev/null
                kill -9 $(pidof -x tail) &>/dev/null
                echo -e "\n$GREEN>$GREENRED Error:$GREEN See $HOME/rpmbuild/TMP/kernel.err. Try Again.$WHITE\n"
                echo -e "$GREEN>($(date +%H"h":%M"m")) Finished.$WHITE\n"
                echo "Error. See debug console." > /tmp/speak
                text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
                play /tmp/speak.wav 2>/dev/null
                rm -fr /tmp/speak*
                kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" --error="[Error]: See $HOME/rpmbuild/TMP/kernel.err. Try Again." 2>/dev/null
                exit 1
        fi
}

make-config-kernel() {
        echo -e "\n$GREEN> Creating Kernel Config File...$WHITE\n"
        make oldconfig
        make xconfig 2>/dev/null
}

save-config-i686() {
        echo -e "\n$GREEN> Saving Kernel Config File In $HOME...$WHITE\n"
        cp .config ~/rpmbuild/SOURCES/config-$(uname -m)-PAE
        cp .config ~/kernel-config-$(uname -m)-PAE_$(date +%d-%m-%Y_%H-%M-%S)
}

save-config-x86_64() {
        echo -e "\n$GREEN> Saving Kernel Config File In $HOME...$WHITE\n"
        cp .config ~/rpmbuild/SOURCES/config-$(uname -m)-generic
        cp .config ~/kernel-config-$(uname -m)-generic_$(date +%d-%m-%Y_%H-%M-%S)
}

compile-i686() {
        before-compile
        cd ~/rpmbuild/SPECS
        ccache -M 2 >/dev/null
        rm -fr ~/rpmbuild/RPMS/$(uname -m)/kernel-*.rpm
        echo -e "\n$GREEN> Building Kernel For $(uname -m) Arch...$GREEN$WHITE\n"
        BEGIN_TIME=$(date +%s)
        touch ~/rpmbuild/TMP/kernel.log
        tail -fn0 ~/rpmbuild/TMP/kernel.log|pv -cN "stderr data" -bt >/dev/null &
        rpmbuild -bb --quiet --with paeonly --without debug --without debuginfo --without backports --target=$(uname -m) --clean --rmsource \
                --rmspec kernel.spec &>> ~/rpmbuild/TMP/kernel.log
        rpmbuild-error
        kill -9 $(pidof -x tail) &>/dev/null
        kill -9 $(pidof -x tail) &>/dev/null
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
        ccache -c >/dev/null
}

compile-x86_64() {
        before-compile
        cd ~/rpmbuild/SPECS
        ccache -M 2 >/dev/null
        rm -fr ~/rpmbuild/RPMS/$(uname -m)/kernel-*.rpm
        echo -e "\n$GREEN> Building Kernel For $(uname -m) Arch...$GREEN$WHITE\n"
        BEGIN_TIME=$(date +%s)
        touch ~/rpmbuild/TMP/kernel.log
        tail -fn0 ~/rpmbuild/TMP/kernel.log|pv -cN "stderr data" -bt >/dev/null &
        rpmbuild -bb --quiet --with baseonly --without debug --without debuginfo --without backports --target=$(uname -m) --clean --rmsource \
                --rmspec kernel.spec &>> ~/rpmbuild/TMP/kernel.log
        rpmbuild-error
        kill -9 $(pidof -x tail) &>/dev/null
        kill -9 $(pidof -x tail) &>/dev/null
        FINAL_TIME=$(date +%s)
        ELAPSED_TIME=$((FINAL_TIME-BEGIN_TIME))
        ccache -c >/dev/null
}

install-packages() {
        VERSION=$(rpm -qip $HOME/rpmbuild/RPMS/$(uname -m)/kernel-headers*.rpm|grep -e Version -e Release|awk -F " " '{print $3}'|xargs|\
                        awk -F " " '{print $1,$2}'|sed 's/ /-/g')
        echo -e "\n$GREEN> Installing Kernel RPM Packages...$WHITE\n"
        rm -f $HOME/rpmbuild/RPMS/$(uname -m)/*devel*
        sudo rm -fr /lib/modules/$VERSION* &>/dev/null
        sudo rpm -Uvh $HOME/rpmbuild/RPMS/$(uname -m)/kernel-headers* &>/dev/null
        sudo rpm -Uvh $HOME/rpmbuild/RPMS/$(uname -m)/kernel-tools* &>/dev/null
        sudo rpm -ivh --force $(find $HOME/rpmbuild/RPMS/$(uname -m)/ -name "kernel-*"|grep -v tools|grep -v headers)
        sudo rm -fr /usr/src/linux &>/dev/null
        echo -e "\n$GREEN> Updating Bootloader...$WHITE\n"
        echo "Enter root password for bootloader update" > /tmp/speak
        text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
        play /tmp/speak.wav 2>/dev/null
        rm -fr /tmp/speak*
        kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" --passivepopup="Enter [root] password for bootloader update" 2>/dev/null
        setterm -cursor on
        echo -n "Enter Root "; su -c 'grub2-mkconfig -o /boot/grub2/grub.cfg'
        echo -e "\n$GREEN>($(date +%H"h":%M"m")) Finished.$WHITE\n"
}

finish-notify() {
        echo "Finish Build Custom Kernel" > /tmp/speak
        text2wave -F 48000 -o /tmp/speak.wav /tmp/speak
        play /tmp/speak.wav 2>/dev/null
        rm -fr /tmp/speak*
        elapsed-time
}

test-network() {
        if [ "$?" != "0" ]; then
                kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" \
                        --error="No Internet Communication: You have some network or repositories problem, can't download kernel source rpm package." 2>/dev/null
                kill -9 $(pidof xterm|awk -F " " '{print $1}') &>/dev/null
                exit 1
        fi
}

sudo-no-timeout() {
        sudo grep passwd_timeout /etc/sudoers >/dev/null
    
        if [ "$?" != "0" ]; then
                echo -n "Enter Root "; su -c 'cat >> /etc/sudoers << EOF
Defaults    passwd_timeout = 0
Defaults    timestamp_timeout = -1
EOF'
        fi
}

check-builddep() {
        if [ "$?" != "0" ]; then
                kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" \
                        --error="Can't install all the RPMs needed to build the source rpm package. Check the packages repository." 2>/dev/null
                kill -9 $(pidof xterm|awk -F " " '{print $1}') &>/dev/null
                exit 1
        fi
}

##############################
############ Main ############
##############################

if [ "$(uname -m)" != "i686" ] && [ "$(uname -m)" != "x86_64" ]; then
        kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" \
                --sorry="No Find Compatible Arch: Only i686 or x86_64 arch is allowed. I apologize for any inconvenience." 2>/dev/null
        kill -9 $(pidof xterm|awk -F " " '{print $1}') &>/dev/null
        exit 1
fi

echo -e "$GREEN> Running Build Custom Kernel For $(uname -m) Arch...$WHITE\n"

if [ "$(id|grep -o wheel)" != "wheel" ]; then
        kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" \
                --sorry="Your user is not in the Administrators group (wheel), please add it. After relogin, try again." 2>/dev/null
        exit 1
fi

sudo-no-timeout
setterm -cursor off
echo -e "\n$GREEN> Check Build Require Depends...$WHITE\n"

if [ "$(yum list installed|grep -oe rpmdevtools -oe yum-utils -oe qt-devel|awk -F . '{print $1}'|sort -u|xargs)" != \
        "qt-devel rpmdevtools yum-utils" ]; then
        sudo yum -y --nogpgcheck install rpmdevtools yum-utils qt-devel
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

echo -e "$GREEN> Cleaning $HOME/rpmbuild Tree...$WHITE\n"
rm -fr ~/rpmbuild/BUILD/* 2>/dev/null
rm -fr ~/rpmbuild/BUILDROOT/* 2>/dev/null
rm -fr ~/rpmbuild/SOURCES/* 2>/dev/null
rm -fr ~/rpmbuild/SPECS/* 2>/dev/null
rm -fr ~/rpmbuild/TMP/* 2>/dev/null
rpmdev-setuptree
mkdir -p ~/rpmbuild/TMP &>/dev/null

KERNELSOURCE=$(kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" --yesnocancel "Have the kernel source RPM package?" 2>/dev/null)
EXIT=$?
if-cancel-exit

if [ "$EXIT" = "1" ]; then
        cd ~/rpmbuild/SRPMS
        echo -e "$GREEN> Downloading Kernel Source RPM Packages...$WHITE\n"
        yumdownloader --source kernel
        test-network
        INTERNETVERSION=$(yumdownloader --url --source kernel|grep kernel|grep -v "No source RPM found"|sed 's/^.*kernel-//'|sed 's/.fc...src.rpm$//')
        yumdownloader --url --source kernel &>/dev/null
        test-network
        echo -e "$GREEN> Installing RPMs Needed For Build kernel-$INTERNETVERSION...$WHITE\n"
        sudo yum-builddep -y --nogpgcheck kernel-$INTERNETVERSION.*.src.rpm
        check-builddep
        echo -e "$GREEN> Installing Source RPM Package kernel-$INTERNETVERSION...$WHITE\n"
        rpm -Uvh kernel-$INTERNETVERSION.*.src.rpm &>/dev/null
fi

if [ "$EXIT" = "0" ]; then
        KERNELSOURCEPATH=$(kdialog --icon=ks-kernel-rebuild --title="Kernel Source RPM File" \
                                        --getopenfilename ~/rpmbuild/SRPMS kernel-*.src.rpm 2>/dev/null)
        EXIT=$?
        if-cancel-exit2
        sudo chown $USER:$USER $KERNELSOURCEPATH
        cd ${KERNELSOURCEPATH%/*} 2>/dev/null
        KERNELFILE=${KERNELSOURCEPATH##*/}
        KERNELVERSION=$(echo ${KERNELSOURCEPATH##*/}|sed 's/^.*kernel-//'|sed 's/.fc...src.rpm$//')
        echo -e "$GREEN> Checking update for kernel...$WHITE\n"
        INTERNETVERSION=$(yumdownloader --url --source kernel|grep kernel|grep -v "No source RPM found"|sed 's/^.*kernel-//'|sed 's/.fc...src.rpm$//')
        yumdownloader --url --source kernel &>/dev/null
        EXIT=$?

        if [ "$EXIT" != "0" ]; then
                kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" \
                        --sorry="No Internet Communication: You have some network or repositories problem, can't check updates. Installing $KERNELFILE" \
                    2>/dev/null &
                echo -e "$GREEN> Installing RPMs Needed For Build $KERNELFILE...$WHITE\n"
                sudo yum-builddep -y --nogpgcheck $KERNELFILE
                check-builddep
                echo -e "\n$GREEN> Installing Source RPM Package $KERNELFILE...$WHITE\n"
                rpm -Uvh $KERNELFILE &>/dev/null
                EXIT=6
        fi
    
        if [ "$EXIT" = "0" ]; then
                if [ "$KERNELVERSION" != "$INTERNETVERSION" ]; then
                        kdialog --icon=ks-kernel-rebuild --title="Kernel Source RPM File" \
                                --yesnocancel "New kernel version available: kernel-$INTERNETVERSION, Do you want to download it and use it instead?" \
                        2>/dev/null
                        EXIT=$?
                        if-cancel-exit
                
                        if [ "$EXIT" != "0" ]; then
                                echo -e "$GREEN> Installing RPMs Needed For Build $KERNELFILE...$WHITE\n"
                                sudo yum-builddep -y --nogpgcheck $KERNELFILE
                                check-builddep
                                echo -e "$GREEN> Installing Source RPM Package $KERNELFILE...$WHITE\n"
                                rpm -Uvh $KERNELFILE &>/dev/null
                        else
                                yumdownloader --source kernel
                                test-network
                                echo -e "\n$GREEN> Installing RPMs Needed For Build kernel-$INTERNETVERSION...$WHITE\n"
                                sudo yum-builddep -y --nogpgcheck kernel-$INTERNETVERSION.*.src.rpm
                                check-builddep
                                echo -e "$GREEN> Installing Source RPM Package kernel-$INTERNETVERSION...$WHITE\n"
                                rpm -Uvh kernel-$INTERNETVERSION.*.src.rpm &>/dev/null
                        fi
                else
                    echo -e "$GREEN> Installing RPMs Needed For Build $KERNELFILE...$WHITE\n"
                    sudo yum-builddep -y --nogpgcheck $KERNELFILE
                    check-builddep
                    echo -e "$GREEN> Installing Source RPM Package $KERNELFILE...$WHITE\n"
                    rpm -Uvh $KERNELFILE &>/dev/null
                fi
        fi
fi

cd ~/rpmbuild/SPECS

touch ~/rpmbuild/TMP/kernel.log
tail -fn0 ~/rpmbuild/TMP/kernel.log|pv -cN "stderr data" -bt >/dev/null &
rpmbuild --quiet -bp --target=$(uname -m) kernel.spec > ~/rpmbuild/TMP/kernel.log
rpmbuild-error
kill -9 $(pidof -x tail) &>/dev/null
kill -9 $(pidof -x tail) &>/dev/null

cd ~/rpmbuild/BUILD/kernel-*/vanilla-*/

if [ ! -s ~/.kde-services/kernel-cflags ]; then
        mkdir ~/.kde-services &>/dev/null
        echo "-O2" > ~/.kde-services/kernel-cflags
fi

BINOPT=$(cat ~/.kde-services/kernel-cflags 2>/dev/null)

kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel | B.O.O.=\"$BINOPT\"" \
        --yesnocancel="          Do you want to reconfigure Binary Optimization Option(s) of compilation?               " 2>/dev/null
EXIT="$?"

if [ "$EXIT" = "0" ]; then
        mkdir ~/.kde-services &>/dev/null
        BINOPT=$(kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" --combobox="Choose Binary Optimization Option(s)" \
                        "Ofast -ffast-math -funroll-loops" "Ofast -funroll-loops" Ofast "O3 -ffast-math -funroll-loops" "O3 -funroll-loops" \
                        O3 "O2 -ffast-math -funroll-loops" "O2 -funroll-loops" O2 O1 O0 Os --default "Ofast -ffast-math -funroll-loops" 2>/dev/null)
        EXIT=$?
        if-cancel-exit2
        echo "-$BINOPT" > ~/.kde-services/kernel-cflags
        sudo sed -i "" "s;-O2;-$BINOPT;g" Makefile
elif [ "$EXIT" = "1" ]; then
        BINOPT=$(cat ~/.kde-services/kernel-cflags 2>/dev/null)
        sudo sed -i "" "s;-O2;$BINOPT;g" Makefile
elif [ "$EXIT" = "2" ]; then
        if-cancel-exit
fi

cd ~/rpmbuild/BUILD/kernel-*/linux-*/

kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" --yesnocancel "Have the kernel config file?" 2>/dev/null
EXIT=$?
if-cancel-exit

if [ "$EXIT" = "1" ]; then
        if [ "$(uname -m)" = "i686" ]; then
                cp configs/*PAE.config .config
                make-config-kernel
                save-config-i686
                compile-i686
                install-packages
                finish-notify
        else
                cp configs/*x86_64.config .config
                make-config-kernel
                save-config-x86_64
                compile-x86_64
                install-packages
                finish-notify
        fi
fi

if [ "$EXIT" = "0" ]; then
        KERNELCONFIG=$(kdialog --icon=ks-kernel-rebuild --title="Kernel Config File" --getopenfilename ~/ 2>/dev/null)
    
        if [ "$(uname -m)" = "i686" ]; then
                cp $KERNELCONFIG ~/rpmbuild/SOURCES/config-$(uname -m)-PAE
        else
                cp $KERNELCONFIG ~/rpmbuild/SOURCES/config-$(uname -m)-generic
        fi
    
        cp $KERNELCONFIG .config
        kdialog --icon=ks-kernel-rebuild --title="Build Custom Kernel" --yesnocancel "Do you want to make changes in the kernel config file?" 2>/dev/null
        EXIT=$?
        if-cancel-exit
    
        if [ "$EXIT" = "1" ]; then
                if [ "$(uname -m)" = "i686" ]; then
                        compile-i686
                        install-packages
                        finish-notify
                else
                        compile-x86_64
                        install-packages
                        finish-notify
                fi
        fi
    
        if [ "$EXIT" = "0" ]; then
                make-config-kernel
        
                if [ "$(uname -m)" = "i686" ]; then
                        save-config-i686
                        compile-i686
                        install-packages
                        finish-notify
                else
                        save-config-x86_64
                        compile-x86_64
                        install-packages
                        finish-notify
                fi
        fi
fi

exit 0
