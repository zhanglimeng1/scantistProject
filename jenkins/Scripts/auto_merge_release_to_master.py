# coding:utf-8
import gitlab
import pymysql
import sys
import subprocess

curr_release = sys.argv[1]
groupname = sys.argv[2]
projectname = sys.argv[3]

url = 'http://git.vnnox.net/'
token = 'TrZf2mcP2uVGUWmDWy3Y'
gl = gitlab.Gitlab(url, token)

def get_project_gitlab_id(groupname,projectname):
    '''
     从gitproject表获取给定modulename的gitlab仓库id
    :param projectname: 项目名称
    :param groupname: 项目所属组名称
    :return: 项目gitlab仓库id
    '''
    try:
        db = pymysql.connect(host='172.16.82.13',user='query',password='Query@123',database='gitlab_measure',port=3306)
        try:
            cursor = db.cursor()
            cursor.execute("select projectid from projects where groupname='%s' and projectname = '%s'" % (groupname, projectname))
            data = cursor.fetchall()
            id = data[0][0]
            return id
        except Exception as e:
            print(e)
            exit(1)
        finally:
            cursor.close()
            db.close()

    except Exception as e:
        print(e)
        exit(1)
def auto_merge(id):
    '''
    已投产的release合并master
    :param id: 仓库id
    :return:
    '''
    project = gl.projects.get(id)
    title = 'Merge branch' + ' ' + curr_release + ' ' + 'into master'
    try:

        mr = project.mergerequests.create({'source_branch': curr_release,'target_branch': 'master','title': title})
        mr.merge()
        print(groupname + ' ' + projectname + ' Merge branch ' + curr_release + ' to master success!')
    except gitlab.exceptions.GitlabMRClosedError: #gitlab.exceptions.GitlabMRClosedError: 405: 405 Method Not Allowed
        print('release已合并过master，跳过')
        exit(0)
    except gitlab.exceptions.GitlabCreateError:#gitlab.exceptions.GitlabCreateError: 409: ['Another open merge request already exists for this source branch: !12']
        print('Another open merge request already exists for this source branch,跳过')
        exit(0)
    except Exception as e:
        print(groupname + ' ' + projectname + ' Merge branch ' + curr_release + ' to master failure!' + str(e))
        exit(1)
def git_diff(id):
    '''
    :param id: 仓库id
    :return:
    '''
    project = gl.projects.get(id)
    res = project.repository_compare('master',curr_release)
    if len(res['diffs']) > 0:
        auto_merge(id)
    else:
        print(curr_release+'分支没有比master分支更新的差异文件，所以无需合并！')

if __name__ == '__main__':
        print('当前窗口:' + curr_release )
        print('合并系统信息：' + groupname +'  ' + projectname + '  ' + curr_release)
        id = get_project_gitlab_id(groupname, projectname)
        git_diff(id)