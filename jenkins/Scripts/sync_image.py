# -*- coding=utf-8 -*-

import json
import sys

env = sys.argv[1]
namespace = sys.argv[2]
image_name = sys.argv[3]
branch_name = sys.argv[4]
image_tag = branch_name.split('_')[-1]


env_dict = {
  "cn": "registry.cn-hangzhou.aliyuncs.com",
  "us": "registry.us-west-1.aliyuncs.com",
  "eu": "registry.eu-central-1.aliyuncs.com",
  "au": "registry.ap-southeast-2.aliyuncs.com",
  "in": "registry-vpc.ap-south-1.aliyuncs.com",
  "jp": "registry.cn-hangzhou.aliyuncs.com"
}

auth_dict = {
    "auth": {
            env_dict[env]: {
            "username": "dev@1023171698610100",
            "password": "q$d4qHLw3p"
        }
    },
    "images": {
        "{}/{}/{}:{}".format(env_dict['cn'],namespace,image_name,image_tag): "{}/{}/{}:{}".format(env_dict[env],namespace,image_name,image_tag)
    }
}

with open('auth.json', 'w', encoding='utf-8') as json_file:
    json.dump(auth_dict, json_file, indent=4)
