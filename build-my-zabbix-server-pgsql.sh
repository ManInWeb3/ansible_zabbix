# Build zabbix-server-pgsql
pushd zabbix-docker/server-pgsql/alpine
./build.sh
popd
pushd my-zabbix-server-pgsql/alpine
docker build -t my-zabbix-server-pgsql:alpine-latest .
popd

# Build zabbix Java gateway
pushd zabbix-docker/web-nginx-pgsql/alpine
./build.sh
popd
# Build zabbix web frontend
pushd zabbix-docker/java-gateway/alpine
./build.sh
popd

