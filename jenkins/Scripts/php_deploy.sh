#!/bin/sh

set -e 
TAG_NUMBER=$1
TIMESTAMP=$2
NAMESPACE=$3
CONFING_ROOT=$4
VALUES_ROOT=$5
ENV=$6
SERVICE_NAME=$7
OPERATE=$8
IMAGE_NAME=$9
VERSION=${TAG_NUMBER##*_}

run() {

    if [[ ${ENV} == "uat" || ${ENV} == "sit" || ${ENV} == "dev" ]];then
        VERSION=${TAG_NUMBER}
    fi
    
    echo "VERSION is ${VERSION}"
    if [[ ${OPERATE} == "install" ]]; then
        helm --kubeconfig=${CONFING_ROOT}/config-${ENV} del vnnox-${SERVICE_NAME} -n ${env} 
        wait
        helm --kubeconfig=${CONFING_ROOT}/config-${ENV} install vnnox-${SERVICE_NAME} -n ${NAMESPACE} ${VALUES_ROOT} --set image.repository=${IMAGE_NAME}.pullPolicy=Always,image.tag=${VERSION},service_type=${SERVICE_NAME},vnnox_tag=${VERSION},timestamp=${TIMESTAMP}
    elif [[ ${OPERATE} == "upgrade" ]]; then 
        helm --kubeconfig=${CONFING_ROOT}/config-${ENV} upgrade vnnox-${SERVICE_NAME} -n ${NAMESPACE} ${VALUES_ROOT} --set image.repository=${IMAGE_NAME},image.pullPolicy=Always,image.tag=${VERSION},service_type=${SERVICE_NAME},vnnox_tag=${VERSION},timestamp=${TIMESTAMP}
    elif [[ ${OPERATE} == "rollback" ]]; then
        helm --kubeconfig=${CONFING_ROOT}/config-${ENV} rollback vnnox-${SERVICE_NAME} -n ${NAMESPACE} ${VALUES_ROOT} --set image.repository=${IMAGE_NAME},image.pullPolicy=Always,image.tag=${VERSION},service_type=${SERVICE_NAME},vnnox_tag=${VERSION},timestamp=${TIMESTAMP}
    else
        echo 'OPERATE is error！！！'
    fi
}

run || exit 1