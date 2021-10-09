#!/bin/sh

##初期設定
DB_PASSWORD="shmag"
ADMIN_NAME="admin"
ADMIN_PASSWORD="admin"
OWNCLOUD_FILE="owncloud-10.8.0.tar.bz2"

##ヘルパースクリプト「occ」の作成
cat << EOM | sudo tee /usr/local/bin/occ
#! /bin/bash
cd /var/www/owncloud
sudo -E -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOM
sudo chmod +x /usr/local/bin/occ

##必要・推奨パッケージのインストール
sudo apt update
sudo apt -y install apache2 libapache2-mod-php mysql-server php-imagick php-common php-curl php-gd php-imap php-intl php-json php-mbstring php-mysql php-ssh2 php-xml php-zip php-apcu php-redis redis-server
sudo apt -y install jq inetutils-ping

##ownCloudの設定ファイル作成
sudo sed -i "s%html%owncloud%" /etc/apache2/sites-available/000-default.conf
cat << EOM | sudo tee /etc/apache2/sites-available/owncloud.conf
Alias /owncloud "/var/www/owncloud/"

<Directory /var/www/owncloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
EOM

##Apache HTTP Serverの設定
sudo a2ensite owncloud.conf
sudo a2enmod dir env headers mime rewrite setenvif
sudo systemctl restart apache2

##ownCloudの入手と展開
wget https://download.owncloud.org/community/$OWNCLOUD_FILE
tar -jxf $OWNCLOUD_FILE
sudo mv owncloud /var/www/.
sudo chown -R www-data /var/www/owncloud

##データベースの作成
sudo mysql -e "create database owncloud;"
sudo mysql -e "create user 'owncloud'@'%' identified by '$DB_PASSWORD';"
sudo mysql -e "grant all privileges on owncloud.* to 'owncloud'@'%';"

##ownCloudのインストール
echo "しばらくおまちください。"
occ maintenance:install --database "mysql" --database-name "owncloud" --database-user "owncloud" --database-pass $DB_PASSWORD --admin-user "$ADMIN_NAME" --admin-pass "$ADMIN_PASSWORD"
myip=$(hostname -I|cut -f1 -d ' ')
occ config:system:set trusted_domains 1 --value="$myip"

##バックグラウンド処理の設定
occ background:cron
sudo sh -c 'echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" > /var/spool/cron/crontabs/www-data'
sudo chown www-data.crontab /var/spool/cron/crontabs/www-data
sudo chmod 0600 /var/spool/cron/crontabs/www-data

##キャッシュとロックファイルの作成
occ config:system:set memcache.local --value '\OC\Memcache\APCu'
occ config:system:set memcache.locking --value '\OC\Memcache\Redis'
occ config:system:set redis --value '{"host": "127.0.0.1", "port": "6379"}' --type json

##ログローテーションの設定
cat << EOM | sudo tee /etc/logrotate.d/owncloud
/var/www/owncloud/data/owncloud.log {
  size 10M
  rotate 12
  copytruncate
  missingok
  compress
  compresscmd /bin/gzip
}
EOM
