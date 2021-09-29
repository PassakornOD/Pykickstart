#!/bin/bash

ConfigDHCP() {

  # Configure dhcp file
  cat >> /etc/dhcp/dhcpd.conf << EOF
  option space pxelinux;
  option pxelinux.magic code 208 = string;
  option pxelinux.configfile code 209 = text;
  option pxelinux.pathprefix code 210 = text;
  option pxelinux.reboottime code 211 = unsigned integer 32;
  option architecture-type code 93 = unsigned integer 16;

  subnet 192.168.70.0 netmask 255.255.255.0 {
  	option routers 192.168.70.2;
  	range 192.168.70.126 192.168.70.253;

  	class "pxeclients" {
  	  match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
  	  next-server 192.168.70.20;

  	  if option architecture-type = 00:07 {
  	    filename "shim.efi";
  	    } else {
  	    filename "pxelinux.0";
  	  }
  	}
  }
  # #DHCP configuration for PXE boot server
  # ddns-update-style interim;
  # ignore client-updates;
  # authoritative;
  # allow booting;
  # allow bootp;
  # allow unknown-clients;
  #
  # subnet 192.168.70.0
  # netmask 255.255.255.0
  # {
  #   range 192.168.70.100 192.168.70.199;
  #   option domain-name-servers 192.168.70.2;
  #   option domain-name "linuxlab.com";
  #   option routers 192.168.70.2;
  #   option broadcast-address 192.168.70.255;
  #   default-lease-time 600;
  #   max-lease-time 7200;
  #   class "pxeclients" {
  #         match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
  #         next-server 192.168.70.20;
  #
  #         if substring (option vendor-class-identifier, 15, 5) = "00009" {
  #           filename "grubx64.efi";
  #           } else {
  #           filename "pxelinux.0";
  #       }
  #   }
  # }
EOF
}

ConfigPxelinux() {

  ##############################Configure pxelinux file########################
  cat >> /var/lib/tftpboot/pxelinux.cfg/default << EOF
    default menu.c32
    prompt 0
    timeout 30
    menu title Passakorn's PXE Menu
    label 1^) Install CentOS7 Manual
    kernel /networkboot/centos7/vmlinuz
    append initrd=/networkboot/centos7/initrd.img inst.repo=ftp://192.168.70.20/pub/centos7/

    label 2^) Install CentOS7 Kickstart
    kernel /networkboot/centos7/vmlinuz
    append initrd=/networkboot/centos7/initrd.img inst.repo=ftp://192.168.70.20/pub/centos7 ks=ftp://192.168.70.20/pub/centos7/centos7_gui.cfg
EOF
}

ConfigEFI() {

  ##############################Configure EFI file########################
  cat >> /var/lib/tftpboot/grub.cfg << EOF
    set timeout=60

    menuentry 'Install CentOS7 Manual' {
            linuxefi /networkboot/centos7/vmlinuz inst.repo=ftp://192.168.70.20/pub/centos7/
            initrdefi /networkboot/centos7/initrd.img
    }

    menuentry 'Install CentOS7 Kickstart' {
        linuxefi /networkboot/centos7/vmlinuz inst.repo=ftp://192.168.70.20/pub/centos7/ inst.ks=ftp://192.168.70.20/pub/centos7/centos7_gui.cfg
        initrdefi /networkboot/centos7/initrd.img
    }
EOF
}
