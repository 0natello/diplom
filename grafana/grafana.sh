#!/bin/bash

# Устанавливаем Grafana
wget https://dl.grafana.com/oss/release/grafana-7.5.7.linux-amd64.tar.gz
tar -zxvf grafana-7.5.7.linux-amd64.tar.gz
sudo mv grafana-7.5.7 /usr/share/grafana

# Устанавливаем плагин Zabbix для Grafana
sudo grafana-cli plugins install alexanderzobnin-zabbix-app

# Настраиваем подключение к Zabbix
sudo cp /usr/share/grafana/conf/sample.ini /usr/share/grafana/conf/custom.ini
sudo sed -i 's/;[zabbix]/[zabbix]/g' /usr/share/grafana/conf/custom.ini
sed -i 's/;url = http:\/\/localhost\/zabbix/url = http:\/\/192.168.0.7\/zabbix/g' /usr/share/grafana/conf/custom.ini
sed -i 's/;username = Admin/username = Admin/g' /usr/share/grafana/conf/custom.ini
sed -i 's/;password = zabbix/password = zabbix/g' /usr/share/grafana/conf/custom.ini

# Запускаем Grafana
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server.service