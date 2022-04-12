#!/bin/sh

BUILD_STYLE=$1
# sonar扫描

set -e 

run() {

    if [[ ${BUILD_STYLE} == 'npm' ]];then
       echo 'npm sonar ...' 
    elif [[ ${BUILD_STYLE} == 'gradle' ]];then
        ./gradlew sonarqube -x test
    fi
}

run || exit 1