#!/bin/sh

##初期設定
WORKGROUP_NAME="SHMAG"
SHARE_NAME="share"
SHARE_FOLDER="/var/share"

##Sambaのインストール
sudo apt update
sudo apt -y install samba

##旧設定バックアップ
mkdir -p ~/old_settings
sudo mv /etc/samba/smb.conf ~/old_settings/.

##Sambaの共有設定
cat << EOF | sudo tee /etc/samba/smb.conf > /dev/null
[global]
workgroup = workgroup_name
dos charset = CP932
unix charset = UTF8

[share_name]
comment = Raspberry Pi share
path = share_folder
browsable = yes
writable = yes
create mask = 0777
directory mask = 0777
EOF
sudo sed -i -e "s%workgroup_name%'$WORKGROUP_NAME'%" /etc/samba/smb.conf
sudo sed -i -e "s%share_name%'$SHARE_NAME'%" /etc/samba/smb.conf
sudo sed -i -e "s%share_folder%'$SHARE_FOLDER'%" /etc/samba/smb.conf

##共有フォルダ作成
sudo mkdir -p $SHARE_FOLDER
sudo chmod 777 $SHARE_FOLDER

##Sambaの設定反映
sudo systemctl restart smbd
sudo systemctl restart nmbd
