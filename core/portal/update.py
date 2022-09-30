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
from turtle import clone

from core import GIT
from core.logger import logger

def update_tool():
  repo_url = "git@github.com:orzcrz/bstools.git"
  clone_dir = tempfile.mkdtemp()
  cmd = [GIT, 'clone', '--depth', '1', '--recurse-submodules', repo_url, clone_dir]
  logger.debug('Running: %r', cmd)
  subprocess.check_call(cmd)
    
  tool_root_dir = os.path.join(os.path.expanduser('~'), '.bstools')
  excludes = [
    '.git', '.lldbinit', '.zprofile', '.zshrc', '.gitmodules', 
    '__pycache__',
  ]
  for root, dirs, files in os.walk(clone_dir):
    if os.path.basename(root) in excludes:
      logger.debug('忽略 %s' % root)
      # 修改列表数据，不再向下遍历
      dirs[:] = []  
      continue
    
    for file in files:
      if file in excludes:
        logger.debug('忽略 %s' % file)
        continue
      
      suffix = root.split(clone_dir)[1]
      file_path = os.path.join(root, file)
      target_path = os.path.join(tool_root_dir + suffix, file)
      shutil.copyfile(file_path, target_path)
      logger.debug('替换 %s' % target_path)
