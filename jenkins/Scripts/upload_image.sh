#!/bin/sh

set -e

IMAGE_REPO=$1
USERNAME=$2
PASSWORD=$3
NAMESPACE=$4
PROJECT_NAME=${5,,}
TAG=$6

run() {

    #登陆镜像仓库
    docker login -u ${USERNAME} -p ${PASSWORD} ${IMAGE_REPO}
    judge login

    #推送镜像到镜像仓库
    docker push ${IMAGE_REPO}/${NAMESPACE}/${PROJECT_NAME}:${TAG}
    judge push

    #删除本地镜像节省空间
    docker rmi ${IMAGE_REPO}/${NAMESPACE}/${PROJECT_NAME}:${TAG}
    judge rmi
}

judge() {
    is_ok=$?
    if [[ $is_ok == 0 ]]; then
        echo "Succeed to docker $1."
    else
        echo "Failed to docker $1."
        exit 1
    fi
}

run || exit 1