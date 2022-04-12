#!/bin/bash


IMAGE_REPO=$1
USERNAME=$2
PASSWORD=$3
NAMESPACE=$4
PROJECT_NAME=$5
TAG=$6
VERSION=${TAG%-*}

set -e

run() {

    #下载需要晋级的镜像
    docker pull ${IMAGE_REPO}/${NAMESPACE}/${PROJECT_NAME}:${TAG}
    judge pull

    #修改镜像版本号
    docker tag ${IMAGE_REPO}/${NAMESPACE}/${PROJECT_NAME}:${TAG} ${IMAGE_REPO}/${NAMESPACE}/${PROJECT_NAME}:${VERSION}
    judge tag

    #登陆镜像仓库
    docker login -u ${USERNAME} -p ${PASSWORD} ${IMAGE_REPO}
    judge login

    #推送镜像到镜像仓库
    docker push ${IMAGE_REPO}/${NAMESPACE}/${PROJECT_NAME}:${VERSION}
    judge push

    #删除本地镜像节省空间
    docker rmi ${IMAGE_REPO}/${NAMESPACE}/${PROJECT_NAME}:${VERSION}
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