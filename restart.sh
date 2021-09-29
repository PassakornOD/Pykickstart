#!/bin/bash

systemctl start dhcpd.service
systemctl start vsftpd.service
systemctl start tftp.service
