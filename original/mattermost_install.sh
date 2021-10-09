#!/bin/sh

##初期設定
DB_PASSWORD="shmag"
MATTERMOST="v5.39.0/mattermost-v5.39.0-linux-arm64.tar.gz"
SITE_URL="http://192.168.11.100/"

##データベースの作成
sudo apt update
sudo apt -y install mysql-server
sudo mysql -uroot -e "create user 'mmuser'@'%' identified by '$DB_PASSWORD';"
sudo mysql -uroot -e "create database mattermost;"
sudo mysql -uroot -e "grant all privileges on mattermost.* to 'mmuser'@'%';"

##mattermostの入手と展開
wget https://github.com/SmartHoneybee/ubiquitous-memory/releases/download/$MATTERMOST
tar -xvzf mattermost*.gz
sudo mv mattermost /opt
sudo mkdir /opt/mattermost/data
sudo useradd --system --user-group mattermost
sudo chown -R mattermost:mattermost /opt/mattermost
sudo chmod -R g+w /opt/mattermost

##設定ファイルの書き換え
sudo sed -i -e 's%"postgres"%"mysql"%' /opt/mattermost/config/config.json
sudo sed -i -e 's%postgres://mmuser:mostest@localhost/mattermost_test?sslmode=disable\\u0026connect_timeout=10%mmuser:'$DB_PASSWORD'@tcp(localhost:3306)/mattermost?charset=utf8mb4,utf8\&writeTimeout=30s%' /opt/mattermost/config/config.json
sudo sed -i -e 's%"SiteURL": "",%"SiteURL": "'$SITE_URL'",%' /opt/mattermost/config/config.json

##起動・停止ファイルの作成
cat << EOF | sudo tee /lib/systemd/system/mattermost.service > /dev/null
[Unit]
Description=Mattermost
After=network.target
After=mysql.service
BindsTo=mysql.service

[Service]
Type=notify
ExecStart=/opt/mattermost/bin/mattermost
TimeoutStartSec=3600
KillMode=mixed
Restart=always
RestartSec=10
WorkingDirectory=/opt/mattermost
User=mattermost
Group=mattermost
LimitNOFILE=49152

[Install]
WantedBy=mysql.service
EOF

##mattermostの起動と自動起動設定
sudo systemctl daemon-reload
sudo systemctl start mattermost
sudo systemctl enable mattermost
