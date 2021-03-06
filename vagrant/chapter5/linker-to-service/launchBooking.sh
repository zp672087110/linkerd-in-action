#!/bin/bash

# 由于linkerd作为sidecar，与booking服务部署在一起,
# 需注册linkerd到Consul, 所有linkerd均以相同名字linkerd注册，
# 使用端口及标签分辩linkerd服务于哪种服务，演示环境中,
# 约定4141=>user服务,4142=>booking服务,4143=>concert服务
SERVICE_NAME=linkerd
SERVICE_TAG=booking
DOCKER_NAME=$SERVICE_TAG-$(cat /dev/urandom | head -n 10 | md5sum | head -c 10)
IP=$(ip addr show | grep eth1 | grep inet | awk '{print $2}' | cut -d'/' -f1)

# booking服务配置信息, 可通过环境变量或JSON文件进行配置
DBNAME=demo
DBUSER=test
DBPASSWORD=pass
DBENDPOINT=mysql.service.consul:3306
CONCERT_SERVICE_ADDR=concert.linkerd.service.consul:4143

docker run -d \
    -p 4142:4141 \
    -p 62001:8181 \
    --dns $IP \
    --name $DOCKER_NAME \
    --env SERVICE_4141_NAME=$SERVICE_NAME \
    --env SERVICE_TAGS=$SERVICE_TAG \
    --env SERVICE_8181_IGNORE=true \
    --env DBNAME=$DBNAME \
    --env DBUSER=$DBUSER \
    --env DBPASSWORD=$DBPASSWORD \
    --env DBENDPOINT=$DBENDPOINT \
    --env CONCERT_SERVICE_ADDR=$CONCERT_SERVICE_ADDR \
    --volume $PWD/linkerd-booking.yml:/linkerd.yml \
    zhanyang/booking:1.1
