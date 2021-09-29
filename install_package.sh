#!/bin/bash


#Prepare environment repository for CentOS7/RHEL7
Prepare_repo() {
mount=$1

  if [ `uname -n` = 'centos7' ]
  then
    cd /etc/yum.repos.d
    echo -e "************************************************"
    echo "number of repo file"
    ls |grep repo|wc -l
    if [ `ls |grep repo|wc -l` != '0' ]
    then
      rm -f *.repo
      echo -e "remove repo successfull.\n"
    fi
    cd ~
  fi

  if [ `grep gpgcheck /etc/yum.conf |awk -F= '{print $2}'` != '0' ]
  then

    GPG=`grep gpgcheck /etc/yum.conf`
    sed -i "s/${GPG}/gpgcheck=0/g" /etc/yum.conf
    GPG1=`grep gpgcheck /etc/yum.conf`
    echo "Change parameter from ${GPG} to ${GPG1}"
    echo -e "************************************************\n"
  fi
  echo -e "************************************************"
  if [ ! -d $mount ]
  then
    mkdir -p $mount
    echo "create mountpoint ${mount}"
  fi

  if [ `df -h|grep $mount|wc -l` = '0' ]
  then
    mount -o loop /dev/cdrom ${mount}
  fi
  yum-config-manager --add-repo=file://${mount}
  yum clean all
  echo -e "************************************************\n"
}


#Install package for kickstart
InstallDhcp() {

  # Install dhcp service
  yum install -y dhcp

}

InstallTftpServer() {

  # Install tftp server service
  yum install -y tftp-server

}

InstallFtp() {

  # Install FTP service
  yum install -y vsftpd

}

InstallSyslinux() {

  # install syslinx service
  yum install -y syslinux

}

CreateDirectory() {

  # create directory for boot label
  mkdir /var/lib/tftpboot/pxelinux.cfg
  # create directory networkboot
  mkdir -p /var/lib/tftpboot/networkboot/centos7
  # create directory for source media
  mkdir /var/ftp/pub/centos7
  # create directory for shim
  mkdir -p /root/shim
  # create directory for grubx64
  mkdir -p /root/grubx64
}

PXEboot() {

  #Copy file pxe to tftpboot
  cp -v /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
  cp -v /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
  cp -v /usr/share/syslinux/mboot.c32 /var/lib/tftpboot/
  cp -v /usr/share/syslinux/chain.c32 /var/lib/tftpboot/

  # Copy boot image file
  cp /var/ftp/pub/centos7/images/pxeboot/{initrd.img,vmlinuz} /var/lib/tftpboot/networkboot/centos7

  #bootloader of UEFI
  cp /var/ftp/pub/centos7/EFI/BOOT/grubx64.efi /var/lib/tftpboot
 }

 PXEbootEFI() {
   #bootloader of UEFI
   # cp /var/ftp/pub/centos7/EFI/BOOT/grubx64.efi /var/lib/tftpboot

   dirc=/var/ftp/pub/centos7/Packages
   shim=/root/shim
   grub2=/root/grubx64

   echo "start copy from media"
   #Copy shim rpm file
   cd ${dirc}
   cp -pr `ls |grep shim` ${shim}
   echo "Done.."
   #Copy shim rpm file
   # echo "start copy from media1"
   # cd ${dirc}
   # cp -pr `ls |grep grub-efi-x64` ${grub2}
   # echo "Done.."
   # echo "cpio shim start"

   cd ${shim}
   rpm2cpio `ls |grep shim` | cpio -dimv
   cp -vf boot/efi/EFI/centos/shim.efi /var/lib/tftpboot/
   echo "cpio grub2 start"
   # cd ${grub2}
   # echo "${grub2}"
   # rpm2cpio `ls |grep grub-efi-x64` | cpio -dimv
   # cp -vf boot/efi/EFI/centos/grubx64.efi /var/lib/tftpboot/
   # echo -e "cpio done\n start copy"
   echo "Done.."
 }

ContentMedia() {

  echo "Start copy content media"
   # Copy contents of ISO file
  cp -rpf ${mount}/* /var/ftp/pub/centos7/
  echo "Done...."




 }

 PrepareKickstart() {

   #Kickstart file
   cp ${PWD}/centos7_gui.cfg /var/ftp/pub/centos7/
   chmod +r /var/ftp/pub/centos7/centos7_gui.cfg

 }


StartService() {
  # Start DHCP service
  systemctl start dhcpd.service
  systemctl enable dhcpd.service

  # Start tftp service
  systemctl start tftp.service
  systemctl enable tftp.service

  # Start FTP service
  systemctl enable vsftpd.service
  systemctl start vsftpd.service
}

AllowFirewall() {
  # Allow dhcp and proxy dhcp service
  firewall-cmd --permanent --add-service={dhcp,proxy-dhcp}

  # Allow tftp server service
  firewall-cmd --permanent --add-service=tftp

  # Allow FTP service
  firewall-cmd --permanent --add-service=ftp


  # reload rule firewall
  firewall-cmd --reload
}

################## Call function ######################
# echo -e "======Welcome to Kickstart==========\n\n\n"
# read -p "Please chose mountpoint for repository : " mountpoint
# Prepare_repo $mountpoint
# InstallDhcp
# InstallTftpServer
# InstallFtp
# InstallSyslinux
# ConfigPXEboot $mountpoint
# StartService
# AllowFirewall
