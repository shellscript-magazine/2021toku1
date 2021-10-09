#!/bin/sh

##初期設定
DB_PASSWORD="shmag"

##必要なパッケージのインストール
sudo apt update
sudo apt -y install mediawiki imagemagick

##データベースの作成
sudo mysql -e "create database my_wiki;"
sudo mysql -e "create user 'mediawiki'@'%' identified by '$DB_PASSWORD';"
sudo mysql -e "grant all privileges on my_wiki.* to 'mediawiki'@'%';"
