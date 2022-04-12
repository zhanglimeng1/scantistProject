#!/bin/sh

set -e 

TAG_NUMBER=$1
PACKAGE_ROOT=$2
NEXUS_DIST_URL=$3
VERSION=$4
USERNAME=$5
PASSWORD=$6
REPORT_DIR=$7
PROJECT_NAME=$8
file_type_array=("" "" "" "" "" "")
#将制品包进行打包
pack() {
    echo "TAG_NUMBER is ${TAG_NUMBER}, PACKAGE_ROOT is ${PACKAGE_ROOT}."
    if [[ ! -n ${TAG_NUMBER} || ! -n ${PACKAGE_ROOT} ]];then
        echo "some parameter is null, exit now"
        return 1
    else
        if [ -n "`find ./${PACKAGE_ROOT}/ -maxdepth 1 -name '*.jar'`" ] ; then :
            cp ./${PACKAGE_ROOT}/*.jar .
            file_type_array[0]="*.jar"
        fi
        if [ -n "`find ./${PACKAGE_ROOT}/ -maxdepth 1 -name '*.tar'`" ] ; then :
            cp ./${PACKAGE_ROOT}/*.tar .
            file_type_array[1]="*.tar"
        fi
        if [ -n "`find ./${PACKAGE_ROOT}/ -maxdepth 1 -name '*.war'`" ] ; then :
            cp ./${PACKAGE_ROOT}/*.war .
            file_type_array[2]="*.war"
        fi
        if [ -n "`find ./${PACKAGE_ROOT}/ -maxdepth 1 -name '*.apk'`" ] ; then :
            cp ./${PACKAGE_ROOT}/*.apk .
            file_type_array[3]="*.apk"
        fi
        if [ -n "`find ./${PACKAGE_ROOT}/ -maxdepth 1 -name '*.zip'`" ] ; then :
            cp ./${PACKAGE_ROOT}/*.zip .
            file_type_array[4]="*.zip"
        fi
        if [[ -d ./dist ]]; then
            file_type_array[5]="./dist/"
        fi
        tar -zcf ${TAG_NUMBER}.tar.gz ${file_type_array[0]} ${file_type_array[1]} ${file_type_array[2]} ${file_type_array[3]} ${file_type_array[4]} ${file_type_array[5]}
        
        pkg_file="./${TAG_NUMBER}.tar.gz"
        echo ${pkg_file} > pkg_file
        echo ${pkg_file}
    fi

    #测试报告打包
    if [[ ! -n ${REPORT_DIR} ]];then
        echo "the unit report is null, skip the tar!"
    else 
        tar -zcf TEST-REPORTS.tar.gz ${REPORT_DIR}
    fi
}

#制品包及单元测试报告上传

upload() {
    #打印输入参数，校验是否为空
    echo "NEXUS_DIST_URL is ${NEXUS_DIST_URL}, VERSION is ${VERSION}, pkg_file is ${pkg_file}."
    if [[ ! -n ${NEXUS_DIST_URL} || ! -n ${VERSION} || ! -n ${pkg_file} ]];then
        echo "some parameter is null, exit now"
        return 1
    else
        #上传安装包到nexus
        res=(`curl -v -u ${USERNAME}:${PASSWORD} -w %{http_code} -I -o /dev/null -s --upload-file ${pkg_file} ${NEXUS_DIST_URL}/${PROJECT_NAME}/${VERSION}/${TAG_NUMBER}/`)
        if [[ ! ${res} -eq 201 ]] ; then
            echo "Failed to deploy";
            return 1
        else
            echo "Succeed to deploy";
        fi
    
        #上传单元测试报告到nexus
        if [[ ! -n ${REPORT_DIR} ]];then
            echo "the unit report is null, skip the curl!"
        else 
            res=(`curl -v -u ${USERNAME}:${PASSWORD} -w %{http_code} -I -o /dev/null -s --upload-file ./TEST-REPORTS.tar.gz ${NEXUS_DIST_URL}/${PROJECT_NAME}/${VERSION}/${TAG_NUMBER}/`)
            if [[ ! ${res} -eq 201 ]] ; then
                echo "Failed to deploy";
                return 1
            else
                echo "Succeed to deploy";
            fi
        fi
    fi
}

pack || exit 1

upload || exit 1