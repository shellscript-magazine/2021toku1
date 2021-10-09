#!/bin/sh

##初期設定
SIZE="100M"
DB_PASSWORD="admin"

##必要なパッケージの導入
sudo apt update
sudo apt -y install apache2 php php-curl php-xml php-mysql mysql-server unzip

##RainLoop Webmailの導入
wget https://www.rainloop.net/repository/webmail/rainloop-community-latest.zip
sudo mkdir -p /var/www/html/rainloop
sudo unzip rainloop-community-latest.zip -d /var/www/html/rainloop/.
sudo chown -R www-data /var/www/html/rainloop
cat << EOF | sudo tee /etc/apache2/sites-available/rainloop.conf >> /dev/null
<Directory /var/www/html/rainloop/data>
    Require all denied
</Directory>
EOF
sudo a2ensite rainloop

##連絡先データベースの作成とApacheに反映
sudo mysql -e "create database rainloop;"
sudo mysql -e "create user 'rainloop'@'%' identified by '$DB_PASSWORD';"
sudo mysql -e "grant all privileges on rainloop.* to 'rainloop'@'%';"

##添付ファイルサイズの拡大
sudo sed -i -e "s%upload_max_filesize = 2M%upload_max_filesize = '$SIZE'%" /etc/php/7.4/apache2/php.ini
sudo sed -i -e "s%post_max_size = 8M%post_max_size = '$SIZE'%" /etc/php/7.4/apache2/php.ini
sudo systemctl restart apache2
