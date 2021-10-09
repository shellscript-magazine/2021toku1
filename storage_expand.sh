#!/bin/sh

##パーティション作成とフォーマット
sudo parted -s /dev/sda rm 1
sudo parted -s /dev/sda mklabel msdos
sudo parted -s /dev/sda mkpart primary 0% 100%
sudo mke2fs -t ext4 -F /dev/sda1

##/varディレクトリに自動マウント
sudo e2label /dev/sda1 usbssd
sudo sh -c "echo 'LABEL=usbssd /var ext4 defaults 0 0' >> /etc/fstab"

##読み書き許可と/varディレクトリコピー
sudo mount /dev/sda1 /mnt
sudo chmod 777 /mnt
sudo cp -a /var/* /mnt

##完了後の再起動
read -p "再起動しますか [y/N]:" YN
if [ " $YN" = " y" ] || [ " $YN" = " Y" ]; then
  sudo reboot
fi
