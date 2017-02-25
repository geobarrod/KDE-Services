#!/bin/bash

#################################################################
# For KDE-Services. 2011-2013.					#
# By Geovani Barzaga Rodriguez <igeo.cu@gmail.com>		#
#################################################################

VGA=$(lspci |grep -i vga)

###################################
############ Functions ############
###################################

if-cancel-exit() {
    if [ "$?" != "0" ]; then
        rm -fr /tmp/xorg-configure
        exit 1
    fi
}

##############################
############ Main ############
##############################

DRIVER=$(kdialog --icon=ks-xorg --title="Xorg Configure: ${VGA#*: }" \
       --menu="Select a suitable video driver." glint "3DLabs, TI" \
                                    tdfx "3Dfx" \
                                    ast "ASpeedTech" \
                                    mach64 "ATi Mach64" \
                                    radeon "ATi Radeon" \
                                    r128 "ATi Rage 128 based" \
                                    ati "ATi Technologies Inc." \
                                    apm "Alliance Pro Motion" \
                                    cirrus "Cirrus Logic" \
                                    vesa "Generic VESA compatible" \
                                    i740 "Intel i740" \
                                    intel "Intel i8xx and up" \
                                    mga "Matrox Graphics" \
                                    i128 "Number Nine I128" \
                                    nouveau "nVidia RIVA/GeForce (generic)" \
                                    nv "nVidia RIVA/GeForce (old)" \
                                    nvidia "nVidia RIVA/GeForce (new)" \
                                    rendition "Rendition" \
                                    savage "S3 Savage" \
                                    s3virge "S3 ViRGE" \
                                    sisusb "SiS USB" \
                                    sis "SiS" \
                                    siliconmotion "Silicon Motion" \
                                    trident "Trident" \
                                    openchrome "VIA UniChrome/Chrome9" \
                                    v4l "Video4Linux" \
                                    voodoo "Voodoo/Voodoo2" \
                                    2> /dev/null)
if-cancel-exit

cat > /tmp/xorg-configure << EOF
Section "Device"
    Identifier  "Configured Video Device"
    Driver      "$DRIVER"
EndSection

Section "Monitor"
    Identifier  "Configured Monitor"
  # HorizSync    30.00 - 100.00    # for LCD
  # VertRefresh  50.00 - 100.00
  # Modeline
EndSection

Section "Screen"
    Identifier  "Default Screen"
    Device      "Configured Video Device"
    Monitor     "Configured Monitor"
EOF

DEPTH=$(kdialog --icon=ks-xorg --title="Xorg Configure: ${VGA#*: }" --combobox="Select a color depth." 4 8 16 24 32 --default 24 2> /dev/null)
if-cancel-exit

cat >> /tmp/xorg-configure << EOF
    DefaultDepth $DEPTH
    Subsection  "Display"
        Depth    $DEPTH
EOF

SCREEN=$(kdialog --icon=ks-xorg --title="Xorg Configure: ${VGA#*: }" --combobox="Select your screen resolution." 640x480 \
                                                                                                                800x500 \
                                                                                                                800x600 \
                                                                                                                1024x600 \
                                                                                                                1024x640 \
                                                                                                                1024x768 \
                                                                                                                1152x864 \
                                                                                                                1280x720 \
                                                                                                                1280x800 \
                                                                                                                1280x960 \
                                                                                                                1280x1024 \
                                                                                                                1360x768 \
                                                                                                                1366x768 \
                                                                                                                1440x900 \
                                                                                                                1400x1050 \
                                                                                                                1600x900 \
                                                                                                                1600x1200 \
                                                                                                                1680x1050 \
                                                                                                                1920x1080 \
                                                                                                                1920x1200 \
                                                                                                                2560x1600 \
                                                                                                                3200x2048 \
                                                                                                                3840x2400 \
                                                                                                                6400x4096 \
                                                                                                                7680x4800 \
                                                                                                            --default 1024x768 2> /dev/null)
if-cancel-exit

FREQ=$(kdialog --icon=ks-xorg --title="Xorg Configure: ${VGA#*: }" --combobox="Select your screen vertical refresh frequency in Hz." 50 \
                                                                                                                                    55 \
                                                                                                                                    60 \
                                                                                                                                    65 \
                                                                                                                                    70 \
                                                                                                                                    75 \
                                                                                                                                    80 \
                                                                                                                                    85 \
                                                                                                                                    90 \
                                                                                                                                    95 \
                                                                                                                                    100 \
                                                                                                                --default 60 2> /dev/null)
if-cancel-exit

cat >> /tmp/xorg-configure << EOF
        Modes   "$SCREEN"
    EndSubsection
EndSection

Section "ServerLayout"
    Identifier  "Default Layout"
    Screen      "Default Screen"
EndSection
EOF

SCREEN_FREQ=$(echo $SCREEN $FREQ|sed 's/x/ /')
MODELINE=$(gtf $SCREEN_FREQ|grep -v "#"|sed "s;_$FREQ.00;;")
sed -i "s;# Modeline;$(echo $MODELINE);" /tmp/xorg-configure
mv -f /tmp/xorg-configure /etc/X11/xorg.conf

kdialog --icon=ks-xorg --title="Xorg Configure: ${VGA#*: }" --msgbox="You must restart X-Windows session for the changes to be applied."  2> /dev/null
exit 0
