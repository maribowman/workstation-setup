#!/bin/bash

# mount local NAS share
mkdir /home/mari/LocalShare
sudo echo "//192.168.0.3/local-share /home/mari/LocalShare cifs rw,dir_mode=0777,file_mode=0777,vers=2.0,username=mari,password=<SYNOLOGY_PASSWORD> 0 0" | tee -a /etc/fstab
sudo mount -a

# create local Dev share
echo "[Dev]" | tee -a /etc/samba/smb.conf
echo "   comment = Share Dev directory in network" | tee -a /etc/samba/smb.conf
echo "   path = /home/mari/Dev" | tee -a /etc/samba/smb.conf
echo "   read only = no" | tee -a /etc/samba/smb.conf
