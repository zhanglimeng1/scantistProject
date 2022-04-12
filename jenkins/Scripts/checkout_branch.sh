#!/bin/sh

BRANCH_NAME=$1

set -e 

run() {

    # 判断当前分支是否存在
    is_exists=$(git branch -a | grep ${BRANCH_NAME})
    if [[ -n ${is_exists} ]];then
        echo "the ${BRANCH_NAME} is exists."
    else
        echo "the ${BRANCH_NAME} is not exists."
        BRANCH_NAME=master
    fi

    git checkout ${BRANCH_NAME}

    # gradlew命令赋权限
    if [[ -e gradlew ]];then
        chmod +x ./gradlew
    fi
}

run || exit 1