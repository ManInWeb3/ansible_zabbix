
# Runing and managing Zabbix server and Zabbix web interface
To run monitoring server and web interface 
1. clone this repo
2. Set correct DB credentials in **.env_db_pgsql**
	1. If the given DB is empty, during start container will populate with new DB data. Use the following credentials to login to the new system: Admin/zabbix .
	2. To restore DB from backup befor starting server restore your DB dump to the database
    2. This Db stores all data about configuration and metrics values so it's important to back it up.
3. Run/stop the system
    1. To start system execute  docker-compose -f docker-compose_zbx-server_zbx-web.yaml up -d 
    2. To see logs docker-compose -f docker-compose_zbx-server_zbx-web.yaml logs
    3. To stop system docker-compose -f docker-compose_zbx-server_zbx-web.yaml stop
4. To automate agents registration on the server **Auto registratoin** should be configured on the server.

# Backingup/Restoring Zabiix configuration

To backup the configuration of the monitoring system (Configuration include all settings, added host, groups, templates, alerts, notifications, metrics but not include values of the metrics and their history)
1. Define postgres container id
2. Execute backup-zabbix-config.sh script with the container id as argument, as a result you'll get sql dump,n zabbix-backups folder, which consist zabbix db scheme and all configuration data

To restore the configuration
1. Create DB and user for zabbix
2. Set correct values in Zabbix configs
3. Restore the configuration dump to the DB
4. Start Zabbix server and web interface
5. If zabbix agents have correct values (Server) then server will start getting metrics.



# Installing and running zabbix agent on servers
1. Set correct **ZBX_SERVER_HOST** and **ZBX_ACTIVESERVERS** values ( ZBX_SERVER_HOST shuld be equal to zabbix-oklus.my.net.int,ZABBIX_SERVER_IP and ZBX_ACTIVESERVERS=ZABBIX_SERVER_IP ) in **.env_agent**
2. Execute **zabbix-agent_installnconfig.sh** script to install zabbix-agent and configure it with data from **.env_agent** file.

## Source repository

[Zabbix docker monitoring](https://github.com/szimszon/docker_monitor_zabbix)
[Zabbix disk io monitoring](https://github.com/grundic/zabbix-disk-performance)


[Zabbix github](https://github.com/zabbix/zabbix-docker)

[Zabbix addons Community Repos](https://github.com/zabbix/zabbix-community-repos.git) 

[Zabbix Slack notification](https://github.com/ericoc/zabbix-slack-alertscript) - installed

[A lot of zabbix addons](https://monitoringartist.github.io/zabbix-searcher/#)

[Zabbix share](https://share.zabbix.com/)







