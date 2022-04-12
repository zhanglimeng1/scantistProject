#!/bin/sh

set -e 
TAG_NUMBER=$1
TIMESTAMP=$2
NAMESPACE=$3
CONFING_ROOT=$4
VALUES_ROOT=$5
ENV=$6
PROJECT_NAME=$7
OPERATE=$8
VERSION=${TAG_NUMBER##*_}

run() {

    if [[ ${ENV} == "uat" || ${ENV} == "sit" || ${ENV} == "dev" ]];then
        VERSION=${TAG_NUMBER}
    fi
    
    echo "VERSION is ${VERSION}"
    if [[ ${OPERATE} == "install" ]]; then
        helm --kubeconfig=${CONFING_ROOT}/config-${ENV} del ${PROJECT_NAME} -n ${env} 
        wait
        helm --kubeconfig=${CONFING_ROOT}/config-${ENV} install ${PROJECT_NAME} -n ${NAMESPACE} ${VALUES_ROOT} --set image.tag=${VERSION},timestamp='${TIMESTAMP}' -f ${VALUES_ROOT}/values-${ENV}.yaml
    elif [[ ${OPERATE} == "upgrade" ]]; then 
        helm --kubeconfig=${CONFING_ROOT}/config-${ENV} upgrade ${PROJECT_NAME} -n ${NAMESPACE} ${VALUES_ROOT} --set image.tag=${VERSION},timestamp='${TIMESTAMP}' -f ${VALUES_ROOT}/values-${ENV}.yaml
    elif [[ ${OPERATE} == "rollback" ]]; then
        helm --kubeconfig=${CONFING_ROOT}/config-${ENV} rollback ${PROJECT_NAME} -n ${NAMESPACE} ${VALUES_ROOT} --set image.tag=${VERSION},timestamp='${TIMESTAMP}' -f ${VALUES_ROOT}/values-${ENV}.yaml
    else
        echo 'OPERATE is error！！！'
    fi
}

run || exit 1