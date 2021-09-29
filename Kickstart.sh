#!/bin/bash

source ./install_package.sh
##########function in install_package.sh#############
# Prepare_repo
# InstallDhcp
# InstallTftpServer
# InstallFtp
# InstallSyslinux
# CreateDirectory
# PXEboot
# PXEbootEFI
# ContentMedia
# PrepareKickstart
# StartService
# AllowFirewall
#####################################################

source ./configure.sh
############function in configure.sh#################
# ConfigDHCP
# ConfigPxelinux
# ConfigEFI


################## Call function ######################
echo -e "======Welcome to Kickstart==========\n\n"
read -p "Please chose mountpoint for repository : " mountpoint
Prepare_repo $mountpoint
InstallDhcp
InstallTftpServer
InstallFtp
InstallSyslinux
CreateDirectory
ContentMedia $mountpoint
PXEboot
PXEbootEFI
ConfigDHCP
ConfigPxelinux
ConfigEFI
StartService
AllowFirewall
