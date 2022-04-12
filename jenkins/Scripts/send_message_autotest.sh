#!/bin/bash
# 此脚本可实现jenkins往企业微信推送消息
INFO="$1"
INFO2="$2"
INFO3="$3"
INFO4="$4"
INFO5="$5"
uiurl="$6"
uifailed="$7"
apiurl="$8"
apifailed="$9"
project="${10}"
env="${11}"
curyear="$(date '+%Y-%m-%d')"
curtime="$(date '+%H:%M:%S')"

CHAT_WEBHOOK_KEY='8e098cea-3b13-444d-8e8d-1929d58e7710'
CHAT_CONTENT_TYPE='Content-Type: application/json'
CHAT_WEBHOOK_URL='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key'


if [ _"${CHAT_WEBHOOK_KEY}" = _"" ]; then
  echo "please make sure CHAT_WEBHOOK_KEY has been exported as environment variable"
  exit 1
fi

  echo "## send message for : ${INFO}"
  curl "${CHAT_WEBHOOK_URL}=${CHAT_WEBHOOK_KEY}" \
   -H "${CHAT_CONTENT_TYPE}" \
   -d '
      {
          "msgtype": "markdown",
          "markdown": {
              "content": "'${project}'<font color=\"warning\">:'${INFO}'</font>
		>构建人:<font color=\"comment\">'${INFO2}'</font>
		>构建链接:<font color=\"info\">['${INFO3}']('${INFO3}')</font>
		>构建分支:<font color=\"comment\">'${INFO4}'</font>
		>构建次数:<font color=\"comment\">'${INFO5}'</font>
    >部署环境:<font color=\"comment\">'${env}'</font>
    >构建时间:<font color=\"comment\">'${curyear}"\ "${curtime}'</font>
		>ui测试报告:<font color=\"info\">['${uiurl}']('${uiurl}')</font>
		>ui测试失败:<font color=\"info\">'${uifailed}'</font>
		>api测试报告:<font color=\"info\">['${apiurl}']('${apiurl}')</font>	
	  >api测试失败:<font color=\"info\">'${apifailed}'</font>
	 	"
          }
      }'

               
