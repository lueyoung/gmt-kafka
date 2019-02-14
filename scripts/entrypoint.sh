#!/bin/bash

set -ex
info() {
    echo $(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - "$*"
}

ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-"2181"}
ZK_PORT=${ZOOKEEPER_PORT}

THIS_IP=$(hostname -i)
THIS_NAME=$(hostname -s)
ALIAS=$(echo $THIS_NAME | awk -F '-' '{print $1}')
ID=$(echo $THIS_NAME | awk -F '-' '{print $2}')
#ID=$(echo $THIS_NAME | awk -F '-' '{print $2}' | awk -F '.' '{print $1}')
info Nodes in this cluster: $N_NODES
info IP: ${THIS_IP}
info ID: ${ID}
info Alias: ${ALIAS}
info svc discovery: $DISCOVERY
info pod namespace: $POD_NAMESPACE

# get zk info
SEP=''
ZK_HOSTS=''
for i in $(seq -s ' ' 1 3); do
  j=$[i-1]
  ZK_HOSTS+="$SEP"
  ZK_HOSTS+="${DISCOVERY}$j.${POD_NAMESPACE}:${ZK_PORT}"
  SEP=','
done
echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - $0 - zk info: $ZK_HOSTS"

cat /tmp/server.properties > /etc/server.properties

sed -i "s/{{broker.id}}/${ID}/g" /etc/server.properties
#sed -i "s/\#delete.topic.enable=true/delete.topic.enable=true/g" /opt/kafka/config/server.properties
sed -i "s/{{zookeeper.nodes}}/${ZK_HOSTS}/g" /etc/server.properties
#sed -i "s/{{.hostname}}/${THIS_NAME}/g" /etc/server.properties
sed -i "s/{{.hostname}}/kafka-0,kafka-1,kafka-2/g" /etc/server.properties
echo -e "\n\nlog.cleaner.enable=true\n" >> /etc/server.properties

kafka-server-start.sh /etc/server.properties
