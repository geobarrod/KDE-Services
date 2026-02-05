###################################################################################
# KDE-Services ⚙ 2011-2026.                                                       #
# Uninstalling KDE-Services, from appropriate directories.                        #
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
	rm -f ${PREFIXmenu5}/Add-Timestamp-Prefix_addtoservicemenu.desktop \
		${PREFIXmenu5}/Android-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Audio-Video-Info_addtoservicemenu.desktop \
		${PREFIXmenu5}/AVI-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Backup-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Change-Owner_addtoservicemenu.desktop \
		${PREFIXmenu5}/Change-Timestamp_addtoservicemenu.desktop \
		${PREFIXmenu5}/CheckSum-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Compressed-File-Integrity-Check_addtoservicemenu.desktop \
		${PREFIXmenu5}/Dolphin-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Dropbox-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Graphic-Tools_servicemenu.desktop \
		${PREFIXmenu5}/ISO-Image-Tools_servicemenu.desktop \
		${PREFIXmenu5}/MEGA-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Midnight-Tools_servicemenu.desktop \
		${PREFIXmenu5}/MKV-Extract-Subtitle_addtoservicemenu.desktop \
		${PREFIXmenu5}/Multimedia-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Multiplex-Subtitle_addtoservicemenu.desktop \
		${PREFIXmenu5}/Name-Whitespace-Replace_addtoservicemenu.desktop \
		${PREFIXmenu5}/Network-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Package-Tools_servicemenu.desktop \
		${PREFIXmenu5}/PDF-Tools2_servicemenu.desktop \
		${PREFIXmenu5}/PDF-Tools_servicemenu.desktop \
		${PREFIXmenu5}/SaMBa-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Search-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Security-Tools2_servicemenu.desktop \
		${PREFIXmenu5}/Security-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Send-By-Email_addtoservicemenu.desktop \
		${PREFIXmenu5}/Show-Status_addtoservicemenu.desktop \
		${PREFIXmenu5}/SSH-Tools_servicemenu.desktop \
		${PREFIXmenu5}/System-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Terminal-Tools_servicemenu.desktop \
		${PREFIXmenu5}/Text-Replace_addtoservicemenu.desktop \
		${PREFIXmenu5}/YouTube-Tools_servicemenu.desktop
elif [ "$KDE_SESSION_VERSION" == "6" ]; then
	rm -f ${PREFIXmenu6}/Add-Timestamp-Prefix_addtoservicemenu.desktop \
		${PREFIXmenu6}/Android-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Audio-Video-Info_addtoservicemenu.desktop \
		${PREFIXmenu6}/AVI-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Backup-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Change-Owner_addtoservicemenu.desktop \
		${PREFIXmenu6}/Change-Timestamp_addtoservicemenu.desktop \
		${PREFIXmenu6}/CheckSum-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Compressed-File-Integrity-Check_addtoservicemenu.desktop \
		${PREFIXmenu6}/Dolphin-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Dropbox-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Graphic-Tools_servicemenu.desktop \
		${PREFIXmenu6}/ISO-Image-Tools_servicemenu.desktop \
		${PREFIXmenu6}/MEGA-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Midnight-Tools_servicemenu.desktop \
		${PREFIXmenu6}/MKV-Extract-Subtitle_addtoservicemenu.desktop \
		${PREFIXmenu6}/Multimedia-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Multiplex-Subtitle_addtoservicemenu.desktop \
		${PREFIXmenu6}/Name-Whitespace-Replace_addtoservicemenu.desktop \
		${PREFIXmenu6}/Network-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Package-Tools_servicemenu.desktop \
		${PREFIXmenu6}/PDF-Tools2_servicemenu.desktop \
		${PREFIXmenu6}/PDF-Tools_servicemenu.desktop \
		${PREFIXmenu6}/SaMBa-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Search-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Security-Tools2_servicemenu.desktop \
		${PREFIXmenu6}/Security-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Send-By-Email_addtoservicemenu.desktop \
		${PREFIXmenu6}/Show-Status_addtoservicemenu.desktop \
		${PREFIXmenu6}/SSH-Tools_servicemenu.desktop \
		${PREFIXmenu6}/System-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Terminal-Tools_servicemenu.desktop \
		${PREFIXmenu6}/Text-Replace_addtoservicemenu.desktop \
		${PREFIXmenu6}/YouTube-Tools_servicemenu.desktop
fi

rm -f ${PREFIXservicetypes5}/konqpopupmenuplugin.desktop

rm -f ${PREFIXapp}/About_KDE-Services.desktop \
		${PREFIXapp}/About_KDE-Services.sh \
		${PREFIXapp}/Android_Tools-apk-manager.desktop \
		${PREFIXapp}/Android_Tools-apk-manager.sh \
		${PREFIXapp}/Android_Tools-backup-restore.desktop \
		${PREFIXapp}/Android_Tools-backup-restore.sh \
		${PREFIXapp}/Android_Tools-push-pull.desktop \
		${PREFIXapp}/Android_Tools-push-pull.sh \
		${PREFIXapp}/Android_Tools-reboot.desktop \
		${PREFIXapp}/Android_Tools-reboot.sh \
		${PREFIXapp}/AVI_Tools-avi-split-size.sh \
		${PREFIXapp}/AVI_Tools-avi-split-time.sh \
		${PREFIXapp}/Backup_Tools-standard.desktop \
		${PREFIXapp}/Backup_Tools-standard.sh \
		${PREFIXapp}/Change_file-dir_timestamp.sh \
		${PREFIXapp}/CheckSum_Tools-verify-checksum.sh \
		${PREFIXapp}/Compressed_file_integrity_check.sh \
		${PREFIXapp}/DiskCloner.sh \
		${PREFIXapp}/Dolphin_Tools-change-owner.sh \
		${PREFIXapp}/Dolphin_Tools-connect.desktop \
		${PREFIXapp}/Dolphin_Tools-connect.sh \
		${PREFIXapp}/Dolphin_Tools-disk-use.sh \
		${PREFIXapp}/Dolphin_Tools-name-whitespace-replace.sh \
		${PREFIXapp}/Dropbox_Tools-frontend.py \
		${PREFIXapp}/Dropbox_Tools-frontend.pyc \
		${PREFIXapp}/Dropbox_Tools-frontend.pyo \
		${PREFIXapp}/Dropbox_Tools-main.sh \
		${PREFIXapp}/Dropbox_Tools-service-autostart.desktop \
		${PREFIXapp}/Dropbox_Tools-service-install.desktop \
		${PREFIXapp}/Dropbox_Tools-service-start.desktop \
		${PREFIXapp}/Dropbox_Tools-service-stop.desktop \
		${PREFIXapp}/Dropbox_Tools-service-update.desktop \
		${PREFIXapp}/DVD_Tools-d.v.d.-assembler.desktop \
		${PREFIXapp}/DVD_Tools-d.v.d.-assembler.sh \
		${PREFIXapp}/ffmpeg_multifile-add-subtitle.sh \
		${PREFIXapp}/ffmpeg_multifile-audio-mp3-attach-cover.sh \
		${PREFIXapp}/ffmpeg_multifile-clean-metadata-media-file.sh \
		${PREFIXapp}/ffmpeg_multifile-concatenate-media-file.sh \
		${PREFIXapp}/ffmpeg_multifile-convert-video.sh \
		${PREFIXapp}/ffmpeg_multifile-edit-media-time.sh \
		${PREFIXapp}/ffmpeg_multifile-extract-audio.sh \
		${PREFIXapp}/ffmpeg_multifile-video-rotate.sh \
		${PREFIXapp}/ffmpeg_record-my-desktop.sh \
		${PREFIXapp}/Graphic_Tools-the-converter.desktop \
		${PREFIXapp}/Graphic_Tools-the-resizer.desktop \
		${PREFIXapp}/HTTP_Server.sh \
		${PREFIXapp}/iso_manager-burn-image.sh \
		${PREFIXapp}/iso_manager-mount-image.sh \
		${PREFIXapp}/MEGA_Tools-main.sh \
		${PREFIXapp}/Midnight_Tools-mc-root.desktop \
		${PREFIXapp}/Midnight_Tools-mc.desktop \
		${PREFIXapp}/MKV_Extract-subtitle.sh \
		${PREFIXapp}/Multimedia_Tools-add-subtitle.desktop \
		${PREFIXapp}/Multimedia_Tools-audio-mp3-attach-cover.desktop \
		${PREFIXapp}/Multimedia_Tools-audio-normalize.desktop \
		${PREFIXapp}/Multimedia_Tools-audio-normalize.sh \
		${PREFIXapp}/Multimedia_Tools-clean-metadata-media-file.desktop \
		${PREFIXapp}/Multimedia_Tools-concatenate-media-file.desktop \
		${PREFIXapp}/Multimedia_Tools-convert-video.desktop \
		${PREFIXapp}/Multimedia_Tools-diskcloner.desktop \
		${PREFIXapp}/Multimedia_Tools-edit-media-time.desktop \
		${PREFIXapp}/Multimedia_Tools-extract-audio.desktop \
		${PREFIXapp}/Multimedia_Tools-record-my-desktop.desktop \
		${PREFIXapp}/Multimedia_Tools-video-rotate.desktop \
		${PREFIXapp}/Multiplex_Subtitle.sh \
		${PREFIXapp}/Network_Tools-connect-sentry.desktop \
		${PREFIXapp}/Network_Tools-connect-sentry.sh \
		${PREFIXapp}/Network_Tools-listening-sockets.desktop \
		${PREFIXapp}/Network_Tools-listening-sockets.sh \
		${PREFIXapp}/PDFktools.sh \
		${PREFIXapp}/SaMBa_Tools-mount-umount-share.desktop \
		${PREFIXapp}/SaMBa_Tools-mount-umount-share.sh \
		${PREFIXapp}/Search_Tools-modified-files-here.sh \
		${PREFIXapp}/Search_Tools-search-by-name.desktop \
		${PREFIXapp}/Search_Tools-search-by-name.sh \
		${PREFIXapp}/Search_Tools-search-by-string.sh \
		${PREFIXapp}/Search_Tools-search-here.sh \
		${PREFIXapp}/Search_Tools-statistics-search-db.desktop \
		${PREFIXapp}/Search_Tools-statistics-search-db.sh \
		${PREFIXapp}/Search_Tools-update-search-db.desktop \
		${PREFIXapp}/Search_Tools-update-search-db.sh \
		${PREFIXapp}/Show_file-dir_status.sh \
		${PREFIXapp}/SSH_Tools-connect-remote-machine.desktop \
		${PREFIXapp}/SSH_Tools-connect.sh \
		${PREFIXapp}/SSH_Tools-copy-id.sh \
		${PREFIXapp}/SSH_Tools-install-public-key.desktop \
		${PREFIXapp}/SSH_Tools-keygen.desktop \
		${PREFIXapp}/SSH_Tools-register-machine.desktop \
		${PREFIXapp}/SSH_Tools-register-machine.sh \
		${PREFIXapp}/SSH_Tools-scp.sh \
		${PREFIXapp}/SSH_Tools-ssh-keygen.sh \
		${PREFIXapp}/SSH_Tools-sshfs.desktop \
		${PREFIXapp}/SSH_Tools-sshfs.sh \
		${PREFIXapp}/System_Tools-build-custom-kernel.desktop \
		${PREFIXapp}/System_Tools-build-custom-kernel.sh \
		${PREFIXapp}/System_Tools-check-kernel-update.desktop \
		${PREFIXapp}/System_Tools-check-kernel-update.sh \
		${PREFIXapp}/System_Tools-process-viewer.desktop \
		${PREFIXapp}/System_Tools-process-viewer.sh \
		${PREFIXapp}/System_Tools-rebuild-package.desktop \
		${PREFIXapp}/System_Tools-rebuild-package.sh \
		${PREFIXapp}/System_Tools-sys-info.desktop \
		${PREFIXapp}/System_Tools-sys-info.sh \
		${PREFIXapp}/System_Tools-system-monitor.desktop \
		${PREFIXapp}/System_Tools-system-monitor.sh \
		${PREFIXapp}/System_Tools-Xorg-configure.desktop \
		${PREFIXapp}/System_Tools-Xorg-configure.sh \
		${PREFIXapp}/The_Converter.sh \
		${PREFIXapp}/The_Resizer.sh \
		${PREFIXapp}/YouTube_Tools-download-video.desktop \
		${PREFIXapp}/YouTube_Tools-download-video.sh \
		${PREFIXapp}/YouTube_Tools-download-video-list.desktop \
		${PREFIXapp}/YouTube_Tools-download-video-list.sh \
		${PREFIXapp}/YouTube_Tools-video-code-collector.desktop \
		${PREFIXapp}/YouTube_Tools-video-code-collector.sh

rm -f ${PREFIXSVGicons}/ks-add-subs.svgz \
		${PREFIXSVGicons}/ks-android-apk-manager.svgz \
		${PREFIXSVGicons}/ks-android-backup-restore.svgz \
		${PREFIXSVGicons}/ks-android-push-pull.svgz \
		${PREFIXSVGicons}/ks-android-reboot.svgz \
		${PREFIXSVGicons}/ks-audio-mp3-attach-cover.svgz \
		${PREFIXSVGicons}/ks-audio-normalize.svgz \
		${PREFIXSVGicons}/ks-audio-video-info.svgz \
		${PREFIXSVGicons}/ks-audio.svgz \
		${PREFIXSVGicons}/ks-checksum.svgz \
		${PREFIXSVGicons}/ks-clock.svgz \
		${PREFIXSVGicons}/ks-compressed-file.svgz \
		${PREFIXSVGicons}/ks-concatenate-media-file.svgz \
		${PREFIXSVGicons}/ks-connect-to.svgz \
		${PREFIXSVGicons}/ks-database.svgz \
		${PREFIXSVGicons}/ks-decrypt.svgz \
		${PREFIXSVGicons}/ks-disk-space-used.svgz \
		${PREFIXSVGicons}/ks-dolphin-file-manager.svgz \
		${PREFIXSVGicons}/ks-dropbox-off.svgz \
		${PREFIXSVGicons}/ks-dropbox-on.svgz \
		${PREFIXSVGicons}/ks-dropbox.svgz \
		${PREFIXSVGicons}/ks-encrypt.svgz \
		${PREFIXSVGicons}/ks-error.svgz \
		${PREFIXSVGicons}/ks-extracting-subs.svgz \
		${PREFIXSVGicons}/ks-folder-encrypt-mount.svgz \
		${PREFIXSVGicons}/ks-folder-encrypt-unmount.svgz \
		${PREFIXSVGicons}/ks-folder-encrypt.svgz \
		${PREFIXSVGicons}/ks-folder-public-web.svgz \
		${PREFIXSVGicons}/ks-folder-remote.svgz \
		${PREFIXSVGicons}/ks-hwinfo.svgz \
		${PREFIXSVGicons}/ks-image.svgz \
		${PREFIXSVGicons}/ks-info.svgz \
		${PREFIXSVGicons}/ks-kernel-rebuild.svgz \
		${PREFIXSVGicons}/ks-kernel-update.svgz \
		${PREFIXSVGicons}/ks-key.svgz \
		${PREFIXSVGicons}/ks-keygen.svgz \
		${PREFIXSVGicons}/ks-mc-root.svgz \
		${PREFIXSVGicons}/ks-mc-user.svgz \
		${PREFIXSVGicons}/ks-mcedit-root.svgz \
		${PREFIXSVGicons}/ks-mcedit-user.svgz \
		${PREFIXSVGicons}/ks-media-clean-metadata.svgz \
		${PREFIXSVGicons}/ks-media-edit-time.svgz \
		${PREFIXSVGicons}/ks-media-optical-burn.svgz \
		${PREFIXSVGicons}/ks-media-optical-clone.svgz \
		${PREFIXSVGicons}/ks-media-optical-info.svgz \
		${PREFIXSVGicons}/ks-media-optical-integrity-check.svgz \
		${PREFIXSVGicons}/ks-media-optical-md5sum.svgz \
		${PREFIXSVGicons}/ks-media-optical-mount.svgz \
		${PREFIXSVGicons}/ks-media-optical-umount.svgz \
		${PREFIXSVGicons}/ks-media-optical-video.svgz \
		${PREFIXSVGicons}/ks-media-tape.svgz \
		${PREFIXSVGicons}/ks-mega.svgz \
		${PREFIXSVGicons}/ks-menu.svgz \
		${PREFIXSVGicons}/ks-multiplexing-subs.svgz \
		${PREFIXSVGicons}/ks-optical-drive-info.svgz \
		${PREFIXSVGicons}/ks-owner.svgz \
		${PREFIXSVGicons}/ks-pdf.svgz \
		${PREFIXSVGicons}/ks-rebuild-rpm.svgz \
		${PREFIXSVGicons}/ks-resize-image.svgz \
		${PREFIXSVGicons}/ks-search-database-update.svgz \
		${PREFIXSVGicons}/ks-search-name.svgz \
		${PREFIXSVGicons}/ks-search-replace.svgz \
		${PREFIXSVGicons}/ks-search-stats.svgz \
		${PREFIXSVGicons}/ks-search-string.svgz \
		${PREFIXSVGicons}/ks-secure-mail.svgz \
		${PREFIXSVGicons}/ks-sentry-off.svgz \
		${PREFIXSVGicons}/ks-sentry-on.svgz \
		${PREFIXSVGicons}/ks-sentry-warning.svgz \
		${PREFIXSVGicons}/ks-server.svgz \
		${PREFIXSVGicons}/ks-shellscript.svgz \
		${PREFIXSVGicons}/ks-shredder.svgz \
		${PREFIXSVGicons}/ks-smbfs.svgz \
		${PREFIXSVGicons}/ks-socket.svgz \
		${PREFIXSVGicons}/ks-sshfs.svgz \
		${PREFIXSVGicons}/ks-system-process.svgz \
		${PREFIXSVGicons}/ks-terminal.svgz \
		${PREFIXSVGicons}/ks-text-plain.svgz \
		${PREFIXSVGicons}/ks-video-rotate.svgz \
		${PREFIXSVGicons}/ks-video.svgz \
		${PREFIXSVGicons}/ks-warning.svgz \
		${PREFIXSVGicons}/ks-whitespace-replace.svgz \
		${PREFIXSVGicons}/ks-xorg.svgz \
		${PREFIXSVGicons}/ks-youtube-download-video.svgz \
		${PREFIXSVGicons}/ks-youtube-video-code-collector.svgz \
		${PREFIXSVGicons}/ks-play-test-boot.svgz

rm -f ${PREFIXmime}/kde-services.xml \
		~/.local/share/mime/packages/kde-services.xml

rm -f ${PREFIXappmerge}/kde-services.menu

rm -f ${PREFIXdeskdir}/KDE-Services.directory \
		${PREFIXdeskdir}/KDE-Services_Android-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_Backup-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_Dolphin-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_Dropbox-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_Graphic-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_Midnight-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_Multimedia-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_Network-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_SaMBa-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_Search-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_SSH-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_System-Tools.directory \
		${PREFIXdeskdir}/KDE-Services_YouTube-Tools.directory

rm -fr ${PREFIXdoc}

update-mime-database ~/.local/share/mime > /dev/null
xdg-icon-resource forceupdate --theme hicolor
xdg-desktop-menu forceupdate
