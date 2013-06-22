#################################################################
# Installing KDE Services, to appropriate directories.		#
# Author: Geovani Barzaga Rodriguez <igeo.cu@gmail.com>.	#
# KDE-Services 2011-2013. GPLv3+				#
#################################################################

PREFIXmenu=$(RPM_BUILD_ROOT)/usr/share/kde4/services/ServiceMenus
PREFIXapp=$(RPM_BUILD_ROOT)/usr/share/applications
PREFIX256apps=$(RPM_BUILD_ROOT)/usr/share/icons/hicolor/256x256/apps
PREFIXmime=$(RPM_BUILD_ROOT)/usr/share/mime/text
PREFIXappmerge=$(RPM_BUILD_ROOT)/etc/xdg/menus/applications-merged
PREFIXdeskdir=$(RPM_BUILD_ROOT)/usr/share/desktop-directories
PREFIXdoc=$(RPM_BUILD_ROOT)/usr/share/doc/kde-services

install:
	mkdir -p $(PREFIXmenu)
	mkdir -p $(PREFIXapp)
	mkdir -p $(PREFIX256apps)
	mkdir -p $(PREFIXmime)
	mkdir -p $(PREFIXappmerge)
	mkdir -p $(PREFIXdeskdir)
	mkdir -p $(PREFIXdoc)

	rm -f $(PREFIXmenu)/image-resizer_servicemenu.desktop

	cp ServiceMenus/* $(PREFIXmenu)
	cp applications/* $(PREFIXapp)
	cp 256x256/apps/* $(PREFIX256apps)
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
		$(PREFIXmenu)/image-resizer_servicemenu.desktop \
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
		$(PREFIXapp)/Search_Tools-search-by-name.desktop \
		$(PREFIXapp)/Search_Tools-search-by-name.sh \
		$(PREFIXapp)/Search_Tools-search-by-string.sh \
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
		$(PREFIXapp)/The_Converter.sh \
		$(PREFIXapp)/The_Sizer.sh \
		$(PREFIXapp)/YouTube_Tools-download-video.desktop \
		$(PREFIXapp)/YouTube_Tools-download-video.sh \
		$(PREFIXapp)/YouTube_Tools-video-code-collector.desktop \
		$(PREFIXapp)/YouTube_Tools-video-code-collector.sh

	rm -f $(PREFIX256apps)/application-exit.png \
		$(PREFIX256apps)/application-pdf.png \
		$(PREFIX256apps)/application-x-shellscript.png \
		$(PREFIX256apps)/application-x-smb-server.png \
		$(PREFIX256apps)/audio-x-generic.png \
		$(PREFIX256apps)/code-block.png \
		$(PREFIX256apps)/code-class.png \
		$(PREFIX256apps)/code-context.png \
		$(PREFIX256apps)/connect-creating.png \
		$(PREFIX256apps)/connect-sentry-established.png \
		$(PREFIX256apps)/connect-sentry-off.png \
		$(PREFIX256apps)/connect-sentry-on.png \
		$(PREFIX256apps)/dialog-warning.png \
		$(PREFIX256apps)/disk-full.png \
		$(PREFIX256apps)/document-decrypt.png \
		$(PREFIX256apps)/document-encrypt.png \
		$(PREFIX256apps)/edit-delete-shred.png \
		$(PREFIX256apps)/edit-find-mail.png \
		$(PREFIX256apps)/edit-find-project.png \
		$(PREFIX256apps)/edit-find-replace.png \
		$(PREFIX256apps)/edit-rename.png \
		$(PREFIX256apps)/emblem-new.png \
		$(PREFIX256apps)/folder-remote.png \
		$(PREFIX256apps)/hwinfo.png \
		$(PREFIX256apps)/image-x-generic.png \
		$(PREFIX256apps)/internet-mail.png \
		$(PREFIX256apps)/kde-services.png \
		$(PREFIX256apps)/keyring.png \
		$(PREFIX256apps)/list-add-font.png \
		$(PREFIX256apps)/mcedit.png \
		$(PREFIX256apps)/mcedit-root.png \
		$(PREFIX256apps)/mc.png \
		$(PREFIX256apps)/mc-root.png \
		$(PREFIX256apps)/media-optical-blu-ray.png \
		$(PREFIX256apps)/media-optical-burn.png \
		$(PREFIX256apps)/media-optical-data.png \
		$(PREFIX256apps)/media-optical-dvd-video.png \
		$(PREFIX256apps)/media-optical.png \
		$(PREFIX256apps)/media-optical-recordable.png \
		$(PREFIX256apps)/media-tape.png \
		$(PREFIX256apps)/meeting-organizer.png \
		$(PREFIX256apps)/online.png \
		$(PREFIX256apps)/resizeimages.png \
		$(PREFIX256apps)/server-database.png \
		$(PREFIX256apps)/server.png \
		$(PREFIX256apps)/socket.png \
		$(PREFIX256apps)/sshfs.png \
		$(PREFIX256apps)/svn-update.png \
		$(PREFIX256apps)/text-x-plain.png \
		$(PREFIX256apps)/timeadjust.png \
		$(PREFIX256apps)/utilities-terminal.png \
		$(PREFIX256apps)/utilities-terminal-user.png \
		$(PREFIX256apps)/video-x-generic.png \
		$(PREFIX256apps)/view-process-all.png \
		$(PREFIX256apps)/youtube-video-download.png
	
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

