#!/bin/bash

CONFING_ROOT=$1
ENV=$2
NAMESPACE=$3
DEPLOY_NAME=$4
TAG=$5
DATETIME=$6
IMAGE_TAG=${TAG##*_}

run () {
    if [[ ! -n ${CONFING_ROOT} || ! -n ${ENV} || ! -n ${NAMESPACE} || ! -n ${DEPLOY_NAME} || ! -n ${TAG} || ! -n ${DATETIME} ]];then
        echo 'some params is null, exit now.'
        exit 1
    else
        if [[ ${ENV} == "uat" || ${ENV} == "sit" || ${ENV} == "dev" ]];then
            
            IMAGE_TAG=${TAG}
        fi
    	echo '等待返回pod启动结果！！！' 
    	for ((i=1; i<=200; i++))
    	do 
            sleep 3
            #获取pod名
            POD_NAME=`kubectl --kubeconfig=${CONFING_ROOT}/config-${ENV} get pods --namespace ${NAMESPACE} -l "app.kubernetes.io/instance=${DEPLOY_NAME}" -o jsonpath="{.items[0].metadata.name}"`

            #获取pod状态
            POD_STATUS=`kubectl --kubeconfig=${CONFING_ROOT}/config-${ENV} -n ${NAMESPACE} get pod $POD_NAME -o yaml | grep "ready:" | awk '{print $2}'`

            #获取部署镜像标签
            podtag=`kubectl --kubeconfig=${CONFING_ROOT}/config-${ENV} -n ${NAMESPACE} get pod $POD_NAME -o yaml | grep "image:" | grep ":${IMAGE_TAG}" | awk -F ':' '{print $3}' | sort | uniq`
	        timestamps=`kubectl --kubeconfig=${CONFING_ROOT}/config-${ENV} -n ${NAMESPACE} get pod $POD_NAME -o yaml | grep "current.time" | awk -F ':' '{print $2}' | sed 's/\"//g'`
            if [[ ${IMAGE_TAG} == ${podtag} ]];then
                #比较部署开始时间戳和pod启动后的时间戳，防止sit环境无法通过版本号比较是否部署成功
                if [[ ${timestamps} -gt ${DATETIME} && ${POD_STATUS} == 'true' ]];then
                    echo ${IMAGE_TAG}'部署成功！！！'
                    echo '等待第'$i'个3秒....' 
                    break
                elif [[ $i == 100 ]];then
                    echo '部署的不是最新镜像或等待超过5分钟退出，部署失败！！！'
                    exit 1
                fi
            elif [[ $i == 100 ]];then
                echo '当前部署环境运行的镜像为:'${podtag}', 不是当前流水线构建镜像或等待时间超过5分钟退出，部署失败！！！'
                exit 1
            fi
        done
    fi   
}

run || exit 1