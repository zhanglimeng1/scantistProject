# coding=utf-8
import json
import sys
import time
import subprocess
import requests

url = "http://172.16.82.19:7070/openapi/v1/teams"

headers = {
  'Authorization': '5686800accfd2f8c16a8dd31f1bcd36e4a5335f3'
}


def get_team():
    teams = []
    res = requests.request("GET", url, headers=headers)
    data = res.json()['tenants']
    for i in data:
        team = {'tenant_id': i['tenant_id'], 'tenant_alias': i['tenant_alias']}
        teams.append(team)
    return teams

def get_project(team_name):
    projects = []
    global  team_id
    teams = get_team()
    for team in teams:
        if team['tenant_alias'] == team_name:
            team_id = team['tenant_id']
    res = requests.request("GET", url+"/"+team_id+"/regions/novastar1/apps", headers=headers)
    data = res.json()
    for i in data:
        project = {'ID': i['ID'], 'group_name': i['group_name']}
        projects.append(project)
    return projects
def get_pod_info(team_name, group_name, service_cname):
    projects = get_project(team_name)
    for project in projects:
        if project['group_name'] == group_name:
            ID = project['ID']
            res = requests.request("GET", url + "/" + team_id + "/regions/novastar1/apps/%d/services" % ID, headers=headers)
            data = res.json()
            for i in data:
                if i['service_cname'] == service_cname:
                    service_id = i['service_id']
                    return service_id


def curl_webhook_and_get_pod_status(team_name, group_name, service_cname):
    service_id = get_pod_info(team_name, group_name, service_cname)
    old_status_id,old_pod_id = subprocess.getstatusoutput("kubectl --kubeconfig=./nova-jenkins-pipeline/Config/config-dev -n "+team_id+" get pods | grep "+service_id+" | awk -F ' ' '{print $1}'")
    print("old_pod_id: "+old_pod_id)
    url = "http://172.16.82.19:7070/console/custom/deploy/"+service_id
    h = {
        "Content-type": "application/json"
    }
    s = json.dumps({"secret_key": "novastar"})
    res = requests.request("POST", url, headers=h, data=s)
    data = res.json()
    time.sleep(10)
    for i in range(100):
        time.sleep(3)
        status_id,pod_id = subprocess.getstatusoutput("kubectl --kubeconfig=./nova-jenkins-pipeline/Config/config-dev -n "+team_id+" get pods | grep "+service_id+" | awk -F ' ' '{print $1}'")
        print("pod_id: "+pod_id)
        if pod_id not in old_pod_id:
            she = "kubectl --kubeconfig=./nova-jenkins-pipeline/Config/config-dev -n "+team_id+" get pod "+pod_id+" -o yaml | grep 'ready:' | awk '{print $2}'"
            service_status_id,service_status  = subprocess.getstatusoutput(she)
            print(service_status)
            if service_status == 'true':
                print("组件构建启动，滚动升级组件中！！！")
                break
        elif i == 99:
            print("服务启动失败或等待超时！！！")
            exit(1)

if __name__ == '__main__':
    team_name = sys.argv[1]
    group_name = sys.argv[2]
    service_cname = sys.argv[3]
    curl_webhook_and_get_pod_status(team_name, group_name, service_cname)