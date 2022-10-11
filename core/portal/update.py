#!/usr/bin/env python
# -*- encoding: utf-8 -*-

"""
Created by crzorz on 2022/09/30
Copyright © 2022 BaldStudio. All rights reserved.
"""

import os
import shutil
import tempfile
import subprocess

from urllib import request
from distutils.version import StrictVersion

from core import GIT, VERSION
from core.logger import logger

def run_command(cmd):
  logger.debug('Running: %r', cmd)
  subprocess.check_call(cmd)
  

def is_need_udpate():
  logger.info('尝试获取最新版本...')
  remote_version_file = request.urlopen('https://raw.githubusercontent.com/orzcrz/bstools/master/version')
  remote_version = remote_version_file.read().decode('utf8')
  return StrictVersion(remote_version) > StrictVersion(VERSION)

def update_tool():
  if not is_need_udpate():
    logger.info('已经是最新版本了!')
    return
  
  logger.info('开始更新 ✊✊✊')
  
  repo_url = "git@github.com:orzcrz/bstools.git"
  clone_dir = tempfile.mkdtemp()
  clone_cmd = [ GIT, 'clone', '--depth', '1', '--recurse-submodules', 
               repo_url, clone_dir ]
  run_command(clone_cmd)
    
  tool_root_dir = os.path.join(os.path.expanduser('~'), '.bstools')
  excludes = [
    '.git', '.gitmodules', '.gitignore', '.gitignore_global', '.github',
    '.lldbinit', '.zprofile', '.zshrc', '.vscode', '__pycache__',
  ]
  
  for root, dirs, files in os.walk(clone_dir):
    if os.path.basename(root) in excludes:
      logger.debug('忽略 %s' % root)
      # 修改列表数据，不再向下遍历
      dirs[:] = []  
      continue
    
    for file in files:
      if file in excludes:
        logger.debug('忽略 %s' % os.path.join(root, file))
        continue
      
      suffix = root.split(clone_dir)[1]
      file_path = os.path.join(root, file)
      target_path = os.path.join(tool_root_dir + suffix, file)
      shutil.copyfile(file_path, target_path)
      logger.debug('替换 %s' % target_path)
      
  logger.info('更新完成 👏👏👏')