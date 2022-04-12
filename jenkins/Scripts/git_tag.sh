#!/bin/bash

set -e
BRANCH_NAME=$1
MODULE_NAME=$2
run() {
    #打印输入参数，校验是否为空
    echo "BRANCH_NAME is ${BRANCH_NAME}"
    if [[ ! -n ${BRANCH_NAME} ]]; then
        echo "BRANCH_NAME is null, exit now"
        return 1
    else
        #生成tag号 
        versionID=`echo ${BRANCH_NAME#*_}`
        if [[ -n ${MODULE_NAME} ]];then
            versionID=${MODULE_NAME}-$versionID
        fi
        echo $versionID > versionID
        #根据窗口版本号匹配git的tag
        git tag |grep ${versionID} > ${versionID}
        if [ ! -s ${versionID} ];then
            tagNumber=${versionID}-BETA_1
        else
            #对已存在的tag进行排序，获取最大版本号，加1即创建最新的beta版本,形如1.13.0.0_BETA_10
            sed "s/${versionID}-BETA_/ /g" ${versionID} > number
            sort -g number > sortNumber
            MAX=`tail -1 sortNumber | sed 's/ //g'`
            let MAX+=1
            tagNumber=${versionID}-BETA_${MAX}
        fi
        echo $tagNumber > tagNumber
    fi

    #创建tag并push到git仓库
    git tag  ${tagNumber} && git push origin ${tagNumber}
    is_ok=$?
    if [[ $is_ok == 0 ]]; then
        echo "Succeed to create tag."
    else
        echo "Failed to create tag."
        return 1
    fi
}
run || exit 1