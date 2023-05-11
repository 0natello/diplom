#!/bin/bash
# Установка и настройка сервера Zabbix

# Обновляем список пакетов
sudo apt update

# Устанавливаем необходимые пакеты
sudo apt install -y apache2 php php-mysql php-gd libcurl4-openssl-dev libxml2-dev libssl-dev php-xml php-bcmath libapache2-mod-php php-ldap mariadb-server

# Создаем базу данных для Zabbix
sudo mysql -u root -p -e "CREATE DATABASE zabbix CHARACTER SET UTF8 COLLATE UTF8_BIN"
sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost IDENTIFIED BY 'password'"

# Скачиваем пакеты Zabbix и устанавливаем
sudo wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
sudo dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb
sudo apt update
sudo apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent

# Настраиваем сервер Zabbix
sudo nano /etc/zabbix/zabbix_server.conf
# Редактируем строки:
# DBName=zabbix
# DBUser=zabbix
# DBPassword=password

# Рестартуем сервер Zabbix
sudo systemctl restart zabbix-server zabbix-agent apache2

# Устанавливаем SELinux
sudo apt install -y policycoreutils selinux-utils
sudo setsebool -P httpd_can_connect_zabbix on

# Готово!