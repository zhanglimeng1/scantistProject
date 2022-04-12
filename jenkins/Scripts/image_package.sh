#!/bin/sh

IMAGE_REPO=$1
NAMESPACE=$2
PROJECT_NAME=${3,,}
TAG=$4
DOCKERFILE_ROOT=$5

set -e 

run() {

    #复制dockerfile目录到当前工作目录
    if [[ ${TAG} == 'dev' && -z ${DOCKERFILE_ROOT} ]];then
        # 删除旧版本Dockerfile
        rm -rf ./Dockerfile
        cp ./k8s.dockerfile ./Dockerfile
    else
        cp -r ${DOCKERFILE_ROOT}/* ./
    fi

    #构建docker镜像
    docker build -t ${IMAGE_REPO}/${NAMESPACE}/${PROJECT_NAME}:${TAG} .

    is_ok=$?
    if [[ $is_ok == 0 ]]; then
        echo "Succeed to docker build."
    else
        echo "Failed to docker build."
        exit 1
    fi
}

run || exit 1