#!/bin/bash

USERNAME=$1
PASSWORD=$2
NEXUS_BETA_URL=$3
NEXUS_RELEASE_URL=$4
PROJECT_NAME=$5
TAG_NAME=$6
VERSION=${TAG_NAME%-*}

set -e 

run() {

    #检查制品包是否存在
    check_product=(`curl -w %{http_code} -I -o /dev/null -v -u ${USERNAME}:${PASSWORD} -s ${NEXUS_BETA_URL}/${PROJECT_NAME}/${VERSION}/${TAG_NAME}/${TAG_NAME}.tar.gz`)

    #下载需要升级的制品包并重命名
    if [[ ${check_product} -eq 200 ]]; then
        curl -v -u ${USERNAME}:${PASSWORD} -s ${NEXUS_BETA_URL}/${PROJECT_NAME}/${VERSION}/${TAG_NAME}/${TAG_NAME}.tar.gz > ${VERSION}.tar.gz
    else
        echo "${NEXUS_BETA_URL}/${PROJECT_NAME}/${VERSION}/${TAG_NAME}/${TAG_NAME}.tar.gz is not existed!"
        return 1
    fi
    #上传晋级后的制品包
    res=(`curl -v -u ${USERNAME}:${PASSWORD} -w %{http_code} -I -o /dev/null -s --upload-file ./${VERSION}.tar.gz ${NEXUS_RELEASE_URL}/${PROJECT_NAME}/${VERSION}/`)
    if [[ ! ${res} -eq 201 ]] ; then
        echo "Uploading ${VERSION}.tar.gz failed, cause:" ${res}
        return 1
    fi 
}

run || exit 1