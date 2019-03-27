FROM zabbix-server-pgsql:alpine-latest

RUN apk update && \
    apk add ${APK_FLAGS_PERSISTENT} \
	    curl \
            python \
             && \
    rm -rf /var/cache/apk/* && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip \
            xmltodict \
            requests \
             && \
    rm -r /root/.cache
