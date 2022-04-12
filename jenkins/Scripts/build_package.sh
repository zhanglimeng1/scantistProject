#!/bin/sh
BUILD_STYLE=$1
PROJECT_PATH=$2

set -e 

run() {
    if [[ ${BUILD_STYLE} == 'npm' ]];then
       docker pull registry.cn-hangzhou.aliyuncs.com/nova-base/node:screen
       docker run -v ${PROJECT_PATH}:/app --rm registry.cn-hangzhou.aliyuncs.com/nova-base/node:screen
    else
       if [[ -n ${PROJECT_PATH} ]];then
          /${PROJECT_PATH}/gradlew clean build -x test 
       else
         ./gradlew clean build -x test     
       fi
    fi 
}

run || exit 1