#################################################################
# Installing KDE-Services, to appropriate directories.		#
# Author: Geovani Barzaga Rodriguez <igeo.cu@gmail.com>.	#
# KDE-Services 2011-2013. GPLv3+				#
#################################################################

PREFIXmenu=$(RPM_BUILD_ROOT)/usr/share/kde4/services/ServiceMenus
PREFIXapp=$(RPM_BUILD_ROOT)/usr/share/applications
PREFIX512apps=$(RPM_BUILD_ROOT)/usr/share/icons/hicolor/512x512/apps
PREFIXmime=$(RPM_BUILD_ROOT)/usr/share/mime/text
PREFIXappmerge=$(RPM_BUILD_ROOT)/etc/xdg/menus/applications-merged
PREFIXdeskdir=$(RPM_BUILD_ROOT)/usr/share/desktop-directories
PREFIXdoc=$(RPM_BUILD_ROOT)/usr/share/doc/kde-services

install:
	mkdir -p $(PREFIXmenu)
	mkdir -p $(PREFIXapp)
	mkdir -p $(PREFIX512apps)
	mkdir -p $(PREFIXmime)
	mkdir -p $(PREFIXappmerge)
	mkdir -p $(PREFIXdeskdir)
	mkdir -p $(PREFIXdoc)
	
	cp ServiceMenus/* $(PREFIXmenu)
	cp applications/* $(PREFIXapp)
	cp 512x512/apps/* $(PREFIX512apps)
	cp mime/text/* $(PREFIXmime)
	cp applications-merged/* $(PREFIXappmerge)
	cp desktop-directories/* $(PREFIXdeskdir)
	cp doc/* $(PREFIXdoc)

	xdg-mime install --mode system --novendor $(PREFIXmime)/hash.xml
	update-mime-database /usr/share/mime > /dev/null
	xdg-icon-resource forceupdate --theme hicolor
	xdg-desktop-menu forceupdate

uninstall:
	rm -f $(PREFIXmenu)/add-timestamp-prefix_servicemenu.desktop \
		$(PREFIXmenu)/AVI-Tools_servicemenu.desktop \
		$(PREFIXmenu)/Backup-Tools_addtoservicemenu.desktop \
		$(PREFIXmenu)/change-timestamp_servicemenu.desktop \
		$(PREFIXmenu)/CheckSum-Tools_addtoservicemenu.desktop \
		$(PREFIXmenu)/Dolphin-Tools_addtoservicemenu.desktop \
		$(PREFIXmenu)/Dolphin-Tools_change-owner.desktop \
		$(PREFIXmenu)/Dolphin-Tools_name-whitespace-replace-servicemenu.desktop \
		$(PREFIXmenu)/Dropbox-Tools_servicemenu.desktop \
		$(PREFIXmenu)/Graphic-Tools_servicemenu.desktop \
		$(PREFIXmenu)/iso-manager_addtoservicemenu.desktop \
		$(PREFIXmenu)/konsole-script_servicemenu.desktop \
		$(PREFIXmenu)/Midnight-Tools_addtoservicemenu.desktop \
		$(PREFIXmenu)/MKV-Extract-Subtitle_servicemenu.desktop \
		$(PREFIXmenu)/Multimedia-Tools_addtoservicemenu.desktop \
		$(PREFIXmenu)/Multiplex-Subtitle_servicemenu.desktop \
		$(PREFIXmenu)/Network-Tools_addtoservicemenu.desktop \
		$(PREFIXmenu)/Package-Tools_servicemenu.desktop \
		$(PREFIXmenu)/PDF-Tools_servicemenu.desktop \
		$(PREFIXmenu)/SaMBa-Tools_addtoservicemenu.desktop \
		$(PREFIXmenu)/Search-Tools_addtoservicemenu.desktop \
		$(PREFIXmenu)/Security-Tools_servicemenu.desktop \
		$(PREFIXmenu)/show-status_servicemenu.desktop \
		$(PREFIXmenu)/SSH-Tools_addtoservicemenu.desktop \
		$(PREFIXmenu)/System-Tools_addtoservicemenu.desktop \
		$(PREFIXmenu)/Text-Replace_servicemenu.desktop \
		$(PREFIXmenu)/thunderbird_addattachmentservicemenu.desktop \
		$(PREFIXmenu)/Video-Info_servicemenu.desktop \
		$(PREFIXmenu)/YouTube-Tools_addtoservicemenu.desktop

	rm -f $(PREFIXapp)/About_KDE-Services.desktop \
		$(PREFIXapp)/About_KDE-Services.sh \
		$(PREFIXapp)/AVI_Tools-avi-split-size.sh \
		$(PREFIXapp)/AVI_Tools-avi-split-time.sh \
		$(PREFIXapp)/Backup_Tools-standard.desktop \
		$(PREFIXapp)/Backup_Tools-standard.sh \
		$(PREFIXapp)/Change_file-dir_timestamp.sh \
		$(PREFIXapp)/CheckSum_Tools-verify-checksum.sh \
		$(PREFIXapp)/Dolphin_Tools-change-owner.sh \
		$(PREFIXapp)/Dolphin_Tools-connect.desktop \
		$(PREFIXapp)/Dolphin_Tools-connect.sh \
		$(PREFIXapp)/Dolphin_Tools-disk-use.sh \
		$(PREFIXapp)/Dolphin_Tools-name-whitespace-replace.sh \
		$(PREFIXapp)/Dropbox_Tools-frontend.py \
		$(PREFIXapp)/Dropbox_Tools-frontend.pyc \
		$(PREFIXapp)/Dropbox_Tools-frontend.pyo \
		$(PREFIXapp)/Dropbox_Tools-main.sh \
		$(PREFIXapp)/DVD_Tools-d.v.d.-assembler.desktop \
		$(PREFIXapp)/DVD_Tools-d.v.d.-assembler.sh \
		$(PREFIXapp)/ffmpeg_multifile-convert-video.sh \
		$(PREFIXapp)/ffmpeg_multifile-extract-audio.sh \
		$(PREFIXapp)/ffmpeg_record-my-desktop.sh \
		$(PREFIXapp)/Graphic_Tools-the-converter.desktop \
		$(PREFIXapp)/Graphic_Tools-the-sizer.desktop \
		$(PREFIXapp)/HTTP_Publisher.sh \
		$(PREFIXapp)/iso_manager-burn-image.sh \
		$(PREFIXapp)/iso_manager-mount-image.sh \
		$(PREFIXapp)/Midnight_Tools-mc.desktop \
		$(PREFIXapp)/Midnight_Tools-mc-root.desktop \
		$(PREFIXapp)/MKV_Extract-subtitle.sh \
		$(PREFIXapp)/Multimedia_Tools-convert-video.desktop \
		$(PREFIXapp)/Multimedia_Tools-extract-audio.desktop \
		$(PREFIXapp)/Multimedia_Tools-record-my-desktop.desktop \
		$(PREFIXapp)/Multiplex_Subtitle.sh \
		$(PREFIXapp)/Network_Tools-connect-sentry.desktop \
		$(PREFIXapp)/Network_Tools-connect-sentry.sh \
		$(PREFIXapp)/Network_Tools-listening-sockets.desktop \
		$(PREFIXapp)/Network_Tools-listening-sockets.sh \
		$(PREFIXapp)/PDFktools.sh \
		$(PREFIXapp)/SaMBa_Tools-mount-umount-share.desktop \
		$(PREFIXapp)/SaMBa_Tools-mount-umount-share.sh \
		$(PREFIXapp)/Search_Tools-modified-files-here.sh \
		$(PREFIXapp)/Search_Tools-search-by-name.desktop \
		$(PREFIXapp)/Search_Tools-search-by-name.sh \
		$(PREFIXapp)/Search_Tools-search-by-string.sh \
		$(PREFIXapp)/Search_Tools-search-here.sh \
		$(PREFIXapp)/Search_Tools-statistics-search-db.desktop \
		$(PREFIXapp)/Search_Tools-statistics-search-db.sh \
		$(PREFIXapp)/Search_Tools-update-search-db.desktop \
		$(PREFIXapp)/Search_Tools-update-search-db.sh \
		$(PREFIXapp)/Show_file-dir_status.sh \
		$(PREFIXapp)/SSH_Tools-connect-remote-machine.desktop \
		$(PREFIXapp)/SSH_Tools-connect.sh \
		$(PREFIXapp)/SSH_Tools-copy-id.sh \
		$(PREFIXapp)/SSH_Tools-install-public-key.desktop \
		$(PREFIXapp)/SSH_Tools-keygen.desktop \
		$(PREFIXapp)/SSH_Tools-register-machine.desktop \
		$(PREFIXapp)/SSH_Tools-register-machine.sh \
		$(PREFIXapp)/SSH_Tools-scp.sh \
		$(PREFIXapp)/SSH_Tools-ssh-keygen.sh \
		$(PREFIXapp)/SSH_Tools-sshfs.desktop \
		$(PREFIXapp)/SSH_Tools-sshfs.sh \
		$(PREFIXapp)/System_Tools-build-custom-kernel.desktop \
		$(PREFIXapp)/System_Tools-build-custom-kernel.sh \
		$(PREFIXapp)/System_Tools-check-kernel-update.desktop \
		$(PREFIXapp)/System_Tools-check-kernel-update.sh \
		$(PREFIXapp)/System_Tools-process-viewer.desktop \
		$(PREFIXapp)/System_Tools-process-viewer.sh \
		$(PREFIXapp)/System_Tools-rebuild-package.desktop \
		$(PREFIXapp)/System_Tools-rebuild-package.sh \
		$(PREFIXapp)/System_Tools-sys-info.desktop \
		$(PREFIXapp)/System_Tools-sys-info.sh \
		$(PREFIXapp)/System_Tools-Xorg-configure.desktop \
		$(PREFIXapp)/System_Tools-Xorg-configure.sh \
		$(PREFIXapp)/The_Converter.sh \
		$(PREFIXapp)/The_Sizer.sh \
		$(PREFIXapp)/YouTube_Tools-download-video.desktop \
		$(PREFIXapp)/YouTube_Tools-download-video.sh \
		$(PREFIXapp)/YouTube_Tools-video-code-collector.desktop \
		$(PREFIXapp)/YouTube_Tools-video-code-collector.sh

	rm -f $(PREFIX512apps)/ks-audio.png \
		$(PREFIX512apps)/ks-checksum.png \
		$(PREFIX512apps)/ks-clock.png \
		$(PREFIX512apps)/ks-connect-to.png \
		$(PREFIX512apps)/ks-database.png \
		$(PREFIX512apps)/ks-decrypt.png \
		$(PREFIX512apps)/ks-disk-space-used.png \
		$(PREFIX512apps)/ks-dolphin-file-manager.png \
		$(PREFIX512apps)/ks-dropbox-off.png \
		$(PREFIX512apps)/ks-dropbox-on.png \
		$(PREFIX512apps)/ks-dropbox.png \
		$(PREFIX512apps)/ks-encrypt.png \
		$(PREFIX512apps)/ks-error.png \
		$(PREFIX512apps)/ks-extracting-subs.png \
		$(PREFIX512apps)/ks-folder-public-web.png \
		$(PREFIX512apps)/ks-folder-remote.png \
		$(PREFIX512apps)/ks-hwinfo.png \
		$(PREFIX512apps)/ks-image.png \
		$(PREFIX512apps)/ks-info.png \
		$(PREFIX512apps)/ks-kernel-rebuild.png \
		$(PREFIX512apps)/ks-kernel-update.png \
		$(PREFIX512apps)/ks-key.png \
		$(PREFIX512apps)/ks-keygen.png \
		$(PREFIX512apps)/ks-mc-root.png \
		$(PREFIX512apps)/ks-mc-user.png \
		$(PREFIX512apps)/ks-mcedit-root.png \
		$(PREFIX512apps)/ks-mcedit-user.png \
		$(PREFIX512apps)/ks-media-optical-burn.png \
		$(PREFIX512apps)/ks-media-optical-integrity-check.png \
		$(PREFIX512apps)/ks-media-optical-md5sum.png \
		$(PREFIX512apps)/ks-media-optical-mount.png \
		$(PREFIX512apps)/ks-media-optical-umount.png \
		$(PREFIX512apps)/ks-media-optical-video.png \
		$(PREFIX512apps)/ks-media-tape.png \
		$(PREFIX512apps)/ks-menu.png \
		$(PREFIX512apps)/ks-multiplexing-subs.png \
		$(PREFIX512apps)/ks-owner.png \
		$(PREFIX512apps)/ks-pdf.png \
		$(PREFIX512apps)/ks-rebuild-rpm.png \
		$(PREFIX512apps)/ks-resize-image.png \
		$(PREFIX512apps)/ks-search-database-update.png \
		$(PREFIX512apps)/ks-search-name.png \
		$(PREFIX512apps)/ks-search-replace.png \
		$(PREFIX512apps)/ks-search-stats.png \
		$(PREFIX512apps)/ks-search-string.png \
		$(PREFIX512apps)/ks-secure-mail.png \
		$(PREFIX512apps)/ks-sentry-off.png \
		$(PREFIX512apps)/ks-sentry-on.png \
		$(PREFIX512apps)/ks-sentry-warning.png \
		$(PREFIX512apps)/ks-server.png \
		$(PREFIX512apps)/ks-shellscript.png \
		$(PREFIX512apps)/ks-shredder.png \
		$(PREFIX512apps)/ks-smbfs.png \
		$(PREFIX512apps)/ks-socket.png \
		$(PREFIX512apps)/ks-sshfs.png \
		$(PREFIX512apps)/ks-system-process.png \
		$(PREFIX512apps)/ks-terminal.png \
		$(PREFIX512apps)/ks-text-plain.png \
		$(PREFIX512apps)/ks-video.png \
		$(PREFIX512apps)/ks-warning.png \
		$(PREFIX512apps)/ks-whitespace-replace.png \
		$(PREFIX512apps)/ks-xorg.png \
		$(PREFIX512apps)/ks-youtube-download-video.png \
		$(PREFIX512apps)/ks-youtube-video-code-collector.png

	xdg-mime uninstall --mode system --novendor $(PREFIXmime)/hash.xml
	
	rm -f $(PREFIXmime)/hash.xml
	rm -f /usr/share/mime/packages/hash.xml

	rm -f $(PREFIXappmerge)/kde-services.menu

	rm -f $(PREFIXdeskdir)/KDE-Services_Backup-Tools.directory \
		$(PREFIXdeskdir)/KDE-Services.directory \
		$(PREFIXdeskdir)/KDE-Services_Dolphin-Tools.directory \
		$(PREFIXdeskdir)/KDE-Services_Graphic-Tools.directory \
		$(PREFIXdeskdir)/KDE-Services_Midnight-Tools.directory \
		$(PREFIXdeskdir)/KDE-Services_Multimedia-Tools.directory \
		$(PREFIXdeskdir)/KDE-Services_Network-Tools.directory \
		$(PREFIXdeskdir)/KDE-Services_SaMBa-Tools.directory \
		$(PREFIXdeskdir)/KDE-Services_Search-Tools.directory \
		$(PREFIXdeskdir)/KDE-Services_SSH-Tools.directory \
		$(PREFIXdeskdir)/KDE-Services_System-Tools.directory \
		$(PREFIXdeskdir)/KDE-Services_YouTube-Tools.directory

	rm -fr $(PREFIXdoc)

	update-mime-database /usr/share/mime > /dev/null
	xdg-icon-resource forceupdate --theme hicolor
	xdg-desktop-menu forceupdate

