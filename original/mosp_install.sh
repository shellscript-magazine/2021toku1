#!/bin/sh

##初期設定
MOSP="time4.war"

##必要なパッケージのインストール
sudo apt update
sudo apt -y install tomcat9 tomcat9-admin postgresql
##Mosp勤怠管理の導入
sudo chown tomcat:tomcat $MOSP
sudo chmod 775 $MOSP
sudo mv $MOSP /var/lib/tomcat9/webapps/.

##データベース管理者に切り替え
sudo -i -u postgres

##初期設定
DBADMIN_PASSWORD="shmag"

##管理者パスワード設定
psql -c "alter role postgres with password '$DBADMIN_PASSWORD';"