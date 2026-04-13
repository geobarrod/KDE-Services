#!/usr/bin/env bash
###################################################################################
# KDE-Services ⚙ 2012-2026.
#
# BSD 3-Clause License
#
# Copyright (c) 2026, Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###################################################################################

# ---------------------------------------------
# Script Metadata and Configuration
# ---------------------------------------------
set -E

KDE_SERVICES_URL="https://store.kde.org/p/998464/"
DONATE_URL="https://raw.githubusercontent.com/geobarrod/KDE-Services/refs/heads/master/doc/DONATE"
TEMP_FILE="/tmp/about_kde-services.$$"

# Function to clean up the temporary file on exit/error
cleanup() {
    # Remove temp file safely
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT ERR INT TERM

# ---------------------------------------------
# SED PORTABILITY DETECTOR (For consistency)
# ---------------------------------------------
if [[ "$(uname)" == "Darwin" || "$(uname)" == *"BSD"* ]]; then
    SED_EDIT_IN_PLACE=("-i" "")
else
    SED_EDIT_IN_PLACE=("-i")
fi

# ---------------------------------------------
# VERSION RETRIEVAL
# ---------------------------------------------
VERSION=$( \
    find "${HOME}/.local/share/doc/" -maxdepth 2 -type f -name "ChangeLog" 2>/dev/null | \
    head -n1 | \
    xargs -r head -n1 2>/dev/null | \
    awk '{print $10}' \
)

if [[ -z "$VERSION" ]]; then
    VERSION="Unknown"
fi

# ---------------------------------------------
# 1. DEFAULT TEXT DEFINITIONS (English)
# ---------------------------------------------
msg_app_description="Enables the following functionalities on the Dolphin's (File Manager) right click contextual menu on KDE Plasma 6."
msg_language_support="Language support:"
msg_required_dependencies="Required dependencies:"
msg_contributors="Contributors:"
msg_author="Author:"
msg_license="License:"
msg_donate_title="Donate 🎔:"
msg_donate_text_1="You can make a donation to support the overall efforts of the KDE-Services project author."
msg_donate_text_2="The receiver's information can be found following:"
msg_donate_thanks="Thanks!"
msg_kdialog_title="About KDE-Services"

# Full text block description (English - Default)
msg_description_block=$(cat << 'EOF_DESC'
    Submenu "Actions" => "KDE-Services" (it is shown when right-clicked any file/dir).
    - "Add Timestamp Prefix to [File|Dir]name"
    - "Change Timestamp to [File|Directory]"
    - "Send by Email"
    - "[Audio|Video] Info" (it is shown only when right-clicked any audio/video file).
    - "Show [File|Directory] Status"
    - "Change Owner Here" (owner and permission of file/dir).
    - "Text Replace" (it is shown only when right-clicked any text file).
    - "Compressed File Integrity Check" (it is shown only when right-clicked any compressed file).
    - "MKV Extract Subtitle" (it is shown only when right-clicked MKV video file).
    - "Multiplex Subtitle" (only support MPEG-2 video file)(it is shown only when right-clicked MPG video file).
    - "[File|Dir]name Whitespace Replace" (by underscore ASCII)(it is shown when right-clicked an directory).

    Submenu "AVI Tools" (it is shown only when right-clicked AVI video file).
    - "Split (to size)"
    - "Split (by time range)"

    Submenu "Android Tools" (it is shown when right-clicked an directory).
    - "Android Backup Manager" (backup or restore all device applications and data).
    - "Android File Manager" (copy file/dir from/to device).
    - "Android Package Manager" (install/uninstall *.apk applications).
    - "Android Reboot Manager" (reboots the device, optionally into the bootloader or recovery program).

    Submenu "Backup Tools" (it is shown when right-clicked an directory).
    - "Standards" (backup/restore directories /etc/ and /root/ or aMule, AnyDesk, Audacity, Chrome, GnuPG,
      HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
      Tmux, Wine and general user configurations).

    Submenu "CheckSum Tools" (it is shown when right-clicked any file).
    - "MD5 (strong)"
    - "SHA1 (good strong)"
    - "SHA256 (very strong)"
    - "SHA512 (high strong)"
    - "Verify CheckSum" (checksum file *.md5/*.sha1/*.sha256/*.sha512).

    Submenu "Dolphin Tools" (it is shown when right-clicked an directory).
    - "Connect to" (FTP/SFTP/SMB protocol).
    - "Registered Servers" (show or edit IP/Hostname previously connected).
    - "Disk Space Used"

    Submenu "Dropbox Tools" (it is shown when right-clicked an directory).
    - "Copy to Dropbox"
    - "Move to Dropbox"
    - "Copy to Public Dropbox and get URL"
    - "Move to Public Dropbox and get URL"
    - "Get public URL"
    - "Install Dropbox service"
    - "Update Dropbox service"
    - "Start Dropbox service"
    - "Stop Dropbox service"
    - "Enable autostart Dropbox service"

    Submenu "Graphic Tools" (it is shown only when right-clicked any image file).
    - "The Converter" (from several image file formats to BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
      PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF or XPM).
    - "The Resizer" (customize the width of the image frame).
    - "16x16 (Icon)"
    - "32x32 (Icon)"
    - "48x48 (Icon)"
    - "64x64 (Icon)"
    - "128x128 (Icon)"
    - "256x256 (Icon)"
    - "300x300 (ID card)"
    - "320x240 (QVGA)"
    - "352x288 (CIF)"
    - "414X532 (visa)"
    - "480X320 (HVGA)"
    - "512X512 (Icon)"
    - "532X532 (Passport)"
    - "640X480 (VGA)"
    - "720X480 (NTSC)"
    - "800X600 (SVGA)"
    - "960X540 (QHD)"
    - "1024X768 (XGA)"
    - "1280X1024 (SXGA)"
    - "1366X768 (WXGA)"
    - "1440X900 (WXGA)"
    - "1600X1200 (UXGA)"
    - "1920X1200 (WUXGA)"
    - "2048X1080 (2K)"
    - "2560X2048 (QSXGA)"
    - "3200X2048 (WQSXGA)"
    - "3840X2400 (WQUXGA)"
    - "4096X2160 (4K)"
    - "5120X4096 (HSXGA)"
    - "6400X4096 (WHSXGA)"
    - "7680X4800 (WHUXGA)"
    - "8192X4320 (8K)"

    Submenu "ISO-9660 Image Tools" (it is shown only when right-clicked ISO-9660 image file).
    - "Mount ISO-9660 Image"
    - "Unmount ISO-9660 Image"
    - "Integrity Check"
    - "Insert MD5sum"
    - "Show MD5sum ISO-9660 Image"
    - "Show SHA1sum ISO-9660 Image"
    - "Show SHA256sum ISO-9660 Image"
    - "Show SHA512sum ISO-9660 Image"
    - "Burn ISO-9660 Image"
    - "Show ISO-9660 Image Info"
    - "Show Optical Drive Info"
    - "Test-Boot ISO-9660 (QEMU BIOS)"
    - "Test-Boot ISO-9660 (QEMU UEFI)"
    - "Test-Boot ISO-9660 (QEMU UEFI, Secure boot)"

    Submenu "MEGA Tools" (it is shown when right-clicked any file/dir).
    - "Register New Account"
    - "Save User Login Credentials"
    - "Show Available Cloud Space"
    - "Create New Remote Folder"
    - "List Files Stored in Cloud"
    - "Remove Files Stored in Cloud"
    - "Upload Files to Cloud"
    - "Synchronize [from|to] Cloud"

    Submenu "Midnight Tools" (it is shown when right-clicked an directory).
    - "[Root ~]# mc" (shell file manager GNU Midnight Commander with superuser privileges).
    - "[Root ~]# mcedit" (internal file editor of GNU Midnight Commander with superuser privileges).
    - "[User ~]$ mc" (shell file manager GNU Midnight Commander with user privileges).
    - "[User ~]$ mcedit" (internal file editor of GNU Midnight Commander with user privileges).

    Submenu "Multimedia Tools" (it is shown when right-clicked an directory).
    - "DVD Assembler" (with menu).
    - "Convert Video Files" (from several video file formats to MPEG-1, MPEG-2, MPEG-4, AVI,
      VCD, SVCD, DVD, 3GP, FLV or WebM).
    - "Add Subtitle to MP4 Files"
    - "Volume Normalize of MP3 Files"
    - "Extract|Convert Audio Track" (from several audio file formats to MP3, MP3(432Hz),
      FLAC, FLAC 432Hz, OGG or OGG 432Hz).
    - "Rotate Video Files"
    - "Edit Time from Media Files"
    - "Attach Cover to MP3 Files"
    - "Clean Metadata from Media Files"
    - "Concatenate Media Files with Same Codec"
    - "Build ISO-9660 Image from Here" (from selected directory).
    - "DiskCloner" (binary copy from selected optical disk device to ISO-9660 image file).
    - "Record My Desktop" (record video screen).
    - "Play Video from Here" (play video files list from selected directory).

    Submenu "Network Tools" (it is shown when right-clicked an directory).
    - "Connect Sentry" (show every established connection to previously selected ports).
    - "HTTP Server" (from selected directory).
    - "Listening Sockets"

    Submenu "PDF Tools" (it is shown only when right-clicked PDF file).
    - "Apply Owner Password (DRM)"
    - "Apply User Password (Encrypt)"
    - "Apply DRM + Encrypt"
    - "Decrypt (DRM)"
    - "Fixer (if possible)"
    - "Extract Select Pages"
    - "Extract All Pages"
    - "Extract All Images"
    - "Optimize"
    - "Compress"
    - "View Metadata"
    - "Edit Metadata"
    - "Merge Selected Files"
    - "Split in Single Page per File"
    - "Information"

    Submenu "Package Tools" (it is shown only when right-clicked SRPM/RPM file).
    - "Show Changelog"
    - "Show Info"
    - "List Content"
    - "List Configuration Files"
    - "List Dependencies"
    - "List [Ins|Unins]tallation Scripts"
    - "Extract Files Here"
    - "Integrity Check"

    Submenu "SSH Tools" (it is shown when right-clicked an directory).
    - "Public Key Generation" (1st mandatory step before connect to remote server).
    - "Install Public Key" (2nd mandatory step before connect to remote server).
    - "Connect to Remote Server"
    - "Send to Remote Server" (only file support).
    - "Mount point to Remote Directory" (mount/unmount remote directory over SSH protocol
      in local filesystem).
    - "Registered Servers" (show or edit IP/Hostname previously connected).

    Submenu "SaMBa Tools" (it is shown when right-clicked an directory).
    - "SaMBa Shares Mounter" (mount/unmount remote shared directory over SMB protocol
      in local filesystem).

    Submenu "Search Tools" (it is shown when right-clicked an directory).
    - "Search Here" (recursively starting from the selected directory).
    - "Search by Name" (file/dir name on all filesystem).
    - "Search by String" (recursively starting from the selected directory into file content).
    - "Statistics Search DataBase"
    - "Update Search DataBase"
    - "Modified Files Here" (recursively starting from the selected directory
      showing all modified files for the 2nd time that is executed).

    Submenu "Security Tools" (it is shown when right-clicked an directory).
    - "Mount Encrypted Directory" (mount an encrypted virtual filesystem
      from the selected directory).
    - "Unmount Encrypted Directory" (unmount an encrypted virtual filesystem
      from the selected mountpoint directory).
    - "Encrypt Directory" (create an encrypted virtual filesystem in the selected directory).

    Submenu "Security Tools" (it is shown when right-clicked any file).
    - "Secure Send to Mailx" (file as email attachment; need SMTP service running in localhost).
    - "Encrypt"
    - "Decrypt"
    - "Paranoid Shredder" (delete files in a very safe way).

    Submenu "System Tools" (it is shown when right-clicked an directory).
    - "Build Custom Kernel" (customize the system kernel easily, increasing the system performance
      and/or adding more hardware support, only for distros based on RHEL).
    - "Check Kernel Update" (only for distros based on RHEL).
    - "Rebuild RPM Package" (customize applications easily, increasing the application performance
      and/or adding more support, only for distros based on RHEL).
    - "System Information"
    - "System Monitor" (show system log fail/error events when they happen).
    - "Process Viewer"
    - "Xorg Configure" (create a configuration file for X11R7 X server).

    Submenu "Terminal Tools" (it is shown only when right-clicked shell scripts/apps file).
    - "Run Application"
    - "Run Application (Root)"

    Submenu "YouTube Tools" (it is shown when right-clicked an directory).
    - "Video Downloader"
    - "Video List Code Collector"
    - "Video List Downloader"
EOF_DESC
)

# ---------------------------------------------
# 2. LANGUAGE DETECTOR AND OVERRIDES
# ---------------------------------------------
sys_lang="${LANG:0:2}"

case "$sys_lang" in
    zh) # Chinese
        msg_app_description="在 KDE Plasma 6 的 Dolphin（文件管理器）右键上下文菜单中启用以下功能。"
        msg_language_support="语言支持："
        msg_required_dependencies="所需依赖项："
        msg_contributors="贡献者："
        msg_author="作者："
        msg_license="许可证："
        msg_donate_title="捐赠 🎔："
        msg_donate_text_1="您可以捐款支持 KDE-Services 项目作者的总体努力。"
        msg_donate_text_2="收款人信息可在以下链接中找到："
        msg_donate_thanks="谢谢！"
        msg_kdialog_title="关于 KDE-Services"
        msg_description_block=$(cat << EOF_DESC_ZH
    Submenú "Actions" => "KDE-Services" (显示在任何文件/目录上右键单击时).
    - "添加时间戳前缀到 [文件|目录]名"
    - "更改 [文件|目录] 的时间戳"
    - "通过电子邮件发送"
    - "[音频|视频] 信息" (仅在任何音频/视频文件上右键单击时显示).
    - "显示 [文件|目录] 状态"
    - "在此更改所有者" (文件/目录所有者和权限).
    - "文本替换" (仅在任何文本文件上右键单击时显示).
    - "压缩文件完整性检查" (仅在任何压缩文件上右键单击时显示).
    - "MKV 提取字幕" (仅在 MKV 视频文件上右键单击时显示).
    - "复用字幕" (仅支持 MPEG-2 视频文件) (仅在 MPG 视频文件上右键单击时显示).
    - "[文件|目录]名空格替换" (通过 ASCII 下划线) (在目录上右键单击时显示).

    Submenú "AVI Tools" (AVI 工具) (仅在 AVI 视频文件上右键单击时显示).
    - "拆分 (按大小)"
    - "拆分 (按时间范围)"
    
    Submenú "Android Tools" (Android 工具) (在目录上右键单击时显示).
    - "Android 备份管理器" (备份或恢复设备上的所有应用和数据).
    - "Android 文件管理器" (从设备/向设备复制文件/目录).
    - "Android 软件包管理器" (安装/卸载 *.apk 应用).
    - "Android 重启管理器" (重启设备，可选进入引导加载程序或恢复程序).
    
    Submenú "Backup Tools" (备份工具) (在目录上右键单击时显示).
    - "标准" (备份/恢复 /etc/ 和 /root/ 目录或 aMule, AnyDesk, Audacity, Chrome, GnuPG,
      HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
      Tmux, Wine 以及一般用户设置).
    
    Submenú "CheckSum Tools" (校验和工具) (在任何文件上右键单击时显示).
    - "MD5 (强)"
    - "SHA1 (良好强)"
    - "SHA256 (非常强)"
    - "SHA512 (高强)"
    - "验证校验和" (*.md5/*.sha1/*.sha256/*.sha512 校验和文件).
    
    Submenú "Dolphin Tools" (Dolphin 工具) (在目录上右键单击时显示).
    - "连接到" (FTP/SFTP/SMB 协议).
    - "已注册服务器" (显示或编辑以前连接的 IP/主机).
    - "已用磁盘空间"
    
    Submenú "Dropbox Tools" (Dropbox 工具) (在目录上右键单击时显示).
    - "复制到 Dropbox"
    - "移动到 Dropbox"
    - "复制到公共 Dropbox 并获取 URL"
    - "移动到公共 Dropbox 并获取 URL"
    - "获取公共 URL"
    - "安装 Dropbox 服务"
    - "更新 Dropbox 服务"
    - "启动 Dropbox 服务"
    - "停止 Dropbox 服务"
    - "启用 Dropbox 服务自动启动"
    
    Submenú "Graphic Tools" (图形工具) (仅在任何图像文件上右键单击时显示).
    - "转换器" (将各种图像文件格式转换为 BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
      PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF 或 XPM).
    - "调整器" (自定义图像帧宽度).
    - "16x16 (图标)"
    - "32x32 (图标)"
    - "48x48 (图标)"
    - "64x64 (图标)"
    - "128x128 (图标)"
    - "256x256 (图标)"
    - "300x300 (证件照)"
    - "320x240 (qvga)"
    - "352x288 (cif)"
    - "414x532 (签证)"
    - "480x320 (hvga)"
    - "512x512 (图标)"
    - "532x532 (护照)"
    - "640x480 (vga)"
    - "720x480 (ntsc)"
    - "800x600 (svga)"
    - "960x540 (qhd)"
    - "1024x768 (xga)"
    - "1280x1024 (sxga)"
    - "1366x768 (wxga)"
    - "1440x900 (wxga)"
    - "1600x1200 (uxga)"
    - "1920x1200 (wuxga)"
    - "2048x1080 (2k)"
    - "2560x2048 (qsxga)"
    - "3200x2048 (wqsxga)"
    - "3840x2400 (wquxga)"
    - "4096x2160 (4k)"
    - "5120x4096 (hsxga)"
    - "6400x4096 (whsxga)"
    - "7680x4800 (whuxga)"
    - "8192x4320 (8k)"
    
    Submenú "ISO-9660 Image Tools" (ISO-9660 镜像工具) (仅在 ISO-9660 镜像文件上右键单击时显示).
    - "挂载 ISO-9660 镜像"
    - "卸载 ISO-9660 镜像"
    - "完整性检查"
    - "插入 MD5sum"
    - "显示 ISO-9660 镜像的 MD5sum"
    - "显示 ISO-9660 镜像的 SHA1sum"
    - "显示 ISO-9660 镜像的 SHA256sum"
    - "显示 ISO-9660 镜像的 SHA512sum"
    - "刻录 ISO-9660 镜像"
    - "显示 ISO-9660 镜像信息"
    - "显示光驱信息"
    - "ISO-9660 测试启动 (QEMU BIOS)"
    - "ISO-9660 测试启动 (QEMU UEFI)"
    - "ISO-9660 测试启动 (QEMU UEFI, Secure boot)"
    
    Submenú "MEGA Tools" (MEGA 工具) (在任何文件/目录上右键单击时显示).
    - "注册新账户"
    - "保存用户登录凭证"
    - "显示可用云空间"
    - "创建新的远程文件夹"
    - "列出存储在云中的文件"
    - "删除存储在云中的文件"
    - "上传文件到云"
    - "同步 [从|到] 云"
    
    Submenú "Midnight Tools" (Midnight 工具) (在目录上右键单击时显示).
    - "[Root ~]# mc" (带超级用户权限的 Shell 文件管理器 GNU Midnight Commander).
    - "[Root ~]# mcedit" (带超级用户权限的 GNU Midnight Commander 内部文件编辑器).
    - "[User ~]$ mc" (带用户权限的 Shell 文件管理器 GNU Midnight Commander).
    - "[User ~]$ mcedit" (带用户权限的 GNU Midnight Commander 内部文件编辑器).
    
    Submenú "Multimedia Tools" (多媒体工具) (在目录上右键单击时显示).
    - "DVD 汇编器" (带菜单).
    - "转换视频文件" (将各种视频文件格式转换为 MPEG-1, MPEG-2, MPEG-4, AVI,
      VCD, SVCD, DVD, 3GP, FLV 或 WebM).
    - "为 MP4 文件添加字幕"
    - "MP3 文件音量标准化"
    - "提取|转换音轨" (将各种音频文件格式转换为 MP3, MP3(432Hz),
      FLAC, FLAC 432Hz, OGG 或 OGG 432Hz).
    - "旋转视频文件"
    - "编辑媒体文件时间"
    - "为 MP3 文件附加封面"
    - "清理媒体文件元数据"
    - "连接相同编解码器的媒体文件"
    - "从此处构建 ISO-9660 镜像" (从选定的目录).
    - "磁盘克隆器" (将选定的光盘设备进行二进制复制到 ISO-9660 镜像文件).
    - "录制我的桌面" (视频屏幕录制).
    - "从此处播放视频" (从选定的目录播放视频文件列表).
    
    Submenú "Network Tools" (网络工具) (在目录上右键单击时显示).
    - "连接哨兵" (显示与先前选择的端口建立的每个连接).
    - "HTTP 服务器" (从选定的目录).
    - "监听套接字"
    
    Submenú "PDF Tools" (PDF 工具) (仅在 PDF 文件上右键单击时显示).
    - "应用所有者密码 (DRM)"
    - "应用用户密码 (加密)"
    - "应用 DRM + 加密"
    - "解密 (DRM)"
    - "修复器 (如果可能)"
    - "提取选定页面"
    - "提取所有页面"
    - "提取所有图像"
    - "优化"
    - "压缩"
    - "查看元数据"
    - "编辑元数据"
    - "合并选定文件"
    - "拆分为每个文件单页"
    - "信息"
    
    Submenú "Package Tools" (软件包工具) (仅在 SRPM/RPM 文件上右键单击时显示).
    - "显示更新日志"
    - "显示信息"
    - "列出内容"
    - "列出配置文件"
    - "列出依赖项"
    - "列出 [安装|卸载] 脚本"
    - "在此处提取文件"
    - "完整性检查"
    
    Submenú "SSH Tools" (SSH 工具) (在目录上右键单击时显示).
    - "公钥生成" (连接到远程服务器之前的第 1 个强制步骤).
    - "安装公钥" (连接到远程服务器之前的第 2 个强制步骤).
    - "连接到远程服务器"
    - "发送到远程服务器" (仅支持文件).
    - "挂载点到远程目录" (通过 SSH 协议将远程目录挂载/卸载到本地文件系统).
    - "已注册服务器" (显示或编辑以前连接的 IP/主机).
    
    Submenú "SaMBa Tools" (SaMBa 工具) (在目录上右键单击时显示).
    - "SaMBa 共享挂载器" (通过 SMB 协议将远程共享目录挂载/卸载到本地文件系统).
    
    Submenú "Search Tools" (搜索工具) (在目录上右键单击时显示).
    - "在此处搜索" (从选定目录开始递归).
    - "按名称搜索" (在整个文件系统中搜索文件/目录名).
    - "按字符串搜索" (从选定目录开始递归搜索文件内容内部).
    - "搜索数据库统计"
    - "更新搜索数据库"
    - "在此处的修改文件" (从选定目录开始递归，
      显示第二次运行时所有修改过的文件).
    
    Submenú "Security Tools" (安全工具) (在目录上右键单击时显示).
    - "挂载加密目录" (从选定目录挂载加密的虚拟文件系统).
    - "卸载加密目录" (从选定的挂载点目录卸载加密的虚拟文件系统).
    - "加密目录" (在选定目录上创建加密的虚拟文件系统).
    
    Submenú "Security Tools" (安全工具) (在任何文件上右键单击时显示).
    - "安全发送到 Mailx" (文件作为电子邮件附件; 需要 SMTP 服务在 localhost 运行).
    - "加密"
    - "解密"
    - "偏执粉碎器" (以非常安全的方式删除文件).
    
    Submenú "System Tools" (系统工具) (在目录上右键单击时显示).
    - "构建自定义内核" (轻松自定义系统内核，提高系统性能和/或增加硬件支持，仅适用于基于 RHEL 的发行版).
    - "检查内核更新" (仅适用于基于 RHEL 的发行版).
    - "重建 RPM 软件包" (轻松自定义应用程序，提高应用程序性能和/或增加支持，仅适用于基于 RHEL 的发行版).
    - "系统信息"
    - "系统监视器" (显示系统日志故障/错误事件发生时的信息).
    - "进程查看器"
    - "Xorg 配置" (为 X11R7 X 服务器创建配置文件).
    
    Submenú "Terminal Tools" (终端工具) (仅在 shell 脚本/应用程序文件上右键单击时显示).
    - "运行应用程序"
    - "运行应用程序 (Root)"
    
    Submenú "YouTube Tools" (YouTube 工具) (在目录上右键单击时显示).
    - "视频下载器"
    - "视频列表代码收集器"
    - "视频列表下载器"
EOF_DESC_ZH
)
        ;;
    fr) # French
        msg_app_description="Active les fonctionnalités suivantes dans le menu contextuel du clic droit de Dolphin (Gestionnaire de fichiers) sur KDE Plasma 6."
        msg_language_support="Prise en charge linguistique :"
        msg_required_dependencies="Dépendances requises :"
        msg_contributors="Contributeurs :"
        msg_author="Auteur :"
        msg_license="Licence :"
        msg_donate_title="Faire un don 🎔 :"
        msg_donate_text_1="Vous pouvez faire un don pour soutenir les efforts généraux de l'auteur du projet KDE-Services."
        msg_donate_text_2="Les informations sur le destinataire peuvent être trouvées en suivant :"
        msg_donate_thanks="Merci !"
        msg_kdialog_title="À propos de KDE-Services"
        msg_description_block=$(cat << EOF_DESC_FR
    Sous-menu "Actions" => "KDE-Services" (affiché lors du clic droit sur n'importe quel fichier/répertoire).
    - "Ajouter un préfixe d'horodatage au [Nom de fichier|Répertoire]"
    - "Changer l'horodatage de [Fichier|Répertoire]"
    - "Envoyer par courriel"
    - "Info [Audio|Vidéo]" (affiché uniquement lors du clic droit sur n'importe quel fichier audio/vidéo).
    - "Afficher l'état du [Fichier|Répertoire]"
    - "Changer le propriétaire ici" (propriétaire et permission de fichier/répertoire).
    - "Remplacer du texte" (affiché uniquement lors du clic droit sur n'importe quel fichier texte).
    - "Vérification de l'intégrité du fichier compressé" (affiché uniquement lors du clic droit sur n'importe quel fichier compressé).
    - "MKV Extraire le sous-titre" (affiché uniquement lors du clic droit sur un fichier vidéo MKV).
    - "Sous-titre Multiplex" (ne prend en charge que les fichiers vidéo MPEG-2) (affiché uniquement lors du clic droit sur un fichier vidéo MPG).
    - "Remplacer les espaces dans [Nom de fichier|Répertoire]" (par un tiret bas ASCII) (affiché lors du clic droit sur un répertoire).
    
    Sous-menu "Outils AVI" (affiché uniquement lors du clic droit sur un fichier vidéo AVI).
    - "Diviser (par taille)"
    - "Diviser (par plage horaire)"
    
    Sous-menu "Outils Android" (affiché lors du clic droit sur un répertoire).
    - "Gestionnaire de sauvegarde Android" (sauvegarde ou restauration de toutes les applications et données de l'appareil).
    - "Gestionnaire de fichiers Android" (copier fichier/répertoire depuis/vers l'appareil).
    - "Gestionnaire de paquets Android" (installer/désinstaller des applications *.apk).
    - "Gestionnaire de redémarrage Android" (redémarre l'appareil, éventuellement vers le bootloader ou le programme de récupération).
    
    Sous-menu "Outils de sauvegarde" (affiché lors du clic droit sur un répertoire).
    - "Standards" (sauvegarde/restauration des répertoires /etc/ et /root/ ou des configurations générales utilisateur et des applications aMule, AnyDesk, Audacity, Chrome, GnuPG,
      HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
      Tmux, Wine).
    
    Sous-menu "Outils de Somme de Contrôle" (affiché lors du clic droit sur n'importe quel fichier).
    - "MD5 (fort)"
    - "SHA1 (assez fort)"
    - "SHA256 (très fort)"
    - "SHA512 (hautement fort)"
    - "Vérifier la Somme de Contrôle" (fichier de somme de contrôle *.md5/*.sha1/*.sha256/*.sha512).
    
    Sous-menu "Outils Dolphin" (affiché lors du clic droit sur un répertoire).
    - "Se connecter à" (Protocole FTP/SFTP/SMB).
    - "Serveurs Enregistrés" (afficher ou modifier l'IP/l'hôte précédemment connecté).
    - "Espace Disque Utilisé"
    
    Sous-menu "Outils Dropbox" (affiché lors du clic droit sur un répertoire).
    - "Copier vers Dropbox"
    - "Déplacer vers Dropbox"
    - "Copier vers Dropbox Public et obtenir l'URL"
    - "Déplacer vers Dropbox Public et obtenir l'URL"
    - "Obtenir l'URL publique"
    - "Installer le service Dropbox"
    - "Mettre à jour le service Dropbox"
    - "Démarrer le service Dropbox"
    - "Arrêter le service Dropbox"
    - "Activer le démarrage automatique du service Dropbox"
    
    Sous-menu "Outils Graphiques" (affiché uniquement lors du clic droit sur n'importe quel fichier image).
    - "Le Convertisseur" (de divers formats de fichier image à BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
      PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF ou XPM).
    - "Le Redimensionneur" (personnaliser la largeur du cadre de l'image).
    - "16x16 (icône)"
    - "32x32 (icône)"
    - "48x48 (icône)"
    - "64x64 (icône)"
    - "128x128 (icône)"
    - "256x256 (icône)"
    - "300x300 (carnet)"
    - "320x240 (qvga)"
    - "352x288 (cif)"
    - "414x532 (visa)"
    - "480x320 (hvga)"
    - "512x512 (icône)"
    - "532x532 (passeport)"
    - "640x480 (vga)"
    - "720x480 (ntsc)"
    - "800x600 (svga)"
    - "960x540 (qhd)"
    - "1024x768 (xga)"
    - "1280x1024 (sxga)"
    - "1366x768 (wxga)"
    - "1440x900 (wxga)"
    - "1600x1200 (uxga)"
    - "1920x1200 (wuxga)"
    - "2048x1080 (2k)"
    - "2560x2048 (qsxga)"
    - "3200x2048 (wqsxga)"
    - "3840x2400 (wquxga)"
    - "4096x2160 (4k)"
    - "5120x4096 (hsxga)"
    - "6400x4096 (whsxga)"
    - "7680x4800 (whuxga)"
    - "8192x4320 (8k)"
    
    Sous-menu "Outils d'Image ISO-9660" (affiché uniquement lors du clic droit sur un fichier image ISO-9660).
    - "Monter l'Image ISO-9660"
    - "Démonter l'Image ISO-9660"
    - "Vérification d'Intégrité"
    - "Insérer MD5sum"
    - "Afficher MD5sum de l'Image ISO-9660"
    - "Afficher SHA1sum de l'Image ISO-9660"
    - "Afficher SHA256sum de l'Image ISO-9660"
    - "Afficher SHA512sum de l'Image ISO-9660"
    - "Graver l'Image ISO-9660"
    - "Afficher les Infos de l'Image ISO-9660"
    - "Afficher les Infos du Lecteur Optique"
    - "Test-Boot de l'image ISO-9660 (QEMU BIOS)"
    - "Test-Boot de l'image ISO-9660 (QEMU UEFI)"
    - "Test-Boot de l'image ISO-9660 (QEMU UEFI, Secure boot)"
    
    Sous-menu "Outils MEGA" (affiché lors du clic droit sur n'importe quel fichier/répertoire).
    - "Enregistrer un Nouveau Compte"
    - "Sauvegarder les Identifiants de Connexion Utilisateur"
    - "Afficher l'Espace Cloud Disponible"
    - "Créer un Nouveau Dossier à Distance"
    - "Lister les Fichiers Stockés dans le Cloud"
    - "Supprimer les Fichiers Stockés dans le Cloud"
    - "Télécharger des Fichiers vers le Cloud"
    - "Synchroniser [depuis|vers] le Cloud"
    
    Sous-menu "Outils Midnight" (affiché lors du clic droit sur un répertoire).
    - "[Root ~]# mc" (Gestionnaire de fichiers Shell GNU Midnight Commander avec les privilèges de superutilisateur).
    - "[Root ~]# mcedit" (Éditeur de fichiers interne GNU Midnight Commander avec les privilèges de superutilisateur).
    - "[User ~]$ mc" (Gestionnaire de fichiers Shell GNU Midnight Commander avec les privilèges d'utilisateur).
    - "[User ~]$ mcedit" (Éditeur de fichiers interne GNU Midnight Commander avec les privilèges d'utilisateur).
    
    Sous-menu "Outils Multimédia" (affiché lors du clic droit sur un répertoire).
    - "Assembleur DVD" (avec menu).
    - "Convertir des Fichiers Vidéo" (de divers formats de fichier vidéo à MPEG-1, MPEG-2, MPEG-4, AVI,
      VCD, SVCD, DVD, 3GP, FLV ou WebM).
    - "Ajouter un Sous-titre aux Fichiers MP4"
    - "Normalisation du Volume des Fichiers MP3"
    - "Extraire|Convertir une Piste Audio" (de divers formats de fichier audio à MP3, MP3(432Hz),
      FLAC, FLAC 432Hz, OGG ou OGG 432Hz).
    - "Faire Pivoter des Fichiers Vidéo"
    - "Modifier l'Heure des Fichiers Multimédia"
    - "Attacher une Couverture aux Fichiers MP3"
    - "Nettoyer les Métadonnées des Fichiers Multimédia"
    - "Concaténer des Fichiers Multimédia avec le Même Codec"
    - "Construire une Image ISO-9660 à Partir d'Ici" (depuis le répertoire sélectionné).
    - "Clonateur de Disque" (copie binaire du périphérique de disque optique sélectionné vers un fichier image ISO-9660).
    - "Enregistrer Mon Bureau" (enregistrement d'écran vidéo).
    - "Lire la Vidéo à Partir d'Ici" (lire la liste des fichiers vidéo à partir du répertoire sélectionné).
    
    Sous-menu "Outils Réseau" (affiché lors du clic droit sur un répertoire).
    - "Sentinelle de Connexion" (afficher chaque connexion établie aux ports précédemment sélectionnés).
    - "Serveur HTTP" (depuis le répertoire sélectionné).
    - "Sockets d'Écoute"
    
    Sous-menu "Outils PDF" (affiché uniquement lors du clic droit sur un fichier PDF).
    - "Appliquer le Mot de Passe Propriétaire (DRM)"
    - "Appliquer le Mot de Passe Utilisateur (Chiffrer)"
    - "Appliquer DRM + Chiffrer"
    - "Déchiffrer (DRM)"
    - "Réparateur (si possible)"
    - "Extraire les Pages Sélectionnées"
    - "Extraire Toutes les Pages"
    - "Extraire Toutes les Images"
    - "Optimiser"
    - "Compresser"
    - "Voir les Métadonnées"
    - "Modifier les Métadonnées"
    - "Fusionner les Fichiers Sélectionnés"
    - "Diviser en une Seule Page par Fichier"
    - "Information"
    
    Sous-menu "Outils de Paquet" (affiché uniquement lors du clic droit sur un fichier SRPM/RPM).
    - "Afficher le Journal des Modifications"
    - "Afficher les Infos"
    - "Lister le Contenu"
    - "Lister les Fichiers de Configuration"
    - "Lister les Dépendances"
    - "Lister les Scripts d'[Ins|Désins]tallation"
    - "Extraire les Fichiers Ici"
    - "Vérification d'Intégrité"
    
    Sous-menu "Outils SSH" (affiché lors du clic droit sur un répertoire).
    - "Génération de Clé Publique" (1ère étape obligatoire avant de se connecter au serveur distant).
    - "Installer la Clé Publique" (2ème étape obligatoire avant de se connecter au serveur distant).
    - "Se Connecter au Serveur Distant"
    - "Envoyer au Serveur Distant" (ne prend en charge que les fichiers).
    - "Point de Montage vers Répertoire Distant" (monter/démonter le répertoire distant via le protocole SSH sur le système de fichiers local).
    - "Serveurs Enregistrés" (afficher ou modifier l'IP/l'hôte précédemment connecté).
    
    Sous-menu "Outils SaMBa" (affiché lors du clic droit sur un répertoire).
    - "Monteur de Partages SaMBa" (monter/démonter le répertoire partagé distant via le protocole SMB sur le système de fichiers local).
    
    Sous-menu "Outils de Recherche" (affiché lors du clic droit sur un répertoire).
    - "Rechercher Ici" (récursivement à partir du répertoire sélectionné).
    - "Rechercher par Nom" (nom de fichier/répertoire dans tout le système de fichiers).
    - "Rechercher par Chaîne" (récursivement à partir du répertoire sélectionné dans le contenu du fichier).
    - "Statistiques de la Base de Données de Recherche"
    - "Mettre à Jour la Base de Données de Recherche"
    - "Fichiers Modifiés Ici" (récursivement à partir du répertoire sélectionné
      affichant tous les fichiers modifiés par la deuxième exécution).
    
    Sous-menu "Outils de Sécurité" (affiché lors du clic droit sur un répertoire).
    - "Monter le Répertoire Chiffré" (monter un système de fichiers virtuel chiffré depuis le répertoire sélectionné).
    - "Démonter le Répertoire Chiffré" (démonter un système de fichiers virtuel chiffré depuis le répertoire de point de montage sélectionné).
    - "Chiffrer le Répertoire" (créer un système de fichiers virtuel chiffré dans le répertoire sélectionné).
    
    Sous-menu "Outils de Sécurité" (affiché lors du clic droit sur n'importe quel fichier).
    - "Envoyer Sécurisé à Mailx" (fichier en pièce jointe d'un courriel; nécessite le service SMTP en cours d'exécution sur localhost).
    - "Chiffrer"
    - "Déchiffrer"
    - "Déchiqueteur Paranoïaque" (supprimer des fichiers de manière très sécurisée).
    
    Sous-menu "Outils Système" (affiché lors du clic droit sur un répertoire).
    - "Construire un Noyau Personnalisé" (personnaliser facilement le noyau système, augmentant les performances du système
      et/ou ajoutant plus de support matériel, uniquement pour les distributions basées sur RHEL).
    - "Vérifier la Mise à Jour du Noyau" (uniquement pour les distributions basées sur RHEL).
    - "Reconstruire le Paquet RPM" (personnaliser facilement les applications, augmentant les performances des applications
      et/ou ajoutant plus de support, uniquement pour les distributions basées sur RHEL).
    - "Informations Système"
    - "Moniteur Système" (afficher les événements de défaillance/erreur du journal système lorsqu'ils se produisent).
    - "Visionneuse de Processus"
    - "Configurer Xorg" (créer un fichier de configuration pour le serveur X11R7 X).
    
    Sous-menu "Outils de Terminal" (affiché uniquement lors du clic droit sur les scripts shell/fichiers d'application).
    - "Exécuter l'Application"
    - "Exécuter l'Application (Root)"
    
    Sous-menu "Outils YouTube" (affiché lors du clic droit sur un répertoire).
    - "Téléchargeur de Vidéos"
    - "Collecteur de Code de Liste de Vidéos"
    - "Téléchargeur de Liste de Vidéos"
EOF_DESC_FR
)
        ;;
    de) # German
        msg_app_description="Aktiviert die folgenden Funktionen im Kontextmenü des Dolphin (Dateimanager) Rechtsklicks auf KDE Plasma 6."
        msg_language_support="Sprachunterstützung:"
        msg_required_dependencies="Erforderliche Abhängigkeiten:"
        msg_contributors="Mitwirkende:"
        msg_author="Autor:"
        msg_license="Lizenz:"
        msg_donate_title="Spenden 🎔:"
        msg_donate_text_1="Sie können eine Spende tätigen, um die gesamten Bemühungen des Autors des KDE-Services-Projekts zu unterstützen."
        msg_donate_text_2="Die Empfängerinformationen finden Sie unter:"
        msg_donate_thanks="Vielen Dank!"
        msg_kdialog_title="Über KDE-Services"
        msg_description_block=$(cat << EOF_DESC_DE
    Untermenü "Aktionen" => "KDE-Services" (wird beim Rechtsklick auf eine beliebige Datei/ein beliebiges Verzeichnis angezeigt).
    - "Zeitstempel-Präfix zu [Datei|Verzeichnis]name hinzufügen"
    - "Zeitstempel von [Datei|Verzeichnis] ändern"
    - "Per E-Mail senden"
    - "[Audio|Video] Info" (wird nur beim Rechtsklick auf eine beliebige Audio-/Videodatei angezeigt).
    - "[Datei|Verzeichnis] Status anzeigen"
    - "Eigentümer hier ändern" (Datei-/Verzeichniseigentümer und -berechtigung).
    - "Textersetzung" (wird nur beim Rechtsklick auf eine beliebige Textdatei angezeigt).
    - "Integritätsprüfung für komprimierte Dateien" (wird nur beim Rechtsklick auf eine beliebige komprimierte Datei angezeigt).
    - "MKV Untertitel extrahieren" (wird nur beim Rechtsklick auf eine MKV-Videodatei angezeigt).
    - "Untertitel Multiplexen" (unterstützt nur MPEG-2-Videodateien) (wird nur beim Rechtsklick auf eine MPG-Videodatei angezeigt).
    - "[Datei|Verzeichnis]name Leerzeichen ersetzen" (durch ASCII-Unterstrich) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    
    Untermenü "AVI Tools" (AVI-Werkzeuge) (wird nur beim Rechtsklick auf eine AVI-Videodatei angezeigt).
    - "Teilen (nach Größe)"
    - "Teilen (nach Zeitbereich)"
    
    Untermenü "Android Tools" (Android-Werkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "Android Backup Manager" (Sicherung oder Wiederherstellung aller Apps und Daten auf dem Gerät).
    - "Android Datei-Manager" (Datei/Verzeichnis vom/zum Gerät kopieren).
    - "Android Paket-Manager" (installieren/deinstallieren von *.apk-Anwendungen).
    - "Android Neustart-Manager" (startet das Gerät neu, optional im Bootloader oder Wiederherstellungsprogramm).
    
    Untermenü "Backup Tools" (Sicherungswerkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "Standards" (Sicherung/Wiederherstellung von /etc/- und /root/-Verzeichnissen oder aMule, AnyDesk, Audacity, Chrome, GnuPG,
      HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
      Tmux, Wine und allgemeinen Benutzereinstellungen).
    
    Untermenü "CheckSum Tools" (Prüfsummen-Werkzeuge) (wird beim Rechtsklick auf eine beliebige Datei angezeigt).
    - "MD5 (stark)"
    - "SHA1 (ziemlich stark)"
    - "SHA256 (sehr stark)"
    - "SHA512 (höchst stark)"
    - "Prüfsumme verifizieren" (*.md5/*.sha1/*.sha256/*.sha512 Prüfsummendatei).
    
    Untermenü "Dolphin Tools" (Dolphin-Werkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "Verbinden mit" (FTP/SFTP/SMB-Protokoll).
    - "Registrierte Server" (vorher verbundene IP/Host anzeigen oder bearbeiten).
    - "Belegter Speicherplatz"
    
    Untermenü "Dropbox Tools" (Dropbox-Werkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "Nach Dropbox kopieren"
    - "Nach Dropbox verschieben"
    - "Nach öffentliches Dropbox kopieren und URL abrufen"
    - "Nach öffentliches Dropbox verschieben und URL abrufen"
    - "Öffentliche URL abrufen"
    - "Dropbox-Dienst installieren"
    - "Dropbox-Dienst aktualisieren"
    - "Dropbox-Dienst starten"
    - "Dropbox-Dienst stoppen"
    - "Dropbox-Dienst Autostart aktivieren"
    
    Untermenü "Graphic Tools" (Grafik-Werkzeuge) (wird nur beim Rechtsklick auf eine beliebige Bilddatei angezeigt).
    - "Der Konverter" (von verschiedenen Bilddateiformaten nach BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
      PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF oder XPM).
    - "Der Größenänderer" (benutzerdefinierte Bildrahmenbreite).
    - "16x16 (Icon)"
    - "32x32 (Icon)"
    - "48x48 (Icon)"
    - "64x64 (Icon)"
    - "128x128 (Icon)"
    - "256x256 (Icon)"
    - "300x300 (Ausweis)"
    - "320x240 (qvga)"
    - "352x288 (cif)"
    - "414x532 (Visum)"
    - "480x320 (hvga)"
    - "512x512 (Icon)"
    - "532x532 (Reisepass)"
    - "640x480 (vga)"
    - "720x480 (ntsc)"
    - "800x600 (svga)"
    - "960x540 (qhd)"
    - "1024x768 (xga)"
    - "1280x1024 (sxga)"
    - "1366x768 (wxga)"
    - "1440x900 (wxga)"
    - "1600x1200 (uxga)"
    - "1920x1200 (wuxga)"
    - "2048x1080 (2k)"
    - "2560x2048 (qsxga)"
    - "3200x2048 (wqsxga)"
    - "3840x2400 (wquxga)"
    - "4096x2160 (4k)"
    - "5120x4096 (hsxga)"
    - "6400x4096 (whsxga)"
    - "7680x4800 (whuxga)"
    - "8192x4320 (8k)"
    
    Untermenü "ISO-9660 Image Tools" (ISO-9660-Image-Werkzeuge) (wird nur beim Rechtsklick auf eine ISO-9660-Imagedatei angezeigt).
    - "ISO-9660-Image mounten"
    - "ISO-9660-Image unmounten"
    - "Integritätsprüfung"
    - "MD5sum einfügen"
    - "MD5sum des ISO-9660-Images anzeigen"
    - "SHA1sum des ISO-9660-Images anzeigen"
    - "SHA256sum des ISO-9660-Images anzeigen"
    - "SHA512sum des ISO-9660-Images anzeigen"
    - "ISO-9660-Image brennen"
    - "ISO-9660-Image-Info anzeigen"
    - "Info zum optischen Laufwerk anzeigen"
    - "ISO-9660 Test-Boot (QEMU BIOS)"
    - "ISO-9660 Test-Boot (QEMU UEFI)"
    - "ISO-9660 Test-Boot (QEMU UEFI, Secure boot)"
    
    Untermenü "MEGA Tools" (MEGA-Werkzeuge) (wird beim Rechtsklick auf eine beliebige Datei/ein beliebiges Verzeichnis angezeigt).
    - "Neues Konto registrieren"
    - "Benutzeranmeldeinformationen speichern"
    - "Verfügbaren Cloud-Speicher anzeigen"
    - "Neuen Remote-Ordner erstellen"
    - "Im Cloud gespeicherte Dateien auflisten"
    - "Im Cloud gespeicherte Dateien entfernen"
    - "Dateien in den Cloud hochladen"
    - "Synchronisieren [von|zum] Cloud"
    
    Untermenü "Midnight Tools" (Midnight-Werkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "[Root ~]# mc" (Shell-Dateimanager GNU Midnight Commander mit Superuser-Berechtigungen).
    - "[Root ~]# mcedit" (Interner Dateieditor von GNU Midnight Commander mit Superuser-Berechtigungen).
    - "[User ~]$ mc" (Shell-Dateimanager GNU Midnight Commander mit Benutzerberechtigungen).
    - "[User ~]$ mcedit" (Interner Dateieditor von GNU Midnight Commander mit Benutzerberechtigungen).
    
    Untermenü "Multimedia Tools" (Multimedia-Werkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "DVD-Assembler" (mit Menü).
    - "Video-Dateien konvertieren" (von verschiedenen Videodateiformaten nach MPEG-1, MPEG-2, MPEG-4, AVI,
      VCD, SVCD, DVD, 3GP, FLV oder WebM).
    - "Untertitel zu MP4-Dateien hinzufügen"
    - "Lautstärke-Normalisierung von MP3-Dateien"
    - "Audiospur extrahieren|konvertieren" (von verschiedenen Audiodatenformaten nach MP3, MP3(432Hz),
      FLAC, FLAC 432Hz, OGG oder OGG 432Hz).
    - "Video-Dateien drehen"
    - "Zeit von Mediendateien bearbeiten"
    - "Cover an MP3-Dateien anhängen"
    - "Metadaten von Mediendateien bereinigen"
    - "Mediendateien mit gleichem Codec verketten"
    - "ISO-9660-Image von hier erstellen" (vom ausgewählten Verzeichnis).
    - "DiskCloner" (binäre Kopie vom ausgewählten optischen Laufwerk zu einer ISO-9660-Imagedatei).
    - "Meinen Desktop aufnehmen" (Video-Bildschirmaufnahme).
    - "Video von hier abspielen" (Wiedergabe der Liste der Videodateien aus dem ausgewählten Verzeichnis).
    
    Untermenü "Network Tools" (Netzwerk-Werkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "Verbindungs-Wächter" (jede zum zuvor ausgewählten Port hergestellte Verbindung anzeigen).
    - "HTTP-Server" (vom ausgewählten Verzeichnis).
    - "Listening Sockets" (Abhör-Sockets)
    
    Untermenü "PDF Tools" (PDF-Werkzeuge) (wird nur beim Rechtsklick auf eine PDF-Datei angezeigt).
    - "Eigentümerpasswort anwenden (DRM)"
    - "Benutzerpasswort anwenden (Verschlüsseln)"
    - "DRM + Verschlüsseln anwenden"
    - "Entschlüsseln (DRM)"
    - "Reparatur (wenn möglich)"
    - "Ausgewählte Seiten extrahieren"
    - "Alle Seiten extrahieren"
    - "Alle Bilder extrahieren"
    - "Optimieren"
    - "Komprimieren"
    - "Metadaten anzeigen"
    - "Metadaten bearbeiten"
    - "Ausgewählte Dateien zusammenführen"
    - "In einzelne Seiten pro Datei aufteilen"
    - "Information"
    
    Untermenü "Package Tools" (Paket-Werkzeuge) (wird nur beim Rechtsklick auf eine SRPM/RPM-Datei angezeigt).
    - "Changelog anzeigen"
    - "Info anzeigen"
    - "Inhalt auflisten"
    - "Konfigurationsdateien auflisten"
    - "Abhängigkeiten auflisten"
    - "Installations-/Deinstallationsskripte auflisten"
    - "Dateien hier extrahieren"
    - "Integritätsprüfung"
    
    Untermenü "SSH Tools" (SSH-Werkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "Generierung öffentlicher Schlüssel" (1. obligatorischer Schritt vor der Verbindung zum Remote-Server).
    - "Öffentlichen Schlüssel installieren" (2. obligatorischer Schritt vor der Verbindung zum Remote-Server).
    - "Mit Remote-Server verbinden"
    - "An Remote-Server senden" (unterstützt nur Dateien).
    - "Mount-Punkt zu Remote-Verzeichnis" (Remote-Verzeichnis über SSH-Protokoll in das lokale Dateisystem mounten/unmounten).
    - "Registrierte Server" (vorher verbundene IP/Host anzeigen oder bearbeiten).
    
    Untermenü "SaMBa Tools" (SaMBa-Werkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "SaMBa-Freigaben-Mounten" (Remote-Freigabeverzeichnis über SMB-Protokoll in das lokale Dateisystem mounten/unmounten).
    
    Untermenü "Search Tools" (Suchwerkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "Hier suchen" (rekursiv, beginnend im ausgewählten Verzeichnis).
    - "Nach Name suchen" (Datei-/Verzeichnisname im gesamten Dateisystem).
    - "Nach Zeichenkette suchen" (rekursiv, beginnend im ausgewählten Verzeichnis im Dateiinhalt).
    - "Suchdatenbank-Statistiken"
    - "Suchdatenbank aktualisieren"
    - "Hier geänderte Dateien" (rekursiv, beginnend im ausgewählten Verzeichnis,
      Anzeige aller Dateien, die beim zweiten Ausführen geändert wurden).
    
    Untermenü "Security Tools" (Sicherheitswerkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "Verschlüsseltes Verzeichnis mounten" (ein verschlüsseltes virtuelles Dateisystem aus dem ausgewählten Verzeichnis mounten).
    - "Verschlüsseltes Verzeichnis unmounten" (ein verschlüsseltes virtuelles Dateisystem aus dem ausgewählten Mount-Punkt-Verzeichnis unmounten).
    - "Verzeichnis verschlüsseln" (ein verschlüsseltes virtuelles Dateisystem im ausgewählten Verzeichnis erstellen).
    
    Untermenü "Security Tools" (Sicherheitswerkzeuge) (wird beim Rechtsklick auf eine beliebige Datei angezeigt).
    - "Sicher an Mailx senden" (Datei als E-Mail-Anhang; erfordert laufenden SMTP-Dienst auf localhost).
    - "Verschlüsseln"
    - "Entschlüsseln"
    - "Paranoider Schredder" (Dateien auf sehr sichere Weise löschen).
    
    Untermenü "System Tools" (Systemwerkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "Benutzerdefinierten Kernel bauen" (einfache Anpassung des Systemkernels, Steigerung der Systemleistung
      und/oder Hinzufügen weiterer Hardware-Unterstützung, nur für RHEL-basierte Distributionen).
    - "Kernel-Update prüfen" (nur für RHEL-basierte Distributionen).
    - "RPM-Paket neu bauen" (einfache Anpassung von Anwendungen, Steigerung der Anwendungsleistung
      und/oder Hinzufügen weiterer Unterstützung, nur für RHEL-basierte Distributionen).
    - "Systeminformationen"
    - "Systemmonitor" (Anzeige von Systemprotokoll-Fehler-/Störungsereignissen, wenn sie auftreten).
    - "Prozess-Viewer"
    - "Xorg konfigurieren" (eine Konfigurationsdatei für den X11R7 X Server erstellen).
    
    Untermenü "Terminal Tools" (Terminal-Werkzeuge) (wird nur beim Rechtsklick auf Shell-Skripte/Anwendungsdateien angezeigt).
    - "Anwendung ausführen"
    - "Anwendung ausführen (Root)"
    
    Untermenü "YouTube Tools" (YouTube-Werkzeuge) (wird beim Rechtsklick auf ein Verzeichnis angezeigt).
    - "Video-Downloader"
    - "Video-Listen-Code-Sammler"
    - "Video-Listen-Downloader"
EOF_DESC_DE
)
        ;;
    it) # Italian
        msg_app_description="Abilita le seguenti funzionalità nel menu contestuale del clic destro di Dolphin (File Manager) su KDE Plasma 6."
        msg_language_support="Supporto linguistico:"
        msg_required_dependencies="Dipendenze richieste:"
        msg_contributors="Collaboratori:"
        msg_author="Autore:"
        msg_license="Licenza:"
        msg_donate_title="Dona 🎔:"
        msg_donate_text_1="Puoi fare una donazione per sostenere gli sforzi complessivi dell'autore del progetto KDE-Services."
        msg_donate_text_2="Le informazioni sul destinatario sono disponibili qui:"
        msg_donate_thanks="Grazie!"
        msg_kdialog_title="Informazioni su KDE-Services"
        msg_description_block=$(cat << EOF_DESC_IT
    Sottomenu "Azioni" => "KDE-Services" (mostrato al clic destro su qualsiasi file/directory).
    - "Aggiungi Prefisso Timestamp a [Nome File|Directory]"
    - "Cambia Timestamp a [File|Directory]"
    - "Invia tramite Email"
    - "Info [Audio|Video]" (mostrato solo al clic destro su qualsiasi file audio/video).
    - "Mostra Stato [File|Directory]"
    - "Cambia Proprietario Qui" (proprietario e permesso di file/directory).
    - "Sostituzione Testo" (mostrato solo al clic destro su qualsiasi file di testo).
    - "Controllo di Integrità File Compresso" (mostrato solo al clic destro su qualsiasi file compresso).
    - "MKV Estrai Sottotitolo" (mostrato solo al clic destro su file video MKV).
    - "Sottotitolo Multiplex" (supporta solo file video MPEG-2) (mostrato solo al clic destro su file video MPG).
    - "Sostituzione Spazi in [Nome File|Directory]" (con underscore ASCII) (mostrato al clic destro su una directory).
    
    Sottomenu "Strumenti AVI" (mostrato solo al clic destro su file video AVI).
    - "Dividi (per dimensione)"
    - "Dividi (per intervallo di tempo)"
    
    Sottomenu "Strumenti Android" (mostrato al clic destro su una directory).
    - "Gestore Backup Android" (backup o ripristino di tutte le app e i dati del dispositivo).
    - "Gestore File Android" (copia file/directory da/verso il dispositivo).
    - "Gestore Pacchetti Android" (installa/disinstalla applicazioni *.apk).
    - "Gestore Riavvio Android" (riavvia il dispositivo, opzionalmente in bootloader o programma di ripristino).
    
    Sottomenu "Strumenti di Backup" (mostrato al clic destro su una directory).
    - "Standard" (backup/ripristino delle directory /etc/ e /root/ o aMule, AnyDesk, Audacity, Chrome, GnuPG,
      HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
      Tmux, Wine e configurazioni generali utente).
    
    Sottomenu "Strumenti CheckSum" (mostrato al clic destro su qualsiasi file).
    - "MD5 (forte)"
    - "SHA1 (abbastanza forte)"
    - "SHA256 (molto forte)"
    - "SHA512 (altamente forte)"
    - "Verifica CheckSum" (file checksum *.md5/*.sha1/*.sha256/*.sha512).
    
    Sottomenu "Strumenti Dolphin" (mostrato al clic destro su una directory).
    - "Connetti a" (protocollo FTP/SFTP/SMB).
    - "Server Registrati" (mostra o modifica IP/Host precedentemente connesso).
    - "Spazio Disco Utilizzato"
    
    Sottomenu "Strumenti Dropbox" (mostrato al clic destro su una directory).
    - "Copia su Dropbox"
    - "Sposta su Dropbox"
    - "Copia su Dropbox Pubblico e ottieni URL"
    - "Sposta su Dropbox Pubblico e ottieni URL"
    - "Ottieni URL pubblico"
    - "Installa servizio Dropbox"
    - "Aggiorna servizio Dropbox"
    - "Avvia servizio Dropbox"
    - "Ferma servizio Dropbox"
    - "Abilita avvio automatico servizio Dropbox"
    
    Sottomenu "Strumenti Grafici" (mostrato solo al clic destro su qualsiasi file immagine).
    - "Il Convertitore" (da vari formati di file immagine a BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
      PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF o XPM).
    - "Il Ridimensionatore" (personalizza la larghezza del frame dell'immagine).
    - "16x16 (icona)"
    - "32x32 (icona)"
    - "48x48 (icona)"
    - "64x64 (icona)"
    - "128x128 (icona)"
    - "256x256 (icona)"
    - "300x300 (tessera)"
    - "320x240 (qvga)"
    - "352x288 (cif)"
    - "414x532 (visto)"
    - "480x320 (hvga)"
    - "512x512 (icona)"
    - "532x532 (passaporto)"
    - "640x480 (vga)"
    - "720x480 (ntsc)"
    - "800x600 (svga)"
    - "960x540 (qhd)"
    - "1024x768 (xga)"
    - "1280x1024 (sxga)"
    - "1366x768 (wxga)"
    - "1440x900 (wxga)"
    - "1600x1200 (uxga)"
    - "1920x1200 (wuxga)"
    - "2048x1080 (2k)"
    - "2560x2048 (qsxga)"
    - "3200x2048 (wqsxga)"
    - "3840x2400 (wquxga)"
    - "4096x2160 (4k)"
    - "5120x4096 (hsxga)"
    - "6400x4096 (whsxga)"
    - "7680x4800 (whuxga)"
    - "8192x4320 (8k)"
    
    Sottomenu "Strumenti Immagine ISO-9660" (mostrato solo al clic destro su file immagine ISO-9660).
    - "Monta Immagine ISO-9660"
    - "Smonta Immagine ISO-9660"
    - "Controllo di Integrità"
    - "Inserisci MD5sum"
    - "Mostra MD5sum Immagine ISO-9660"
    - "Mostra SHA1sum Immagine ISO-9660"
    - "Mostra SHA256sum Immagine ISO-9660"
    - "Mostra SHA512sum Immagine ISO-9660"
    - "Masterizza Immagine ISO-9660"
    - "Mostra Info Immagine ISO-9660"
    - "Mostra Info Unità Ottica"
    - "Test-Boot di immagine ISO-9660 (QEMU BIOS)"
    - "Test-Boot di immagine ISO-9660 (QEMU UEFI)"
    - "Test-Boot di immagine ISO-9660 (QEMU UEFI, Secure boot)"
    
    Sottomenu "Strumenti MEGA" (mostrato al clic destro su qualsiasi file/directory).
    - "Registra Nuovo Account"
    - "Salva Credenziali di Accesso Utente"
    - "Mostra Spazio Cloud Disponibile"
    - "Crea Nuova Cartella Remota"
    - "Elenca File Archiviati nel Cloud"
    - "Rimuovi File Archiviati nel Cloud"
    - "Carica File su Cloud"
    - "Sincronizza [da|a] Cloud"
    
    Sottomenu "Strumenti Midnight" (mostrato al clic destro su una directory).
    - "[Root ~]# mc" (Shell file manager GNU Midnight Commander con privilegi di superutente).
    - "[Root ~]# mcedit" (Editor di file interno di GNU Midnight Commander con privilegi di superutente).
    - "[User ~]$ mc" (Shell file manager GNU Midnight Commander con privilegi di utente).
    - "[User ~]$ mcedit" (Editor di file interno di GNU Midnight Commander con privilegi di utente).
    
    Sottomenu "Strumenti Multimediali" (mostrato al clic destro su una directory).
    - "Assemblatore DVD" (con menu).
    - "Converti File Video" (da vari formati di file video a MPEG-1, MPEG-2, MPEG-4, AVI,
      VCD, SVCD, DVD, 3GP, FLV o WebM).
    - "Aggiungi Sottotitolo a File MP4"
    - "Normalizzazione Volume File MP3"
    - "Estrai|Converti Traccia Audio" (da vari formati di file audio a MP3, MP3(432Hz),
      FLAC, FLAC 432Hz, OGG o OGG 432Hz).
    - "Ruota File Video"
    - "Modifica Tempo da File Multimediali"
    - "Allega Copertina a File MP3"
    - "Pulisci Metadati da File Multimediali"
    - "Concatena File Multimediali con Stesso Codec"
    - "Crea Immagine ISO-9660 da Qui" (dalla directory selezionata).
    - "Clonatore Disco" (copia binaria dal dispositivo disco ottico selezionato a un file immagine ISO-9660).
    - "Registra il Mio Desktop" (registrazione schermo video).
    - "Riproduci Video da Qui" (riproduci l'elenco dei file video dalla directory selezionata).
    
    Sottomenu "Strumenti di Rete" (mostrato al clic destro su una directory).
    - "Sentinella di Connessione" (mostra ogni connessione stabilita alle porte precedentemente selezionate).
    - "Server HTTP" (dalla directory selezionata).
    - "Socket in Ascolto"
    
    Sottomenu "Strumenti PDF" (mostrato solo al clic destro su file PDF).
    - "Applica Password Proprietario (DRM)"
    - "Applica Password Utente (Cripta)"
    - "Applica DRM + Cripta"
    - "Decripta (DRM)"
    - "Riparatore (se possibile)"
    - "Estrai Pagine Selezionate"
    - "Estrai Tutte le Pagine"
    - "Estrai Tutte le Immagini"
    - "Ottimizza"
    - "Comprimi"
    - "Visualizza Metadati"
    - "Modifica Metadati"
    - "Unisci File Selezionati"
    - "Dividi in Pagina Singola per File"
    - "Informazioni"
    
    Sottomenu "Strumenti Pacchetti" (mostrato solo al clic destro su file SRPM/RPM).
    - "Mostra Changelog"
    - "Mostra Info"
    - "Elenca Contenuto"
    - "Elenca File di Configurazione"
    - "Elenca Dipendenze"
    - "Elenca Script di [Ins|Disins]tallazione"
    - "Estrai File Qui"
    - "Controllo di Integrità"
    
    Sottomenu "Strumenti SSH" (mostrato al clic destro su una directory).
    - "Generazione Chiave Pubblica" (1° passo obbligatorio prima di connettersi al server remoto).
    - "Installa Chiave Pubblica" (2° passo obbligatorio prima di connettersi al server remoto).
    - "Connetti a Server Remoto"
    - "Invia a Server Remoto" (supporta solo file).
    - "Punto di Montaggio a Directory Remota" (monta/smonta directory remota tramite protocollo SSH nel filesystem locale).
    - "Server Registrati" (mostra o modifica IP/Host precedentemente connesso).
    
    Sottomenu "Strumenti SaMBa" (mostrato al clic destro su una directory).
    - "Montatore Condivisioni SaMBa" (monta/smonta directory condivisa remota tramite protocollo SMB nel filesystem locale).
    
    Sottomenu "Strumenti di Ricerca" (mostrato al clic destro su una directory).
    - "Cerca Qui" (ricorsivamente a partire dalla directory selezionata).
    - "Cerca per Nome" (nome di file/directory in tutto il filesystem).
    - "Cerca per Stringa" (ricorsivamente a partire dalla directory selezionata all'interno del contenuto del file).
    - "Statistiche Database di Ricerca"
    - "Aggiorna Database di Ricerca"
    - "File Modificati Qui" (ricorsivamente a partire dalla directory selezionata
      mostrando tutti i file modificati dalla seconda esecuzione).
    
    Sottomenu "Strumenti di Sicurezza" (mostrato al clic destro su una directory).
    - "Monta Directory Criptata" (monta un filesystem virtuale criptato dalla directory selezionata).
    - "Smonta Directory Criptata" (smonta un filesystem virtuale criptato dalla directory del punto di montaggio selezionato).
    - "Cripta Directory" (crea un filesystem virtuale criptato nella directory selezionata).
    
    Sottomenu "Strumenti di Sicurezza" (mostrato al clic destro su qualsiasi file).
    - "Invio Sicuro a Mailx" (file come allegato email; richiede il servizio SMTP in esecuzione su localhost).
    - "Cripta"
    - "Decripta"
    - "Trituratore Paranoico" (elimina i file in modo molto sicuro).
    
    Sottomenu "Strumenti di Sistema" (mostrato al clic destro su una directory).
    - "Costruisci Kernel Personalizzato" (personalizza facilmente il kernel di sistema, aumentando le prestazioni di sistema
      e/o aggiungendo più supporto hardware, solo per distro basate su RHEL).
    - "Controlla Aggiornamento Kernel" (solo per distro basate su RHEL).
    - "Ricostruisci Pacchetto RPM" (personalizza facilmente le applicazioni, aumentando le prestazioni delle applicazioni
      e/o aggiungendo più supporto, solo per distro basate su RHEL).
    - "Informazioni di Sistema"
    - "Monitor di Sistema" (mostra gli eventi di errore/guasto del registro di sistema quando si verificano).
    - "Visualizzatore Processi"
    - "Configura Xorg" (crea un file di configurazione per il server X11R7 X).
    
    Sottomenu "Strumenti Terminale" (mostrato solo al clic destro su script shell/file di applicazione).
    - "Esegui Applicazione"
    - "Esegui Applicazione (Root)"
    
    Sottomenu "Strumenti YouTube" (mostrato al clic destro su una directory).
    - "Scaricatore Video"
    - "Collezionista Codice Lista Video"
    - "Scaricatore Lista Video"
EOF_DESC_IT
)
        ;;
    ja) # Japanese
        msg_app_description="KDE Plasma 6 の Dolphin（ファイルマネージャー）の右クリックコンテキストメニューで、以下の機能を有効にします。"
        msg_language_support="対応言語:"
        msg_required_dependencies="必要な依存関係:"
        msg_contributors="貢献者:"
        msg_author="作者:"
        msg_license="ライセンス:"
        msg_donate_title="寄付 🎔:"
        msg_donate_text_1="KDE-Services プロジェクトの作者の全体的な取り組みを支援するために寄付をすることができます。"
        msg_donate_text_2="受取人の情報は以下で見つけることができます:"
        msg_donate_thanks="ありがとうございます！"
        msg_kdialog_title="KDE-Services について"
        msg_description_block=$(cat << EOF_DESC_JA
    サブメニュー "アクション" => "KDE-サービス" (任意のファイル/ディレクトリを右クリックしたときに表示されます)。
    - "[ファイル|ディレクトリ]名にタイムスタンプのプレフィックスを追加"
    - "[ファイル|ディレクトリ]のタイムスタンプを変更"
    - "メールで送信"
    - "[オーディオ|ビデオ]情報" (任意のオーディオ/ビデオファイルを右クリックしたときにのみ表示されます)。
    - "[ファイル|ディレクトリ]のステータスを表示"
    - "ここで所有者を変更" (ファイル/ディレクトリの所有者と権限)。
    - "テキスト置換" (任意のテキストファイルを右クリックしたときにのみ表示されます)。
    - "圧縮ファイルの整合性チェック" (任意の圧縮ファイルを右クリックしたときにのみ表示されます)。
    - "MKV 字幕を抽出" (MKV ビデオファイルを右クリックしたときにのみ表示されます)。
    - "字幕を多重化" (MPEG-2 ビデオファイルのみサポート) (MPG ビデオファイルを右クリックしたときにのみ表示されます)。
    - "[ファイル|ディレクトリ]名の空白を置換" (ASCII アンダーバーに) (ディレクトリを右クリックしたときに表示されます)。
    
    サブメニュー "AVI ツール" (AVI ビデオファイルを右クリックしたときにのみ表示されます)。
    - "分割 (サイズ指定)"
    - "分割 (時間範囲指定)"
    
    サブメニュー "Android ツール" (ディレクトリを右クリックしたときに表示されます)。
    - "Android バックアップマネージャー" (デバイス上のすべてのアプリとデータのバックアップまたは復元)。
    - "Android ファイルマネージャー" (デバイスとの間でファイル/ディレクトリをコピー)。
    - "Android パッケージマネージャー" (*.apk アプリケーションのインストール/アンインストール)。
    - "Android 再起動マネージャー" (デバイスを再起動、オプションでブートローダーまたはリカバリプログラムへ)。
    
    サブメニュー "バックアップツール" (ディレクトリを右クリックしたときに表示されます)。
    - "標準" (/etc/ および /root/ ディレクトリ、または aMule, AnyDesk, Audacity, Chrome, GnuPG,
      HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
      Tmux, Wine および一般ユーザー設定のバックアップ/復元)。
    
    サブメニュー "チェックサムツール" (任意のファイルを右クリックしたときに表示されます)。
    - "MD5 (強力)"
    - "SHA1 (かなり強力)"
    - "SHA256 (非常に強力)"
    - "SHA512 (極めて強力)"
    - "チェックサムを検証" (*.md5/*.sha1/*.sha256/*.sha512 チェックサムファイル)。
    
    サブメニュー "Dolphin ツール" (ディレクトリを右クリックしたときに表示されます)。
    - "接続先" (FTP/SFTP/SMB プロトコル)。
    - "登録済みサーバー" (以前接続した IP/ホストを表示または編集)。
    - "使用済みディスク容量"
    
    サブメニュー "Dropbox ツール" (ディレクトリを右クリックしたときに表示されます)。
    - "Dropbox にコピー"
    - "Dropbox に移動"
    - "公開 Dropbox にコピーして URL を取得"
    - "公開 Dropbox に移動して URL を取得"
    - "公開 URL を取得"
    - "Dropbox サービスをインストール"
    - "Dropbox サービスを更新"
    - "Dropbox サービスを開始"
    - "Dropbox サービスを停止"
    - "Dropbox サービスを自動起動を有効にする"
    
    サブメニュー "グラフィックツール" (任意の画像ファイルを右クリックしたときにのみ表示されます)。
    - "コンバーター" (さまざまな画像ファイル形式を BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
      PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF または XPM に変換)。
    - "リサイザー" (画像フレームの幅をカスタマイズ)。
    - "16x16 (アイコン)"
    - "32x32 (アイコン)"
    - "48x48 (アイコン)"
    - "64x64 (アイコン)"
    - "128x128 (アイコン)"
    - "256x256 (アイコン)"
    - "300x300 (証明写真)"
    - "320x240 (qvga)"
    - "352x288 (cif)"
    - "414x532 (ビザ)"
    - "480x320 (hvga)"
    - "512x512 (アイコン)"
    - "532x532 (パスポート)"
    - "640x480 (vga)"
    - "720x480 (ntsc)"
    - "800x600 (svga)"
    - "960x540 (qhd)"
    - "1024x768 (xga)"
    - "1280x1024 (sxga)"
    - "1366x768 (wxga)"
    - "1440x900 (wxga)"
    - "1600x1200 (uxga)"
    - "1920x1200 (wuxga)"
    - "2048x1080 (2k)"
    - "2560x2048 (qsxga)"
    - "3200x2048 (wqsxga)"
    - "3840x2400 (wquxga)"
    - "4096x2160 (4k)"
    - "5120x4096 (hsxga)"
    - "6400x4096 (whsxga)"
    - "7680x4800 (whuxga)"
    - "8192x4320 (8k)"
    
    サブメニュー "ISO-9660 イメージツール" (ISO-9660 イメージファイルを右クリックしたときにのみ表示されます)。
    - "ISO-9660 イメージをマウント"
    - "ISO-9660 イメージをアンマウント"
    - "整合性チェック"
    - "MD5sum を挿入"
    - "ISO-9660 イメージの MD5sum を表示"
    - "ISO-9660 イメージの SHA1sum を表示"
    - "ISO-9660 イメージの SHA256sum を表示"
    - "ISO-9660 イメージの SHA512sum を表示"
    - "ISO-9660 イメージを書き込み"
    - "ISO-9660 イメージ情報を表示"
    - "光ディスクドライブ情報を表示"
    - "ISO-9660 をテスト起動 (QEMU BIOS)"
    - "ISO-9660 をテスト起動 (QEMU UEFI)"
    - "ISO-9660 をテスト起動 (QEMU UEFI, Secure boot)"
    
    サブメニュー "MEGA ツール" (任意のファイル/ディレクトリを右クリックしたときに表示されます)。
    - "新しいアカウントを登録"
    - "ユーザーログイン認証情報を保存"
    - "利用可能なクラウドスペースを表示"
    - "新しいリモートフォルダを作成"
    - "クラウドに保存されているファイルを一覧表示"
    - "クラウドに保存されているファイルを削除"
    - "クラウドにファイルをアップロード"
    - "クラウドと [から|へ] 同期"
    
    サブメニュー "Midnight ツール" (ディレクトリを右クリックしたときに表示されます)。
    - "[Root ~]# mc" (スーパーユーザー権限を持つシェルファイルマネージャー GNU Midnight Commander)。
    - "[Root ~]# mcedit" (スーパーユーザー権限を持つ GNU Midnight Commander の内部ファイルエディター)。
    - "[User ~]$ mc" (ユーザー権限を持つシェルファイルマネージャー GNU Midnight Commander)。
    - "[User ~]$ mcedit" (ユーザー権限を持つ GNU Midnight Commander の内部ファイルエディター)。
    
    サブメニュー "マルチメディアツール" (ディレクトリを右クリックしたときに表示されます)。
    - "DVD アセンブラ" (メニュー付き)。
    - "ビデオファイルを変換" (さまざまなビデオファイル形式を MPEG-1, MPEG-2, MPEG-4, AVI,
      VCD, SVCD, DVD, 3GP, FLV または WebM に変換)。
    - "MP4 ファイルに字幕を追加"
    - "MP3 ファイルの音量を正規化"
    - "オーディオトラックを抽出|変換" (さまざまなオーディオファイル形式を MP3, MP3(432Hz),
      FLAC, FLAC 432Hz, OGG または OGG 432Hz に変換)。
    - "ビデオファイルを回転"
    - "メディアファイルから時間を編集"
    - "MP3 ファイルにカバーを添付"
    - "メディアファイルからメタデータをクリーンアップ"
    - "同じコーデックのメディアファイルを連結"
    - "ここから ISO-9660 イメージをビルド" (選択したディレクトリから)。
    - "ディスククローナー" (選択した光ディスクデバイスから ISO-9660 イメージファイルへのバイナリコピー)。
    - "デスクトップを録画" (ビデオ画面録画)。
    - "ここからビデオを再生" (選択したディレクトリからビデオファイルのリストを再生)。
    
    サブメニュー "ネットワークツール" (ディレクトリを右クリックしたときに表示されます)。
    - "接続センチネル" (以前選択したポートへの確立された各接続を表示)。
    - "HTTP サーバー" (選択したディレクトリから)。
    - "リスニングソケット"
    
    サブメニュー "PDF ツール" (PDF ファイルを右クリックしたときにのみ表示されます)。
    - "所有者パスワードを適用 (DRM)"
    - "ユーザーパスワードを適用 (暗号化)"
    - "DRM + 暗号化を適用"
    - "復号化 (DRM)"
    - "修復 (可能な場合)"
    - "選択したページを抽出"
    - "すべてのページを抽出"
    - "すべての画像を抽出"
    - "最適化"
    - "圧縮"
    - "メタデータを表示"
    - "メタデータを編集"
    - "選択したファイルを結合"
    - "ファイルごとに単一ページに分割"
    - "情報"
    
    サブメニュー "パッケージツール" (SRPM/RPM ファイルを右クリックしたときにのみ表示されます)。
    - "チェンジログを表示"
    - "情報を表示"
    - "内容を一覧表示"
    - "設定ファイルを一覧表示"
    - "依存関係を一覧表示"
    - "[インストール|アンインストール] スクリプトを一覧表示"
    - "ここにファイルを抽出"
    - "整合性チェック"
    
    サブメニュー "SSH ツール" (ディレクトリを右クリックしたときに表示されます)。
    - "公開鍵の生成" (リモートサーバーに接続する前の最初の必須ステップ)。
    - "公開鍵をインストール" (リモートサーバーに接続する前の2番目の必須ステップ)。
    - "リモートサーバーに接続"
    - "リモートサーバーに送信" (ファイルのみサポート)。
    - "リモートディレクトリへのマウントポイント" (SSH プロトコルを介してリモートディレクトリをローカルファイルシステムにマウント/アンマウント)。
    - "登録済みサーバー" (以前接続した IP/ホストを表示または編集)。
    
    サブメニュー "SaMBa ツール" (ディレクトリを右クリックしたときに表示されます)。
    - "SaMBa 共有マウンター" (SMB プロトコルを介してリモート共有ディレクトリをローカルファイルシステムにマウント/アンマウント)。
    
    サブメニュー "検索ツール" (ディレクトリを右クリックしたときに表示されます)。
    - "ここで検索" (選択したディレクトリから再帰的に)。
    - "名前で検索" (ファイルシステム全体のファイル/ディレクトリ名)。
    - "文字列で検索" (選択したディレクトリから再帰的にファイル内容の内部を検索)。
    - "検索データベースの統計"
    - "検索データベースを更新"
    - "ここで変更されたファイル" (選択したディレクトリから再帰的に、
      2回目の実行で変更されたすべてのファイルを表示)。
    
    サブメニュー "セキュリティツール" (ディレクトリを右クリックしたときに表示されます)。
    - "暗号化されたディレクトリをマウント" (選択したディレクトリから暗号化された仮想ファイルシステムをマウント)。
    - "暗号化されたディレクトリをアンマウント" (選択したマウントポイントディレクトリから暗号化された仮想ファイルシステムをアンマウント)。
    - "ディレクトリを暗号化" (選択したディレクトリに暗号化された仮想ファイルシステムを作成)。
    
    サブメニュー "セキュリティツール" (任意のファイルを右クリックしたときに表示されます)。
    - "Mailx に安全に送信" (電子メール添付ファイルとして。localhost で SMTP サービスが実行されている必要があります)。
    - "暗号化"
    - "復号化"
    - "偏執的なシュレッダー" (ファイルを非常に安全な方法で削除)。
    
    サブメニュー "システムツール" (ディレクトリを右クリックしたときに表示されます)。
    - "カスタムカーネルのビルド" (システムカーネルを簡単にカスタマイズし、システムパフォーマンスを向上
      および/またはより多くのハードウェアサポートを追加。RHEL ベースのディストリビューションのみ)。
    - "カーネルアップデートをチェック" (RHEL ベースのディストリビューションのみ)。
    - "RPM パッケージを再構築" (アプリケーションを簡単にカスタマイズし、アプリケーションパフォーマンスを向上
      および/またはより多くのサポートを追加。RHEL ベースのディストリビューションのみ)。
    - "システム情報"
    - "システムモニター" (システムログの障害/エラーイベントが発生したときに表示)。
    - "プロセスビューア"
    - "Xorg 設定" (X11R7 X サーバーの構成ファイルを作成)。
    
    サブメニュー "ターミナルツール" (シェルスクリプト/アプリケーションファイルを右クリックしたときにのみ表示されます)。
    - "アプリケーションを実行"
    - "アプリケーションを実行 (ルート)"
    
    サブメニュー "YouTube ツール" (ディレクトリを右クリックしたときに表示されます)。
    - "動画ダウンローダー"
    - "動画リストコードコレクター"
    - "動画リストダウンローダー"
EOF_DESC_JA
)
        ;;
    ko) # Korean
        msg_app_description="KDE Plasma 6의 Dolphin(파일 관리자) 마우스 오른쪽 버튼 메뉴에서 다음 기능을 활성화합니다."
        msg_language_support="언어 지원:"
        msg_required_dependencies="필수 종속성:"
        msg_contributors="기여자:"
        msg_author="저자:"
        msg_license="라이선스:"
        msg_donate_title="기부 🎔:"
        msg_donate_text_1="KDE-Services 프로젝트 저자의 전반적인 노력을 지원하기 위해 기부할 수 있습니다."
        msg_donate_text_2="수신자 정보는 다음에서 찾을 수 있습니다:"
        msg_donate_thanks="감사합니다!"
        msg_kdialog_title="KDE-Services 정보"
        msg_description_block=$(cat << EOF_DESC_KO
    서브메뉴 "Actions" => "KDE-Services" (모든 파일/디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "[파일|디렉토리] 이름에 타임스탬프 접두사 추가"
    - "[파일|디렉토리] 타임스탬프 변경"
    - "이메일로 보내기"
    - "[오디오|비디오] 정보" (오디오/비디오 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "[파일|디렉토리] 상태 표시"
    - "여기서 소유자 변경" (파일/디렉토리 소유자 및 권한).
    - "텍스트 바꾸기" (텍스트 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "압축 파일 무결성 검사" (압축 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "MKV 자막 추출" (MKV 비디오 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "자막 다중화" (MPEG-2 비디오 파일만 지원) (MPG 비디오 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "[파일|디렉토리] 이름 공백 바꾸기" (ASCII 밑줄로) (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    
    서브메뉴 "AVI 도구" (AVI 비디오 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "분할 (크기 지정)"
    - "분할 (시간 범위 지정)"
    
    서브메뉴 "Android 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "Android 백업 관리자" (장치의 모든 앱 및 데이터 백업 또는 복원).
    - "Android 파일 관리자" (장치와 파일/디렉토리 복사).
    - "Android 패키지 관리자" (*.apk 애플리케이션 설치/제거).
    - "Android 재부팅 관리자" (장치 재부팅, 선택적으로 부트로더 또는 복구 프로그램으로).
    
    서브메뉴 "백업 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "표준" (/etc/ 및 /root/ 디렉토리 또는 aMule, AnyDesk, Audacity, Chrome, GnuPG,
      HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
      Tmux, Wine 및 일반 사용자 설정 백업/복원).
    
    서브메뉴 "체크섬 도구" (모든 파일에서 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "MD5 (강력)"
    - "SHA1 (상당히 강력)"
    - "SHA256 (매우 강력)"
    - "SHA512 (최고 강력)"
    - "체크섬 확인" (*.md5/*.sha1/*.sha256/*.sha512 체크섬 파일).
    
    서브메뉴 "Dolphin 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "연결" (FTP/SFTP/SMB 프로토콜).
    - "등록된 서버" (이전에 연결된 IP/호스트 표시 또는 편집).
    - "사용된 디스크 공간"
    
    서브메뉴 "Dropbox 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "Dropbox에 복사"
    - "Dropbox로 이동"
    - "공개 Dropbox에 복사하고 URL 가져오기"
    - "공개 Dropbox로 이동하고 URL 가져오기"
    - "공개 URL 가져오기"
    - "Dropbox 서비스 설치"
    - "Dropbox 서비스 업데이트"
    - "Dropbox 서비스 시작"
    - "Dropbox 서비스 중지"
    - "Dropbox 서비스 자동 시작 활성화"
    
    서브메뉴 "그래픽 도구" (이미지 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "변환기" (다양한 이미지 파일 형식을 BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
      PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF 또는 XPM으로 변환).
    - "크기 조절기" (이미지 프레임 너비 사용자 지정).
    - "16x16 (아이콘)"
    - "32x32 (아이콘)"
    - "48x48 (아이콘)"
    - "64x64 (아이콘)"
    - "128x128 (아이콘)"
    - "256x256 (아이콘)"
    - "300x300 (증명사진)"
    - "320x240 (qvga)"
    - "352x288 (cif)"
    - "414x532 (비자)"
    - "480x320 (hvga)"
    - "512x512 (아이콘)"
    - "532x532 (여권)"
    - "640x480 (vga)"
    - "720x480 (ntsc)"
    - "800x600 (svga)"
    - "960x540 (qhd)"
    - "1024x768 (xga)"
    - "1280x1024 (sxga)"
    - "1366x768 (wxga)"
    - "1440x900 (wxga)"
    - "1600x1200 (uxga)"
    - "1920x1200 (wuxga)"
    - "2048x1080 (2k)"
    - "2560x2048 (qsxga)"
    - "3200x2048 (wqsxga)"
    - "3840x2400 (wquxga)"
    - "4096x2160 (4k)"
    - "5120x4096 (hsxga)"
    - "6400x4096 (whsxga)"
    - "7680x4800 (whuxga)"
    - "8192x4320 (8k)"
    
    서브메뉴 "ISO-9660 이미지 도구" (ISO-9660 이미지 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "ISO-9660 이미지 마운트"
    - "ISO-9660 이미지 마운트 해제"
    - "무결성 검사"
    - "MD5sum 삽입"
    - "ISO-9660 이미지 MD5sum 표시"
    - "ISO-9660 이미지 SHA1sum 표시"
    - "ISO-9660 이미지 SHA256sum 표시"
    - "ISO-9660 이미지 SHA512sum 표시"
    - "ISO-9660 이미지 굽기"
    - "ISO-9660 이미지 정보 표시"
    - "광학 드라이브 정보 표시"
    - "ISO-9660 테스트 부팅 (QEMU BIOS)"
    - "ISO-9660 테스트 부팅 (QEMU UEFI)"
    - "ISO-9660 테스트 부팅 (QEMU UEFI, Secure boot)"
    
    서브메뉴 "MEGA 도구" (모든 파일/디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "새 계정 등록"
    - "사용자 로그인 자격 증명 저장"
    - "사용 가능한 클라우드 공간 표시"
    - "새 원격 폴더 생성"
    - "클라우드에 저장된 파일 목록"
    - "클라우드에 저장된 파일 제거"
    - "클라우드에 파일 업로드"
    - "클라우드 [에서|로] 동기화"
    
    서브메뉴 "Midnight 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "[Root ~]# mc" (슈퍼유저 권한의 셸 파일 관리자 GNU Midnight Commander).
    - "[Root ~]# mcedit" (슈퍼유저 권한의 GNU Midnight Commander 내부 파일 편집기).
    - "[User ~]$ mc" (사용자 권한의 셸 파일 관리자 GNU Midnight Commander).
    - "[User ~]$ mcedit" (사용자 권한의 GNU Midnight Commander 내부 파일 편집기).
    
    서브메뉴 "멀티미디어 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "DVD 어셈블러" (메뉴 포함).
    - "비디오 파일 변환" (다양한 비디오 파일 형식을 MPEG-1, MPEG-2, MPEG-4, AVI,
      VCD, SVCD, DVD, 3GP, FLV 또는 WebM으로 변환).
    - "MP4 파일에 자막 추가"
    - "MP3 파일 볼륨 정규화"
    - "오디오 트랙 추출|변환" (다양한 오디오 파일 형식을 MP3, MP3(432Hz),
      FLAC, FLAC 432Hz, OGG 또는 OGG 432Hz로 변환).
    - "비디오 파일 회전"
    - "미디어 파일 시간 편집"
    - "MP3 파일에 표지 첨부"
    - "미디어 파일 메타데이터 정리"
    - "동일한 코덱의 미디어 파일 연결"
    - "여기에서 ISO-9660 이미지 빌드" (선택한 디렉토리에서).
    - "디스크 클로너" (선택한 광학 디스크 장치에서 ISO-9660 이미지 파일로 바이너리 복사).
    - "내 데스크톱 녹화" (비디오 화면 녹화).
    - "여기에서 비디오 재생" (선택한 디렉토리에서 비디오 파일 목록 재생).
    
    서브메뉴 "네트워크 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "연결 감시" (이전에 선택한 포트로 설정된 각 연결 표시).
    - "HTTP 서버" (선택한 디렉토리에서).
    - "리스닝 소켓" (Listening Sockets)
    
    서브메뉴 "PDF 도구" (PDF 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "소유자 비밀번호 적용 (DRM)"
    - "사용자 비밀번호 적용 (암호화)"
    - "DRM + 암호화 적용"
    - "복호화 (DRM)"
    - "복구 도구 (가능한 경우)"
    - "선택한 페이지 추출"
    - "모든 페이지 추출"
    - "모든 이미지 추출"
    - "최적화"
    - "압축"
    - "메타데이터 보기"
    - "메타데이터 편집"
    - "선택한 파일 병합"
    - "파일당 단일 페이지로 분할"
    - "정보"
    
    서브메뉴 "패키지 도구" (SRPM/RPM 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "변경 로그 표시"
    - "정보 표시"
    - "내용 목록"
    - "구성 파일 목록"
    - "종속성 목록"
    - "[설치|제거] 스크립트 목록"
    - "여기에 파일 추출"
    - "무결성 검사"
    
    서브메뉴 "SSH 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "공개 키 생성" (원격 서버에 연결하기 전 1차 필수 단계).
    - "공개 키 설치" (원격 서버에 연결하기 전 2차 필수 단계).
    - "원격 서버에 연결"
    - "원격 서버로 전송" (파일만 지원).
    - "원격 디렉토리 마운트 지점" (SSH 프로토콜을 통해 원격 디렉토리를 로컬 파일 시스템에 마운트/마운트 해제).
    - "등록된 서버" (이전에 연결된 IP/호스트 표시 또는 편집).
    
    서브메뉴 "SaMBa 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "SaMBa 공유 마운터" (SMB 프로토콜을 통해 원격 공유 디렉토리를 로컬 파일 시스템에 마운트/마운트 해제).
    
    서브메뉴 "검색 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "여기서 검색" (선택한 디렉토리에서 재귀적으로).
    - "이름으로 검색" (전체 파일 시스템의 파일/디렉토리 이름).
    - "문자열로 검색" (선택한 디렉토리에서 재귀적으로 파일 내용 내부 검색).
    - "검색 데이터베이스 통계"
    - "검색 데이터베이스 업데이트"
    - "여기에서 수정된 파일" (선택한 디렉토리에서 재귀적으로,
      두 번째 실행으로 수정된 모든 파일 표시).
    
    서브메뉴 "보안 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "암호화된 디렉토리 마운트" (선택한 디렉토리에서 암호화된 가상 파일 시스템 마운트).
    - "암호화된 디렉토리 마운트 해제" (선택한 마운트 지점 디렉토리에서 암호화된 가상 파일 시스템 마운트 해제).
    - "디렉토리 암호화" (선택한 디렉토리에 암호화된 가상 파일 시스템 생성).
    
    서브메뉴 "보안 도구" (모든 파일에서 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "Mailx로 보안 전송" (이메일 첨부 파일로; localhost에서 SMTP 서비스가 실행 중이어야 함).
    - "암호화"
    - "복호화"
    - "강력 파일 분쇄기" (매우 안전한 방식으로 파일 삭제).
    
    서브메뉴 "시스템 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "사용자 지정 커널 빌드" (시스템 커널을 쉽게 사용자 지정하여 시스템 성능 향상
      및/또는 더 많은 하드웨어 지원 추가, RHEL 기반 배포판에만 해당).
    - "커널 업데이트 확인" (RHEL 기반 배포판에만 해당).
    - "RPM 패키지 재빌드" (애플리케이션을 쉽게 사용자 지정하여 애플리케이션 성능 향상
      및/또는 더 많은 지원 추가, RHEL 기반 배포판에만 해당).
    - "시스템 정보"
    - "시스템 모니터" (시스템 로그 오류/고장 이벤트 발생 시 표시).
    - "프로세스 뷰어"
    - "Xorg 구성" (X11R7 X 서버에 대한 구성 파일 생성).
    
    서브메뉴 "터미널 도구" (셸 스크립트/애플리케이션 파일에서만 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "응용 프로그램 실행"
    - "응용 프로그램 실행 (Root)"
    
    서브메뉴 "YouTube 도구" (디렉토리를 마우스 오른쪽 버튼으로 클릭할 때 표시됨).
    - "비디오 다운로더"
    - "비디오 목록 코드 수집기"
    - "비디오 목록 다운로더"
EOF_DESC_KO
)
        ;;
    pt) # Portuguese
        msg_app_description="Ativa as seguintes funcionalidades no menu de contexto do clique direito do Dolphin (Gerenciador de Arquivos) no KDE Plasma 6."
        msg_language_support="Suporte a idiomas:"
        msg_required_dependencies="Dependências necessárias:"
        msg_contributors="Contribuidores:"
        msg_author="Autor:"
        msg_license="Licença:"
        msg_donate_title="Doar 🎔:"
        msg_donate_text_1="Você pode fazer uma doação para apoiar os esforços gerais do autor do projeto KDE-Services."
        msg_donate_text_2="As informações do destinatário podem ser encontradas em:"
        msg_donate_thanks="Obrigado!"
        msg_kdialog_title="Sobre o KDE-Services"
        msg_description_block=$(cat << EOF_DESC_PT
    Submenu "Ações" => "KDE-Services" (mostrado ao clicar com o botão direito em qualquer arquivo/diretório).
    - "Adicionar Prefixo de Carimbo de Data/Hora ao [Nome do Arquivo|Diretório]"
    - "Alterar Carimbo de Data/Hora de [Arquivo|Diretório]"
    - "Enviar por E-mail"
    - "Informações de [Áudio|Vídeo]" (mostrado apenas ao clicar com o botão direito em qualquer arquivo de áudio/vídeo).
    - "Mostrar Status de [Arquivo|Diretório]"
    - "Mudar Proprietário Aqui" (proprietário e permissão de arquivo/diretório).
    - "Substituição de Texto" (mostrado apenas ao clicar com o botão direito em qualquer arquivo de texto).
    - "Verificação de Integridade de Arquivo Compactado" (mostrado apenas ao clicar com o botão direito em qualquer arquivo compactado).
    - "MKV Extrair Subtítulo" (mostrado apenas ao clicar com o botão direito em arquivo de vídeo MKV).
    - "Subtítulo Multiplex" (suporta apenas arquivo de vídeo MPEG-2) (mostrado apenas ao clicar com o botão direito em arquivo de vídeo MPG).
    - "Substituição de Espaços em Branco em [Nome do Arquivo|Diretório]" (por sublinhado ASCII) (mostrado ao clicar com o botão direito em um diretório).
    
    Submenu "Ferramentas AVI" (mostrado apenas ao clicar com o botão direito em arquivo de vídeo AVI).
    - "Dividir (por tamanho)"
    - "Dividir (por intervalo de tempo)"
    
    Submenu "Ferramentas Android" (mostrado ao clicar com o botão direito em um diretório).
    - "Gerenciador de Backup Android" (backup ou restauração de todos os aplicativos e dados do dispositivo).
    - "Gerenciador de Arquivos Android" (copiar arquivo/diretório de/para o dispositivo).
    - "Gerenciador de Pacotes Android" (instalar/desinstalar aplicativos *.apk).
    - "Gerenciador de Reinicialização Android" (reinicia o dispositivo, opcionalmente para o bootloader ou programa de recuperação).
    
    Submenu "Ferramentas de Backup" (mostrado ao clicar com o botão direito em um diretório).
    - "Padrões" (backup/restauração dos diretórios /etc/ e /root/ ou aMule, AnyDesk, Audacity, Chrome, GnuPG,
      HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
      Tmux, Wine e configurações gerais do usuário).
    
    Submenu "Ferramentas de CheckSum" (mostrado ao clicar com o botão direito em qualquer arquivo).
    - "MD5 (forte)"
    - "SHA1 (bastante forte)"
    - "SHA256 (muito forte)"
    - "SHA512 (altamente forte)"
    - "Verificar CheckSum" (arquivo checksum *.md5/*.sha1/*.sha256/*.sha512).
    
    Submenu "Ferramentas Dolphin" (mostrado ao clicar com o botão direito em um diretório).
    - "Conectar a" (Protocolo FTP/SFTP/SMB).
    - "Servidores Registrados" (mostrar ou editar IP/Host previamente conectado).
    - "Espaço em Disco Usado"
    
    Submenu "Ferramentas Dropbox" (mostrado ao clicar com o botão direito em um diretório).
    - "Copiar para Dropbox"
    - "Mover para Dropbox"
    - "Copiar para Dropbox Público e obter URL"
    - "Mover para Dropbox Público e obter URL"
    - "Obter URL pública"
    - "Instalar serviço Dropbox"
    - "Atualizar serviço Dropbox"
    - "Iniciar serviço Dropbox"
    - "Parar serviço Dropbox"
    - "Ativar início automático do serviço Dropbox"
    
    Submenu "Ferramentas Gráficas" (mostrado apenas ao clicar com o botão direito em qualquer arquivo de imagem).
    - "O Conversor" (de vários formatos de arquivo de imagem para BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
      PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF ou XPM).
    - "O Redimensionador" (personalizar a largura do quadro da imagem).
    - "16x16 (ícone)"
    - "32x32 (ícone)"
    - "48x48 (ícone)"
    - "64x64 (ícone)"
    - "128x128 (ícone)"
    - "256x256 (ícone)"
    - "300x300 (carteira)"
    - "320x240 (qvga)"
    - "352x288 (cif)"
    - "414x532 (visto)"
    - "480x320 (hvga)"
    - "512x512 (ícone)"
    - "532x532 (passaporte)"
    - "640x480 (vga)"
    - "720x480 (ntsc)"
    - "800x600 (svga)"
    - "960x540 (qhd)"
    - "1024x768 (xga)"
    - "1280x1024 (sxga)"
    - "1366x768 (wxga)"
    - "1440x900 (wxga)"
    - "1600x1200 (uxga)"
    - "1920x1200 (wuxga)"
    - "2048x1080 (2k)"
    - "2560x2048 (qsxga)"
    - "3200x2048 (wqsxga)"
    - "3840x2400 (wquxga)"
    - "4096x2160 (4k)"
    - "5120x4096 (hsxga)"
    - "6400x4096 (whsxga)"
    - "7680x4800 (whuxga)"
    - "8192x4320 (8k)"
    
    Submenu "Ferramentas de Imagem ISO-9660" (mostrado apenas ao clicar com o botão direito em arquivo de imagem ISO-9660).
    - "Montar Imagem ISO-9660"
    - "Desmontar Imagem ISO-9660"
    - "Verificação de Integridade"
    - "Inserir MD5sum"
    - "Mostrar MD5sum da Imagem ISO-9660"
    - "Mostrar SHA1sum da Imagem ISO-9660"
    - "Mostrar SHA256sum da Imagem ISO-9660"
    - "Mostrar SHA512sum da Imagem ISO-9660"
    - "Gravar Imagem ISO-9660"
    - "Mostrar Informações da Imagem ISO-9660"
    - "Mostrar Informações da Unidade Óptica"
    - "Test-Boot de imagem ISO-9660 (QEMU BIOS)"
    - "Test-Boot de imagen ISO-9660 (QEMU UEFI)"
    - "Test-Boot de imagen ISO-9660 (QEMU UEFI, Secure boot)"
    
    Submenu "Ferramentas MEGA" (mostrado ao clicar com o botão direito em qualquer arquivo/diretório).
    - "Registrar Nova Conta"
    - "Salvar Credenciais de Login do Usuário"
    - "Mostrar Espaço de Nuvem Disponível"
    - "Criar Nova Pasta Remota"
    - "Listar Arquivos Armazenados na Nuvem"
    - "Remover Arquivos Armazenados na Nuvem"
    - "Carregar Arquivos para a Nuvem"
    - "Sincronizar [de|para] a Nuvem"
    
    Submenu "Ferramentas Midnight" (mostrado ao clicar com o botão direito em um diretório).
    - "[Root ~]# mc" (Gerenciador de arquivos Shell GNU Midnight Commander com privilégios de superusuário).
    - "[Root ~]# mcedit" (Editor de arquivos interno GNU Midnight Commander com privilégios de superusuário).
    - "[User ~]$ mc" (Gerenciador de arquivos Shell GNU Midnight Commander com privilégios de usuário).
    - "[User ~]$ mcedit" (Editor de arquivos interno GNU Midnight Commander com privilégios de usuário).
    
    Submenu "Ferramentas Multimídia" (mostrado ao clicar com o botão direito em um diretório).
    - "Montador de DVD" (com menu).
    - "Converter Arquivos de Vídeo" (de vários formatos de arquivo de vídeo para MPEG-1, MPEG-2, MPEG-4, AVI,
      VCD, SVCD, DVD, 3GP, FLV ou WebM).
    - "Adicionar Legenda a Arquivos MP4"
    - "Normalização de Volume de Arquivos MP3"
    - "Extrair|Converter Faixa de Áudio" (de vários formatos de arquivo de áudio para MP3, MP3(432Hz),
      FLAC, FLAC 432Hz, OGG ou OGG 432Hz).
    - "Girar Arquivos de Vídeo"
    - "Editar Tempo de Arquivos Multimídia"
    - "Anexar Capa a Arquivos MP3"
    - "Limpar Metadados de Arquivos Multimídia"
    - "Concatenar Arquivos Multimídia com o Mesmo Codec"
    - "Construir Imagem ISO-9660 a Partir Daqui" (do diretório selecionado).
    - "Clonador de Disco" (cópia binária do dispositivo de disco óptico selecionado para um arquivo de imagem ISO-9660).
    - "Gravar Minha Área de Trabalho" (gravação de tela de vídeo).
    - "Reproduzir Vídeo a Partir Daqui" (reproduzir lista de arquivos de vídeo do diretório selecionado).
    
    Submenu "Ferramentas de Rede" (mostrado ao clicar com o botão direito em um diretório).
    - "Sentinela de Conexão" (mostrar cada conexão estabelecida com portas previamente selecionadas).
    - "Servidor HTTP" (do diretório selecionado).
    - "Sockets de Escuta"
    
    Submenu "Ferramentas PDF" (mostrado apenas ao clicar com o botão direito em arquivo PDF).
    - "Aplicar Senha do Proprietário (DRM)"
    - "Aplicar Senha do Usuário (Criptografar)"
    - "Aplicar DRM + Criptografar"
    - "Descriptografar (DRM)"
    - "Reparador (se possível)"
    - "Extrair Páginas Selecionadas"
    - "Extrair Todas as Páginas"
    - "Extrair Todas as Imagens"
    - "Otimizar"
    - "Comprimir"
    - "Ver Metadados"
    - "Editar Metadados"
    - "Mesclar Arquivos Selecionados"
    - "Dividir em Página Única por Arquivo"
    - "Informação"
    
    Submenu "Ferramentas de Pacote" (mostrado apenas ao clicar com o botão direito em arquivo SRPM/RPM).
    - "Mostrar Changelog"
    - "Mostrar Informações"
    - "Listar Conteúdo"
    - "Listar Arquivos de Configuração"
    - "Listar Dependências"
    - "Listar Scripts de [Ins|Desins]talação"
    - "Extrair Arquivos Aqui"
    - "Verificação de Integridade"
    
    Submenu "Ferramentas SSH" (mostrado ao clicar com o botão direito em um diretório).
    - "Geração de Chave Pública" (1ª etapa obrigatória antes de conectar ao servidor remoto).
    - "Instalar Chave Pública" (2ª etapa obrigatória antes de conectar ao servidor remoto).
    - "Conectar ao Servidor Remoto"
    - "Enviar para Servidor Remoto" (suporta apenas arquivos).
    - "Ponto de Montagem para Diretório Remoto" (montar/desmontar diretório remoto via protocolo SSH no sistema de arquivos local).
    - "Servidores Registrados" (mostrar ou editar IP/Host previamente conectado).
    
    Submenu "Ferramentas SaMBa" (mostrado ao clicar com o botão direito em um diretório).
    - "Montador de Compartilhamentos SaMBa" (montar/desmontar diretório compartilhado remoto via protocolo SMB no sistema de arquivos local).
    
    Submenu "Ferramentas de Busca" (mostrado ao clicar com o botão direito em um diretório).
    - "Buscar Aqui" (recursivamente começando do diretório selecionado).
    - "Buscar por Nome" (nome de arquivo/diretório em todo o sistema de arquivos).
    - "Buscar por String" (recursivamente começando do diretório selecionado dentro do conteúdo do arquivo).
    - "Estatísticas do Banco de Dados de Busca"
    - "Atualizar Banco de Dados de Busca"
    - "Arquivos Modificados Aqui" (recursivamente começando do diretório selecionado
      mostrando todos os arquivos modificados pela segunda vez que é executado).
    
    Submenu "Ferramentas de Segurança" (mostrado ao clicar com o botão direito em um diretório).
    - "Montar Diretório Criptografado" (montar um sistema de arquivos virtual criptografado a partir do diretório selecionado).
    - "Desmontar Diretório Criptografado" (desmontar um sistema de arquivos virtual criptografado a partir do diretório de ponto de montagem selecionado).
    - "Criptografar Diretório" (criar um sistema de arquivos virtual criptografado no diretório selecionado).
    
    Submenu "Ferramentas de Segurança" (mostrado ao clicar com o botão direito em qualquer arquivo).
    - "Envio Seguro para Mailx" (arquivo como anexo de e-mail; requer o serviço SMTP em execução no localhost).
    - "Criptografar"
    - "Descriptografar"
    - "Destruidor Paranoico" (excluir arquivos de uma maneira muito segura).
    
    Submenu "Ferramentas do Sistema" (mostrado ao clicar com o botão direito em um diretório).
    - "Construir Kernel Personalizado" (personalizar facilmente o kernel do sistema, aumentando o desempenho do sistema
      e/ou adicionando mais suporte de hardware, apenas para distros baseadas em RHEL).
    - "Verificar Atualização do Kernel" (apenas para distros baseadas em RHEL).
    - "Reconstruir Pacote RPM" (personalizar facilmente aplicativos, aumentando o desempenho dos aplicativos
      e/ou adicionando mais suporte, apenas para distros baseadas em RHEL).
    - "Informações do Sistema"
    - "Monitor do Sistema" (mostrar eventos de falha/erro do log do sistema quando ocorrem).
    - "Visualizador de Processos"
    - "Configurar Xorg" (cria um arquivo de configuração para o servidor X11R7 X).
    
    Submenu "Ferramentas de Terminal" (mostrado apenas ao clicar com o botão direito em scripts shell/arquivos de aplicativo).
    - "Executar Aplicativo"
    - "Executar Aplicativo (Root)"
    
    Submenu "Ferramentas do YouTube" (mostrado ao clicar com o botão direito em um diretório).
    - "Downloader de Vídeos"
    - "Coletor de Código de Lista de Vídeos"
    - "Downloader de Lista de Vídeos"
EOF_DESC_PT
)
        ;;
    ru) # Russian
        msg_app_description="Включает следующие функции в контекстном меню правого клика Dolphin (файлового менеджера) в KDE Plasma 6."
        msg_language_support="Языковая поддержка:"
        msg_required_dependencies="Требуемые зависимости:"
        msg_contributors="Авторы:"
        msg_author="Разработчик:"
        msg_license="Лицензия:"
        msg_donate_title="Пожертвовать 🎔:"
        msg_donate_text_1="Вы можете сделать пожертвование, чтобы поддержать общие усилия автора проекта KDE-Services."
        msg_donate_text_2="Информацию о получателе можно найти по адресу:"
        msg_donate_thanks="Спасибо!"
        msg_kdialog_title="О KDE-Services"
        msg_description_block=$(cat << EOF_DESC_RU
    Подменю "Действия" => "KDE-Services" (отображается при нажатии правой кнопки мыши на любом файле/каталоге).
    - "Добавить префикс метки времени к [Имени файла|Директории]"
    - "Изменить метку времени [Файла|Директории]"
    - "Отправить по электронной почте"
    - "Информация [Аудио|Видео]" (отображается только при нажатии правой кнопки мыши на любом аудио-/видеофайле).
    - "Показать статус [Файла|Директории]"
    - "Сменить владельца здесь" (владелец и разрешение файла/каталога).
    - "Замена текста" (отображается только при нажатии правой кнопки мыши на любом текстовом файле).
    - "Проверка целостности сжатого файла" (отображается только при нажатии правой кнопки мыши на любом сжатом файле).
    - "MKV Извлечь субтитры" (отображается только при нажатии правой кнопки мыши на видеофайле MKV).
    - "Мультиплексирование субтитров" (поддерживает только видеофайл MPEG-2) (отображается только при нажатии правой кнопки мыши на видеофайле MPG).
    - "Замена пробелов в [Имени файла|Директории]" (на символ ASCII-подчеркивания) (отображается при нажатии правой кнопки мыши на каталоге).
    
    Подменю "Инструменты AVI" (отображается только при нажатии правой кнопки мыши на видеофайле AVI).
    - "Разделить (по размеру)"
    - "Разделить (по диапазону времени)"
    
    Подменю "Инструменты Android" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Менеджер резервного копирования Android" (резервное копирование или восстановление всех приложений и данных устройства).
    - "Менеджер файлов Android" (копирование файла/каталога с/на устройство).
    - "Менеджер пакетов Android" (установка/удаление приложений *.apk).
    - "Менеджер перезагрузки Android" (перезагрузка устройства, опционально в загрузчик или программу восстановления).
    
    Подменю "Инструменты резервного копирования" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Стандарты" (резервное копирование/восстановление каталогов /etc/ и /root/ или aMule, AnyDesk, Audacity, Chrome, GnuPG,
      HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
      Tmux, Wine и общих пользовательских настроек).
    
    Подменю "Инструменты контрольной суммы" (отображается при нажатии правой кнопки мыши на любом файле).
    - "MD5 (сильная)"
    - "SHA1 (достаточно сильная)"
    - "SHA256 (очень сильная)"
    - "SHA512 (крайне сильная)"
    - "Проверить контрольную сумму" (файл контрольной суммы *.md5/*.sha1/*.sha256/*.sha512).
    
    Подменю "Инструменты Dolphin" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Подключиться к" (протокол FTP/SFTP/SMB).
    - "Зарегистрированные серверы" (показать или изменить ранее подключенный IP/хост).
    - "Использованное дисковое пространство"
    
    Подменю "Инструменты Dropbox" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Копировать в Dropbox"
    - "Переместить в Dropbox"
    - "Копировать в публичный Dropbox и получить URL"
    - "Переместить в публичный Dropbox и получить URL"
    - "Получить публичный URL"
    - "Установить службу Dropbox"
    - "Обновить службу Dropbox"
    - "Запустить службу Dropbox"
    - "Остановить службу Dropbox"
    - "Включить автозапуск службы Dropbox"
    
    Подменю "Графические инструменты" (отображается только при нажатии правой кнопки мыши на любом файле изображения).
    - "Конвертер" (из различных форматов файлов изображений в BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
      PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF или XPM).
    - "Изменение размера" (настройка ширины рамки изображения).
    - "16x16 (значок)"
    - "32x32 (значок)"
    - "48x48 (значок)"
    - "64x64 (значок)"
    - "128x128 (значок)"
    - "256x256 (значок)"
    - "300x300 (карточка)"
    - "320x240 (qvga)"
    - "352x288 (cif)"
    - "414x532 (виза)"
    - "480x320 (hvga)"
    - "512x512 (значок)"
    - "532x532 (паспорт)"
    - "640x480 (vga)"
    - "720x480 (ntsc)"
    - "800x600 (svga)"
    - "960x540 (qhd)"
    - "1024x768 (xga)"
    - "1280x1024 (sxga)"
    - "1366x768 (wxga)"
    - "1440x900 (wxga)"
    - "1600x1200 (uxga)"
    - "1920x1200 (wuxga)"
    - "2048x1080 (2k)"
    - "2560x2048 (qsxga)"
    - "3200x2048 (wqsxga)"
    - "3840x2400 (wquxga)"
    - "4096x2160 (4k)"
    - "5120x4096 (hsxga)"
    - "6400x4096 (whsxga)"
    - "7680x4800 (whuxga)"
    - "8192x4320 (8k)"
    
    Подменю "Инструменты образа ISO-9660" (отображается только при нажатии правой кнопки мыши на файле образа ISO-9660).
    - "Смонтировать образ ISO-9660"
    - "Размонтировать образ ISO-9660"
    - "Проверка целостности"
    - "Вставить MD5sum"
    - "Показать MD5sum образа ISO-9660"
    - "Показать SHA1sum образа ISO-9660"
    - "Показать SHA256sum образа ISO-9660"
    - "Показать SHA512sum образа ISO-9660"
    - "Записать образ ISO-9660"
    - "Показать информацию об образе ISO-9660"
    - "Показать информацию об оптическом приводе"
    - "Test-Boot образа ISO-9660 (QEMU BIOS)"
    - "Test-Boot образа ISO-9660 (QEMU UEFI)"
    - "Test-Boot образа ISO-9660 (QEMU UEFI, Secure boot)"
    
    Подменю "Инструменты MEGA" (отображается при нажатии правой кнопки мыши на любом файле/каталоге).
    - "Зарегистрировать новую учетную запись"
    - "Сохранить учетные данные для входа пользователя"
    - "Показать доступное облачное пространство"
    - "Создать новую удаленную папку"
    - "Список файлов, хранящихся в облаке"
    - "Удалить файлы, хранящиеся в облаке"
    - "Загрузить файлы в облако"
    - "Синхронизировать [из|в] облако"
    
    Подменю "Инструменты Midnight" (отображается при нажатии правой кнопки мыши на каталоге).
    - "[Root ~]# mc" (оболочечный файловый менеджер GNU Midnight Commander с правами суперпользователя).
    - "[Root ~]# mcedit" (внутренний файловый редактор GNU Midnight Commander с правами суперпользователя).
    - "[User ~]$ mc" (оболочечный файловый менеджер GNU Midnight Commander с правами пользователя).
    - "[User ~]$ mcedit" (внутренний файловый редактор GNU Midnight Commander с правами пользователя).
    
    Подменю "Мультимедийные инструменты" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Сборщик DVD" (с меню).
    - "Конвертировать видеофайлы" (из различных форматов видеофайлов в MPEG-1, MPEG-2, MPEG-4, AVI,
      VCD, SVCD, DVD, 3GP, FLV или WebM).
    - "Добавить субтитры к файлам MP4"
    - "Нормализация громкости файлов MP3"
    - "Извлечь|Конвертировать аудиодорожку" (из различных форматов аудиофайлов в MP3, MP3(432Hz),
      FLAC, FLAC 432Hz, OGG или OGG 432Hz).
    - "Повернуть видеофайлы"
    - "Редактировать время мультимедийных файлов"
    - "Прикрепить обложку к файлам MP3"
    - "Очистить метаданные мультимедийных файлов"
    - "Объединить мультимедийные файлы с одинаковым кодеком"
    - "Создать образ ISO-9660 отсюда" (из выбранного каталога).
    - "Клонировщик дисков" (бинарная копия с выбранного оптического дисковода в файл образа ISO-9660).
    - "Записать мой рабочий стол" (видеозапись экрана).
    - "Воспроизвести видео отсюда" (воспроизвести список видеофайлов из выбранного каталога).
    
    Подменю "Сетевые инструменты" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Сторож соединения" (показать каждое установленное соединение с ранее выбранными портами).
    - "HTTP-сервер" (из выбранного каталога).
    - "Прослушиваемые сокеты"
    
    Подменю "Инструменты PDF" (отображается только при нажатии правой кнопки мыши на файле PDF).
    - "Применить пароль владельца (DRM)"
    - "Применить пароль пользователя (Зашифровать)"
    - "Применить DRM + Зашифровать"
    - "Расшифровать (DRM)"
    - "Восстановитель (если возможно)"
    - "Извлечь выбранные страницы"
    - "Извлечь все страницы"
    - "Извлечь все изображения"
    - "Оптимизировать"
    - "Сжать"
    - "Посмотреть метаданные"
    - "Редактировать метаданные"
    - "Объединить выбранные файлы"
    - "Разделить на одну страницу по файлам"
    - "Информация"
    
    Подменю "Инструменты пакетов" (отображается только при нажатии правой кнопки мыши на файле SRPM/RPM).
    - "Показать журнал изменений"
    - "Показать информацию"
    - "Список содержимого"
    - "Список файлов конфигурации"
    - "Список зависимостей"
    - "Список скриптов [Установки|Удаления]"
    - "Извлечь файлы сюда"
    - "Проверка целостности"
    
    Подменю "Инструменты SSH" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Генерация открытого ключа" (1-й обязательный шаг перед подключением к удаленному серверу).
    - "Установить открытый ключ" (2-й обязательный шаг перед подключением к удаленному серверу).
    - "Подключиться к удаленному серверу"
    - "Отправить на удаленный сервер" (поддерживает только файлы).
    - "Точка монтирования к удаленному каталогу" (монтирование/размонтирование удаленного каталога через протокол SSH в локальную файловую систему).
    - "Зарегистрированные серверы" (показать или изменить ранее подключенный IP/хост).
    
    Подменю "Инструменты SaMBa" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Монтировщик общих ресурсов SaMBa" (монтирование/размонтирование удаленного общего каталога через протокол SMB в локальную файловую систему).
    
    Подменю "Инструменты поиска" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Искать здесь" (рекурсивно, начиная с выбранного каталога).
    - "Искать по имени" (имя файла/каталога во всей файловой системе).
    - "Искать по строке" (рекурсивно, начиная с выбранного каталога внутри содержимого файла).
    - "Статистика базы данных поиска"
    - "Обновить базу данных поиска"
    - "Измененные файлы здесь" (рекурсивно, начиная с выбранного каталога,
      показывая все файлы, измененные с момента второго запуска).
    
    Подменю "Инструменты безопасности" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Смонтировать зашифрованный каталог" (смонтировать зашифрованную виртуальную файловую систему из выбранного каталога).
    - "Размонтировать зашифрованный каталог" (размонтировать зашифрованную виртуальную файловую систему из выбранного каталога точки монтирования).
    - "Зашифровать каталог" (создать зашифрованную виртуальную файловую систему в выбранном каталоге).
    
    Подменю "Инструменты безопасности" (отображается при нажатии правой кнопки мыши на любом файле).
    - "Безопасная отправка в Mailx" (файл в качестве вложения электронной почты; требуется работающая служба SMTP на localhost).
    - "Зашифровать"
    - "Расшифровать"
    - "Параноидальный измельчитель" (удалить файлы очень безопасным способом).
    
    Подменю "Системные инструменты" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Собрать пользовательское ядро" (простая настройка системного ядра, повышение производительности системы
      и/или добавление дополнительной аппаратной поддержки, только для дистрибутивов на основе RHEL).
    - "Проверить обновление ядра" (только для дистрибутивов на основе RHEL).
    - "Пересобрать пакет RPM" (простая настройка приложений, повышение производительности приложений
      и/или добавление дополнительной поддержки, только для дистрибутивов на основе RHEL).
    - "Системная информация"
    - "Монитор системы" (показать события сбоев/ошибок системного журнала при их возникновении).
    - "Просмотр процессов"
    - "Настроить Xorg" (создать файл конфигурации для X11R7 X Server).
    
    Подменю "Инструменты терминала" (отображается только при нажатии правой кнопки мыши на shell-скриптах/файлах приложений).
    - "Запустить приложение"
    - "Запустить приложение (Root)"
    
    Подменю "Инструменты YouTube" (отображается при нажатии правой кнопки мыши на каталоге).
    - "Загрузчик видео"
    - "Сборщик кодов списков видео"
    - "Загрузчик списков видео"
EOF_DESC_RU
)
        ;;
    es) # Spanish
        msg_app_description="Habilita las siguientes funcionalidades en el menú contextual del clic derecho de Dolphin (Gestor de Archivos) en KDE Plasma 6."
        msg_language_support="Soporte de idiomas:"
        msg_required_dependencies="Dependencias requeridas:"
        msg_contributors="Contribuyentes:"
        msg_author="Autor:"
        msg_license="Licencia:"
        msg_donate_title="Donar 🎔:"
        msg_donate_text_1="Puede hacer una donación para apoyar los esfuerzos generales del autor del proyecto KDE-Services."
        msg_donate_text_2="La información del destinatario se puede encontrar siguiendo:"
        msg_donate_thanks="¡Gracias!"
        msg_kdialog_title="Acerca de KDE-Services"
        msg_description_block=$(cat << EOF_DESC_ES
    Submenú "Acciones" => "KDE-Services" (se muestra al hacer clic derecho en cualquier archivo/directorio).
    - "Agregar Prefijo de Marca de Tiempo a [Nombre de Archivo|Directorio]"
    - "Cambiar Marca de Tiempo a [Archivo|Directorio]"
    - "Enviar por Correo Electrónico"
    - "Información [Audio|Video]" (se muestra solo al hacer clic derecho en cualquier archivo de audio/video).
    - "Mostrar Estado de [Archivo|Directorio]"
    - "Cambiar Propietario Aquí" (propietario y permiso de archivo/directorio).
    - "Reemplazo de Texto" (se muestra solo al hacer clic derecho en cualquier archivo de texto).
    - "Comprobación de Integridad de Archivo Comprimido" (se muestra solo al hacer clic derecho en cualquier archivo comprimido).
    - "Extraer Subtítulo MKV" (se muestra solo al hacer clic derecho en archivo de video MKV).
    - "Subtítulo Multiplex" (solo soporta archivo de video MPEG-2) (se muestra solo al hacer clic derecho en archivo de video MPG).
    - "Reemplazo de Espacios en Blanco en [Nombre de Archivo|Directorio]" (por guion bajo ASCII) (se muestra al hacer clic derecho en un directorio).
    
    Submenú "Herramientas AVI" (se muestra solo al hacer clic derecho en archivo de video AVI).
    - "Dividir (por tamaño)"
    - "Dividir (por rango de tiempo)"
    
    Submenú "Herramientas Android" (se muestra al hacer clic derecho en un directorio).
    - "Gestor de Copias de Seguridad Android" (copia de seguridad o restauración de todas las aplicaciones y datos del dispositivo).
    - "Gestor de Archivos Android" (copiar archivo/directorio desde/hacia el dispositivo).
    - "Gestor de Paquetes Android" (instalar/desinstalar aplicaciones *.apk).
    - "Gestor de Reinicio Android" (reinicia el dispositivo, opcionalmente en el cargador de arranque o programa de recuperación).
    
    Submenú "Herramientas de Copia de Seguridad" (se muestra al hacer clic derecho en un directorio).
    - "Estándares" (copia de seguridad/restauración de directorios /etc/ y /root/ o aMule, AnyDesk, Audacity, Chrome, GnuPG,
    HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
    Tmux, Wine y configuraciones generales de usuario).
    
    Submenú "Herramientas de Suma de Verificación" (se muestra al hacer clic derecho en cualquier archivo).
    - "MD5 (fuerte)"
    - "SHA1 (bastante fuerte)"
    - "SHA256 (muy fuerte)"
    - "SHA512 (altamente fuerte)"
    - "Verificar Suma de Verificación" (archivo de suma de verificación *.md5/*.sha1/*.sha256/*.sha512).
    
    Submenú "Herramientas Dolphin" (se muestra al hacer clic derecho en un directorio).
    - "Conectar a" (protocolo FTP/SFTP/SMB).
    - "Servidores Registrados" (mostrar o editar IP/Host previamente conectado).
    - "Espacio en Disco Usado"
    
    Submenú "Herramientas Dropbox" (se muestra al hacer clic derecho en un directorio).
    - "Copiar a Dropbox"
    - "Mover a Dropbox"
    - "Copiar a Dropbox Público y obtener URL"
    - "Mover a Dropbox Público y obtener URL"
    - "Obtener URL pública"
    - "Instalar servicio Dropbox"
    - "Actualizar servicio Dropbox"
    - "Iniciar servicio Dropbox"
    - "Detener servicio Dropbox"
    - "Habilitar inicio automático del servicio Dropbox"
    
    Submenú "Herramientas Gráficas" (se muestra solo al hacer clic derecho en cualquier archivo de imagen).
    - "El Convertidor" (de varios formatos de archivo de imagen a BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
    PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF o XPM).
    - "El Redimensionador" (personalizar el ancho del marco de la imagen).
    - "16x16 (icono)"
    - "32x32 (icono)"
    - "48x48 (icono)"
    - "64x64 (icono)"
    - "128x128 (icono)"
    - "256x256 (icono)"
    - "300x300 (carnet)"
    - "320x240 (qvga)"
    - "352x288 (cif)"
    - "414x532 (visa)"
    - "480x320 (hvga)"
    - "512x512 (icono)"
    - "532x532 (pasaporte)"
    - "640x480 (vga)"
    - "720x480 (ntsc)"
    - "800x600 (svga)"
    - "960x540 (qhd)"
    - "1024x768 (xga)"
    - "1280x1024 (sxga)"
    - "1366x768 (wxga)"
    - "1440x900 (wxga)"
    - "1600x1200 (uxga)"
    - "1920x1200 (wuxga)"
    - "2048x1080 (2k)"
    - "2560x2048 (qsxga)"
    - "3200x2048 (wqsxga)"
    - "3840x2400 (wquxga)"
    - "4096x2160 (4k)"
    - "5120x4096 (hsxga)"
    - "6400x4096 (whsxga)"
    - "7680x4800 (whuxga)"
    - "8192x4320 (8k)"
    
    Submenú "Herramientas de Imagen ISO-9660" (se muestra solo al hacer clic derecho en archivo de imagen ISO-9660).
    - "Montar Imagen ISO-9660"
    - "Desmontar Imagen ISO-9660"
    - "Comprobación de Integridad"
    - "Insertar MD5sum"
    - "Mostrar MD5sum de Imagen ISO-9660"
    - "Mostrar SHA1sum de Imagen ISO-9660"
    - "Mostrar SHA256sum de Imagen ISO-9660"
    - "Mostrar SHA512sum de Imagen ISO-9660"
    - "Grabar Imagen ISO-9660"
    - "Mostrar Información de Imagen ISO-9660"
    - "Mostrar Información de Unidad Óptica"
    - "Test-Boot de imagen ISO-9660 (QEMU BIOS)"
    - "Test-Boot de imagen ISO-9660 (QEMU UEFI)"
    - "Test-Boot de imagen ISO-9660 (QEMU UEFI, Secure boot)"
    
    Submenú "Herramientas MEGA" (se muestra al hacer clic derecho en cualquier archivo/directorio).
    - "Registrar Nueva Cuenta"
    - "Guardar Credenciales de Inicio de Sesión de Usuario"
    - "Mostrar Espacio en la Nube Disponible"
    - "Crear Nueva Carpeta Remota"
    - "Listar Archivos Almacenados en la Nube"
    - "Eliminar Archivos Almacenados en la Nube"
    - "Subir Archivos a la Nube"
    - "Sincronizar [desde|hacia] la Nube"
    
    Submenú "Herramientas Midnight" (se muestra al hacer clic derecho en un directorio).
    - "[Root ~]# mc" (Shell file manager GNU Midnight Commander con privilegios de superusuario).
    - "[Root ~]# mcedit" (Editor de archivos interno de GNU Midnight Commander con privilegios de superusuario).
    - "[User ~]$ mc" (Shell file manager GNU Midnight Commander con privilegios de usuario).
    - "[User ~]$ mcedit" (Editor de archivos interno de GNU Midnight Commander con privilegios de usuario).
    
    Submenú "Herramientas Multimedia" (se muestra al hacer clic derecho en un directorio).
    - "Ensamblador de DVD" (con menú).
    - "Convertir Archivos de Video" (de varios formatos de archivo de video a MPEG-1, MPEG-2, MPEG-4, AVI,
    VCD, SVCD, DVD, 3GP, FLV o WebM).
    - "Agregar Subtítulo a Archivos MP4"
    - "Normalizar Volumen de Archivos MP3"
    - "Extraer|Convertir Pista de Audio" (de varios formatos de archivo de audio a MP3, MP3(432Hz),
    FLAC, FLAC 432Hz, OGG o OGG 432Hz).
    - "Rotar Archivos de Video"
    - "Editar Tiempo de Archivos Multimedia"
    - "Adjuntar Portada a Archivos MP3"
    - "Limpiar Metadatos de Archivos Multimedia"
    - "Concatenar Archivos Multimedia con el Mismo Códec"
    - "Construir Imagen ISO-9660 Desde Aquí" (desde el directorio seleccionado).
    - "Clonador de Disco" (copia binaria desde el dispositivo de disco óptico seleccionado a un archivo de imagen ISO-9660).
    - "Grabar Mi Escritorio" (grabar pantalla de video).
    - "Reproducir Video Desde Aquí" (reproducir lista de archivos de video desde el directorio seleccionado).
    
    Submenú "Herramientas de Red" (se muestra al hacer clic derecho en un directorio).
    - "Centinela de Conexión" (mostrar cada conexión establecida a puertos previamente seleccionados).
    - "Servidor HTTP" (desde el directorio seleccionado).
    - "Sockets de Escucha"
    
    Submenú "Herramientas PDF" (se muestra solo al hacer clic derecho en archivo PDF).
    - "Aplicar Contraseña de Propietario (DRM)"
    - "Aplicar Contraseña de Usuario (Cifrar)"
    - "Aplicar DRM + Cifrar"
    - "Descifrar (DRM)"
    - "Reparador (si es posible)"
    - "Extraer Páginas Seleccionadas"
    - "Extraer Todas las Páginas"
    - "Extraer Todas las Imágenes"
    - "Optimizar"
    - "Comprimir"
    - "Ver Metadatos"
    - "Editar Metadatos"
    - "Fusionar Archivos Seleccionados"
    - "Dividir en Página Única por Archivo"
    - "Información"
    
    Submenú "Herramientas de Paquetes" (se muestra solo al hacer clic derecho en archivo SRPM/RPM).
    - "Mostrar Registro de Cambios"
    - "Mostrar Información"
    - "Listar Contenido"
    - "Listar Archivos de Configuración"
    - "Listar Dependencias"
    - "Listar Scripts de [Ins|Desins]talación"
    - "Extraer Archivos Aquí"
    - "Comprobación de Integridad"
    
    Submenú "Herramientas SSH" (se muestra al hacer clic derecho en un directorio).
    - "Generación de Clave Pública" (1er paso obligatorio antes de conectar al servidor remoto).
    - "Instalar Clave Pública" (2do paso obligatorio antes de conectar al servidor remoto).
    - "Conectar a Servidor Remoto"
    - "Enviar a Servidor Remoto" (solo soporta archivos).
    - "Punto de Montaje a Directorio Remoto" (montar/desmontar directorio remoto a través del protocolo SSH en el sistema de archivos local).
    - "Servidores Registrados" (mostrar o editar IP/Host previamente conectado).
    
    Submenú "Herramientas SaMBa" (se muestra al hacer clic derecho en un directorio).
    - "Montador de Comparticiones SaMBa" (montar/desmontar directorio compartido remoto a través del protocolo SMB en el sistema de archivos local).
    
    Submenú "Herramientas de Búsqueda" (se muestra al hacer clic derecho en un directorio).
    - "Buscar Aquí" (recursivamente comenzando desde el directorio seleccionado).
    - "Buscar por Nombre" (nombre de archivo/directorio en todo el sistema de archivos).
    - "Buscar por Cadena" (recursivamente comenzando desde el directorio seleccionado dentro del contenido del archivo).
    - "Estadísticas Base de Datos de Búsqueda"
    - "Actualizar Base de Datos de Búsqueda"
    - "Archivos Modificados Aquí" (recursivamente comenzando desde el directorio seleccionado
    mostrando todos los archivos modificados por segunda vez que se ejecuta).
    
    Submenú "Herramientas de Seguridad" (se muestra al hacer clic derecho en un directorio).
    - "Montar Directorio Cifrado" (montar un sistema de archivos virtual cifrado desde el directorio seleccionado).
    - "Desmontar Directorio Cifrado" (desmontar un sistema de archivos virtual cifrado desde el directorio de punto de montaje seleccionado).
    - "Cifrar Directorio" (crear un sistema de archivos virtual cifrado en el directorio seleccionado).
    
    Submenú "Herramientas de Seguridad" (se muestra al hacer clic derecho en cualquier archivo).
    - "Envío Seguro a Mailx" (archivo como adjunto de correo electrónico; necesita el servicio SMTP ejecutándose en localhost).
    - "Cifrar"
    - "Descifrar"
    - "Trituradora Paranoica" (eliminar archivos de una manera muy segura).
    
    Submenú "Herramientas de Sistema" (se muestra al hacer clic derecho en un directorio).
    - "Construir Kernel Personalizado" (personalizar el kernel del sistema fácilmente, aumentando el rendimiento del sistema
    y/o añadiendo más soporte de hardware, solo para distros basadas en RHEL).
    - "Comprobar Actualización del Kernel" (solo para distros basadas en RHEL).
    - "Reconstruir Paquete RPM" (personalizar aplicaciones fácilmente, aumentando el rendimiento de la aplicación
    y/o añadiendo más soporte, solo para distros basadas en RHEL).
    - "Información del Sistema"
    - "Monitor del Sistema" (mostrar eventos de fallo/error del registro del sistema cuando ocurren).
    - "Visor de Procesos"
    - "Configurar Xorg" (crear un archivo de configuración para el servidor X11R7 X).
    
    Submenú "Herramientas de Terminal" (se muestra solo al hacer clic derecho en scripts shell/archivos de aplicación).
    - "Ejecutar Aplicación"
    - "Ejecutar Aplicación (Root)"
    
    Submenú "Herramientas de YouTube" (se muestra al hacer clic derecho en un directorio).
    - "Descargador de Videos"
    - "Colector de Código de Lista de Videos"
    - "Descargador de Lista de Videos"
EOF_DESC_ES
)
        ;;
    uk) # Ukrainian
        msg_app_description="Вмикає наступні функції у контекстному меню правого кліка Dolphin (файлового менеджера) в KDE Plasma 6."
        msg_language_support="Мовна підтримка:"
        msg_required_dependencies="Необхідні залежності:"
        msg_contributors="Співавтори:"
        msg_author="Автор:"
        msg_license="Ліцензія:"
        msg_donate_title="Пожертвувати 🎔:"
        msg_donate_text_1="Ви можете зробити пожертвування, щоб підтримати загальні зусилля автора проєкту KDE-Services."
        msg_donate_text_2="Інформацію про одержувача можна знайти за посиланням:"
        msg_donate_thanks="Дякую!"
        msg_kdialog_title="Про KDE-Services"
        msg_description_block=$(cat << EOF_DESC_UK
    Підменю "Actions" => "KDE-Services" (відображається при натисканні правої кнопки миші на будь-якому файлі/каталозі).
    - "Додати префікс часової мітки до [Імені файлу|Каталогу]"
    - "Змінити часову мітку [Файлу|Каталогу]"
    - "Надіслати електронною поштою"
    - "[Аудіо|Відео] Інфо" (відображається лише при натисканні правою кнопкою миші на будь-якому аудіо/відео файлі).
    - "Показати статус [Файлу|Каталогу]"
    - "Змінити власника тут" (власник і дозвіл файлу/каталогу).
    - "Заміна тексту" (відображається лише при натисканні правою кнопкою миші на будь-якому текстовому файлі).
    - "Перевірка цілісності стисненого файлу" (відображається лише при натисканні правою кнопкою миші на будь-якому стисненому файлі).
    - "MKV Витягнути субтитри" (відображається лише при натисканні правою кнопкою миші на відеофайлі MKV).
    - "Мультиплексування субтитрів" (підтримує лише відеофайл MPEG-2) (відображається лише при натисканні правою кнопкою миші на відеофайлі MPG).
    - "Заміна пробілів у [Імені файлу|Каталогу]" (на ASCII-підкреслення) (відображається при натисканні правою кнопкою миші на каталозі).
    
    Підменю "Інструменти AVI" (відображається лише при натисканні правою кнопкою миші на відеофайлі AVI).
    - "Розділити (за розміром)"
    - "Розділити (за часовим діапазоном)"
    
    Підменю "Інструменти Android" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Менеджер резервного копіювання Android" (резервне копіювання або відновлення всіх додатків і даних пристрою).
    - "Менеджер файлів Android" (копіювання файлу/каталогу з/на пристрій).
    - "Менеджер пакетів Android" (встановлення/видалення програм *.apk).
    - "Менеджер перезавантаження Android" (перезавантажує пристрій, опціонально в завантажувач або програму відновлення).
    
    Підменю "Інструменти резервного копіювання" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Стандарти" (резервне копіювання/відновлення каталогів /etc/ та /root/ або aMule, AnyDesk, Audacity, Chrome, GnuPG,
    HPLip, I2P, JDownloader, FileZilla, Firefox, KDE, KDE-Services, Pidgin, SSH, Thunderbird,
    Tmux, Wine та загальних налаштувань користувача).
    
    Підменю "Інструменти контрольної суми" (відображається при натисканні правою кнопкою миші на будь-якому файлі).
    - "MD5 (сильний)"
    - "SHA1 (досить сильний)"
    - "SHA256 (дуже сильний)"
    - "SHA512 (надзвичайно сильний)"
    - "Перевірити контрольну суму" (файл контрольної суми *.md5/*.sha1/*.sha256/*.sha512).
    
    Підменю "Інструменти Dolphin" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Підключитися до" (протокол FTP/SFTP/SMB).
    - "Зареєстровані сервери" (показати або змінити раніше підключений IP/хост).
    - "Використаний дисковий простір"
    
    Підменю "Інструменти Dropbox" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Копіювати до Dropbox"
    - "Перемістити до Dropbox"
    - "Копіювати до публічного Dropbox та отримати URL"
    - "Перемістити до публічного Dropbox та отримати URL"
    - "Отримати публічний URL"
    - "Встановити службу Dropbox"
    - "Оновити службу Dropbox"
    - "Запустити службу Dropbox"
    - "Зупинити службу Dropbox"
    - "Увімкнути автозапуск служби Dropbox"
    
    Підменю "Графічні інструменти" (відображається лише при натисканні правою кнопкою миші на будь-якому файлі зображення).
    - "Конвертер" (з різних форматів файлів зображень у BMP, EPS, GIF, ICO, JPEG, JPEG 2000, PBM,
    PDF, PGM,PNG,PPM,PSD,SGI,TGA,TIFF або XPM).
    - "Зміна розміру" (налаштувати ширину кадру зображення).
    - "16x16 (іконка)"
    - "32x32 (іконка)"
    - "48x48 (іконка)"
    - "64x64 (іконка)"
    - "128x128 (іконка)"
    - "256x256 (іконка)"
    - "300x300 (картка)"
    - "320x240 (qvga)"
    - "352x288 (cif)"
    - "414x532 (віза)"
    - "480x320 (hvga)"
    - "512x512 (іконка)"
    - "532x532 (паспорт)"
    - "640x480 (vga)"
    - "720x480 (ntsc)"
    - "800x600 (svga)"
    - "960x540 (qhd)"
    - "1024x768 (xga)"
    - "1280x1024 (sxga)"
    - "1366x768 (wxga)"
    - "1440x900 (wxga)"
    - "1600x1200 (uxga)"
    - "1920x1200 (wuxga)"
    - "2048x1080 (2k)"
    - "2560x2048 (qsxga)"
    - "3200x2048 (wqsxga)"
    - "3840x2400 (wquxga)"
    - "4096x2160 (4k)"
    - "5120x4096 (hsxga)"
    - "6400x4096 (whsxga)"
    - "7680x4800 (whuxga)"
    - "8192x4320 (8k)"
    
    Підменю "Інструменти образу ISO-9660" (відображається лише при натисканні правою кнопкою миші на файлі образу ISO-9660).
    - "Монтувати образ ISO-9660"
    - "Демонтувати образ ISO-9660"
    - "Перевірка цілісності"
    - "Вставити MD5sum"
    - "Показати MD5sum образу ISO-9660"
    - "Показати SHA1sum образу ISO-9660"
    - "Показати SHA256sum образу ISO-9660"
    - "Показати SHA512sum образу ISO-9660"
    - "Записати образ ISO-9660"
    - "Показати інформацію про образ ISO-9660"
    - "Показати інформацію про оптичний привід"
    - "Test-Boot образу ISO-9660 (QEMU BIOS)"
    - "Test-Boot образу ISO-9660 (QEMU UEFI)"
    - "Test-Boot образу ISO-9660 (QEMU UEFI, Secure boot)"
    
    Підменю "Інструменти MEGA" (відображається при натисканні правою кнопкою миші на будь-якому файлі/каталозі).
    - "Зареєструвати новий обліковий запис"
    - "Зберегти облікові дані користувача"
    - "Показати доступний хмарний простір"
    - "Створити нову віддалену папку"
    - "Перелічити файли, що зберігаються в хмарі"
    - "Видалити файли, що зберігаються в хмарі"
    - "Завантажити файли в хмару"
    - "Синхронізувати [з|до] хмари"
    
    Підменю "Інструменти Midnight" (відображається при натисканні правою кнопкою миші на каталозі).
    - "[Root ~]# mc" (оболонковий файловий менеджер GNU Midnight Commander з правами суперкористувача).
    - "[Root ~]# mcedit" (внутрішній файловий редактор GNU Midnight Commander з правами суперкористувача).
    - "[User ~]$ mc" (оболонковий файловий менеджер GNU Midnight Commander з правами користувача).
    - "[User ~]$ mcedit" (внутрішній файловий редактор GNU Midnight Commander з правами користувача).
    
    Підменю "Мультимедійні інструменти" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Збирач DVD" (з меню).
    - "Конвертувати відеофайли" (з різних форматів відеофайлів у MPEG-1, MPEG-2, MPEG-4, AVI,
    VCD, SVCD, DVD, 3GP, FLV або WebM).
    - "Додати субтитри до файлів MP4"
    - "Нормалізація гучності файлів MP3"
    - "Витягнути|Конвертувати аудіодоріжку" (з різних форматів аудіофайлів у MP3, MP3(432Hz),
    FLAC, FLAC 432Hz, OGG або OGG 432Hz).
    - "Повернути відеофайли"
    - "Редагувати час мультимедійних файлів"
    - "Прикріпити обкладинку до файлів MP3"
    - "Очистити метадані мультимедійних файлів"
    - "Об'єднати мультимедійні файли з однаковим кодеком"
    - "Створити образ ISO-9660 звідси" (з вибраного каталогу).
    - "Клонувач дисків" (бінарна копія з вибраного оптичного дисковода у файл образу ISO-9660).
    - "Записати мій робочий стіл" (відеозапис екрана).
    - "Відтворити відео звідси" (відтворити список відеофайлів з вибраного каталогу).
    
    Підменю "Мережеві інструменти" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Вартовий з'єднання" (показати кожне встановлене з'єднання з раніше вибраними портами).
    - "HTTP-сервер" (з вибраного каталогу).
    - "Сокети прослуховування"
    
    Підменю "Інструменти PDF" (відображається лише при натисканні правою кнопкою миші на файлі PDF).
    - "Застосувати пароль власника (DRM)"
    - "Застосувати пароль користувача (Шифрувати)"
    - "Застосувати DRM + Шифрувати"
    - "Розшифрувати (DRM)"
    - "Відновлювач (якщо можливо)"
    - "Витягнути вибрані сторінки"
    - "Витягнути всі сторінки"
    - "Витягнути всі зображення"
    - "Оптимізувати"
    - "Стиснути"
    - "Переглянути метадані"
    - "Редагувати метадані"
    - "Об'єднати вибрані файли"
    - "Розділити на одну сторінку по файлах"
    - "Інформація"
    
    Підменю "Інструменти пакетів" (відображається лише при натисканні правою кнопкою миші на файлі SRPM/RPM).
    - "Показати журнал змін"
    - "Показати інформацію"
    - "Список вмісту"
    - "Список файлів конфігурації"
    - "Список залежностей"
    - "Список скриптів [Встановлення|Видалення]"
    - "Витягнути файли сюди"
    - "Перевірка цілісності"
    
    Підменю "Інструменти SSH" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Генерація відкритого ключа" (1-й обов'язковий крок перед підключенням до віддаленого сервера).
    - "Встановити відкритий ключ" (2-й обов'язковий крок перед підключенням до віддаленого сервера).
    - "Підключитися до віддаленого сервера"
    - "Надіслати на віддалений сервер" (підтримує лише файли).
    - "Точка монтування до віддаленого каталогу" (монтування/демонтування віддаленого каталогу через протокол SSH у локальну файлову систему).
    - "Зареєстровані сервери" (показати або змінити раніше підключений IP/хост).
    
    Підменю "Інструменти SaMBa" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Монтувальник спільних ресурсів SaMBa" (монтування/демонтування віддаленого спільного каталогу через протокол SMB у локальну файлову систему).
    
    Підменю "Інструменти пошуку" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Шукати тут" (рекурсивно, починаючи з вибраного каталогу).
    - "Шукати за назвою" (ім'я файлу/каталогу по всій файловій системі).
    - "Шукати за рядком" (рекурсивно, починаючи з вибраного каталогу всередині вмісту файлу).
    - "Статистика бази даних пошуку"
    - "Оновити базу даних пошуку"
    - "Змінені файли тут" (рекурсивно, починаючи з вибраного каталогу,
    показуючи всі файли, змінені під час другого запуску).
    
    Підменю "Інструменти безпеки" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Монтувати зашифрований каталог" (монтувати зашифровану віртуальну файлову систему з вибраного каталогу).
    - "Демонтувати зашифрований каталог" (демонтувати зашифровану віртуальну файлову систему з вибраного каталогу точки монтування).
    - "Зашифрувати каталог" (створити зашифровану віртуальну файлову систему у вибраному каталозі).
    
    Підменю "Інструменти безпеки" (відображається при натисканні правою кнопкою миші на будь-якому файлі).
    - "Безпечна відправка до Mailx" (файл як вкладення електронної пошти; потрібна запущена служба SMTP на localhost).
    - "Шифрувати"
    - "Розшифрувати"
    - "Параноїдальний шредер" (видалити файли дуже безпечним способом).
    
    Підменю "Системні інструменти" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Створити користувацьке ядро" (легко налаштувати системне ядро, підвищити продуктивність системи
    та/або додати більше апаратної підтримки, лише для дистрибутивів на основі RHEL).
    - "Перевірити оновлення ядра" (лише для дистрибутивів на основі RHEL).
    - "Перебудувати пакет RPM" (легко налаштувати програми, підвищити продуктивність програм
    та/або додати більше підтримки, лише для дистрибутивів на основі RHEL).
    - "Системна інформація"
    - "Монітор системи" (показати події збою/помилки системного журналу, коли вони виникають).
    - "Переглядач процесів"
    - "Налаштувати Xorg" (створити файл конфігурації для X11R7 X Server).
    
    Підменю "Інструменти терміналу" (відображається лише при натисканні правою кнопкою миші на shell-скриптах/файлах програм).
    - "Запустити програму"
    - "Запустити програму (Root)"
    
    Підменю "Інструменти YouTube" (відображається при натисканні правою кнопкою миші на каталозі).
    - "Завантажувач відео"
    - "Збирач кодів списку відео"
    - "Завантажувач списку відео"
EOF_DESC_UK
)
        ;;
    *)  # Default to English (already defined above)
        ;;
esac

# ---------------------------------------------
# CORE LOGIC: Generate and Display Info Box
# ---------------------------------------------

# Use cat with EOT to cleanly include all the content.
cat > "$TEMP_FILE" << EOF

                                      ⚙ KDE-Services ⚙ version $VERSION ⚙ 2011-2026 ⚙
                                             ${KDE_SERVICES_URL}

    Description:
    $msg_app_description

$msg_description_block

    $msg_language_support
    - Chinese
    - French
    - German
    - Italian
    - Japanese
    - Korean
    - Portuguese
    - Russian
    - Spanish
    - Ukrainian

    $msg_required_dependencies
    - android-tools
    - bash
    - bc
    - bzip2
    - cifs-utils
    - coreutils
    - diffutils
    - dmidecode
    - dvdauthor
    - edk2-*
    - festival
    - ffmpeg
    - file
    - findutils
    - fuse
    - fuseiso
    - fuse-encfs
    - fuse-sshfs
    - gawk
    - genisoimage
    - ghostscript
    - gnupg
    - htop
    - ImageMagick
    - iproute
    - isomd5sum
    - kde-baseapps
    - kde-runtime
    - kernel-tools
    - konsole
    - libcdio
    - liberation-sans-fonts
    - lynx
    - mailx
    - mc
    - megatools
    - mkvtoolnix
    - mlocate
    - mp3gain
    - net-tools
    - openssh-askpass
    - pdftk
    - perl
    - perl-Image-ExifTool
    - poppler
    - poppler-utils
    - procps
    - psmisc
    - pv
    - qemu
    - recode
    - samba-client
    - sed
    - shared-mime-info
    - sox
    - tar
    - transcode
    - unar
    - util-linux
    - vlc
    - wget
    - wodim
    - xdg-utils
    - xorg-x11-server-utils
    - xorg-x11-server-Xorg
    - xterm
    - yt-dlp
    - zip

    $msg_contributors
    - Sylvain Vidal <garion@mailoo.org> (Author of servicemenu PDFktools).
    - David Baum <david.baum@naraesk.eu> (Service menu PDFktools bugfixer and author of the good idea
      of integrating PDFktools on "PDF Tools").
    - Victor Guardiola <victor.guardiola@gmail.com> (Improved source code for "Mount ISO Image" and "Umount ISO Image"
      servicemenus; fixed the problem of [dir|file]name with whitespace).
    - Vasyl V. Vercynskyj <fuckel@ukr.net> (Translations to Russian and Ukrainian languages).
    - Pawan Yadav <pawanyadav@gmail.com> (Research for KF5 support).
    - Bruce Zhang <zttt183525594@gmail.com> (Translations to Chinese language).
    - Daniele Scasciafratte <mte90@linux.it> (Translations to Italian language).
    - Manuel Tancoigne <m.tancoigne@gmail.com> (Translations to French language).
    - Gabriel Fontenelle <contato@gabrielfontenelle.com> (Fix a problem with unmounting image removing directory
      not created by fuseiso).
    - Mateus Cruz <mateushenriquedacc@gmail.com> (Translations to Brazilian Portuguese and Portuguese).
    - ookatuk (Translations to Japanese language; fix of the translation display of the "Android Tools" submenu
      and addition to the "ISO-9660 Image Tools" submenu of servicemenus to test the ISO image of a live OS with QEMU).

    $msg_author
    - Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>, Developer.

    $msg_license
    - BSD 3-Clause License
    - Copyright (c) 2026, Geovani Barzaga Rodriguez (geobarrod) <igeo.cu@gmail.com>
    - Redistribution and use in source and binary forms, with or without
      modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright notice, this
         list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright notice,
         this list of conditions and the following disclaimer in the documentation
         and/or other materials provided with the distribution.
      3. Neither the name of the copyright holder nor the names of its
         contributors may be used to endorse or promote products derived from
         this software without specific prior written permission.
      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
      AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
      IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
      DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
      FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
      DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
      SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
      CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
      OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    $msg_donate_title
    - $msg_donate_text_1
    - $msg_donate_text_2
      ${DONATE_URL}
      $msg_donate_thanks

EOF

# Display the information using kdialog
kdialog --icon=ks-menu --title="$msg_kdialog_title" --textbox "$TEMP_FILE" 1125 555 2> /dev/null
