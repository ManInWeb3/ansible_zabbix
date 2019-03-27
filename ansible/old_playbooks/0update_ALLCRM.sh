#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False
#update INVENTORY list
curl -k -o ./inventory.lst https://10.0.253.1/crm/ansiblegroups.php


exit
ansible-playbook ./update_zabbix -i ./inventory.lst --limit '10.0.146.1'
ansible-playbook crm_update -i crm_all.lst --limit 'gr_dshlcrm_en,gr_dshlcrm_ru:!10.1.208.1,gr_deauracrm_en,gr_deauracrm_ru'

ansible-playbook crm_update_files -i crm_all.lst

if [ `find /root -type f`]
