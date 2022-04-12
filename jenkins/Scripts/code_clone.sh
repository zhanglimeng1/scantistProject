#!/bin/sh
set -e

GITLAB_IP=$1
PROJECT_GROUP=$2
PROJECT_NAME=$3

run() {
    #打印输出参数，校验是否为空
    if [[ ! -n ${GITLAB_IP} || ! -n ${PROJECT_GROUP} || ! -n ${PROJECT_NAME} ]]; then
        echo "the params is null, exit now"
        return 1
    else
        #git clone git@${GITLAB_IP}:${PROJECT_GROUP}/${PROJECT_NAME}.git
    fi
}

run || exit 1
