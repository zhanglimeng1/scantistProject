#!/bin/sh

BUILD_STYLE=$1
#代码静态检查扫描

set -e 

run() {
    if [[ ${BUILD_STYLE} == 'npm' ]];then
       npm install -g cnpm && cnpm install && npm run eslint 
    else
        ./gradlew checkMain && ./gradlew pmdMain
    fi
}

run || exit 1