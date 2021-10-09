#!/bin/sh

##日本のタイムゾーン設定
sudo timedatectl set-timezone Asia/Tokyo

##全ソフトウエア更新
sudo apt update
sudo apt -y upgrade
sudo apt -y autoremove
sudo apt clean

##ファームウエアアップデート
sudo apt -y install rpi-eeprom
sudo rpi-eeprom-update

##完了後の再起動
read -p "再起動しますか [y/N]:" YN
if [ " $YN" = " y" ] || [ " $YN" = " Y" ]; then
  sudo reboot
fi
