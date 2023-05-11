#!/bin/bash

# Установка zabbix-agent
sudo apt-get update
sudo apt-get install zabbix-agent

# Настройка файла конфигурации zabbix-agent
sudo sed -i 's/^Server=.*/Server=192.168.0.7/' /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/^ServerActive=.*/ServerActive=192.168.0.7/' /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/^Hostname=.*/Hostname=$(hostname)/' /etc/zabbix/zabbix_agentd.conf

# Перезапуск zabbix-agent
sudo systemctl restart zabbix-agent

# Добавление хоста на сервере Zabbix
curl -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"host.create","params":{"host":"$(hostname)","interfaces":[{"type":1,"main":1,"useip":1,"ip":"$(hostname -I | awk '{print $1}')","dns":""}],"groups":[{"groupid":"1"}]},"auth":"$(cat /etc/zabbix/zabbix_agentd.psk | cut -d':' -f2)","id":1}' http://192.168.0.7/api_jsonrpc.php

# Добавление шаблона на сервере Zabbix
curl -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"template.create","params":{"host":"$(hostname)","groups":[{"groupid":"1"}],"templates":[{"templateid":"10001"}]},"auth":"$(cat /etc/zabbix/zabbix_agentd.psk | cut -d':' -f2)","id":1}' http://192.168.0.7/api_jsonrpc.php

echo "Компьютер успешно добавлен в сервер Zabbix"