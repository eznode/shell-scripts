#!/bin/bash
#######################################################################################################
# UEFI guidelines,tips and tricks (updated in June 2017):
#######################################################################################################
# !!!!! STEP 1) Method to boot 2GB USB stick in UEFI compatible mode in order to
# !!!!! create dual boot install where both Windows 10 and Ubuntu are booting in UEFI+SecureBoot mode:
# !!!!! Install Rufus USB utility in Windows 10 64-bit using chocolatey. Format USB stick in FAT32 disk format. 
# !!!!! Write .iso image to USB stick in Rufus using GPT partitioning (not MBR partitioning) to ensure 
# !!!!! it can boot in UEFI SecureBoot mode. Reboot into UEFI BIOS settings. Make sure to move new
# !!!!! UEFI USB partition to top of UEFI boot list.Save change to UEFI BIOS settings.
# !!!!! STEP 2) Fix UEFI boot loader issues where Windows 10 skips the Ubuntu EFI bootloader
# !!!!! by using BCDEdit in Windows 10 or by installing efibootmgr Ubuntu package 
# !!!!! in an Ubuntu LiveUSB session and then following these instructions:
# !!!!! https://www.lifewire.com/fix-uefi-bootloader-issues-when-dual-booting-2200655
# !!!!! Also try changing the OS boot loader order in the UEFI settings screen after installing Ubuntu
# !!!!! in UEFI+SecureBoot mode. Make sure Ubuntu EFI bootloader is put above the Windows EFI bootloader.
# !!!!! Disable QuickBoot/FastBoot and Intel Smart Response Technology (SRT) in the UEFI settings screen.
#######################################################################################################

# !!!!! Mac OS X users (v10.9 or newer) should install and use homebrew cask command line tool to install software:
# !!!!! https://github.com/MarkRijckenberg/shell-scripts/blob/master/OSX-restore-packagelist.bash
# !!!!! for semi-automated OS X application deployments and updates
# !!!!! WINDOWS 8.1 64-bit users should use ninite.com and 
# !!!!! https://github.com/MarkRijckenberg/shell-scripts/blob/master/Windows-restore-packagelist.cmd
# !!!!! for semi-automated Windows application deployments and updates
# !!!!! WINDOWS 8.1 64-bit users should install "Classic Start" utility
# !!!!! and disable Superfetch Windows service to avoid hard disk thrashing and excessive memory use
# !!!!! WINDOWS 8.1 64-bit users should use http://www.pendrivelinux.com/yumi-multiboot-usb-creator/  to
# !!!!! to add operating systems one by one in a flexible manner onto a multi-boot multi-OS USB stick
# !!!!! WINDOWS 8.1 64-bit users should install new games via Steam and via www.pokki.com
# !!!!! WINDOWS 8.1 64-bit App Store URL: http://windows.microsoft.com/en-us/windows-8/apps#Cat=t1
# !!!!! WINDOWS 8.1 64-bit Second App Store URL: http://www.pokki.com/
# !!!!! WINDOWS 10 64-bit: to avoid memory leaks in svchost process: disable the BITS (background intelligent transfer 
# !!!!! service) and Windows Superfetch/prefetch service in services.msc !!!

# Run this script using this command:   time bash restore-packagelist-Ubuntu.bash

# TYPE: Bash Shell script.
# PURPOSE: This bash shell script allows you to easily restore packages into a clean install of 
# neon-useredition-20160630-1018-amd64.iso or Lubuntu 16.04 LTS 64-bit:
# RECOMMENDS: minimum of 2 gigabytes of RAM memory
# REQUIRES: Lubuntu 17.10 64-bit or newer
# (to support UEFI+SecureBoot+biber+bibtex+bluetooth), 
# cinnamon-bluetooth, 
# wget, apt, unp, wine, biber, biblatex
# REQUIRES: kernel version 4.10 or newer
# CONFLICTS: with Kubuntu, Linux Mint and DistroAstro packages!!!!!!! Do not use any package repository except for
# Ubuntu package repositories -> Linux Mint and DistroAstro packages destabilize the GUI interface
# Use Cinnamon instead of Unity interface, because Unity causes Teamviewer sessions to slow down due to window 
# animation in Unity
# REQUIRED FREE DISKSPACE FOR Lubuntu 16.04 LTS 64-bit : 2.7 GB of free disk space in root partition
# REQUIRED FREE DISKSPACE FOR BASEPACKAGES:  6.4 GB of free disk space in root partition after installing Lubuntu 16.04 LTS 64-bit 
# REQUIRED FREE DISKSPACE FOR ASTRONOMY PACKAGES:  2.340 GB of free disk space in root partition after installing Lubuntu/Xubuntu 14.04 LTS 64-bit 
# TOTAL REQUIRED DISKSPACE IN ROOT (/) WITHOUT INSTALLING ASTRONOMY SOFTWARE: 2.7 GB + 6.4 GB  = 9.1 GB
# TOTAL REQUIRED DISKSPACE IN ROOT (/) WHEN INSTALLING BASEPACKAGES + ASTRONOMY SOFTWARE: 9.1 GB + 2.340 GB = 11.44 GB
# INSTALLATION DURATION WITHOUT INSTALLING ASTRONOMY SOFTWARE: around 30 minutes on a modern laptop without SSD storage
# COMPATIBILITY WITH WIRELESS BLUETOOTH SPEAKERS: bluetooth speakers fully work in Linux Mint 16 Cinnamon
# thanks to cinnamon-bluetooth package.
# To make bluetooth speakers work in lxqt desktop, run these 4 Terminal commands:
# 1) pactl list | grep -i module-bluetooth-discover
# 2) pactl load-module module-bluetooth-discover
# 3) pavucontrol   
# 4) sudo apt remove blueman
#  -> select bluetooth speakers as output in pavucontrol

# INSTALL DURATION: 20 minutes for install of Lubuntu/Xubuntu 14.04 LTS 64-bit  + 74 minutes for install of base packages and PPA packages
# Author: Mark Rijckenberg
# INITIAL REVISION DATE: 20120812
# LAST REVISION DATE: June 2017

# regarding the HP Laserjet 1020 in Berlin:
# procedure to install printer driver for HP Laserjet 1020 without needing access to openprinting.org website:
# see https://github.com/MarkRijckenberg/shell-scripts/blob/master/hplip-to-foo2zjs-driver-install.bash

#sudo su
PATH=/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin
#Prerequisites: USB drives SAMSUNG and IOMEGA need to be mounted correctly in order for this script to work correctly!

LogDay=`date -I`
MACHINE_TYPE=`uname -m`

# define Astronomy filename variables
SCISOFTFILENAME="7.7.0"
C2AFILENAME="c2a_full_2_1_3.zip"
AUDELAFILENAME="audela-2.1.0"
WEKAFILENAME=

#define source directories
HOME=$(eval echo ~${SUDO_USER})
SOURCE2=/etc/
SOURCE3=/media/windows/rsync/


#define target directories where backup will be stored
cd $HOME
TARGET1=/media/SAMSUNG/$HOME/
TARGET2=/media/IOMEGA/$HOME/
TARGET3=/media/SAMSUNG/etc/
TARGET4=/media/IOMEGA/etc/
TARGET5=/media/SAMSUNG/media/windowsdata/rsync/
TARGET6=/media/IOMEGA/media/windowsdata/rsync/
ZIP=zip/
TAR=tar/
PDF=pdf/
DEB=deb/
KMZ=kmz/
mkdir $ZIP
mkdir $TAR
mkdir $PDF
mkdir $DEB
mkdir $KMZ
mkdir triatlas

# clean up current directory
echo "Performing file cleanup"
cd $HOME
mv *.deb $DEB
rm *.exe
mv *.km? $KMZ
mv *.pdf $PDF
mv *gz $TAR
mv *.zip $ZIP
rm *.cab
rm *.crt
rm .goutputstrea*
rm *.html
rm *.sh
rm *.xpi
rm ica_*
rm google*
# sudo rm /etc/apt/sources.list.d/*
sudo rm /etc/apt/trusted.gpg.d/*

# clean up old install of vlc player:
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes  libvlccore8 libvlccore9

#sudo /usr/bin/rsync -quvra   --exclude='.*' --exclude "$HOME.gvfs"  --max-size='100M' $TARGET1 $HOME 
#sudo /usr/bin/rsync -quvra   --exclude='.*' --exclude "$HOME.gvfs"  --max-size='100M' $TARGET2 $HOME
#sudo /usr/bin/rsync -quvra   --exclude='.*' --exclude "$HOME.gvfs"  --max-size='100M' $TARGET3 $SOURCE2
#sudo /usr/bin/rsync -quvra   --exclude='.*' --exclude "$HOME.gvfs"  --max-size='100M' $TARGET4 $SOURCE2 
# not required during restore: sudo /usr/bin/rsync -quvra   --exclude='.*' --exclude "$HOME.gvfs"  --max-size='100M' $TARGET5 $SOURCE3
# not required during restore: sudo /usr/bin/rsync -quvra   --exclude='.*' --exclude "$HOME.gvfs"  --max-size='100M' $TARGET6 $SOURCE3
#sudo DEBIAN_FRONTEND=noninteractive apt install dselect rsync -y
#sudo DEBIAN_FRONTEND=noninteractive apt-key add $TARGET1/Repo.keys
# sudo DEBIAN_FRONTEND=noninteractive apt-key add Repo.keys
#sudo dpkg --set-selections < $TARGET1/Package.list
#sudo dpkg --set-selections < Package.list
#sudo dselect

#sudo cp /etc/apt/sources.list  /etc/apt/sources.list.$LogDay.backup
#sudo cp sources.list.12.04 /etc/apt/sources.list

###############################################################################################
#     BASE PACKAGES SECTION                                                                   #
###############################################################################################

# 20170805: disable systemd service / timer which causes apt-get update to fail in AppVM or TemplateVM
# running Ubuntu 17.04 on Xen hypervisor in Qubes OS
sudo systemctl disable apt-daily.service # disable run when system boot
sudo systemctl disable apt-daily.timer   # disable timer run

# https://www.maketecheasier.com/fix-windows-linux-show-different-times/
timedatectl set-local-rtc 1 --adjust-system-clock

# show filelist before installing
cd
comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) > filelist-before-installing.txt
# store start time when running script
start=$(date +%s)

# delete old custom aliases in ~/.bashrc file
egrep -v 'apt|d-u|wget|googler|streamlink'  ~/.bashrc > ~/.bashrc.$LogDay.backup
cp ~/.bashrc.$LogDay.backup ~/.bashrc

# define custom aliases in ~/.bashrc file
echo "alias apti='sudo apt update;sudo apt install '" >> ~/.bashrc
echo "alias aptr='sudo apt remove '" >> ~/.bashrc
echo "alias aptp='sudo apt purge '" >> ~/.bashrc
echo "alias aptu='sudo apt update'" >> ~/.bashrc
echo "alias apts='apt search '" >> ~/.bashrc
echo "alias d-u='sudo apt update;sudo apt upgrade'" >> ~/.bashrc
echo "alias wget='wget --no-check-certificate'" >> ~/.bashrc
echo "alias g='googler -n 10 -c be -x '" >> ~/.bashrc
echo "alias s='streamlink'" >> ~/.bashrc
alias wget="wget --no-check-certificate"


# define custom config in .streamlinkrc file
rm ~/.streamlinkrc
touch ~/.streamlinkrc
echo "player=vlc" >> ~/.streamlinkrc

# turn off apport error/crash reporting
sudo sed -i s/enabled=1/enabled=0/ /etc/default/apport

# lower swappiness value to 10
# Decrease swap usage to a more reasonable level
rm /tmp/sysctl.conf
rm /tmp/sysctl.conf.1
cp /etc/sysctl.conf /tmp/sysctl.conf
grep -v vm.swappiness /tmp/sysctl.conf > /tmp/sysctl.conf.1
echo 'vm.swappiness=10' >> /tmp/sysctl.conf.1
sudo cp /tmp/sysctl.conf.1 /etc/sysctl.conf

# enable new Quad9 (9.9.9.9) DNS and DNSSEC service 
# in Ubuntu 17.10 64-bit using a bash shell script
sudo apt purge unbound
LogTime=$(date '+%Y-%m-%d_%Hh%Mm%Ss')
cp /etc/resolv.conf $HOME/resolv.conf_$LogTime
cp /etc/nsswitch.conf $HOME/nsswitch.conf_$LogTime
cp /etc/systemd/resolved.conf $HOME/resolved.conf_$LogTime
cp /etc/network/interfaces $HOME/interfaces_$LogTime

sudo service resolvconf stop
sudo update-rc.d resolvconf remove
cp /etc/resolv.conf /tmp/resolv.conf
grep -v nameserver  /tmp/resolv.conf > /tmp/resolv.conf.1
echo 'nameserver 9.9.9.9' >> /tmp/resolv.conf.1
echo 'nameserver 2620:fe::fe' >> /tmp/resolv.conf.1
echo 'domain dnsknowledge.com' >> /tmp/resolv.conf.1
echo 'options rotate' >> /tmp/resolv.conf.1
sudo cp /tmp/resolv.conf.1  /etc/resolv.conf
sudo service resolvconf start

# configure DNS server on Ubuntu 16.04 LTS:
cp /etc/network/interfaces /tmp/interfaces
grep -v nameservers  /tmp/interfaces > /tmp/interfaces.1
grep -v search  /tmp/interfaces.1 > /tmp/interfaces.2
grep -v options  /tmp/interfaces.2 > /tmp/interfaces.3
echo 'dns-nameservers 9.9.9.9 2620:fe::fe' >> /tmp/interfaces.3
echo 'dns-search dnsknowledge.com' >> /tmp/interfaces.3
echo 'dns-options rotate' >> /tmp/interfaces.3
sudo cp /tmp/interfaces.3  /etc/network/interfaces


# replace DNS resolution via /etc/resolv.conf by DNS resolution via systemd in order to use DNS server 9.9.9.9:
# sudo rm /etc/resolv.conf
# comment out the next line to avoid breaking DNS resolution in Ubuntu/Fedora running in Qubes OS 3.2
#sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

# enable systemd caching DNS resolver
rm /tmp/nsswitch.conf
rm /tmp/nsswitch.conf.1
cp /etc/nsswitch.conf /tmp/nsswitch.conf
grep -v hosts  /tmp/nsswitch.conf > /tmp/nsswitch.conf.1
# dns must be mentioned in next line, or else wget does not work
echo 'hosts: files mdns4_minimal [NOTFOUND=return] resolv dns myhostname mymachines' >> /tmp/nsswitch.conf.1
sudo cp /tmp/nsswitch.conf.1 /etc/nsswitch.conf

# set DNS server to 9.9.9.9
rm /tmp/resolved.conf
rm /tmp/resolved.conf.1
cp /etc/systemd/resolved.conf /tmp/resolved.conf
grep -v DNS  /tmp/resolved.conf > /tmp/resolved.conf.1
# enable new Quad9 (9.9.9.9) DNS and DNSSEC service
# https://arstechnica.com/information-technology/2017/11/new-quad9-dns-service-blocks-malicious-domains-for-everyone/
echo 'DNS=9.9.9.9' >> /tmp/resolved.conf.1
echo 'DNSSEC=yes' >> /tmp/resolved.conf.1
sudo cp /tmp/resolved.conf.1 /etc/systemd/resolved.conf
sudo systemd-resolve --flush-caches
sudo systemctl restart systemd-resolved
sudo systemd-resolve --flush-caches
sudo systemd-resolve  --status

# It is probably also necessary to manually set
# the DNS server to 9.9.9.9 in the router's configuration
# and in the NetworkManager GUI

# test DNSSEC validation using dig command-line tool
# see: https://docs.menandmice.com/display/MM/How+to+test+DNSSEC+validation
dig pir.org +dnssec +multi
host dnsknowledge.com

#######################################################################################################################
# https://www.cyberciti.biz/cloud-computing/increase-your-linux-server-internet-speed-with-tcp-bbr-congestion-control/
# REQUIRES: kernel version 4.9 or newer
rm /tmp/10-custom-kernel-bbr.conf
touch /tmp/10-custom-kernel-bbr.conf
echo 'net.core.default_qdisc=fq' >> /tmp/10-custom-kernel-bbr.conf
echo 'net.ipv4.tcp_congestion_control=bbr' >> /tmp/10-custom-kernel-bbr.conf
sudo cp /tmp/10-custom-kernel-bbr.conf /etc/sysctl.d/10-custom-kernel-bbr.conf
sudo sysctl --system

##########################################################################################################
# only disable touchpad on certain PC
##########################################################################################################
if [ `echo $HOSTNAME|grep ulysses` == ""   ] 
then
     echo "not my PC"
else
    sudo rm /tmp/blacklist-elan_i2c.conf
    sudo rm /etc/modprobe.d/blacklist-elan_i2c.conf
    sudo touch /etc/modprobe.d/blacklist-elan_i2c.conf
    echo 'blacklist elan_i2c' >> /tmp/blacklist-elan_i2c.conf
    sudo cp /tmp/blacklist-elan_i2c.conf /etc/modprobe.d/blacklist-elan_i2c.conf
    echo "customized for specific pc"
fi

##########################################################################################################
# add base PPA repositories
##########################################################################################################
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   software-properties-common
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:hsoft/ppa
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:lubuntu-dev/lubuntu-daily
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:gilir/q-project
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:danielrichter2007/grub-customizer
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:libreoffice/ppa
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:mjblenner/ppa-hal
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:flexiondotorg/hal-flash
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:nemh/gambas3
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:peterlevi/ppa
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:linrunner/tlp
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:kazam-team/stable-series
sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:dhor/myway
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:webupd8team/atom
sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:webupd8team/brackets
sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:philip5/extra
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:stebbins/handbrake-releases
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:lyc256/sopcast-player-ppa
sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:surfernsk/internet-software
sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:makson96/desurium
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:ubuntuhandbook1/apps
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:tualatrix/ppa
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:webupd8team/y-ppa-manager
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:ubuntu-wine/ppa
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:videolan/master-daily
# deprecated: sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:wine/wine-builds
wget -nc https://dl.winehq.org/wine-builds/Release.key
sudo apt-key add Release.key
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes https://dl.winehq.org/wine-builds/ubuntu/
# disable oibaf PPA which wants to install newer linux-image package that kills wireless on new Asus N551VW laptop!
# sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:oibaf/graphics-drivers
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:noobslab/apps
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:gertvdijk/opensc-backports
# very important security related PPA that was the first repository to fix the 
# CVE-2014-6277 bash shellshock vulnerability on October 8, 2014: 
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:ubuntu-security-proposed/ppa
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:numix/ppa
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:fish-shell/release-2
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:marutter/rrutter
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:marutter/c2d4u
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:stellarium/stellarium-releases
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:clipgrab-team/ppa
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:qbittorrent-team/qbittorrent-stable
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:heyarje/libav-11
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:niko2040/e19
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:git-core/ppa
# sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:budgie-remix/ppa
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:nilarimogard/webupd8
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:strukturag/libde265
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:twodopeshaggy/jarun
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:webupd8team/tor-browser
# sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:openshot.developers/ppa
# sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:fyrmir/livewallpaper-daily
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:jonathonf/vlc
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:mc3man/mpv-tests
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes "deb [arch=amd64] https://osquery-packages.s3.amazonaws.com/bionic bionic main"
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:flexiondotorg/audio

##########################################################################################################
# add astronomy PPA repositories
##########################################################################################################
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:mutlaqja/astrometry.net
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:mutlaqja/ppa

# Do NOT add repository for distroastro software packages
# Distroastro v3.0.1 breaks the windowing functionality of metacity and does not work well
# Distroastro mixes packages from Ubuntu and Linux Mint, causing severe issues
# replace codename (for example: trusty) with right Ubuntu codename
#RELEASE=`awk -F'[" ]' '/VERSION=/{print $3}' /etc/os-release| awk '{print tolower($0)}'`
#sudo touch /etc/apt/sources.list.d/distroastro.list
#sudo sh -c 'echo "deb http://packages.distroastro.org/distroastro juno free non-free" >> /etc/apt/sources.list.d/distroastro.list'
#sudo sh -c 'echo "deb-src http://packages.distroastro.org/distroastro juno free non-free" >> /etc/apt/sources.list.d/distroastro.list'
#wget -qO - http://packages.distroastro.org/key | sudo apt-key add -

# add repository for eid-mw and eid-viewer software packages
# replace codename (for example: trusty) with right Ubuntu codename
RELEASE=`cat /etc/os-release |tail -n 1|cut -d"=" -f2`
sudo rm /etc/apt/sources.list.d/eid.list
sudo touch /etc/apt/sources.list.d/eid.list
sudo sh -c 'echo "deb http://files.eid.belgium.be/debian bionic main" >> /etc/apt/sources.list.d/eid.list'
sudo sh -c 'echo "deb http://files2.eid.belgium.be/debian bionic main" >> /etc/apt/sources.list.d/eid.list'

# add repository for google music manager software package
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/musicmanager/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

# 1. Add the Spotify repository signing key to be able to verify downloaded packages
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
# 2. Add the Spotify repository
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

# add osquery repository signing key to be able to verify downloaded packages
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B

# add partner repository for skype software package
# replace codename (for example: trusty) with right Ubuntu codename
#sudo touch /etc/apt/sources.list.d/partner.list
#sudo sh -c 'echo "deb http://archive.canonical.com/ubuntu bionic partner" >> /etc/apt/sources.list.d/partner.list'
#sudo sh -c 'echo "deb-src http://archive.canonical.com/ubuntu bionic partner" >> /etc/apt/sources.list.d/partner.list'


# add repository for Google Chrome browser
sudo touch /etc/apt/sources.list.d/googlechrome.list
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/googlechrome.list'

##########################################################################################################
# refresh list of available packages in Ubuntu repositories
sudo DEBIAN_FRONTEND=noninteractive apt-key add Repo.keys
sudo DEBIAN_FRONTEND=noninteractive apt update
##########################################################################################################

##########################################################################################################
# install base packages using basepackages files
cd $HOME/shell-scripts
sudo DEBIAN_FRONTEND=noninteractive apt install aptitude
# following aptitude command works in Ubuntu 16.04 LTS, but not in Ubuntu 17.04 or higher:
sudo DEBIAN_FRONTEND=noninteractive aptitude install `cat basepackages` -o APT::Install-Suggests="false"
# following apt command works in Ubuntu 17.04:
sudo DEBIAN_FRONTEND=noninteractive apt install `cat basepackages-extra`
# following apt command works in Debian 9:
sudo DEBIAN_FRONTEND=noninteractive apt install `cat basepackages-debian`
cd $HOME
##########################################################################################################


# install list of packages defined in packages files
# allpackages = basepackages + astropackages
# sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   `cat  allpackages` -o APT::Install-Suggests="false"

# install osquery
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   osquery

# install mp3gain and aacgain
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   aacgain mp3gain

# commented out following line, because it will break bluetooth support in Lubuntu/Xubuntu 14.04 LTS 64-bit 
# sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   pulseaudio*
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   arno-iptables-firewall
#sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   ufw
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   blueman
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   vlc-data vlc vlc-nox vlc-bin   browser-plugin-vlc sopcast-player
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   vlc vlc-nox

# install newest version of avconf
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   libav-tools

# install Enlightenment 17 (e17) GUI/desktop
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   e17

# Make A Bootable Windows 10 USB Install Stick On Linux using WinUSB Fork from Github
# source: https://github.com/slacka/WinUSB
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    winusb

# status: 20170620:
##########################################################################################################
# install Citrix Receiver icaclient version 13.4.0.10109380 in Ubuntu 16.04.2 64-bit
# Citrix Receiver icaclient version 13.5 and above cause SSL error 4 when trying to connect to corporate
# website
# Only works using Mozilla Firefox, not using Google Chrome
# source 1:  http://ubuntuforums.org/showthread.php?t=2181903
# source 2:  http://blog.vinnymac.org/?p=351
# source 3:  https://help.ubuntu.com/community/CitrixICAClientHowTo
##########################################################################################################
#cd $HOME
#mv $HOME/.ICAClient $HOME/.ICAClient_save 
#sudo dpkg -P icaclient
#sudo rm -rf $HOME/foo
#sudo dpkg --add-architecture i386 # only needed once
# sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   firefox apt-file git openssl ca-certificates
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   firefox apt-file git nspluginwrapper lib32z1 libc6-i386 libxml2:i386 libstdc++6:i386 libxerces-c3.1:i386 libcanberra-gtk-module:i386 libcurl3:i386 libasound2-plugins:i386 libgstreamer-plugins-base0.10-0:i386 openssl ca-certificates
#sudo apt-file update --architecture i386
#sudo apt-file update --architecture amd64
#git clone https://github.com/CloCkWeRX/citrix-receiver-ubuntu-fixed.git foo
#find foo/opt/Citrix/ICAClient/ -exec file {} ';' | grep "ELF" | grep "executable" > ica_elf_list
#cat ica_elf_list | while read f; do arch=$(echo "$f" | grep -o '..-bit' | sed 's/32-bit/i386/' | sed 's/64-bit/amd64/'); file=$(echo "$f" | awk '{print $1}' | sed 's/://g'); ldd "$file" | sed "s/^/$arch/g"; done | sort | uniq > ica_so_list
#cat ica_so_list | awk '{print $4}' | grep '^/' | sort | uniq | while read f; do dpkg -S "$f"; done > ica_deb_list
#cat ica_deb_list | awk '{print $1}' | sed 's/:$//g' | sort | uniq > ica_deb_list_final
#cat ica_so_list | grep "not found" > ica_so_missing
#cat ica_so_missing | while read f; do arch=$(echo "$f" | awk '{print $1}'); file=$(echo "$f" | awk '{print $2}'); apt-file find -x "$file$" -a $arch | sed "s/: /:$arch provides /g"; done > ica_missing_packages
#cat ica_missing_packages | awk '{print $3}' | sort | uniq | while read provided; do providers=$(grep "provides $provided" ica_missing_packages | awk '{print $1}'); count=$(echo $providers | wc -w); selected=$providers; if [ $count -gt 1 ]; then echo "Multiple packages can provide $provided, please select one:" >&2; select selected in $providers; do break; done < /dev/tty; echo "You selected $selected" >&2; fi; echo $selected; done > ica_selected_packages
#missing=$(cat ica_selected_packages | awk '{print $1}'); sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes   install $missing
#cat ica_elf_list | while read f; do arch=$(echo "$f" | grep -o '..-bit' | sed 's/32-bit/i386/' | sed 's/64-bit/amd64/'); file=$(echo "$f" | awk '{print $1}' | sed 's/://g'); ldd "$file" | sed "s/^/$arch/g"; done | sort | uniq > ica_so_list
#cat ica_so_list | awk '{print $4}' | grep '^/' | sort | uniq | while read f; do dpkg -S "$f"; done > ica_deb_list
#cat ica_deb_list | awk '{print $1}' | sed 's/:$//g' | sort | uniq > ica_deb_list_final
#cat ica_so_list | grep "not found" > ica_so_missing
#cat ica_so_missing | while read f; do arch=$(echo "$f" | awk '{print $1}'); file=$(echo "$f" | awk '{print $2}'); apt-file find -x "$file$" -a $arch | sed "s/: /:$arch provides /g"; done > ica_missing_packages
# make sure  ica_so_missing file is now empty:
#cat ica_so_missing
#checked=""; unnecessary=""; unchecked="$(cat ica_deb_list_final) EOF"; while read -d ' ' f <<< $unchecked; do checked="$f $checked"; candidates=$(apt-cache depends "$f" | grep '\sDepends' | awk '{print $2}' | sed 's/[<>]//g'); unchecked="$(for d in $candidates; do if ! grep -q $d <<< $checked; then echo -n "$d "; fi; done) $unchecked"; unchecked="$(echo $unchecked | sed "s/$f //g")"; unnecessary="$(for d in $candidates; do if ! grep -q $d <<< $unnecessary; then echo -n "$d "; fi; done) $unnecessary"; done; for u in $unnecessary; do echo "$u"; done > ica_implicit_dependencies
#original=$(cat ica_deb_list_final); for f in $original; do if ! grep -q $f ica_implicit_dependencies; then echo "$f"; fi; done > ica_explicit_dependencies
#sed -i 's/grep "i\[0-9\]86"/grep "i\\?[x0-9]86"/g' foo/DEBIAN/postinst
#new_depends="$(cat ica_explicit_dependencies | tr '\n' ',') nspluginwrapper"; sed -i "s/^Depends: .*$/Depends: $new_depends/" foo/DEBIAN/control
#rm -rf foo/opt/Citrix/ICAClient/keystore/cacerts
#ln -s /etc/ssl/certs foo/opt/Citrix/ICAClient/keystore/cacerts
#mkdir -p foo/usr/share/applications
#printf '[Desktop Entry]\nName=Citrix ICA client\nComment="Launch Citrix applications from .ica files"\nCategories=Network;\nExec=/opt/Citrix/ICAClient/wfica\nTerminal=false\nType=Application\nNoDisplay=true\nMimeType=application/x-ica' > foo/usr/share/applications/wfica.desktop
#dpkg -b foo icaclient_amd64_fixed_for_14.04_LTS.deb
#sudo dpkg -i icaclient_amd64_fixed_for_14.04_LTS.deb
#sudo DEBIAN_FRONTEND=noninteractive apt install -f
#sudo ln -s /usr/share/ca-certificates/mozilla/* /opt/Citrix/ICAClient/keystore/cacerts
#sudo c_rehash /opt/Citrix/ICAClient/keystore/cacerts/
#xdg-mime default wfica.desktop application/x-ica

# Thank you Michael May for reminding me to add the following step:
# Click on the “open menu” icon in the top right corner of the Mozilla Firefox interface.
# Then click on the Add-ons icon
# Click on Plugins and then on “Citrix Receiver for Linux”
# Choose “Always activate” option next to “Citrix Receiver for Linux”
# Attempt to access your Citrix site. If Firefox prompts you to open a .ica file, choose
# to open it with /opt/Citrix/ICAClient/wfica.sh, and tell Firefox to remember that choice.


# Install Spotify
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   spotify-client

# Install Live Wallpaper
# sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   livewallpaper  livewallpaper-config livewallpaper-indicator

# Install dupeguru-me which can find and delete similar music filenames using fuzzy logic
# rerun dupeguru-me on /media/IOMEGA/downloads/Youtube-playlists  after each mp3 conversion using YouTubeToMP3
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:hsoft/ppa
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   dupeguru-me

# install clipgrab, a friendly downloader for YouTube and other sites
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   clipgrab

# install Tor browser
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   tor-browser

# Install lxqt desktop environment => merge of lxde and razorqt desktops
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:lubuntu-dev/lubuntu-daily
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:gilir/q-project
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    lxqt-metapackage lxqt-panel openbox
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    liblxqt0 libqtxdg0 libqtxdg-data 
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    pcmanfm-qt  lxsession lximage-qt   lxrandr-qt
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    lxqt-about  lxqt-appswitcher  lxqt-config   lxqt-lightdm-greeter  
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    lxqt-notificationd    lxqt-policykit  lxqt-power  lxqt-powermanagement  lxqt-runner  lxqt-session
#sudo rm -rf /etc/xdg/lxlauncher
#sudo rm -rf /etc/xdg/lxpanel
#sudo rm -rf /etc/xdg/lxqt
#sudo rm -rf /etc/xdg/lxsession
#sudo rm -rf /etc/xdg/razor
#rm -rf ~/.config/razor*
#rm -rf ~/.config/pcman*
#rm -rf ~/.config/compiz*
#rm -rf ~/.config/lxpanel
#rm -rf ~/.config/lxsession/
#rm -rf ~/.config/lxterminal/
#rm -rf ~/.config/openbox*
#rm -rf ~/.config/unity*
# the following lxqt commands are dangerous and can cause network-manager to get uninstalled!
#sudo apt purge lxqt-metapackage lxqt-common lximage-qt  pcmanfm-qt 
#sudo apt install lxqt-metapackage lxqt-common 

# installing budgie desktop causes serious issues on mother's desktop pc
# Install budgie desktop environment with excellent font management (even on 40 inch Full HD TV screen)
#dconf reset -f /com/solus-project/budgie-panel/
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   budgie-desktop
#dconf reset -f /com/solus-project/budgie-panel/

#install  numix-icon-theme-circle (choose numix circle icon theme via lxqt start menu button
# then click on Preferences::Appearance::Icons Theme::Numix Circle Light
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    numix-icon-theme-circle

sudo DEBIAN_FRONTEND=noninteractive apt remove   --yes --force-yes    chromium-codecs-ffmpeg-extra

sudo DEBIAN_FRONTEND=noninteractive apt remove   --yes --force-yes    kaccounts-providers

# Install TLP - advanced power management command line tool for Linux
# TLP saves more laptop power than standard Ubuntu package laptop-mode-tools
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:linrunner/tlp
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo apt install  tlp
sudo apt install  tlp-rdw

##########################################################################################################
# install eid card reader middleware - replace codename (for example: trusty) with right Ubuntu codename
# Supported CCID readers:   http://pcsclite.alioth.debian.org/ccid/section.html
##########################################################################################################

# Prerequisites: Ubuntu 16.04.2 LTS 64-bit or newer (LiveUSB session or installed on HD/SSD), newest version of Mozilla Firefox (version 54.0 or newer), Ubuntu packages in procedure below
# install prerequisites for compiling eid-mw from Github
# Supported CCID readers:   http://pcsclite.alioth.debian.org/ccid/section.html
sudo rm /etc/apt/sources.list.d/eid.list
sudo touch /etc/apt/sources.list.d/eid.list
sudo sh -c 'echo "deb http://files.eid.belgium.be/debian bionic main" >> /etc/apt/sources.list.d/eid.list'
sudo sh -c 'echo "deb http://files2.eid.belgium.be/debian bionic main" >> /etc/apt/sources.list.d/eid.list'
cd
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 63F7D4AFF6D61D45  A35743EA6773D225   F9FDA6BED73CDC22 3B4FE6ACC0B21F32  4E940D7FDD7FB8CC  A040830F7FAC5991 16126D3A3E5C1192 
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:gertvdijk/opensc-backports
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove --purge beid*
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install  aptitude
sudo DEBIAN_FRONTEND=noninteractive apt install  usbutils pciutils eid-mw eid-viewer apt  firefox pcscd  default-jre 
sudo DEBIAN_FRONTEND=noninteractive apt install  opensc libacr38u libacr38ucontrol0 libacsccid1  libccid libusb-1.0-0 
sudo DEBIAN_FRONTEND=noninteractive apt install  libpcsclite1 libpcsclite-dev pcsc-tools ca-certificates libtool autoconf 
sudo DEBIAN_FRONTEND=noninteractive apt install  automake checkinstall git libgtk-3-dev libxml++2.6-dev libproxy-dev 
sudo DEBIAN_FRONTEND=noninteractive apt install  openssl libssl-dev libcurl4-openssl-dev
sudo DEBIAN_FRONTEND=noninteractive apt install  libgtk2.0-0 libgtk2.0-dev
sudo update-pciids
sudo update-usbids
# compile and install newest version of eid-mw using Github
cd
sudo rm -rf eid-mw
git clone https://github.com/Fedict/eid-mw.git
cd eid-mw/
autoreconf -i
./configure
make
sudo checkinstall
# press 2 and change eid package name to  eid-mw and hit <ENTER> key
# press 3 and change version to 4.2.10 and hit <ENTER> key
# Ensure that there are absolutely NO add-on EXTENSIONS installed in the Mozilla Firefox webbrowser
# The add-on PLUGINS like Citrix Receiver for Linux,OpenH264 and Shockwave Flash plugins can remain active in Mozilla Firefox, as they do not seem to interfere with the eid card reader.
# Close all web browser windows. Restart Mozilla Firefox browser and test eid card reader.


# install newest version of smtube (Youtube player using few CPU resources, better than streamlink)
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   libqtgui4 libqt4-xml libqt4-network libqt4-dbus phonon-backend-vlc
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   smtube

# install lightweight GTK-based Youtube viewer (inspired by XenialDog 64-bit LiveUSB distro)
# source: https://github.com/trizen/youtube-viewer
# Ubuntu/Linux Mint: sudo add-apt-repository ppa:nilarimogard/webupd8
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  youtube-viewer
# then run this Terminal command to launch: gtk-youtube-viewer

# install streamlink, which is replacement for minitube Youtube streamer and which uses less CPU:
# https://www.ostechnix.com/streamlink-watch-online-video-streams-command-line/
# example of valid command:  streamlink https://www.youtube.com/watch?v=Czy0pXRRZcs  best --player=mplayer
# using ~/.streamlinkrc and ~/.bashrc: s https://www.youtube.com/watch?v=Czy0pXRRZcs 1080p
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  streamlink

sudo npm install -g bower gulp  minimatch graceful-fs minimatch uuid lodash   
# install open-source VOIP and end-to-end encrypted messenger program called "Wire" for iOS,Android,Linux,Windows,MacOSX:
cd
sudo rm -rf wire-desktop/
git clone https://github.com/wireapp/wire-desktop
cd wire-desktop/
npm install
#run following command to start the wire desktop client
# npm start

# install googler - A Command Line Tool to Do ‘Google Search’ from Linux Terminal
# source: http://www.tecmint.com/google-commandline-search-terminal/#
# requires: python3 which is part of basepackages file
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    googler python3

# install LastPass:
cd /tmp
wget --no-check-certificate  https://lastpass.com/lplinux.tar.bz2
unp lplinux*
cd lplinux
./install_lastpass.sh 

# install newest version of WPS Office for GNU/Linux (MS Office compatible)
cd /tmp
rm download*
rm wps-office*
wget --no-check-certificate http://wps-community.org/downloads
wget --no-check-certificate  `echo "http://wps-community.org/downloads" | wget -O- -i- --no-check-certificate | hxnormalize -x  | hxselect -c -i ul li:first-child | lynx -stdin -dump -hiddenlinks=listonly -nonumbers| grep kdl|head -n 1`
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libsm6
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libsm6:i386 
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libpng12-0
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libpng12-0:i386
sudo dpkg -i wps-office*.deb
sudo DEBIAN_FRONTEND=noninteractive apt install -f
##########################################################################################################
# install proprietary TrueType fonts required by WPS Office for GNU/Linux
sudo DEBIAN_FRONTEND=noninteractive apt install msttcorefonts gsfonts-x11
sudo mkdir /usr/share/fonts/wps-office
cd /tmp
rm -rf settings*
git clone https://github.com/tkboy/settings.git
sudo mv settings/.fonts/*  /usr/share/fonts/wps-office
sudo fc-cache -f -v 
##########################################################################################################

# create symbolic link to wkhtmltopdf in /usr/local/bin after installing base packages
sudo ln -s /usr/bin/wkhtmltopdf /usr/local/bin/html2pdf

# install grub customizer
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:danielrichter2007/grub-customizer
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  grub-customizer


# install newest version of Libreoffice
# https://wiki.documentfoundation.org/Feature_Comparison:_LibreOffice_-_Microsoft_Office/fr
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:libreoffice/ppa
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libreoffice


# install following Libreoffice Calc extensions:
# http://extensions.libreoffice.org/extension-center/multisave
# http://extensions.libreoffice.org/extension-center/myparts
# http://extensions.libreoffice.org/extension-center/neuronica
# https://sites.google.com/site/vondorishi/advance-office-chart

# install following Libreoffice Writer extensions:
# http://extensions.libreoffice.org/extension-center/imath
# http://extensions.libreoffice.org/extension-center/texmaths-1
# http://extensions.libreoffice.org/extension-center/languagetool

#install deprecated, obsolete hal package so that fluendo content and DRM-demanding
# Flash websites like Hulu are supported in Lubuntu 13.10 or newer
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:mjblenner/ppa-hal
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  hal
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libhal1-flash

#install i-nex - I-nex is similar to CPU-Z in Windows, it uses the same interface to display your hardware information.
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:i-nex-development-team/daily
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes  ppa:nemh/gambas3
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  i-nex 

# install Variety - cool wallpaper changer
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:peterlevi/ppa
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  variety

#install pipelight which allows to run your favorite Silverlight application directly inside your Linux browser
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository  --yes ppa:ehoover/compholio
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository  --yes ppa:mqchael/pipelight
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   pipelight

# install google-talkplugin
#wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo DEBIAN_FRONTEND=noninteractive apt-key add - 
#sudo sh -c 'echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  google-talkplugin

# install daily build of firefox-trunk (bleeding edge browser)
#sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes  firefox
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:ubuntu-mozilla-daily/ppa
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   firefox-trunk



# Install kazam screen recording tool for Ubuntu 12.04 / 12.10 / 13.04
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:kazam-team/stable-series
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   kazam

# install shutter Screen Capture Tool In Ubuntu 12.04 / 12.10 / 13.04
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:dhor/myway
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   shutter

# install Final Term - excellent Terminal emulator in  Ubuntu 12.04 / 12.10 / 13.04
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:finalterm/daily
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   finalterm

# install xiki shell - A shell console with GUI features 
# http://xiki.org
# source: https://github.com/trogdoro/xiki

#cd $HOME
#sudo rm -rf xiki
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    ruby ruby2.3 ruby2.3-dev
#git clone git://github.com/trogdoro/xiki.git
#cd xiki
#sudo update-ca-certificates
#sudo gem sources -r https://rubygems.org/
#sudo gem sources -a http://rubygems.org/
#sudo gem update --system
#sudo gem sources -r http://rubygems.org/
#sudo gem sources -a https://rubygems.org/
#sudo gem install bundler   # <- no "sudo" if using rvm
#bundle                # <- no "sudo" if using rvm
#ln -s misc etc
#sudo ruby misc/command/copy_xiki_command_to.rb /usr/bin/xiki
#~/xiki/bin/xsh
# xiki web/start
# then navigate to http://localhost:8161/dbs
# to view the locally installed mysql databases, tables and fields
#cd $HOME

# install Google Music Manager - sync local mp3s in Ubuntu with ios or Android device
#wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
#sudo sh -c 'echo "deb http://dl.google.com/linux/musicmanager/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   google-musicmanager-beta
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   google-musicmanager

# install newest version of VLC player
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:videolan/master-daily
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   vlc

# install  libde265, which is an open source implementation of the h.265 video codec in order 
# to support playing HVEC codec using vlc player
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   vlc-plugin-libde265

# install spotify - can sync mp3 files between Ubuntu 13.10 and ipod nano 6th generation
#sudo DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 94558F59
#sudo sh -c 'echo "deb http://repository.spotify.com stable non-free" >> /etc/apt/sources.list.d/spotify.list'
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   spotify-client

# install atom text editor with integrated github support
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes  ppa:webupd8team/atom
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   atom

# install brackets text editor with support for asciidoc
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes  ppa:webupd8team/atom
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   brackets

# Lightworks 12.5 (professional non-linear video editing solution) is better than kdenlive and better than openshot
# http://news.softpedia.com/news/professional-non-linear-video-editing-lightworks-12-5-released-with-4k-support-493587.shtml

# DaVinci Resolve 12.0.1 Studio (video editor)
# https://www.blackmagicdesign.com/products/davinciresolve

# flowblade (video editor)
# https://github.com/jliljebl/flowblade/blob/master/flowblade-trunk/docs/INSTALLING.md

# install kdenlive video editor (one of the best video editors)
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes  ppa:philip5/extra
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   kdenlive

# install openshot which is a simple and easy to use video editor, like a good substitute for the windows movie maker
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:openshot.developers/ppa
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   openshot

# install Handbrake - open source video transcoder - add Subtitles (VobSub, Closed Captions CEA-608, SSA, SRT)
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes  ppa:stebbins/handbrake-releases
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  handbrake 

# install SopCast webTV player = highest quality sport streaming service for Ubuntu
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes  ppa:lyc256/sopcast-player-ppa
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  sopcast-player 

# install qbittorrent client
# import RSS feeds from http://showrss.info/?cs=feeds  into qbittorrent client
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:surfernsk/internet-software
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   qbittorrent

# install frostwire mp3 client
#cd
#sudo rm -rf frostwire
#git clone https://github.com/frostwire/frostwire
#cd frostwire/desktop
#gradle build
cd /tmp
rm frostwire*.deb
FROSTWIREVERSION=`echo "http://www.frostwire.com/download/?os=ubuntu" | wget -O- -i- --no-check-certificate | hxnormalize -x| grep \.deb |cut -d"\"" -f2`
wget --no-check-certificate `echo $FROSTWIREVERSION`
sudo dpkg -i frostwire*.deb
sudo DEBIAN_FRONTEND=noninteractive apt install  --yes --force-yes -f

# install desurium game client
#sudo DEBIAN_FRONTEND=noninteractive apt-add-repository --yes ppa:makson96/desurium
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   desurium

# install 64-bit compatible Steam client
wget --no-check-certificate media.steampowered.com/client/installer/steam.deb
sudo dpkg -i steam.deb
sudo DEBIAN_FRONTEND=noninteractive apt install  --yes --force-yes -f

##########################################################################################################
# install LGOGDownloader game client (unofficial downloader to GOG.com for Linux users) 
# It uses the same API as the official GOGDownloader.
# Prerequisite: first create valid username and password at gog.com website
##########################################################################################################
cd
sudo rm -rf $HOME/lgogdownloader
# install game client prerequisites:
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    libtinyxml2-dev build-essential
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libcurl4-openssl-dev liboauth-dev libjsoncpp-dev 
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libhtmlcxx-dev libboost-system-dev 
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libboost-filesystem-dev libboost-regex-dev 
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libboost-program-options-dev libboost-date-time-dev 
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libtinyxml-dev librhash-dev help2man
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libboost-iostreams1.63-dev
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libboost-iostreams-dev
# compile and install game client:
git clone https://github.com/Sude-/lgogdownloader.git
cd lgogdownloader
#sudo make release
#sudo make install
sudo make clean
sudo cmake .
sudo make
sudo checkinstall

# Added on January 16, 2016
# Fix openssh on Linux (vulnerability CVE-2016-0777)
# Source: http://www.cyberciti.biz/faq/howto-openssh-client-security-update-cve-0216-0777-cve-0216-0778/
echo 'UseRoaming no' | sudo tee -a /etc/ssh/ssh_config

# install lynis (formerly called rkhunter) 
# Security auditing tool and assists with compliance testing (HIPAA/ISO27001/PCI DSS) and system hardening)
cd
sudo rm -rf $HOME/lynis
git clone https://github.com/CISOfy/lynis.git
cd lynis
sudo chmod -R 640 ./include/*
sudo chown root:root ./include/*
sudo ./lynis --version
# sudo ./lynis audit system

#compile and install newest version of openssl in Ubuntu 14.04 LTS
cd
# sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   checkinstall build-essential
sudo DEBIAN_FRONTEND=noninteractive apt build-dep --yes --force-yes openssl
sudo rm -rf ~/openssl
git clone https://github.com/openssl/openssl.git
cd openssl
sudo ./config
sudo make
# sudo make test
sudo checkinstall
sudo rm -rf ~/openssl
sudo mv /usr/bin/c_rehash /usr/bin/c_rehash.$LogDay.backup
sudo mv /usr/bin/openssl /usr/bin/openssl.$LogDay.backup
sudo ln -s /usr/local/bin/c_rehash /usr/bin/c_rehash
sudo ln -s /usr/local/bin/openssl /usr/bin/openssl
openssl version
apt-cache show openssl

# Dependency to compile and install first: openssl
# https://mark911.wordpress.com/2015/01/10/how-to-compile-and-install-newest-version-of-openssl-in-ubuntu-14-04-lts-64-bit-via-github/
# Then compile and install curl from github source in Ubuntu 14.04 LTS 64-bit
cd
sudo DEBIAN_FRONTEND=noninteractive apt update --yes --force-yes 
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   checkinstall build-essential cmake rtmpdump
# sudo DEBIAN_FRONTEND=noninteractive apt purge --yes --force-yes  curl
# sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes build-dep curl
# sudo rm -rf curl curl-build
# mkdir curl-build
# git clone https://github.com/bagder/curl.git
# cd curl
# sudo ./buildconf
# cd lib
# LIB=`pwd`
# cd ..
# sudo ./configure --without-librtmp --enable-shared=no --libdir=`echo $LIB`
# sudo make clean
# sudo make -I `echo $LIB`
# sudo make check
# result of sudo make check should be as follows:
#============================================================================
#Testsuite summary for curl -
#============================================================================
# TOTAL: 2
# PASS:  2
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
#============================================================================
# sudo checkinstall
# set checkinstall curl package version to 7.45 (most current version at this moment)
# before proceeding with the creation of the checkinstall .deb package
# apt-cache show curl
# output of 'apt-cache show curl' command should look like this:
#Package: curl
#Status: install ok installed
#Priority: extra
#Section: checkinstall
#Installed-Size: 6020
#Maintainer: root
#Architecture: i386
#Version: 7.45
#Provides: curl
#Description: Package created with checkinstall 1.6.2
#Description-md5: 556b8d22567101c7733f37ce6557412e
# curl --version
# result of curl --version should be as follows:
# !!!! Make sure that curl and libcurl are both the newest version, in this case: version 7.45.0-DEV !!!!!!!!
#curl 7.45.0-DEV (i686-pc-linux-gnu) libcurl/7.45.0-DEV OpenSSL/1.0.1f zlib/1.2.8 libidn/1.28
#Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtsp smb smbs smtp smtps telnet tftp 
#Features: IDN IPv6 Largefile NTLM NTLM_WB SSL libz TLS-SRP UnixSockets 


# install kde plasma 5 desktop environment
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes  ppa:neon/kf5
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes   install project-neon5-session project-neon5-utils project-neon5-konsole project-neon5-plasma-workspace-wallpapers project-neon5-breeze

# Cuttlefish is an ingenious little tool. It allows you to define a set of actions that occur when a certain stimulus is activated.
# sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:noneed4anick/cuttlefish
#sudo DEBIAN_FRONTEND=noninteractive apt update
cd
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   cuttlefish 

# Install Ubuntu Tweak to easily uninstall old kernel versions
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:tualatrix/ppa
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   ubuntu-tweak

# install Skype (Video Conferencing software)
# better alternative: access https://web.skype.com via Chromium webbrowser in Ubuntu 16.04 LTS
# Only Chromium webbrowser seems to be compatible with web.skype.com, not Firefox or Google Chrome
# better Video Conferencing software: Firefox Hello (using WebRTC)
cd /tmp
rm skype*.deb
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   skype skype-bin
#sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  skype
wget --no-check-certificate  https://go.skype.com/skypeforlinux-64.deb
sudo dpkg -i skypeforlinux-64.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   gtk2-engines-murrine:i386 gtk2-engines-pixbuf:i386 sni-qt:i386
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   pidgin pidgin-skypeweb purple-skypeweb

# install Y PPA Manager
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes ppa:webupd8team/y-ppa-manager
#sudo DEBIAN_FRONTEND=noninteractive apt update
cd $HOME
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    y-ppa-manager

# libdvdcss2, to play encrypted DVDs
cd $HOME
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   libdvdcss2
sudo /usr/share/doc/libdvdread4/./install-css.sh



###############################################################################################
#     WEBBROWSER SOFTWARE SECTION                                                             #
###############################################################################################



if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  # 64-bit stuff here
# install dolphin (Nintendo Wii emulator)
# requires: Core i5 or Core i7 CPU and DirectX 11 videocard
# cd /tmp
# sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libsdl2-2.0-0
# rm *.html
# wget --no-check-certificate  https://dolphin-emu.org/download/
# wget `grep deb index.html |head -n 1|cut -d"\"" -f4`
# sudo dpkg -i dolphin*.deb
  
# install newest version of minitube (requires personal API key from 
# https://console.developers.google.com/apis/credentials )
# my personal API key does not work with minitube in April 2017
# cd /tmp
# rm minitube*
# sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   minitube
# wget -O minitube.sh http://drive.noobslab.com/data/apps/minitube/minitube.sh
# bash minitube.sh
# sudo DEBIAN_FRONTEND=noninteractive apt install -f

# install Vivaldi web browser
cd /tmp
rm *.deb
wget --no-check-certificate  https://vivaldi.com/download/
wget --no-check-certificate   `grep deb index.html |grep amd64|cut -d"\"" -f4`
sudo dpkg -i vivaldi*.deb
sudo apt-get install -f

  
# install Google Chrome browser which includes newest version of Adobe Flash - other browsers do not
cd $HOME
wget --no-check-certificate https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome*.deb
# fix the Google Chrome dependencies issue
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install

# first remove old installation of seamonkey web browser
cd /tmp
rm index.htm*
sudo rm -rf /opt/seamonkey /usr/bin/seamonkey  /tmp/seamonk*
# install bleeding edge version of seamonkey web browser
wget --no-check-certificate   http://ftp.mozilla.org/pub/seamonkey/nightly/latest-comm-aurora/
filename=`echo "http://ftp.mozilla.org/pub/seamonkey/nightly/latest-comm-aurora/" | wget -O- -i- --no-check-certificate | hxnormalize -x  | hxselect -c -i "td" -s '\n' | lynx -stdin -dump -hiddenlinks=listonly -nonumbers|grep bz2|grep x86_64| tail -n 1|cut -c 8-`
wget --no-check-certificate   http://ftp.mozilla.org`echo $filename`
tar -xjvf seamonkey*
wget --no-check-certificate  https://vivaldi.com/download/sudo cp -r seamonkey /opt/seamonkey
sudo ln -sf /opt/seamonkey/seamonkey /usr/bin/seamonkey

# install YouTubeToMP3 - Youtube playlist downloader with no limit on number of downloaded mp3 files
# still works correctly in August 2017
cd /tmp
rm YouTube*
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f purge youtube-to-mp3
wget --no-check-certificate  `echo "http://www.mediahuman.com/download.html" | wget -O- -i- --no-check-certificate | hxnormalize -x   | lynx -stdin -dump -hiddenlinks=listonly -nonumbers|grep amd64|grep MP3`
sudo dpkg -i YouTubeToMP3*.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install

# install 4kyoutubetomp3 that converts personal Youtube playlists to Youtube mp3s
#cd $HOME
#VIDEODOWNLOADERREMOTEDIR="https://www.4kdownload.com/download"
#url=$(wget -O- -q --no-check-certificate `echo $VIDEODOWNLOADERREMOTEDIR` |  sed -ne 's/^.*"\([^"]*4kyoutubetomp3[^"]*amd64*\.deb\)".*/\1/p' | sort -r | head -1) 
# Create a temporary directory
#dir=$(mktemp -dt)
#cd "$dir"
# Download the .deb file
#wget `echo $url`
# Install the package
#sudo dpkg -i "${url##*/}"
# Clean up
#rm "${url##*/}"
#cd $HOME
#rm -rf "$dir"
#cd $HOME
#sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install


# install Google Earth in Ubuntu 13.10 64-bit or newer
#     uninstall old Google Earth
cd $HOME
rm -rf $HOME/.googleearth
sudo rm -rf /opt/google/earth/
sudo rm -rf /opt/google-earth;sudo rm /usr/share/mime/application/vnd.google-earth.* /usr/share/mimelnk/application/vnd.google-earth.* /usr/share/applnk/Google-googleearth.desktop /usr/share/mime/packages/googleearth-mimetypes.xml /usr/share/gnome/apps/Google-googleearth.desktop /usr/share/applications/Google-googleearth.desktop /usr/local/bin/googleearth
sudo rm googleearth*.deb
sudo rm google-earth*.deb
sudo rm GoogleEarth*
sudo dpkg -P google-earth-stable
sudo dpkg -P googleearth
sudo dpkg -P googleearth-package
# install new Google Earth
# sudo dpkg --add-architecture i386
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   libcurl3:i386 libfreeimage3 lib32nss-mdns multiarch-support lsb-core
wget --no-check-certificate https://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb
sudo dpkg -i google-earth*.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install


# install newest wine version 
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository  --yes --force-yes -f ppa:ubuntu-wine/ppa 
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt purge --yes --force-yes  winehq-staging wine wine1.4 wine1.5 wine1.6 wine1.7 wine1.8 wine1.9
sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes -f  --install-recommends install wine-staging
sudo ln -s /opt/wine-staging/bin/wine  /usr/bin/wine

# install Teamviewer server + client which depends on wine1.7
# Direct download URL:  http://download.teamviewer.com/download/teamviewer_i386.deb
cd /tmp
sudo DEBIAN_FRONTEND=noninteractive apt purge --yes --force-yes  teamviewer
sudo rm -rf /opt/teamviewer*
rm -rf ~/.config/teamviewer8
rm -rf ~/.config/teamviewer9
rm -rf ~/.config/teamviewer10
rm -rf ~/.config/teamviewer11
rm *.deb
wget --no-check-certificate `echo "https://www.teamviewer.com/en/download/linux.aspx" | wget -O- -i- --no-check-certificate | hxnormalize -x | lynx -stdin -dump -hiddenlinks=listonly -nonumbers|grep i386|grep deb|head -n 1`
rm team*host*.deb
sudo dpkg -i teamviewer*.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install
# teamviewer autostart fix procedure - add configuration lines below to /etc/rc.local
sudo -k teamviewer --daemon start
cd /opt/teamviewer/tv_bin/script
sudo cp teamviewerd.sysv /etc/init.d/
sudo chmod 755 /etc/init.d/teamviewerd.sysv
sudo update-rc.d teamviewerd.sysv defaults
cd
# !!!!!! Also add teamviewer program to KDE's Autostart (autostart launch command to use: teamviewer)

# install Viber program
#cd $HOME
#wget download.cdn.viber.com/cdn/desktop/Linux/viber.deb
#sudo dpkg -i viber.deb 
#sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install


else
  # 32-bit stuff here

# install newest version of minitube
#cd /tmp
#rm minitube*
#sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   minitube
#wget --no-check-certificate http://flavio.tordini.org/files/minitube/minitube.deb
#sudo dpkg -i minitube.deb
# sudo DEBIAN_FRONTEND=noninteractive apt install minitube
#sudo DEBIAN_FRONTEND=noninteractive apt install -f

# install Vivaldi web browser
cd /tmp
rm *.deb
wget --no-check-certificate  https://vivaldi.com/download/
wget --no-check-certificate  `grep deb index.html |grep i386|cut -d"\"" -f4`
sudo dpkg -i vivaldi*.deb
sudo apt-get install -f

# install Google Chrome browser which has better support for Flash websites (Youtube, ...)
cd $HOME
wget --no-check-certificate https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
sudo dpkg -i google-chrome*.deb
# fix the Google Chrome dependencies issue
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install

# first remove old installation of seamonkey web browser
cd /tmp
rm index.htm*
sudo rm -rf /opt/seamonkey /usr/bin/seamonkey  /tmp/seamonk*
# install bleeding edge version of seamonkey web browser
wget --no-check-certificate   http://ftp.mozilla.org/pub/seamonkey/nightly/latest-comm-aurora/
filename=`echo "http://ftp.mozilla.org/pub/seamonkey/nightly/latest-comm-aurora/" | wget -O- -i- --no-check-certificate | hxnormalize -x  | hxselect -c -i "td" -s '\n' | lynx -stdin -dump -hiddenlinks=listonly -nonumbers|grep bz2|grep i686| tail -n 1|cut -c 8-`
wget --no-check-certificate   http://ftp.mozilla.org`echo $filename`
tar -xjvf seamonkey*
sudo cp -r seamonkey /opt/seamonkey
sudo ln -sf /opt/seamonkey/seamonkey /usr/bin/seamonkey

# install YouTubeToMP3 - Youtube playlist downloader
cd /tmp
rm YouTube*
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f purge youtube-to-mp3
wget --no-check-certificate  `echo "http://www.mediahuman.com/download.html" | wget -O- -i- --no-check-certificate | hxnormalize -x   | lynx -stdin -dump -hiddenlinks=listonly -nonumbers|grep i386|grep MP3`
sudo dpkg -i YouTubeToMP3*.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install

# install 4kvideodownloader that converts personal Youtube playlists to Youtube mp3s
#VIDEODOWNLOADERREMOTEDIR="http://downloads.4kdownload.com/app/"
#url=$(wget -O- -q --no-check-certificate `echo $VIDEODOWNLOADERREMOTEDIR` |  sed -ne 's/^.*"\([^"]*videodownloader[^"]*i386*\.deb\)".*/\1/p' | sort -r | head -1) 
# Create a temporary directory
#dir=$(mktemp -dt)
#cd "$dir"
# Download the .deb file
#wget $VIDEODOWNLOADERREMOTEDIR`echo $url`
# Install the package
#sudo dpkg -i "${url##*/}"
# Clean up
#rm "${url##*/}"
#cd $HOME
#rm -rf "$dir"
#cd $HOME
#sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install

# install Google Earth in Ubuntu 13.10 32-bit or newer
#     uninstall old Google Earth
cd $HOME
rm -rf $HOME/.googleearth
sudo rm -rf /opt/google/earth/
sudo rm -rf /opt/google-earth;sudo rm /usr/share/mime/application/vnd.google-earth.* /usr/share/mimelnk/application/vnd.google-earth.* /usr/share/applnk/Google-googleearth.desktop /usr/share/mime/packages/googleearth-mimetypes.xml /usr/share/gnome/apps/Google-googleearth.desktop /usr/share/applications/Google-googleearth.desktop /usr/local/bin/googleearth
sudo rm googleearth*.deb
sudo rm google-earth*.deb
sudo rm GoogleEarth*
sudo dpkg -P google-earth-stable
sudo dpkg -P googleearth
sudo dpkg -P googleearth-package
# install new Google Earth
# sudo dpkg --add-architecture i386
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   libcurl3:i386 libfreeimage3 lib32nss-mdns multiarch-support lsb-core
wget --no-check-certificate https://dl.google.com/dl/earth/client/current/google-earth-stable_current_i386.deb
sudo dpkg -i google-earth*.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install

# install newest wine version 
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository  --yes --force-yes -f ppa:ubuntu-wine/ppa 
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt purge --yes --force-yes  winehq-staging wine wine1.4 wine1.5 wine1.6 wine1.7 wine1.8 wine1.9
sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes -f  --install-recommends install wine-staging
sudo ln -s /opt/wine-staging/bin/wine  /usr/bin/wine

# install Teamviewer server + client which depends on wine1.7
cd /tmp
sudo DEBIAN_FRONTEND=noninteractive apt purge --yes --force-yes  teamviewer
sudo rm -rf /opt/teamviewer*
rm -rf ~/.config/teamviewer8
rm -rf ~/.config/teamviewer9
rm -rf ~/.config/teamviewer10
rm -rf ~/.config/teamviewer11
rm *.deb
wget --no-check-certificate `echo "https://www.teamviewer.com/en/download/linux.aspx" | wget -O- -i- --no-check-certificate | hxnormalize -x | lynx -stdin -dump -hiddenlinks=listonly -nonumbers|grep i386`
rm team*host*.deb
sudo dpkg -i teamviewer*.deb

sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install
# teamviewer autostart fix procedure - add configuration lines below to /etc/rc.local
sudo -k teamviewer --daemon start
cd /opt/teamviewer/tv_bin/script
sudo cp teamviewerd.sysv /etc/init.d/
sudo chmod 755 /etc/init.d/teamviewerd.sysv
sudo update-rc.d teamviewerd.sysv defaults
cd
# !!!!!! Also add teamviewer program to KDE's Autostart (autostart launch command to use: teamviewer)

fi

# install opera-developer browser (including WhatsApp and built-in free Opera VPN client)
wget -O- http://deb.opera.com/archive.key | sudo DEBIAN_FRONTEND=noninteractive apt-key add -
sudo sh -c 'echo "deb http://deb.opera.com/opera/ stable non-free" >> /etc/apt/sources.list'
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove opera
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   opera-developer

# Enable and upgrade the open-source graphics drivers for Intel, AMD Radeon, and Nouveau (NVIDIA)
#sudo DEBIAN_FRONTEND=noninteractive add-apt-repository  --yes --force-yes -f ppa:oibaf/graphics-drivers
#sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes -f upgrade

# OBSOLETE - install Multimedia codecs
# sudo -E wget --output-document=/etc/apt/sources.list.d/medibuntu.list http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list && sudo DEBIAN_FRONTEND=noninteractive apt --quiet update && sudo DEBIAN_FRONTEND=noninteractive apt --yes --quiet --allow-unauthenticated install medibuntu-keyring && sudo DEBIAN_FRONTEND=noninteractive apt --quiet update
# sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   non-free-codecs libdvdcss

# install Realplayer (latest version is from 2009)
#sudo DEBIAN_FRONTEND=noninteractive apt update && sudo DEBIAN_FRONTEND=noninteractive apt install lsb
#wget --no-check-certificate  http://client-software.real.com/free/unix/RealPlayer11GOLD.deb
#sudo dpkg -i RealPlayer11GOLD.deb

# uninstall Java due to all the critical security issues in 2013
# sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove java-common
# sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove default-jre
# sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove default-jre-headless
# sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove gcj-jre-headless
# sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove openjdk-?

#sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes remove mysql-server-core-?.?
sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes  remove unity-lens-music unity-lens-photos unity-lens-shopping unity-lens-video
# sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   pulseaudio*
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   arno-iptables-firewall
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   mono-runtime
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   libmono-2.0-dev
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes    xscreensaver  xscreensaver-data gnome-screensaver
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   evolution-data-server-common samba snapd
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   gcc-4.6 gcc-4.7 gcc-4.7-base

###############################################################################################
#     WORKAROUNDS FOR BUGS / ISSUES / CPU / MEMORY OVERCONSUMPTION                                                            #
###############################################################################################

# temporary workaround for ASUS Z170 Pro Gamer motherboards:
# sudo apt purge xfce4-notifyd lxqt-powermanagement
# end of workaround.
# April 3, 2016: temporary workaround for issue/problem where pcscd process is using 97% of CPU all the time:
# sudo apt purge pcscd
# end of workaround.

sudo DEBIAN_FRONTEND=noninteractive apt autoclean
sudo DEBIAN_FRONTEND=noninteractive apt clean

# install multisystem tool (best multiboot USB stick creator for Ubuntu):
# procedure:  http://community.linuxmint.com/tutorial/view/1219
# Use axel command line utility to download all the .iso images into the /tmp directory
# then import each .iso image file one by one into multisystem
# multisystem can successfully boot Linux Mint, Knoppix (4GB edition), 
# System Rescue CD and Hiren Boot CD from the same USB stick
# multisystem seems to work better than YUMI, because multisystem can successfully boot
# Knoppix (4GB edition) but YUMI could not, when having multiple iso images on the same USB stick
cd /tmp
wget --no-check-certificate http://liveusb.info/multisystem/install-depot-multisystem.sh.tar.bz2
unp install-depot-multisystem.sh.tar.bz2
./install-depot-multisystem.sh
rm *.sh
rm *.html

# Install yEd graph editor (includes BPMN icons) (Business Process Modeling Notation (BPMN) diagram creation tool))
# (powerful desktop application that can be used to quickly and effectively generate high-quality diagrams)
# Save diagrams in .pdf format so they can be included as graphics in a new latex document in texmaker
# Allows easy creation of Entity Relationship (ER) diagrams (as part of data modeling by data scientist)
# documentation:  http://www.linuxuser.co.uk/tutorials/create-flowcharts-with-yedcreate-flowcharts-with-yed
# other BPMN tools: https://en.wikipedia.org/wiki/Comparison_of_Business_Process_Modeling_Notation_tools
# online version of program: https://www.yworks.com/yed-live/
# online alternative program: https://www.draw.io/
MACHINE_TYPE=`uname -m`
cd /tmp
rm yEd*
rm *.html
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  # 64-bit stuff here
wget --no-check-certificate https://www.yworks.com/en/products_yed_download.html
YEDVERSION=`echo "https://www.yworks.com/products/yed/download" | wget -O- -i- --no-check-certificate | hxnormalize -x |grep productVersion| tail -n 1|cut -d">" -f2| cut -d"<" -f1`
wget --no-check-certificate https://www.yworks.com/products/yed/demo/yEd-`echo $YEDVERSION`_64-bit_setup.sh
sh yEd-`echo $YEDVERSION`_64-bit_setup.sh
else
  # 32-bit stuff here
wget --no-check-certificate https://www.yworks.com/en/products_yed_download.html
YEDVERSION=`echo "https://www.yworks.com/products/yed/download" | wget -O- -i- --no-check-certificate | hxnormalize -x |grep productVersion| tail -n 1|cut -d">" -f2| cut -d"<" -f1`
wget --no-check-certificate https://www.yworks.com/products/yed/demo/yEd-`echo $YEDVERSION`_32-bit_setup.sh
sh yEd-`echo $YEDVERSION`_32-bit_setup.sh
fi



# install Pixum fotoservice software (cheaper than Albelli and Kruidvat - December 2016)
cd $HOME
rm -rf Kruidvat*
rm -rf Pixum*
rm install.pl
rm linux
cd /tmp
wget --no-check-certificate https://dls.photoprintit.com/api/getClient/12455/hps/c3303030303030303030303030303030303030303030303030353933333036366/linux 
tar -zxvf linux
./install.pl 
#chmod +x ~/shell-scripts/pixum-install.pl
#perl ~/shell-scripts/pixum-install.pl

#############################################################################################
# install and run newest version of bleachbit (cleanup utility) in Ubuntu 14.04 LTS 64-bit
#############################################################################################
# install prerequisites for bleachbit
cd
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes  install build-essential unp git
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes  install lynx-cur html-xml-utils
# install and run newest version of bleachbit (cleanup utility) in Ubuntu 14.04 LTS 64-bit
cd
rm *.tar.bz2
rm download*
sudo rm -rf bleachbit*
URL=`echo "http://bleachbit.sourceforge.net/download/source" | wget -O- -i- --no-check-certificate | hxnormalize -x| lynx -stdin -dump -hiddenlinks=listonly -nonumbers|grep bz2| tail -n 1`
wget --no-check-certificate `echo $URL`
tar xvjf bleachbit*tar.bz2 # unpack the archive
cd bleachbit* # change directory
make -C po local # build translations (optional)
sudo python bleachbit.py # start BleachBit GUI

#############################################################################################
# install new secure /etc/hosts file to block malware websites
#############################################################################################
LogDay=`date -I`
cd 
sudo rm -rf hosts
sudo cp /etc/hosts /etc/hosts.$LogDay.backup
git clone https://github.com/StevenBlack/hosts.git
cd hosts
sudo python3 updateHostsFile.py -a -r
sudo chmod 444 /etc/hosts
# copy new hosts file to Windows partition as well:
sudo mv /media/windows/Windows/System32/drivers/etc/hosts  /media/windows/Windows/System32/drivers/etc/hosts.$LogDay.backup
sudo cp  /etc/hosts  /media/windows/Windows/System32/drivers/etc/hosts
# convert line breaks from UNIX to DOS format:
sudo unix2dos -o /media/windows/Windows/System32/drivers/etc/hosts

#############################################################################################
# install Soundcloud Music Playlist Downloader
#############################################################################################
cd 
sudo rm -rf scdl
git clone https://github.com/flyingrub/scdl.git
cd scdl
sudo python3 setup.py install
#############################################################################################
# install newest version of wget from Github sources in order to solve following wget issue in Ubuntu 14.04 LTS : 
# https://github.com/chapmanb/bcbio-nextgen/issues/1133
#############################################################################################
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   flex libboost-all-dev cmake libqt4-dev 
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   build-essential libqtwebkit-dev checkinstall
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   libgnutls28-dev libgnutls-openssl27
sudo DEBIAN_FRONTEND=noninteractive apt build-dep --yes --force-yes   wget
cd
sudo rm -rf wget
git clone https://github.com/mirror/wget.git
cd wget
./bootstrap
./configure
sudo make
sudo checkinstall
# Press 3 and ENTER and then set version to 1.17.1.13
apt-cache show wget

# Terminal output should look like this:
# apt-cache show wget
# Package: wget
# Status: install ok installed
# Priority: extra
# Section: checkinstall
# Installed-Size: 3864
# Maintainer: root
# Architecture: amd64
# Version: 1.17.1.13-1
# Provides: wget
# Conffiles:
#  /etc/wgetrc 618c05b4106ad20141dcf6deada2e87f obsolete
# Description: Package created with checkinstall 1.6.2
# Description-md5: 556b8d22567101c7733f37ce6557412e

#############################################################################################
#  install gdm3 display manager to avoid problem getting to login screen in Ubuntu 16.04 LTS
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    gdm gdm3
#############################################################################################
sudo apt dist-upgrade
#############################################################################################
# Fish shell installation
#############################################################################################
# set fish shell as default shell
chsh -s /usr/bin/fish
#To switch your default shell back, you can run:
#chsh -s /bin/bash
cd $HOME
# customize fish shell using oh-my-fish
rm -rf ~/.oh-my-fish ~/.config/fish/ ~/.local/share/omf  
git clone https://github.com/oh-my-fish/oh-my-fish ~/.oh-my-fish
cp ~/.oh-my-fish/templates/config.fish ~/.config/fish/config.fish
chmod +x ~/.oh-my-fish/bin/install
~/.oh-my-fish/bin/install

# delete old custom aliases in ~/.config/fish/config.fish file
egrep -v 'apt|d-u|wget|googler|streamlink'  ~/.config/fish/config.fish > ~/.config/fish/config.fish.$LogDay.backup
cp ~/.config/fish/config.fish.$LogDay.backup ~/.config/fish/config.fish

# define custom aliases in ~/.config/fish/config.fish file
echo "alias apti='sudo apt update ; sudo apt install '" >> ~/.config/fish/config.fish
echo "alias aptr='sudo apt remove '" >> ~/.config/fish/config.fish
echo "alias aptp='sudo apt purge '" >> ~/.config/fish/config.fish
echo "alias aptu='sudo apt update'" >> ~/.config/fish/config.fish
echo "alias apts='apt search '" >> ~/.config/fish/config.fish
echo "alias d-u='sudo apt update ; sudo apt upgrade'" >> ~/.config/fish/config.fish
echo "alias wget='wget --no-check-certificate'" >> ~/.config/fish/config.fish
echo "alias g='googler -n 10 -c be -x '" >> ~/.config/fish/config.fish
alias wget="wget --no-check-certificate"

# install theme for fish shell
omf update
omf theme robbyrussell

#############################################################################################
# End of Fish shell installation
#############################################################################################

# run shellshock test to see if bash is vulnerable
#cd $HOME
#rm *.sh
#wget --no-check-certificate https://shellshocker.net/shellshock_test.sh ; bash shellshock_test.sh

# clean up current directory
echo "Performing file cleanup"
cd $HOME
rm *.deb
rm *.exe
mv *.km? $KMZ
mv *.pdf $PDF
rm *gz
rm *tar*
mv *.zip $ZIP
rm *.cab
rm *.crt
rm .goutputstrea*
rm *.html
rm *.sh
rm *.xpi
rm ica_*
rm google*

# show total installation duration:
end=$(date +%s)
runtime=$(python -c "print '%u:%02u' % ((${end} - ${start})/60, (${end} - ${start})%60)")
echo "Runtime was $runtime (minutes+seconds)"

# show list of extra installed files:
cd
comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) > filelist-after-installing.txt
echo "Here is the list of extra installed files using this bash script:"
sdiff -s filelist-before-installing.txt  filelist-after-installing.txt
sdiff -s filelist-before-installing.txt  filelist-after-installing.txt > filelist-delta.txt
read -p "Press <ENTER> key to continue with Astronomy section or CTRL-C to abort"

###############################################################################################
#     ASTRONOMY SOFTWARE SECTION                                                              #
###############################################################################################

# install zotero add-on for Mozilla Firefox
#cd $HOME
#wget --no-check-certificate  https://download.zotero.org/extension/zotero-4.0.20.2.xpi
#gksudo firefox -install-global-extension zotero-4.0.20.2.xpi
echo "proceed with Astronomy section of script...."
cd $HOME/shell-scripts
sudo DEBIAN_FRONTEND=noninteractive aptitude install `cat astropackages` -o APT::Install-Suggests="false"
cd $HOME

sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   stellarium

# install texlive 2012.201206 packages (will upgrade texlive 2009 to texlive 2012.201206 in Ubuntu 12.04)
# sudo DEBIAN_FRONTEND=noninteractive add-apt-repository  --yes ppa:texlive-backports/ppa
#sudo DEBIAN_FRONTEND=noninteractive apt update
#sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes  install  texlive-latex-extra texlive-bibtex-extra latex-xcolor biber
#sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes  install  texlive-fonts-recommended texlive-binaries texlive-latex-base texlive-publishers
#sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes  install  texlive-latex-extra biblatex

# install casapy-upstream-binary  - Common Astronomy Software Applications package provided by NRAO, python bindings
# uses more than 4 GB of free disk space!
#cd
#mkdir casa
#cd casa
#wget --no-check-certificate  https://casa.nrao.edu/download/distro/linux/release/el7/casa-release-4.7.2-el7.tar.gz

sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --yes   ppa:olebole/astro-bionic
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   aladin
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   casacore 
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   cpl
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   esorex
# download and decompress SAOImage DS9 software
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   saods9 
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   sextractor 


# download CSC KML Interface to Sky in Google Earth
echo "Downloading CSC KML Interface to Sky in Google Earth"
wget --no-check-certificate http://cxc.harvard.edu/csc/googlecat/cxo_1.2.kml
echo "kml file can be opened using Google Earth"

# download The Crab Nebula Explodes
echo "Downloading The Crab Nebula Explodes"
wget --no-check-certificate https://services.google.com/earth/kmz/crab_nebula_n.kmz
echo "kmz file can be opened using Google Earth"

# download Multicolor Galaxies
echo "Downloading Multicolor Galaxies"
wget --no-check-certificate https://services.google.com/earth/kmz/aegis_n.kmz
echo "kmz file can be opened using Google Earth"

# download Images of Nearby Galaxies from the National Optical Astronomical Observatory
echo "Downloading Images of Nearby Galaxies from the National Optical Astronomical Observatory"
wget --no-check-certificate https://services.google.com/earth/kmz/noao_showcase_n.kmz
echo "kmz file can be opened using Google Earth"

# download The Sloan Digital Sky Survey catalog
echo "Downloading The Sloan Digital Sky Survey catalog"
wget --no-check-certificate https://services.google.com/earth/kmz/sdss_query_n.kmz
echo "kmz file can be opened using Google Earth"

# download Exoplanets
echo "Downloading Exoplanets"
wget --no-check-certificate https://services.google.com/earth/kmz/exo_planets_n.kmz
echo "kmz file can be opened using Google Earth"



if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  # 64-bit stuff here
# download and decompress IRAF - Image Reduction and Analysis Facility, a general purpose
# software system for the reduction and analysis of astronomical data
# IRAF software not updated since 2012!
#echo "Downloading and decompressing IRAF - Image Reduction and Analysis Facility"
#wget ftp://iraf.noao.edu/iraf/v216/PCIX/iraf.lnux.x86_64.tar.gz
#unp iraf.lnux.x86_64.tar.gz

# download and install Audela 64-bit
cd /tmp
echo "Downloading and installing Audela - free and open source astronomy software intended for digital observations"
wget --no-check-certificate https://downloads.sourceforge.net/project/audela/audela/current-development/audela-3.0.0b3-amd64.deb
sudo dpkg -i  audela*.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes  -f install

#download and install Skychart 64-bit which depends on installation of libpasastro
#SKYCHARTREMOTEDIR="http://sourceforge.net/projects/skychart/files/1-%20cdc-skychart/version_3.8/"
#url=$(wget -O- -q --no-check-certificate `echo $SKYCHARTREMOTEDIR` |  sed -ne 's/^.*"\([^"]*skychart[^"]*amd64*\.deb\)".*/\1/p' | sort -r | head -1) 
# Create a temporary directory
#dir=$(mktemp -dt)
#cd "$dir"
# Download the .deb file
#wget `echo $SKYCHARTREMOTEDIR``echo $url`
# Install the package
#sudo dpkg -i $url
# Clean up
#rm $url
#cd $HOME
#rm -rf "$dir"
#cd $HOME
#sudo DEBIAN_FRONTEND=noninteractive apt -f install
cd /tmp
sudo rm skychart*.deb
wget --no-check-certificate https://sourceforge.net/projects/libpasastro/files/version%201.1/libpasastro_1.1-14_amd64.deb
sudo dpkg -i libpasastro*.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install
cd /tmp
wget --no-check-certificate https://sourceforge.net/projects/skychart/files/1-software/version_4.0/skychart_4.0-3575b_amd64.deb
sudo dpkg -i skychart*.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes  -f install
cd /tmp
wget --no-check-certificate https://downloads.sourceforge.net/project/skychart/2-catalogs/Stars/skychart-data-stars_4.0-3421_all.deb
sudo dpkg -i skychart-data-stars*.deb
sudo DEBIAN_FRONTEND=noninteractive apt -f install
cd /tmp
wget --no-check-certificate https://downloads.sourceforge.net/project/skychart/2-catalogs/Nebulea/skychart-data-pictures_4.0-3421_all.deb
sudo dpkg -i skychart-data-pictures*.deb
sudo DEBIAN_FRONTEND=noninteractive apt -f install
cd /tmp
wget --no-check-certificate https://downloads.sourceforge.net/project/skychart/2-catalogs/Nebulea/skychart-data-dso_4.0-3431_all.deb
sudo dpkg -i skychart-data-dso*.deb
sudo DEBIAN_FRONTEND=noninteractive apt -f install


sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes    texmaker
#install texstudio
#TEXSTUDIOREMOTEDIR="http://download.opensuse.org/repositories/home:/jsundermeyer/xUbuntu_13.10/amd64/"
#url=$(wget -O- -q --no-check-certificate `echo $TEXSTUDIOREMOTEDIR` |  sed -ne 's/^.*"\([^"]*texstudio[^"]*\.deb\)".*/\1/p' | sort -r | head -1) 
# Create a temporary directory
#dir=$(mktemp -dt)
#cd "$dir"
# Download the .deb file
#wget `echo $TEXSTUDIOREMOTEDIR``echo $url`
# Install the package
#sudo dpkg -i `echo $url`
# Clean up
#rm `echo $url`
#cd
#rm -rf "$dir"
#cd
#sudo DEBIAN_FRONTEND=noninteractive apt -f install

else
  # 32-bit stuff here
# download and decompress IRAF - Image Reduction and Analysis Facility, a general purpose
# software system for the reduction and analysis of astronomical data
#echo "Downloading and decompressing IRAF - Image Reduction and Analysis Facility"
#wget ftp://iraf.noao.edu/iraf/v216/PCIX/iraf.lnux.x86.tar.gz
#unp iraf.lnux.x86.tar.gz

#echo "Downloading and installing skychart"
#SKYCHARTREMOTEDIR="http://sourceforge.net/projects/skychart/files/1-%20cdc-skychart/version_3.8/"
#url=$(wget -O- -q --no-check-certificate `echo $SKYCHARTREMOTEDIR` |  sed -ne 's/^.*"\([^"]*skychart[^"]*i386*\.deb\)".*/\1/p' | sort -r | head -1) 
# Create a temporary directory
#dir=$(mktemp -dt)
#cd "$dir"
# Download the .deb file
#wget `echo $SKYCHARTREMOTEDIR``echo $url`
# Install the package
#sudo dpkg -i $url
# Clean up
#rm $url
#cd $HOME
#rm -rf "$dir"
#cd $HOME
#sudo DEBIAN_FRONTEND=noninteractive apt -f install

sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes     texmaker
#install texstudio
#TEXSTUDIOREMOTEDIR="http://download.opensuse.org/repositories/home:/jsundermeyer/xUbuntu_12.10/i386/"
#url=$(wget -O- -q --no-check-certificate `echo $TEXSTUDIOREMOTEDIR` |  sed -ne 's/^.*"\([^"]*texstudio[^"]*\.deb\)".*/\1/p' | sort -r | head -1) 
# Create a temporary directory
#dir=$(mktemp -dt)
#cd "$dir"
# Download the .deb file
#wget `echo $TEXSTUDIOREMOTEDIR``echo $url`
# Install the package
#sudo dpkg -i `echo $url`
# Clean up
#rm `echo $url`
#cd
#rm -rf "$dir"
#cd
#sudo DEBIAN_FRONTEND=noninteractive apt -f install

fi

###############################################################################################
#     DOWNLOAD STAR ATLAS PDF FILES BEFORE ANY OTHER PDF FILES                                  #
###############################################################################################
# clean up current directory
echo "Performing file cleanup"
cd $HOME
mv *.deb $DEB
rm *.exe
mv *.km? $KMZ
mv *.pdf $PDF
mv *gz $TAR
mv *.zip $ZIP
rm *.cab
rm *.crt
rm .goutputstrea*
rm *.html
rm *.sh
rm *.xpi
rm ica_*
rm google*


#OBSOLETE: download Triatlas charts in PDF format from http://www.uv.es/jrtorres/triatlas.html
#OBSOLETE:echo "Downloading Triatlas charts (from jrtorres) in A4 format for Europe"
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_a/Triatlas_2ed_A.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/TriAtlas_A_Index.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_b/Triatlas_2ed_B1.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_b/Triatlas_2ed_B2.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_b/Triatlas_2ed_B3.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/TriAtlas_B_Index.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C01_001-030.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C02_031-060.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C03_061-090.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C04_091-120.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C05_121-150.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C06_151-180.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C07_181-210.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C08_211-240.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C09_241-270.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C10_271-300.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C11_301-330.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C12_331-360.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C13_361-390.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C14_391-420.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C15_421-450.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C16_451-480.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C17_481-510.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C18_511-540.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/section_c/C19_541-571.pdf
#OBSOLETE:wget --no-check-certificate  http://www.uv.es/jrtorres/TriAtlas_C_Index.pdf
mkdir $HOME/astronomy
cd $HOME/astronomy

# Get Deep-Sky Hunter Star Atlas (2013)
# Source: http://www.deepskywatch.com/deep-sky-hunter-atlas.html
wget --no-check-certificate http://www.deepskywatch.com/files/deepsky-atlas/Deep-Sky-Hunter-atlas-full.pdf

# download SAO/NASA ADS Help Pages
echo "Downloading SAO/NASA ADS Help Pages"
wget --no-check-certificate http://adsabs.harvard.edu/abs_doc/help_pages/adshelp.pdf
mv adshelp.pdf sao_nasa_ads_help_pages_April_17_2017.pdf

# download American Astronomical Society manuscript preparation guidelines 
echo "Downloading American Astronomical Society manuscript preparation guidelines"
wget --no-check-certificate  http://ctan.mackichan.com/macros/latex/contrib/aastex/docs/aasguide.pdf
mv aasguide.pdf American_Astronomical_Society_guidelines.pdf

# download The Not So Short Introduction to LaTeX2e by Tobias Oetiker et alii
echo "Downloading The Not So Short Introduction to LaTeX2e by Tobias Oetiker et alii"
wget --no-check-certificate  http://tobi.oetiker.ch/lshort/lshort.pdf
mv lshort.pdf latex2-not-so-short-introduction.pdf

wget --no-check-certificate  http://kelder.zeus.ugent.be/~gaspard/latex/latex-cursus.pdf

wget --no-check-certificate  http://latex-project.org/guides/lc2fr-apb.pdf
mv lc2fr-apb.pdf detecting-solving-latex-issues.pdf

echo "Downloading Springer monograph template"
wget --no-check-certificate  http://www.springer.com/cda/content/document/cda_downloaddocument/manuscript-guidelines-1.0.pdf
mv manuscript-guidelines-1.0.pdf Springer-book-manuscript-guidelines-1.0.pdf
wget --no-check-certificate  http://www.springer.com/cda/content/document/cda_downloaddocument/Key_Style_Points_1.0.pdf
mv Key_Style_Points_1.0.pdf Springer-book-Key_Style_Points_1.0.pdf
wget --no-check-certificate  http://www.springer.com/cda/content/document/cda_downloaddocument/svmono.zip
mv svmono.zip Springer-svmono-monograph-Latex-template.zip

echo "Downloading awesome professional looking Legrand Orange Book template"
wget --no-check-certificate  http://www.latextemplates.com/templates/books/2/book_2.zip
mv book_2.zip Legrand_Orange_Book_template_book_2_excellent.zip

# clean up current directory
echo "Performing file cleanup"
cd $HOME
mv *.deb $DEB
rm *.exe
mv *.km? $KMZ
mv *.pdf $PDF
mv *.tar.bz2 $TAR
mv *gz $TAR
mv *.zip $ZIP
rm *.cab
rm *.crt
rm .goutputstrea*
rm *.html
rm *.sh
rm *.xpi
rm ica_*
rm google*

# uninstall Java due to all the critical security issues in 2013
#sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove java-common
#sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove default-jre
#sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove gcj-?.?-jre-headless
#sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes remove openjdk-?
#sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes remove mysql-server-core-?.?
sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes  remove unity-lens-music unity-lens-photos unity-lens-shopping unity-lens-video
# sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   pulseaudio*
sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   arno-iptables-firewall
# sudo DEBIAN_FRONTEND=noninteractive apt  purge --yes --force-yes   ufw 
sudo DEBIAN_FRONTEND=noninteractive apt autoclean
sudo DEBIAN_FRONTEND=noninteractive apt clean
#sudo rm /etc/apt/sources.list.d/*
#grep -v opera /etc/apt/sources.list  > /tmp/sources.list
#sudo cp /tmp/sources.list  /etc/apt/sources.list

# wget --no-check-certificate  http://hea-www.harvard.edu/simx/simx-2.0.6.tar.gz
# tar -zxvf simx-2.0.6.tar.gz
# cd simx-2.0.6/
# sudo ./configure
# sudo make
# sudo make install
# cd ..
# compile fails with error configure: error: Problem with readline; run 
#  configure --help and see --with-readline option


# download and decompress Digital Universe and Partiview Resources
echo "Downloading and decompressing Digital Universe and Partiview Resources"
cd $HOME
rm *.tgz
rm DU*
rm download-files
wget --no-check-certificate http://www.amnh.org/our-research/hayden-planetarium/hayden-planetarium-promos/download-files
wget --no-check-certificate `cat download-files |grep linux|grep undle|cut -d"\"" -f2`
FILENAME=`cat download-files |grep linux|grep undle|cut -d"\"" -f2|cut -d"/" -f7`
unp $FILENAME

# 20161102: check this section about nightfall for coding errors
# Compile and install nightfall - program that can handle calculations involving binary star systems.
cd
rm -rf nightfall
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libgtk2.0-0 libgtk2.0-dev gnuplot
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes  libgl1-mesa-dev freeglut3-dev libgtkgl2.0-dev libjpeg62-dev
wget --no-check-certificate  http://www.la-samhna.de/nightfall/nightfall-1.88.tar.gz
unp nightfall*.tar.gz
cd nightfall*
sudo ./configure --enable-openmp
sudo make
sudo checkinstall
# nightfall -U
# The -U option is necessary to force the GUI to be used interactively.


# download and decompress Nightshade 
# Nightshade is free, open source astronomy simulation and visualization software for teaching and exploring astronomy
#echo "Downloading and decompressing Nightshade"
# install libfastdb first, because nightshade depends on it
#cd $HOME
#rm *.html
#rm *.tar.gz
#rm -rf nightshade*
#rm files
#rm Nightshade*.exe
#wget --no-check-certificate  http://www.garret.ru/fastdb.html
#wget --no-check-certificate  `cat fastdb.html |grep nix|cut -d"\"" -f2`
#unp fastdb*.tar.gz
#cd fastdb*
#sudo ./configure
#sudo make
#sudo make install
#sudo ldconfig

# install SDL_Pango first, because nightshade depends on it
# but nightshade cannot find SDL_Pango library, even after installing it
#cd $HOME
#rm *.html
#wget --no-check-certificate  http://downloads.sourceforge.net/project/sdlpango/SDL_Pango/0.1.2/SDL_Pango-0.1.2.tar.gz
#unp SDL_Pango-0.1.2.tar.gz
#cd SDL_Pango*
#sudo ./configure
#sudo make
#sudo make install
#sudo ldconfig

cd $HOME
rm files
sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes -f install libgraphicsmagick++1-dev libsdl1.2-dev
#wget --no-check-certificate  http://www.nightshadesoftware.org/projects/nightshade/files
#wget --no-check-certificate  http://www.nightshadesoftware.org`cat files|grep win32|cut -d"\"" -f4`
#FILENAME=`cat files|grep win32|cut -d"\"" -f4|cut -d"/" -f5`
#wine $FILENAME
# this Windows version of Nightshade requires a videocard that supports OpenGL 3.0 or higher

# download and decompress scisoft utilities
# source: http://navtejblog.blogspot.be/2014/05/installing-eso-scisoft-on-ubuntu-1404.html
echo "Downloading and decompressing scisoft utilities"
wget ftp://ftp.eso.org/scisoft/scisoft`echo $SCISOFTFILENAME`/linux/fedora11/tar/scisoft-`echo $SCISOFTFILENAME`.tar.gz
unp scisoft-`echo $SCISOFTFILENAME`.tar.gz
sudo DEBIAN_FRONTEND=noninteractive apt  install libc6:i386 libncurses5:i386 libstdc++6:i386
sudo DEBIAN_FRONTEND=noninteractive apt  install tcsh:i386 libgfortran3:i386 libreadline5:i386 libsdl-image1.2:i386 libsdl-ttf2.0-0:i386 unixodbc:i386
sudo DEBIAN_FRONTEND=noninteractive apt  install libxft2:i386 libxrandr2:i386 libxmu6:i386 libXss1:i386  libXtst6:i386  libcanberra-gtk3-module:i386

# download and decompress heasoft utilities
cd
sudo rm -rf heasoft*
wget --no-check-certificate https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release/heasoft-6.21src_no_xspec_modeldata.tar.gz
unp heasoft*.tar.gz
cd heasoft*/BUILD_DIR
sudo ./configure
sudo make
sudo make install

# download and decompress VStar
#cd
#sudo rm -rf vstar*
#wget --no-check-certificate https://downloads.sourceforge.net/project/vstar/2.18.0/vstar-2.18.0-win32.zip
#unp vstar*.zip

# download and compile skyviewer from http://lambda.gsfc.nasa.gov/toolbox/tb_skyviewer_ov.cfm
# installation procedure updated on November 30, 2014
cd $HOME
sudo rm -rf skyviewer*
wget --no-check-certificate  https://lambda.gsfc.nasa.gov/toolbox/skyviewer/skyviewer-1.0.0-windows.zip
unp skyviewer-1.0.0-windows.zip

# sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes -f install unp  libqglviewer-dev  libcfitsio3-dev qt4-dev-tools libglu1-mesa  libglu1-mesa-dev
# sudo DEBIAN_FRONTEND=noninteractive apt  --yes --force-yes -f install libchealpix0  libchealpix-dev

# wget --no-check-certificate  http://lambda.gsfc.nasa.gov/toolbox/tb_skyviewer_ov.cfm
# FILENAME=`grep Version tb_skyviewer_ov.cfm |grep kyviewer|cut -d"\"" -f2|cut -d"/" -f2|head -n1`
# wget --no-check-certificate  http://lambda.gsfc.nasa.gov/toolbox/skyviewer/$FILENAME
# unp $FILENAME
# cd skyviewer*
# qmake
# echo "LIBS = -L/usr/lib/x86_64-linux-gnu -L/usr/X11R6/lib64 -lcfitsio -lQGLViewer -lchealpix -L/usr/local/lib -lpthread -lQtXml -lQtOpenGL -lQtGui -lQtCore -lGL -lGLU" >> Makefile
# make
# cd $HOME
# rm tb_skyviewer_ov.cfm

# download C2A Planetarium Software for Windows platform
cd /tmp
echo "Downloading C2A Planetarium Software for Windows platform - use wine application"
wget --no-check-certificate  http://www.astrosurf.com/c2a/english/download/`echo $C2AFILENAME`
unp `echo $C2AFILENAME`
wine setup.exe

# get hnsky software for Windows platform
cd $HOME
sudo rm -rf hnsky*
echo "Downloading semi-professional free planetarium program HNSKY for MS Windows - use wine application"
wget --no-check-certificate  http://www.hnsky.org/hnsky_setup.exe
wine hnsky_setup.exe

# install texlive the only proper way so that tlmgr also works correctly in Ubuntu 13.10 or Ubuntu 14.04 LTS
# procedure created on March 8, 2014:
# install-tl-ubuntu script requires 4GB of free diskspace

#sudo DEBIAN_FRONTEND=noninteractive apt purge texlive-base texlive-binaries  texlive-fonts-recommended
#sudo DEBIAN_FRONTEND=noninteractive apt purge  texlive-common texlive-doc-base texlive-latex-base texlive-publishers
sudo DEBIAN_FRONTEND=noninteractive apt install texlive-fonts-recommended
#git clone https://github.com/scottkosty/install-tl-ubuntu.git
#cd install-tl-ubuntu
#./install-tl-ubuntu --help

# following script tries to install Ubuntu package parallel which ONLY exists in Ubuntu 13.10 and Ubuntu 14.04 LTS
sudo bash install-tl-ubuntu  --allow-small

sudo texhash
tlmgr init-usertree
tlmgr update --all
tlmgr install hyperref
sudo fmtutil-sys --all
sudo update-texmf

# install R 
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes  install  r-base-core r-base

# install rstudio / R-Studio :
# Free disk space required: around 5 GB
# Mac OS X users should use RStudio-0.98.501.dmg instead of R to avoid the following UNIX child process forking error:
# THE_PROCESS_HAS_FORKED_AND_YOU_CANNOT_USE_THIS_COREFOUNDATION_FUNCTIONALITY_YOU_MUST_EXEC__() to debug.

MACHINE_TYPE=`uname -m`

cd /tmp
sudo rm rstudio*.deb
sudo rm index.html

if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  # 64-bit stuff here

sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   gdebi-core pandoc libssl0.9.8 libapparmor1
wget --no-check-certificate  http://www.rstudio.com/products/rstudio/download/
wget `cat index.html|grep -v tar|grep amd64\.deb|cut -d"\"" -f2`
sudo dpkg -i rstudio*.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install

else
  # 32-bit stuff here
sudo DEBIAN_FRONTEND=noninteractive apt install   --yes --force-yes   gdebi-core pandoc libssl0.9.8 libapparmor1
wget --no-check-certificate  http://www.rstudio.com/products/rstudio/download/
wget `cat index.html|grep -v tar|grep i386\.deb|cut -d"\"" -f2`
sudo dpkg -i rstudio*.deb
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes -f install

fi

cd $HOME

# troubleshooting information to check the rstudio installation:
file /usr/lib/rstudio/bin/rstudio
ldd `which rstudio`

# install texmaker and knitr (used by texmaker) from source code:
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes texinfo texmaker r-base-core r-base
sudo DEBIAN_FRONTEND=noninteractive apt --yes --force-yes texlive-fonts-extra unp

# install testit and rgl packages which are prerequisites
# for the make check command below:
cd
rm -rf testit*
git clone https://github.com/yihui/testit.git
R CMD build testit
R CMD INSTALL testit_*.tar.gz

cd /tmp
rm index.html
wget --no-check-certificate  http://cran.r-project.org/src/contrib/
FILENAME=`grep \"rgl index.html |head -n 1|cut -d"\"" -f8`
wget --no-check-certificate  http://cran.r-project.org/src/contrib/`echo $FILENAME`
unp rgl*
R CMD build rgl
R CMD INSTALL rgl_*.tar.gz

# install knitr 1.9.3:
cd
rm -rf knit*
git clone https://github.com/yihui/knitr.git
R CMD build knitr
R CMD INSTALL knitr_*.tar.gz
sudo cp ~/knitr/inst/bin/knit /usr/bin/knit
cd knitr
make check

cd
rm -rf knitr-examples*
git clone https://github.com/yihui/knitr-examples

# clean up current directory
echo "Performing file cleanup"
cd $HOME
mv *.deb $DEB
rm *.exe
mv *.km? $KMZ
mv *.pdf $PDF
mv *gz $TAR
mv *.zip $ZIP
rm *.cab
rm *.crt
rm .goutputstrea*
rm *.html
rm *.sh
rm *.xpi
rm ica_*
rm google*
# sudo rm /etc/apt/sources.list.d/*


# install weka - import preprocessed .csv from R into weka to perform significant
# feature/variable selection for R models
cd $HOME
rm weka*.zip
wget --no-check-certificate  https://downloads.sourceforge.net/project/weka/weka-3-9/3.9.1/weka-3-9-1.zip
unp weka*.zip

# following URL added on September 20, 2014:
# install Google Cloud SDK (to be able to use Big Query)
curl https://sdk.cloud.google.com | bash

###############################################################################################
#     Links for astronomers                                                                   #
###############################################################################################

echo "Please add these Astronomy bookmarks into all 5 webbrowsers (chromium, firefox, konqueror, chrome, opera)"
echo "http://www.gmail.com"
echo "http://arxiv.org/list/astro-ph/new"
# in arxiv.org: click on 'other' next to 'pdf' and choose to 'download source' using the wget command in a Terminal
# to examine the original .tex file which uses the aastex class
# decompress the extensionless source file using  the unp command
# following URL added on December 2, 2014:
echo "http://libgen.org/"
echo "http://adsabs.harvard.edu/abstract_service.html"
# following URL added on February 12, 2014:
# INSPIRE High Energy Physics information system (search engine):
echo "http://inspirehep.net/?ln=en"
# excellent website added to this list on June 7, 2013
echo "http://cdsweb.u-strasbg.fr/"
echo "http://ned.ipac.caltech.edu/"
# excellent website added to this list on June 3, 2013
echo "http://www.usvao.org/"
# excellent website added to this list on June 3, 2013
echo "http://vao.stsci.edu/portal/Mashup/Clients/Portal/DataDiscovery.html"
echo "http://en.wikipedia.org/wiki/List_of_nearest_stars"
echo "http://www.wolframalpha.com/input/?i=astronomy&a=*C.astronomy-_*ExamplePage-"
echo "http://www.worldwidetelescope.org/webclient/"
echo "http://www.skyviewcafe.com/skyview.php"
echo "http://en.wikipedia.org/wiki/Star_catalogue#Successors_to_USNO-A.2C_USNO-B.2C_NOMAD.2C_UCAC_and_Others"
echo "http://www.aanda.org/"
echo "http://www.usno.navy.mil/USNO/astrometry/information/catalog-info/catalog-information-center-1#usnob1"
echo "http://www.usno.navy.mil/USNO/astrometry/optical-IR-prod/icas/fchpix"
echo "http://be.kompass.com/live/fr/w2866018/edition-livres/edition-livres-astronomie-geodesie-meteorologie-1.html#.UV1dCqA9RZc"
# following URL (Open Source Physics project containing Java simulations for astronomy) added on April 23, 2013:
echo "http://www.opensourcephysics.org/search/categories.cfm?t=SimSearch"
# following URL added on April 23, 2013:
echo "http://astro.unl.edu/naap/"
echo "http://en.wikibooks.org/wiki/LaTeX"
# following URL added on April 23, 2013:
echo "http://latex.ugent.be/cursus.php"
# following URL added on April 30, 2013:
echo "http://www.texdoc.net/"
# following URL added on May 13, 2013:
echo "https://github.com/search?q=documentclass+book+astronomy&nwo=pwl%2Fmaster&search_target=global&type=Code&ref=cmdform"
# following URL added on May 14, 2013 - very handy when creating latex document in texstudio:
echo "http://detexify.kirelabs.org/classify.html"
# following URL added on February 11, 2014 - very handy when creating latex document in texstudio:
# create formula in texstudio using handwriting
echo "http://webdemo.visionobjects.com/home.html?locale=fr_FR#equation"
# following URL added on January 15, 2014:
echo "http://www.math.toronto.edu/mathit/symbols-letter.pdf"
# following URL added on May 28, 2013 - very handy when creating latex document in texstudio:
echo "http://www.latextemplates.com/"
# following URL added on September 23, 2015:
# asciidoc is easier to use than latex to write books
echo "http://powerman.name/doc/asciidoc"
echo "http://www.ottobib.com/"
echo "http://scholar.google.be"
# following URL added on April 23, 2013:
echo "http://www.google.com/mars/"
# following URL added on April 23, 2013:
echo "http://www.google.com/moon/"
# following URL added on June 3, 2013:
echo "http://www.redorbit.com/news/space/"
# following URL added on June 4, 2013:
echo "http://www.intechopen.com/search?q=astronomy"
echo "http://www.youtube.com/"
echo "http://www.krantenkoppen.be/"
# following URL added on June 12, 2013:
echo "http://www.krantenkoppen.be/?rub=koppen&cat=wetenschap&taal=EN"
# following URL added on June 12, 2013:
echo "http://www.krantenkoppen.be/?rub=koppen&cat=wetenschap&taal=NL"
echo "http://www.economist.com/"
echo "http://www.wired.com/"
# following URL added on March 24, 2015:
echo "http://www.flightradar24.com/"
# following URL added on September 26, 2013:
echo "http://www.nytimes.com/"
# following URL added on June 12, 2013:
echo "http://aer.aas.org/"
# following URL added on June 12, 2013:
echo "http://www.doaj.org/doaj?func=subject&cpId=56&uiLanguage=en"
# following URL added on June 12, 2013:
echo "http://www.hindawi.com/journals/aa/contents/"
# following URL added on June 12, 2013:
echo "http://journals.cambridge.org/action/advanceSearch?jid=PAS&sessionId=70EB679458B99DAEDCA3807566C4DCEC.journals"
echo "http://heasarc.gsfc.nasa.gov/docs/heasarc/astro-update/"
# following URL added on June 4, 2013:
echo "http://svs.gsfc.nasa.gov/"
echo "http://mipav.cit.nih.gov/download.php"
echo "http://www.amazon.com"
echo "https://help.ubuntu.com/community/ExternalGuides"
# following URL added on June 15, 2013:
echo "http://www.verkeerscentrum.be/"
# following URL added on June 15, 2013:
echo "http://offshoreleaks.icij.org/"
# following URL added on June 15, 2013:
echo "http://hubblesite.org/"
# following URL added on June 17, 2013:
echo "http://www.newscientist.com/section/space"
# following URL added on June 18, 2013:
echo "http://www.bbc.co.uk/science/space/"
# following URL added on June 26, 2013:
echo "http://www.eso.org/sci/php/libraries/latest-eso-papers.html"
# following URL added on June 27, 2013:
echo "http://www.googleguide.com/advanced_operators_reference.html"
# following URL added on June 28, 2013:
echo "http://spectrum.ieee.org/aerospace/astrophysics"
# following URL added on July 1, 2013:
# info about proper motion of L 726-8 A = “V* BL Cet -- Flare Star” = Luyten 726-8 A
echo "http://simbad.u-strasbg.fr/simbad/sim-basic?Ident=L+726-8+A&submit=SIMBAD+search"
# following URL added on July 1, 2013:
echo "http://science.nasa.gov/science-news/"
# following URL added on July 1, 2013:
echo "http://news.discovery.com/space/tags/astrophysics.htm"
# following URL added on July 1, 2013:
echo "http://www.oalib.com/"
# following URL added on July 5, 2013:
echo "http://www.ncbi.nlm.nih.gov/pmc/"
# following URL added on July 10, 2013:
echo "http://www.capjournal.org/issues/"
# following URL added on July 11, 2013:
echo "http://www.nature.com/nature/archive/subject.html?code=34"
# following URL added on July 11, 2013:
echo "http://www.spacetelescope.org/news/"
# following URL added on July 16, 2013:
echo "http://interestingengineering.com/"
# open-source data analytics / data mining application for Ubuntu - added on July 19, 2013:
echo "http://orange.biolab.si/"
# following URL added on October 18, 2013:
echo "http://www.space.com/"
# following URL added on October 30, 2013:
echo "https://github.com/hannorein/open_exoplanet_catalogue/"
# following URL added on October 30, 2013:
echo "http://www.dlr.de/dlr/en/desktopdefault.aspx/tabid-10079/"
# following URL added on October 30, 2013:
echo "http://7timer.y234.cn/"
# following URL added on November 15, 2013:
echo "http://news.sciencemag.org/category/space"
echo "http://science.sciencemag.org/collection/astronomy"
# following URL added on November 18, 2013:
# PPMXL catalog contains largest list of proper motions for 900 million objects
echo "http://dc.zah.uni-heidelberg.de/ppmxl/q/cone/form"
# following URL added on November 19, 2013:
# PPMXL catalog contains largest list of proper motions for 900 million objects
echo "http://vizier.u-strasbg.fr/viz-bin/VizieR?-source=%20PPMXL"
# following URL added on December 9, 2013:
echo "http://www.pnas.org/content/by/section/Astronomy"

# following URL added on January 25, 2014:
echo "http://science.time.com/category/space-2/"
# following URL added on February 5, 2014:
# Big Data algorithms and applications from Darpa published on github:
echo "http://www.darpa.mil/OpenCatalog/index.html"
# following URL added on February 7, 2014:
echo "http://video.fosdem.org/"
# following URL added on February 12, 2014:
echo "http://www.astro.ulb.ac.be/pmwiki/IAA/HomePage"
# following URL added on February 12, 2014:
echo "http://www.allesoversterrenkunde.nl/#!/actueel"
# following URL added on February 18, 2014:
echo "http://www.stellarium.org/wiki/index.php/Stellarium_User_Guide"
# following URL added on February 26, 2014:
# OAD Open Data Repositories (including Repositories about Astronomy)
echo "http://oad.simmons.edu/oadwiki/Data_repositories"
# following URL added on September 25, 2015:
echo "https://iopscience.iop.org/journals"

###############################################################################################
#     Open access journals                                                                    #
###############################################################################################
# following URL added on July 18, 2016:
echo "https://doaj.org/"
# following URL added on February 25, 2014:
echo "http://www.plos.org/publications/journals/"
# following URL added on July 10, 2014:
echo "http://www.springeropen.com/journals"
# following URL added on July 13, 2014:
echo "http://www.gigasciencejournal.com/"
# following URL added on August 18, 2016:
echo "http://preview.ncbi.nlm.nih.gov/pmc/?term=%22nasa+funded%22%5BFilter%5D"

###############################################################################################
#     Anti-NSA measures - PRISM Break anonymizing websites                                                        #
###############################################################################################
# following URL added on June 15, 2013:
echo "http://prism-break.org/"
# following URL added on January 21, 2014:
echo "https://startpage.com/"
# following URL added on June 15, 2013:
echo "http://www.opennicproject.org/nearest-servers/"
# following URL added on March 23, 2014:
echo "https://3.hidemyass.com"

###############################################################################################
#     Math links for kids                                                                     #
###############################################################################################

# following URL added on October 22, 2017
echo "www.brilliant.org"
# following URL added on February 10, 2014:
echo "http://www.pyromaths.org/enligne/"
# following URL added on March 6, 2017
# Awesome Homework math tutor for kids and students (includes A.I.) running on iOS:
echo "https://itunes.apple.com/be/app/socratic-homework-answers/id1014164514?l=nl&mt=8"
# following URL added on February 18, 2014:
echo "http://mathworld.wolfram.com/"
# free Wolfram CDF player (added on May 7, 2017):
echo "https://www.wolfram.com/cdf-player/"
# following URL added on March 12, 2016 (free competitor to Mathematica):
echo "https://cloud.sagemath.com/"
# following URL added on February 11, 2014 (requires paying for W/A Pro account):
echo "http://www.wolframalpha.com/problem-generator/"
# following URL added on February 11, 2014:
echo "http://symbolab.com/solver"
# following URL added on February 11, 2014:
echo "http://www.grundschulstoff.de/arbeitsblatt-generator/schulfaecher.html"
# following URL added on February 11, 2014:
echo "http://www.mathmaster.org/worksheet/"
# following URL added on February 11, 2014:
echo "http://www.math-aids.com/"
# following URL added on February 11, 2014:
echo "http://www.gomaths.ch/liens_divers.php"
# following URL added on February 11, 2014:
echo "http://www.xm1math.net/"
# advanced online Desmos graphing calculator (free):
echo "https://www.desmos.com/calculator"
echo "https://www.mathway.com"


# following URL added on February 18, 2014:
echo "http://packages.ubuntu.com/trusty/edubuntu-desktop"
echo "http://packages.ubuntu.com/trusty/ubuntu-edu-primary"
# following URL added on February 12, 2014:
echo "http://nl.wikipedia.org/wiki/Hoofdpagina"
# following URL added on February 19, 2014:
echo "https://fr.khanacademy.org/"
# following URL added on February 10, 2014:
echo "http://um.mendelu.cz/maw-html/index.php?lang=fr"
# following URL added on February 10, 2014:
echo "http://doc.ubuntu-fr.org/logiciels_educatifs_pour_les_enfants"

# following URL added on February 13, 2014:
echo "http://www.aplusclick.com/"
# following URL added on February 18, 2014:
echo "http://opensource.com/education/13/4/guide-open-source-education"
# following URL added on February 21, 2014:
echo "https://www.coursesites.com/webapps/Bb-sites-course-creation-BBLEARN/pages/mooccatalog.html"
# following URL added on March 3, 2014:
echo "https://www.oppia.org/learn"
# following URL added on March 29, 2014:
echo "http://www.mooc-list.com/"
# following URL added on March 27, 2015:
echo "https://openeducation.blackboard.com/mooc-catalog/courseDetails/view?course_id=_219_1"


###############################################################################################
#     Language links for kids                                                                     #
###############################################################################################
# following URL added on February 11, 2014:
echo "http://www.lasouris-web.org/lasouris/imprimer.html"
# following URL added on February 11, 2014:
echo "http://www.desmoulins.fr/index.php?pg=scripts!online!scolaire!francais!conjugaison"
# following URL added on February 11, 2014:
echo "http://www.desmoulins.fr/index.php?pg=scripts!online!feuilles!form_feuille_apprendre_ecriture"
# following URL added on February 11, 2014:
echo "http://www.thatquiz.org/fr-D-z2/vocabulaire/Francais/"


###############################################################################################
#     Free course material for high school students                                           #
###############################################################################################
echo "http://www.openculture.com/free_textbooks"
echo "https://www.ck12.org/"
echo "https://www.oercommons.org/"
echo "https://www.saylor.org/books/"

###############################################################################################
#     Free course material for university students                                                                     #
###############################################################################################
# following URL added on February 24, 2017:
echo "http://opencourselibrary.org/course/"
echo "http://oyc.yale.edu/courses"
echo "https://ocw.mit.edu/courses/"
echo "https://openstax.org/subjects"
echo "https://open.umn.edu/opentextbooks/"
echo "http://www.textbookrevolution.org/index.php/Book:Lists/Subjects"
echo "http://www.collegeopentextbooks.org/textbook-listings/textbooks-by-subject"

###############################################################################################
#     Links for authors of Astronomy books                                                    #
###############################################################################################

echo "Check with book publisher in which format the digitized book needs to be sent to the publisher"
echo "(preferably latex instead of hybrid PDF-ODF format, Word .docx format, etc...)"
echo "create star maps using stellarium, save as png, and import into latex document"
echo "get bibliography citations at http://www.ottobib.com  using ISBN number and convert info to bibtex plain text .bib file for use in Latex document"
echo "get bibliography citations at http://scholar.google.be using full title and author and choose import to bibtex"
echo "For example use - filetype:pdf author:'h karttunen'  -  as search term in http://scholar.google.be"
echo "For example use - site:arxiv.org intext:"habitable zone" - as search term in http://www.google.be/"
echo "Get more information about latex package by using command   texdoc <packagename> , for example: texdoc graphicx"


###############################################################################################
#     Links for data scientists                                                               #
###############################################################################################

# Reproducible, scientific, open-source report sharing procedure:
# 1) install R, RStudio, texmaker and knitr
# 2) Create .Rnw document using texmaker+knitr - knitr is slightly better than Sweave
# 3) Add an explanatory comment after each line of R code inside the .Rnw document
# 4) Share new .Rnw document and source .csv datafiles on https://github.com/
# knitr install procedure:

# cd; rm knitr_*.tar.gz
# git clone https://github.com/yihui/knitr.git
# sudo apt update
# sudo apt install texinfo
# sudo apt install texlive-fonts-extra
# R CMD build knitr
# R CMD INSTALL knitr_*.tar.gz
# sudo cp ~/knitr/inst/bin/knit /usr/bin/knit
# cd knitr
# make check
# git clone https://github.com/MarkRijckenberg/book-template-for-texstudio.git
# cd book-template-for-texstudio/
# texmaker main.Rnw
# Configure texmaker version 4.1.1 or newer as follows:
# Texmaker::Options::Configure Texmaker::Commands::R Sweave command should be  Rscript -e "library(knitr); knit('%.Rnw')"
# Texmaker::Options::Configure Texmaker::Quick Build command option should be Sweave + pdflatex + View PDF
# Then press F1,F12,F11,F1,F1 to compile from .Rnw to .tex to .pdf file and to preview it automatically.

# following URL added on February 26, 2014:
# Use Google Docs Forms (or kwiksurveys.com) to create online survey that allows free export of data into R or RStudio
echo "https://www.ashrae.org/File%20Library/docLib/Public/20100301_how_2_app_googledocs.pdf"
# following URL added on February 26, 2014:
# texmaker/knitr source code (.Rnw files) for OpenIntro Labs is here:
echo "http://www.openintro.org/download.php?file=os2_lab_source&referrer=/stat/labs.php"
# following URL added on February 26, 2014:
# Explanation on how to use texmaker with knitr:
echo "http://yihui.name/knitr/demo/editors/"
# Explanation on how to use .Rnw files and RStudio with knitr:
echo "http://kbroman.github.io/knitr_knutshell/pages/latex.html"
# following URL added on July 10, 2014:

# following URL added on February July 10, 2014:
# principles and practice of reproducible research with R
echo "https://osf.io/s9tya/wiki/home/"
echo "http://statsteachr.org/modules/view/40"
echo "http://reproducibleresearch.net/links/"

# following URL added on February 13, 2015:
# detailed examples on how to use ggplot2:
echo "http://www.sthda.com/"
# following URL added on March 9, 2015:
echo "http://www.sthda.com/english/wiki/principal-component-analysis-how-to-reveal-the-most-important-variables-in-your-data-r-software-and-data-mining?utm_content=buffer54310&utm_medium=social&utm_source=facebook.com&utm_campaign=buffer"
# following URL added on February 19, 2014:
# free guides
echo "http://onepager.togaware.com/"
# following URL added on February 19, 2014:
echo "http://www.Rdocumentation.org"
# following URL added on February 19, 2014:
echo "http://www.r-bloggers.com/"

# following URL added on February 19, 2014:
# sample data is here:
echo "http://dataferrett.census.gov/LaunchDFA.html"
# following URL added on February 19, 2014:
echo "http://www.r-statistics.com/2013/07/analyzing-your-data-on-the-aws-cloud-with-r/"
# following URL added on February 26, 2014:
echo "http://jeromyanglim.blogspot.be/search/label/R"

# following URL added on February 19, 2014:
# STEP 1: introduction to R and R-Studio for beginners
echo "http://jsresearch.net/"
# following URL added on March 7, 2014:
# Step 2 Data Smart
echo "http://www.amazon.fr/Data-Smart-Science-Transform-Information/dp/111866146X/ref=sr_1_1?ie=UTF8&qid=1394192108&sr=8-1&keywords=Data+Smart%3A+Using+Data+Science+to+Transform+Information+into+Insight"
# following URL added on March 16, 2014:
# one of the authors of the Data Smart book:
echo "http://www.evanmiller.org/"
# following URL added on March 16, 2014:
# spreadsheets used in Data Smart book:
echo "http://eu.wiley.com/WileyCDA/WileyTitle/productCd-111866146X.html"
# following URL added on August 28, 2014:
echo "http://swirlstats.com/students.html"
echo "https://github.com/swirldev/swirl_courses#swirl-courses"
# following URL added on March 7, 2014:
# STEP 4: following URL added on February 28, 2014:
echo "http://www.amazon.fr/Practical-Data-Science-Nina-Zumel/dp/1617291560/ref=sr_1_1?ie=UTF8&qid=1393583397&sr=8-1&keywords=practical+data+science+with+r"

# following URL added on March 7, 2014:
echo "https://www.edx.org/"
# following URL added on March 12, 2014:
echo "http://www.google.com/trends"

# following URL added on March 18, 2014:
# world news site for data scientists
echo "http://fivethirtyeight.com/"
# following URL added on March 29, 2014:
# list of data visualisation tools
echo "http://selection.datavisualization.ch/"
# data visualization - color guide for good visualization:
echo "http://colorbrewer2.org/"
# list of data visualisation tools
# following URL added on November 27, 2014:
echo "http://www.maartenlambrechts.be/category/datajournalistiek/"
# following URL added on March 29, 2014:
# search engine for R
echo "http://www.rseek.org/"
# following URL added on April 22, 2014:
# Cookbook for R
echo "http://www.cookbook-r.com/"
# R Graphics Cookbook - Practical Recipes for Visualizing Data - Winston Chang - 2012
echo "http://shop.oreilly.com/product/0636920023135.do"
# Data Camp - online interactive tool that teaches how to use R
# following URL added on April 25, 2014:
echo "https://www.datacamp.com/courses/introduction-to-r"
# following URL added on September 7, 2014:
echo "https://www.codeschool.com/courses/try-r"
# time series analysis using R
# following URL added on May 18, 2014:
echo "http://www.statmethods.net/advstats/timeseries.html"
echo "http://a-little-book-of-r-for-time-series.readthedocs.org/en/latest/src/timeseries.html"
# following URL added on August 16, 2017:
# Forecasting: principles and practice using R:
echo "https://www.otexts.org/book/fpp"
echo "http://cran.r-project.org/doc/contrib/Ricci-refcard-ts.pdf"
echo "http://www.statoek.wiso.uni-goettingen.de/veranstaltungen/zeitreihen/sommer03/ts_r_intro.pdf"
echo "https://onlinecourses.science.psu.edu/stat510/"
# following URL added on June 24, 2014:
echo "http://www.scoop.it/t/r-for-journalists"
# following URL added on September 9, 2014:
echo "http://www.bioconductor.org/install/"
# following URL added on September 9, 2014:
# run R online:
echo "http://statace.com/#features"
echo "https://www.getdatajoy.com/?utm_source=dc&utm_medium=email&utm_campaign=dc1"
echo "http://www.roncloud.com/"
echo "http://www.compileonline.com/execute_r_online.php"
echo "http://www.r-fiddle.org/"
echo "http://pbil.univ-lyon1.fr/Rweb/Rweb.general.html"
# following URL added on September 15, 2014:
# detailed examples of supervised and unsupervised learning and time series analysis in R:
echo "http://www.rdatamining.com/docs"
# following URL added on November 9, 2015:
echo "http://www.datasciencecentral.com/profiles/blogs/80-free-data-science-books?utm_content=buffer1d8ae&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer"
echo "http://www.datasciencecentral.com/profiles/blogs/10-great-books-about-r-1"
# following URL added on July 17, 2015:
echo "http://www.datasciencecentral.com/group/resources/forum/topics/the-best-of-our-weekly-digests"
# following URL added on October 13, 2015:
echo "http://www.datasciencecentral.com/profiles/blog/show?id=6448529%3ABlogPost%3A334740"
# following URL added on July 18, 2015:
echo "https://www.youtube.com/user/TheLearnR/playlists"
# following URL added on August 6, 2015:
echo "https://leanpub.com/regmods/read"
# following URL added on September 22, 2015:
echo "https://www.shortcutfoo.com"
# following URL added on October 12, 2015:
# Using R for Statistical Analysis:
echo "https://www.youtube.com/user/swinvideos/playlists"
# How to use neo4j and Cypher (graph DB plugin for MS Excel 2013) in Ubuntu without using a virtual Windows machine:
echo "http://console.neo4j.org/"
# Cypher cheat sheet (when using the console in neo4j)
echo "http://assets.neo4j.org/download/Neo4j_CheatSheet_v3.pdf"

###############################################################################################
#     Sabermetrics                                                                            #
###############################################################################################
# STEP 5: following URL added on June 11, 2014:
echo "http://www.amazon.com/Analyzing-Baseball-Data-Chapman-Series/dp/1466570229/ref=sr_1_1?ie=UTF8&qid=1402506648&sr=8-1&keywords=analyzing+baseball+data+with+r"
# following URL added on June 11, 2014:
echo "http://baseballwithr.wordpress.com/2014/03/17/introduction-to-openwar/"
# following URL added on May 29, 2014:
echo "https://books.google.com/ngrams/graph?content=sabermetrics%2Csabermetric%2Csabermetrician&year_start=1978&year_end=2014&corpus=15&smoothing=3&share=&direct_url=t1%3B%2Csabermetrics%3B%2Cc0%3B.t1%3B%2Csabermetric%3B%2Cc0%3B.t1%3B%2Csabermetrician%3B%2Cc0"
# following URL added on August 29, 2014:
echo "http://www.datascienceriot.com/"

###############################################################################################
#     R model generation and selection tools:                                                 #
###############################################################################################

# following URL added on April 16, 2014:
# how to create hybrid CART-logit model (CART-logistic regression model) in R:
# approach did not work well on real world data set full of missing values
echo "www.casact.org/education/specsem/f2005/handouts/cart.ppt"
# following URL added on April 17, 2014:
# automated R model selection using glmulti R package as replacement for glm 
echo "http://www.jstatsoft.org/v34/i12/paper"
# following URL added on April 17, 2014:
# Excellent examples of using glmulti R package as replacement for glm :
echo "http://rstudio-pubs-static.s3.amazonaws.com/2897_9220b21cfc0c43a396ff9abf122bb351.html"
# following URL added on April 19, 2014:
# Feature selection using caret
echo "http://caret.r-forge.r-project.org/featureselection.html"
echo "http://caret.r-forge.r-project.org/modelList.html"
# select best algorithm by testing them on train data set in Weka Experimenter:
echo "http://machinelearningmastery.com/design-and-run-your-first-experiment-in-weka/"
# most powerful R feature selection method to create an accurate model:
# Perform Hyperparameter optimization using libsvm as explained here:
echo "https://en.wikipedia.org/wiki/Hyperparameter_optimization"
echo "http://www.csie.ntu.edu.tw/~cjlin/papers/guide/guide.pdf"
# Alternative to R Markdown for Data Workflow Visualization: KNIME (Konstanz Information Miner)
# KNIME is a Data Workflow Visualization tool
# following URL added on April 25, 2014:
echo "http://tech.knime.org/files/KNIME_quickstart.pdf"
# following URL added on July 24, 2014:
echo "http://cdn.oreillystatic.com/en/assets/1/event/115/Data%20Workflows%20for%20Machine%20Learning%20Presentation.pdf"


# liblinear is good model to use when number of train data rows (4600) > number of features/variables (110) 
# -> so use liblinear R package -> computations via liblinear much quicker than via libsvm!
# following URL added on April 23, 2014:
echo "http://cran.r-project.org/web/packages/LiblineaR/LiblineaR.pdf"
# following URL added on August 5, 2015:
echo "http://www.kdnuggets.com/2014/06/top-10-data-analysis-tools-business.html"

###############################################################################################
#     Data Science toolkit virtual machine images                                             #
###############################################################################################
# following URL added on July 24, 2014:
echo "http://www.datasciencetoolkit.org/developerdocs#setup"
###############################################################################################
#     Data Science magazines and journals                                                     #
###############################################################################################
# following URL added on July 18, 2014:
echo "http://www.jds-online.com/"
echo "https://www.oreilly.com/topics/data"
#######################################################
# how to clean data and perform data imputation in R  #
#######################################################
# following URL added on April 25, 2014:
echo "http://cran.r-project.org/doc/contrib/de_Jonge+van_der_Loo-Introduction_to_data_cleaning_with_R.pdf"
# Data Cleaning for Beginners: Part 2
# following URL added on April 25, 2014:
echo "http://statsguys.wordpress.com/2014/01/11/data-analytics-for-beginners-pt-2/"
# following URL added on March 21, 2015: 
echo "http://www.analyticbridge.com/group/books/forum/topics/free-ebook-practical-data-cleaning"


# Free online courses:

# following URL added on March 29, 2014:
# list of online course, use search function in top right corner of page:
echo "http://www.mooc-list.com/"

# free Stanford courses about R and other subjects
# following URL added on March 12, 2014:
echo "https://lagunita.stanford.edu/"
# following URL added on February 28, 2014:
# Free online Data Science courses here:
echo "https://www.udacity.com/courses#!/Data%20Science"
# Free online Data Science courses here:
# following URL added on March 12, 2014:
echo "https://courses.edx.org/dashboard"
# following URL added on March 30, 2014:
echo "https://www.coursera.org/courses?orderby=upcoming&lngs=en&cats=cs-theory,cs-systems,cs-programming,cs-ai,stats"
# following URL added on July 21, 2014:
echo "https://www.khanacademy.org/math/probability/statistics-inferential"
# following URL added on July 30, 2014:
echo "https://www.udemy.com/courses/search/?q=data+science&view=list&sort=price-low-to-high"
# following URL added on February 28, 2014:
# Free PDF book "An Introduction to Statistical Learning with Applications in R"
# Very handy book that complements the edX course "MITx: 15.071x The Analytics Edge"
echo "http://www-bcf.usc.edu/~gareth/ISL/"
# following URL added on April 3, 2014:
# book by Julian Faraway on CranR, written in July 2002:
echo "http://cran.r-project.org/doc/contrib/Faraway-PRA.pdf"
# following URL added on March 28, 2014:
# Systems approaches to improving data quality 
echo "http://mitiq.mit.edu/ICIQ/Documents/IQ%20Conference%201996/Papers/SystemsApproachestoImprovingDataQuality.pdf"
# following URL added on March 14, 2014:
echo "https://www.class-central.com/"
# following URL added on April 1, 2014:
# Natural Language Processing - linked to Text Mining
echo "https://www.youtube.com/results?search_query=1%20-%201%20Stanford%20NLP%20-%20Professor%20Dan%20&sm=3"
# following URL added on April 4, 2014:
# Supervised Learning Workflow / Data Analytics Workflow
echo "http://statsguys.files.wordpress.com/2014/03/supervisedworkflow.png"
# NFL dataset for R users in SQL format:
echo "http://rpubs.com/rseiter/22093"
# free courses
echo "https://stacksocial.com/free"

###############################################################################################
#     Open data formats and importing data into R                                             #
###############################################################################################
# Data Sources for Data Scientists
echo "http://www.noodletools.com/debbie/resources/math/stats.html"
# OAD Open Data Repositories (including Repositories about Astronomy)
echo "http://oad.simmons.edu/oadwiki/Data_repositories"
# following URL added on March 4, 2014:
# NASA Data Sources for Data Scientists - data can be manually exported into .csv format
echo "http://mynasadata.larc.nasa.gov/las/UI.vm"
# following URL added on March 7, 2014:
# Flemish government's open data initiative uses JSON format for open data sources/sets instead of .csv format
echo "http://data.opendataforum.info/"
# following URL added on March 25, 2014:
echo "https://www.opencpu.org/posts/jsonlite-a-smarter-json-encoder/"
# following URL added on March 4, 2014:
# How to import data into R from various types of data sources:
echo "http://cran.r-project.org/doc/manuals/r-release/R-data.pdf"
# following URL added on April 1, 2014:
echo "https://github.com/rOpenHealth"
# following URL added on September 16, 2014:
echo "https://ropengov.github.io/"
# following URL added on May 17, 2014:
echo "http://www.infochimps.com/datasets/"
# following URL added on May 18, 2014:
echo "https://datamarket.com/"
# following URL added on July 10, 2014:
# Dryad Digital Repository 
echo "http://datadryad.org"
# following URL added on July 10, 2014:
# Access Quandl open data sets using Quandl R package:
echo "http://www.quandl.com/"

# following URL added on August 14, 2014:
echo "http://www.data.gov/"
# following URL added on October 29, 2014:
echo "http://opendata.stackexchange.com/"

#######################################################################################################
#     Online data analytics challenges requiring use of R or python                                   #
#######################################################################################################
# Kaggle competitions
echo "http://www.kaggle.com/"
# Synapse challenges
echo "https://www.synapse.org/#"
# Coursolve challenges
echo "https://www.coursolve.org"


#######################################################################################################
#     Combine big data datasets with R, RStudio and Amazon EC2 or Google Big Data infrastructure      #
#######################################################################################################
# The data.table package is being increasingly used in fields such as finance, insurance and genomics, 
# and it is making its name as the number one choice for handling large datasets (1Gb - 100GB) in R. 
# Data.table provides you with an enhanced version of a data.frame. The speed and simplicity of using 
# data.table will be a revelation. It reduces your programming and the computing time significantly. 
# following URL added on October 10, 2014:
echo "https://www.datacamp.com/courses/data-analysis-the-data-table-way?utm_source=Data.table%20launch%20email&utm_medium=email&utm_content=finance%20-%20zivot&utm_campaign=Data.table%20launch%20"
# use R,RStudio,postgresql-9.3,postgresql-plr,MADlib,PivotalR to run MADlib in-database modeling 
# functions in database, not in R
echo "http://www.oscon.com/oscon2014/public/schedule/detail/37713"
echo "http://www.louisaslett.com/RStudio_AMI/"
echo "https://developers.google.com/bigquery/"
# following URL added on September 20, 2014:
# Big Query and Data Analytics applied to soccer:
echo "https://github.com/GoogleCloudPlatform/ipython-soccer-predictions"
# following URL added on November 20, 2014:
# combine SciDB (allow big data sets),RStudio (data analytics) and Shiny(interactive visualization)
echo "http://illposed.net/scidb.pdf"
# following URL added on November 28, 2014:
# Combine Apache Spark with Python using pyspark:
# Use tab completion and help function in "ipython notebook" to learn to use python:
echo "https://www.edx.org/course/introduction-to-big-data-with-apache-spark-uc-berkeleyx-cs100-1x"
# following URL added on June 9, 2015:
echo "https://spark.apache.org/docs/latest/api/python/pyspark.html#pyspark.RDD"
# following URL added on November 28, 2014:
# combine Apache Spark with R using SparkR:
echo "https://www.youtube.com/watch?v=CUX1SG9zTkU&list=PL-x35fyliRwiuc6qy9z2erka2VX8LY53x"
# combine Apache Spark with GPU computing using HeteroSpark project:
# following URL added on August 29, 2015:
echo "http://cans.uml.edu/research/heterospark/"
# following URL added on February 18, 2015:
# Prerequisites:
# CUDA toolkit, Python 2.7.x, numpy, pandas, matplotlib, and scikit-learn, lasagne
# lasagne is a library for building Convolutional neural networks with Python and Theano
echo "http://danielnouri.org/notes/2014/12/17/using-convolutional-neural-nets-to-detect-facial-keypoints-tutorial/"

#######################################################################################################
#     Data Science cheat sheets (2017):                                                               #
#     MATLAB (non-free)/Octave(open source),python,R,SAS,RStudio,MySQL commands                                                             #
#######################################################################################################

# MATLAB
# following URL added on April 21, 2017:
# MatLab cheat sheets:
echo "http://www.econ.ku.dk/pajhede/Cheatsheet.pdf"
echo "http://steventhornton.ca/a-matlab-cheat-sheet/"
echo "https://en.wikibooks.org/wiki/MATLAB_Programming/Differences_between_Octave_and_MATLAB"

# Octave (mostly compatible with MATLAB) Reference Card
echo "http://folk.ntnu.no/joern/itgk/refcard-a4.pdf"

# Python data science cheat sheets:
# following URL added on January 3, 2018:
echo "https://www.datacamp.com/community/data-science-cheatsheets"
# following URL added on April 24, 2017:
echo "https://s3.amazonaws.com/assets.datacamp.com/blog_assets/PandasPythonForDataScience.pdf"
echo "https://s3.amazonaws.com/assets.datacamp.com/blog_assets/Numpy_Python_Cheat_Sheet.pdf"
echo "https://s3.amazonaws.com/assets.datacamp.com/blog_assets/Scikit_Learn_Cheat_Sheet_Python.pdf"
echo "http://www.datasciencefree.com/cheatsheets.html"
echo "https://github.com/ehmatthes/pcc/releases/download/v1.0.0/beginners_python_cheat_sheet_pcc_all.pdf"
# Matplotlib (visualisation for Python) cheat sheet:
echo "https://s3.amazonaws.com/assets.datacamp.com/blog_assets/Python_Matplotlib_Cheat_Sheet.pdf"
# PySpark cheat sheet:
echo "https://s3.amazonaws.com/assets.datacamp.com/blog_assets/PySpark_Cheat_Sheet_Python.pdf"
# Keras deep learning library - Scikit-learn - Tensorflow GPU - python framework cheatsheet:
echo "https://s3.amazonaws.com/assets.datacamp.com/blog_assets/Keras_Cheat_Sheet_Python.pdf" 
echo "https://www.datasciencecentral.com/profiles/blogs/learn-python-in-3-days-step-by-step-guide"
# following URL added on January 11, 2018:
# PyTorch cheat sheet (pytorch uses CPU+GPU!)
echo "https://github.com/Tgaaly/pytorch-cheatsheet"

# Quandl for R
echo "https://s3.amazonaws.com/quandl-static-content/Documents/Quandl+-+R+Cheat+Sheet.pdf"

# R
# following URL added on January 3, 2018:
echo "https://www.datacamp.com/community/data-science-cheatsheets"
# following URL added on April 21, 2017:
# One R cheat sheet per data science processing step:
# Includes separate cheat sheet for SparklyR, dplyr and tidyr
echo "https://www.rstudio.com/resources/cheatsheets/"

# R
echo "http://www.datasciencefree.com/cheatsheets.html"

# R
# following URL added on April 24, 2017:
# R Reference Card
echo "https://github.com/jonasstein/R-Reference-Card/blob/master/R-refcard.pdf"

# RStudio Shiny Apps cheatsheet:
echo "http://shiny.rstudio.com/articles/cheatsheet.html"

# SAS
# following URL added on March 17, 2017:
# SAS cheat sheet 1.2c (2009)
echo "http://www.theprogrammerscabin.com/SASCheat.pdf"

# SQL
# following URL added on April 27, 2017:
# SQL cheat sheet:
echo "http://www.sql-tutorial.net/sql-cheat-sheet.pdf"

#######################################################################################################
#     Data Science programming languages - learning requirements:                                      #
#     R,RStudio,MySQL commands,python,SAS,MatLab (non-free)/Octave(open source), Wolfram                                                                #
#######################################################################################################

# following URL added on February 19, 2014:
echo "http://www.rstudio.com/"
echo "http://bigdatauniversity.com/wpcourses/"

# list of MySQL commands to use with RMySQL package in R:
echo "http://www.pantz.org/software/mysql/mysqlcommands.html"
# list of different types of SQL joins
echo "http://www.codeproject.com/Articles/33052/Visual-Representation-of-SQL-Joins"
# following URL added on March 7, 2014:
# Step 3 Sams Teach Yourself SQL in 10 Minutes (4th Edition)
echo "Learn MySQL commands = de facto SQL (dialect) standard"
echo "http://www.amazon.fr/Sams-Teach-Yourself-Minutes-Edition-ebook/dp/B009XDGF2C/ref=sr_1_1?ie=UTF8&qid=1394192160&sr=8-1&keywords=Sams+Teach+Yourself+SQL+in+10+Minutes+%284th+Edition%29"
echo "http://www.markmcilroy.com/downloads/sql_essentials.pdf"

# following URL added on January 20, 2018:
echo "https://courses.edx.org/courses/course-v1:MITx+6.00.1x+2T2017_2/courseware/c77f2cc9fb2a42589f0d723e8fefbd35/c58684c1812443db80c4b0028aba9bc3/?child=first"
# following URL added on June 11, 2015:
echo "https://www.coursera.org/course/pythonlearn"
echo "http://www.codecademy.com/tracks/python"
echo "https://developers.google.com/edu/python/"
echo "http://ucanalytics.com/blogs/r-vs-python-comparison-and-awsome-books-free-pdfs-to-learn-them/"
# ipython notebook webserver in virtualbox VM configured using vagrant (configure time using chef in VM: 31 minutes)
# accessible on host server via http://localhost:8888
echo "https://github.com/ptwobrussell/Mining-the-Social-Web-2nd-Edition"
echo "http://cloud.shogun-toolbox.org/"
# following URL added on April 25, 2017:
echo "http://reference.wolfram.com/language/guide/MachineLearning.html"
# following URL added on April 25, 2017:
# Wolfram Language Computable Workbook:
echo "https://sandbox.open.wolframcloud.com"
# Free book "Physical Modeling in MATLAB" - for absolute beginners:
echo "https://open.umn.edu/opentextbooks/BookDetail.aspx?bookId=82"
#####################################################################################################
#    R User Conference  - presentations and slides about using R and applied predictive modeling      #
#######################################################################################################
# R User Conference:
echo "https://twitter.com/user_brussels"
# Oreilly conferences
echo "https://www.oreilly.com/conferences/"
# OSCON conference
echo "https://conferences.oreilly.com/oscon/oscon-tx/public/schedule/proceedings"
# following URL added on July 10, 2014:
# predictive modeling = machine learning
echo "http://static.squarespace.com/static/51156277e4b0b8b2ffe11c00/t/53ad86e5e4b0b52e4e71cfab/1403881189332/Applied_Predictive_Modeling_in_R.pdf"
# following paper describes dangers of overfitting and "curse of dimensionality":
echo "http://homes.cs.washington.edu/~pedrod/papers/cacm12.pdf"
# Data Day Texas conference
echo "http://datadaytexas.com/"

#######################################################################################################
#     Data Science related mathematics - learning requirements:                                       #
#     linear algebra, vector algebra, category theory and lambda calculus (monads and monoids are     #
#     used as base element for functional programming and big data software like Apache Spark)        #
#     Also important are lambda abstractions/anonymous functions                                      #
#######################################################################################################

###############################################################################################
#     Personal study requirements                                                             #
###############################################################################################
# Job involving Google Analytics platform can help an I.T. freelancer make 800 EUR per day
echo "https://analyticsacademy.withgoogle.com/"
# !!!! Data Smart ('light' data analytics using Microsoft Excel)
echo "http://www.amazon.fr/Data-Smart-Science-Transform-Information/dp/111866146X/ref=sr_1_1?ie=UTF8&qid=1394192108&sr=8-1&keywords=Data+Smart%3A+Using+Data+Science+to+Transform+Information+into+Insight"
# presentations about data analysis using Excel  ('light' data analytics using Microsoft Excel)
echo "http://www.felienne.com/presentations"
# added on 2017/6/12:
# free training material (April 2017) about using MS Excel 2013 for Social Sciences:
echo "http://dlab.berkeley.edu/training"
# study Scala (functional programming language) -> Apache Spark is an extension of Scala
# study SQL Server 2016 (which will include R integration)
# source: http://developers.slashdot.org/story/15/05/16/1748232/in-database-r-coming-to-sql-server-2016
echo "http://download.microsoft.com/download/F/D/3/FD33C34D-3B65-4DA9-8A9F-0B456656DE3B/SQL_Server_2016_datasheet.pdf"
# following URL added on April 15, 2015:
echo "https://campus.datacamp.com/courses/r-programming-with-swirl/chapter-1-the-true-basics?ex=2"
# Informatica PowerCenter ETL
# IBM Cognos Business Intelligence V10.1 Handbook:
echo "http://www.redbooks.ibm.com/redbooks/pdfs/sg247912.pdf"
echo "http://www.redbooks.ibm.com/redbooks.nsf/searchsite?SearchView&query=cognos"
# The Data Warehouse Toolkit: The Definitive Guide to Dimensional Modeling Paperback – July 1, 2013
# Kimball lifecycle
# Microsoft SQL Server 2014 Business Intelligence Development Beginner's Guide
# !!!! An Introduction to Statistical Learning
echo "http://www-bcf.usc.edu/~gareth/ISL/"
# !!!! OpenIntro Statistics 2nd edition
echo "http://www.openintro.org/stat/textbook.php?stat_book=os"
# study ggvis RStudio visualization package
echo "http://ggvis.rstudio.com/"
echo "https://www.datacamp.com/courses/ggvis/free-preview-ggvis?ex=2"
# SCRUM
echo "http://mgmtplaza.com/downloads/Scrum%20Training%20Manual.pdf"
# Agile
