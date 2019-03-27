FROM debian:latest

RUN apt-get -q update && \
    apt-get install -qy iperf3 && \
    apt-get -q clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 5201
ENTRYPOINT ["/usr/bin/iperf3"]
CMD ["-s"]


